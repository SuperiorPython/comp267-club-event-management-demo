// server.js
const express = require('express');
const path = require('path');
const session = require('express-session');
const pool = require('./db');

const app = express();
const PORT = 3000;

// middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// session middleware
app.use(session({
  secret: 'club-event-secret',
  resave: false,
  saveUninitialized: true
}));

// view engine setup
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));


// ============================
// DASHBOARD (HOME PAGE)
// ============================
app.get('/', async (req, res) => {
  try {
    // upcoming events
    const [events] = await pool.query(
      `SELECT e.event_id, e.event_name, e.event_date, c.club_name, 
              e.location, e.capacity
       FROM event e
       JOIN club c ON e.club_id = c.club_id
       WHERE e.event_date > NOW()
       ORDER BY e.event_date
       LIMIT 10`
    );

    // campus stats via view
    let campusStats = [];
    try {
      const [rows] = await pool.query(`SELECT * FROM vw_campus_stats`);
      campusStats = rows;
    } catch (e) {
      campusStats = [];
    }

    res.render('index', {
      events,
      campusStats,
      user: req.session.user || null
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading dashboard');
  }
});


// ============================
// CLUBS PAGE
// ============================
app.get('/clubs', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT 
         c.club_name,
         c.category,
         c.meeting_schedule,
         COUNT(ms.member_id) AS active_members
       FROM club c
       LEFT JOIN membership ms
         ON c.club_id = ms.club_id
        AND ms.membership_status = 'Active'
       WHERE c.club_status = 'Active'
       GROUP BY c.club_id
       ORDER BY active_members DESC, c.club_name`
    );

    res.render('clubs', {
      clubs: rows,
      user: req.session.user || null
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading clubs');
  }
});


// ============================
// MEMBER ACTIVITY PAGE (REAL LOGIN)
// ============================
app.get('/member', async (req, res) => {
  if (!req.session.user) {
    return res.redirect('/login');
  }

  const memberId = req.session.user.member_id;

  try {
    const [rows] = await pool.query(
      `SELECT * FROM vw_member_activity WHERE member_id = ?`,
      [memberId]
    );

    const stats = rows[0] || null;

    res.render('member', {
      user: req.session.user,
      stats
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading member account');
  }
});


// ============================
// EVENTS LIST + CREATE EVENT
// ============================
app.get('/events', async (req, res) => {
  try {
    const [events] = await pool.query(
      `SELECT e.event_id, e.event_name, e.event_date, c.club_name, 
              e.location, e.capacity, e.event_status
       FROM event e
       JOIN club c ON e.club_id = c.club_id
       ORDER BY e.event_date`
    );

    const [clubs] = await pool.query(
      `SELECT club_id, club_name FROM club ORDER BY club_name`
    );

    res.render('events', {
      events,
      clubs,
      message: null,
      user: req.session.user || null
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading events');
  }
});


// CREATE EVENT ENDPOINT
app.post('/events/create', async (req, res) => {
  const { club_id, event_name, description, event_date, location, capacity, event_type } = req.body;

  try {
    await pool.query(
      `INSERT INTO event 
        (club_id, event_name, description, event_date, location, capacity, event_type)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        club_id, event_name, description || null,
        event_date, location || null,
        capacity || null, event_type || null
      ]
    );

    // Reload event list after creation
    const [events] = await pool.query(
      `SELECT e.event_id, e.event_name, e.event_date, c.club_name, 
              e.location, e.capacity, e.event_status
       FROM event e
       JOIN club c ON e.club_id = c.club_id
       ORDER BY e.event_date`
    );

    const [clubs] = await pool.query(
      `SELECT club_id, club_name FROM club ORDER BY club_name`
    );

    res.render('events', {
      events,
      clubs,
      message: 'Event created successfully!',
      user: req.session.user || null
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Error creating event');
  }
});


// ============================
// LOGIN
// ============================
app.get('/login', (req, res) => {
  res.render('login', { error: null, user: null });
});

app.post('/login', async (req, res) => {
  const { email } = req.body;

  try {
    const [rows] = await pool.query(
      `SELECT 
         m.member_id,
         m.first_name,
         m.last_name,
         m.email,
         ur.system_role
       FROM member m
       LEFT JOIN user_roles ur ON m.member_id = ur.member_id
       WHERE m.email = ?`,
      [email]
    );

    if (rows.length === 0) {
      return res.render('login', {
        error: 'No member found with that email.',
        user: null
      });
    }

    const u = rows[0];

    // Save user in session
    req.session.user = {
      member_id: u.member_id,
      name: `${u.first_name} ${u.last_name}`,
      email: u.email,
      role: u.system_role || 'EndUser'
    };

    return res.redirect('/member');

  } catch (err) {
    console.error(err);
    res.render('login', { error: 'Server error during login.', user: null });
  }
});


// ============================
// NO-SHOW REPORT
// ============================
app.get('/no-show', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT 
         e.event_name,
         e.event_date,
         c.club_name,
         CONCAT(m.first_name, ' ', m.last_name) AS member_name,
         m.email
       FROM event e
       JOIN club c ON e.club_id = c.club_id
       JOIN rsvp r ON e.event_id = r.event_id
       JOIN member m ON r.member_id = m.member_id
       LEFT JOIN attendance a
              ON a.event_id = e.event_id
             AND a.member_id = m.member_id
       WHERE e.event_date < NOW()
         AND r.rsvp_status = 'Confirmed'
         AND a.attendance_id IS NULL
       ORDER BY e.event_date, member_name`
    );

    res.render('no_show', {
      results: rows,
      user: req.session.user || null
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Error loading no-show report');
  }
});


// ============================
// START SERVER
// ============================
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
