/* =====================================================================
   Fall 2025 COMP 267 – Database Design Team Project
   Phase 2 – Database System Development
   System: ClubEventManagement
   DBMS: MySQL 8.x
   ===================================================================== */

-- Drop and create database
DROP DATABASE IF EXISTS ClubEventManagement;
CREATE DATABASE ClubEventManagement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ClubEventManagement;

-- =====================================================================
-- TABLE DEFINITIONS
-- =====================================================================

-- Members table
CREATE TABLE member (
    member_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id_number VARCHAR(60) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(320) UNIQUE NOT NULL,
    phone VARCHAR(20),
    major VARCHAR(60),
    year VARCHAR(60),
    location VARCHAR(150),
    account_status VARCHAR(30) DEFAULT 'Active',
    role VARCHAR(60) DEFAULT 'Student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_last_name (last_name)
) ENGINE=InnoDB;

-- Clubs table
CREATE TABLE club (
    club_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    club_name VARCHAR(120) UNIQUE NOT NULL,
    category VARCHAR(60),
    description TEXT,
    advisor_email VARCHAR(320),
    meeting_schedule VARCHAR(200),
    club_status VARCHAR(30) DEFAULT 'Active',
    founded_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_club_name (club_name),
    INDEX idx_category (category)
) ENGINE=InnoDB;

-- Membership table
CREATE TABLE membership (
    membership_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    club_id BIGINT NOT NULL,
    role VARCHAR(60) DEFAULT 'Member',
    join_date DATE NOT NULL,
    membership_status VARCHAR(30) DEFAULT 'Active',
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (club_id) REFERENCES club(club_id) ON DELETE CASCADE,
    UNIQUE KEY unique_membership (member_id, club_id),
    INDEX idx_member (member_id),
    INDEX idx_club (club_id)
) ENGINE=InnoDB;

-- Events table
CREATE TABLE event (
    event_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    club_id BIGINT NOT NULL,
    event_name VARCHAR(150) NOT NULL,
    description TEXT,
    event_date TIMESTAMP NOT NULL,
    location VARCHAR(150),
    capacity INT,
    event_type VARCHAR(60),
    event_status VARCHAR(30) DEFAULT 'Scheduled',
    contact_person_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (club_id) REFERENCES club(club_id) ON DELETE CASCADE,
    FOREIGN KEY (contact_person_id) REFERENCES member(member_id) ON DELETE SET NULL,
    INDEX idx_event_date (event_date),
    INDEX idx_club (club_id)
) ENGINE=InnoDB;

-- Snapshot table for attendance analytics (supports /admin/snapshots/events)
CREATE TABLE event_attendance_snapshot (
    snapshot_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT NOT NULL,
    snapshot_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_rsvps INT NOT NULL,
    total_attended INT NOT NULL,
    attendance_rate DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    INDEX idx_snapshot_event (event_id),
    INDEX idx_snapshot_date (snapshot_date)
) ENGINE=InnoDB;

-- RSVP table
CREATE TABLE rsvp (
    rsvp_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    rsvp_status VARCHAR(30) DEFAULT 'Confirmed',
    rsvp_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    UNIQUE KEY unique_rsvp (member_id, event_id),
    INDEX idx_event (event_id)
) ENGINE=InnoDB;

-- Attendance table
CREATE TABLE attendance (
    attendance_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    attendance_status VARCHAR(30) DEFAULT 'Present',
    check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checked_in_by BIGINT,
    notes TEXT,
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (checked_in_by) REFERENCES member(member_id) ON DELETE SET NULL,
    UNIQUE KEY unique_attendance (member_id, event_id),
    INDEX idx_event (event_id)
) ENGINE=InnoDB;

-- User roles table
CREATE TABLE user_roles (
    role_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    system_role VARCHAR(30) NOT NULL,
    granted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (member_id) REFERENCES member(member_id) ON DELETE CASCADE,
    UNIQUE KEY unique_role (member_id, system_role)
) ENGINE=InnoDB;

-- =====================================================================
-- SAMPLE DATA INSERTS
-- =====================================================================

-- Insert members
INSERT INTO member (member_id_number, first_name, last_name, email, phone, major, year, location, role) VALUES
('STU001', 'Emma', 'Johnson', 'emma.johnson@university.edu', '336-555-0101', 'Computer Science', 'Junior', 'Smith Hall 301', 'Student'),
('STU002', 'Michael', 'Williams', 'michael.williams@university.edu', '336-555-0102', 'Business', 'Senior', 'Johnson Hall 205', 'Student'),
('STU003', 'Sarah', 'Brown', 'sarah.brown@university.edu', '336-555-0103', 'Biology', 'Sophomore', 'Davis Hall 102', 'Student'),
('STU004', 'James', 'Davis', 'james.davis@university.edu', '336-555-0104', 'Engineering', 'Senior', 'Miller Hall 401', 'Officer'),
('STU005', 'Emily', 'Martinez', 'emily.martinez@university.edu', '336-555-0105', 'Psychology', 'Junior', 'Wilson Hall 203', 'Officer'),
('STU006', 'David', 'Garcia', 'david.garcia@university.edu', '336-555-0106', 'Mathematics', 'Freshman', 'Taylor Hall 105', 'Student'),
('STU007', 'Jessica', 'Rodriguez', 'jessica.rodriguez@university.edu', '336-555-0107', 'English', 'Senior', 'Anderson Hall 302', 'Officer'),
('STU008', 'Daniel', 'Wilson', 'daniel.wilson@university.edu', '336-555-0108', 'Chemistry', 'Sophomore', 'Thomas Hall 201', 'Student'),
('STU009', 'Ashley', 'Moore', 'ashley.moore@university.edu', '336-555-0109', 'Art', 'Junior', 'Jackson Hall 104', 'Student'),
('STU010', 'Christopher', 'Taylor', 'christopher.taylor@university.edu', '336-555-0110', 'Political Science', 'Senior', 'White Hall 403', 'Officer'),
('ADM001', 'Robert', 'Anderson', 'robert.anderson@university.edu', '336-555-0201', 'Administration', 'Staff', 'Admin Building', 'Admin'),
('ADM002', 'Linda', 'Thomas', 'linda.thomas@university.edu', '336-555-0202', 'Administration', 'Staff', 'Admin Building', 'Admin');

-- Insert clubs
INSERT INTO club (club_name, category, description, advisor_email, meeting_schedule, founded_date) VALUES
('Computer Science Club', 'Academic', 'CS students collaborate on projects and tech talks', 'advisor.cs@university.edu', 'Wednesdays 6:00 PM', '2015-09-01'),
('Business Leaders Society', 'Academic', 'Developing future business leaders', 'advisor.business@university.edu', 'Thursdays 5:30 PM', '2012-08-15'),
('Environmental Action', 'Service', 'Campus sustainability initiatives', 'advisor.env@university.edu', 'Tuesdays 4:00 PM', '2010-01-20'),
('Theater Arts Guild', 'Arts', 'Theatrical performances and workshops', 'advisor.theater@university.edu', 'Mondays 7:00 PM', '2008-09-10'),
('Robotics Team', 'Academic', 'Design and compete with robots', 'advisor.robotics@university.edu', 'Fridays 3:00 PM', '2016-01-15'),
('Cultural Exchange', 'Social', 'Celebrating diversity through events', 'advisor.culture@university.edu', 'Sundays 3:00 PM', '2014-03-01'),
('Volunteer Corps', 'Service', 'Community volunteer opportunities', 'advisor.volunteer@university.edu', 'Saturdays 10:00 AM', '2011-02-14'),
('Photography Club', 'Arts', 'Photography workshops and exhibitions', 'advisor.photo@university.edu', 'Thursdays 6:30 PM', '2013-09-05'),
('Debate Society', 'Academic', 'Competitive debate and public speaking', 'advisor.debate@university.edu', 'Wednesdays 5:00 PM', '2009-10-01'),
('Fitness Club', 'Sports', 'Health and wellness activities', 'advisor.fitness@university.edu', 'Daily 6:00 AM', '2017-01-10');

-- Insert memberships
INSERT INTO membership (member_id, club_id, role, join_date) VALUES
(1, 1, 'President', '2023-09-01'),
(4, 1, 'Vice President', '2023-09-01'),
(6, 1, 'Member', '2024-01-15'),
(2, 2, 'President', '2022-09-01'),
(5, 2, 'Treasurer', '2023-09-01'),
(3, 3, 'Officer', '2023-09-01'),
(9, 3, 'Member', '2024-01-15'),
(7, 4, 'President', '2022-09-01'),
(9, 4, 'Vice President', '2023-09-01'),
(4, 5, 'Officer', '2023-01-15'),
(6, 5, 'Member', '2023-09-01'),
(5, 6, 'Secretary', '2023-09-01'),
(10, 7, 'President', '2022-09-01'),
(3, 7, 'Member', '2023-09-01'),
(9, 8, 'Officer', '2023-09-01'),
(1, 8, 'Member', '2024-01-15'),
(7, 9, 'Vice President', '2023-01-15'),
(2, 9, 'Member', '2023-09-01'),
(10, 10, 'Officer', '2023-09-01'),
(8, 10, 'Member', '2024-01-15');

-- Insert events
INSERT INTO event (club_id, event_name, description, event_date, location, capacity, event_type, contact_person_id) VALUES
(1, 'Web Development Workshop', 'Learn HTML, CSS, and JavaScript', '2024-10-15 18:00:00', 'Computer Lab A', 30, 'Workshop', 1),
(2, 'Networking Night', 'Meet alumni and build connections', '2024-10-20 19:00:00', 'Student Union', 50, 'Social', 2),
(3, 'Campus Cleanup', 'Campus-wide cleanup initiative', '2024-10-25 10:00:00', 'Main Quad', 100, 'Service', 3),
(4, 'Fall Play', 'Annual theater performance', '2024-11-01 19:30:00', 'University Theater', 200, 'Social', 7),
(1, 'Hackathon 2024', '24-hour coding competition', '2024-11-30 09:00:00', 'Innovation Center', 50, 'Competition', 1),
(2, 'Business Plan Competition', 'Pitch your startup idea', '2024-12-05 14:00:00', 'Business School', 40, 'Competition', 2),
(5, 'Robot Showcase', 'Demonstrate robot projects', '2024-12-10 15:00:00', 'Engineering Lab', 60, 'Workshop', 4),
(6, 'Food Festival', 'Celebrate cultures through food', '2024-12-15 12:00:00', 'Dining Plaza', 200, 'Social', 5),
(7, 'Holiday Toy Drive', 'Collect toys for children', '2024-12-18 10:00:00', 'Community Center', 50, 'Service', 10),
(8, 'Photo Exhibition', 'Student photography showcase', '2025-01-10 18:00:00', 'Art Gallery', 80, 'Social', 9);

-- Insert RSVPs
INSERT INTO rsvp (member_id, event_id, rsvp_status) VALUES
(1, 1, 'Confirmed'),
(4, 1, 'Confirmed'),
(6, 1, 'Confirmed'),
(2, 2, 'Confirmed'),
(5, 2, 'Confirmed'),
(3, 3, 'Confirmed'),
(9, 3, 'Confirmed'),
(7, 4, 'Confirmed'),
(9, 4, 'Confirmed'),
(1, 5, 'Confirmed'),
(4, 5, 'Confirmed'),
(6, 5, 'Confirmed'),
(2, 6, 'Confirmed'),
(4, 7, 'Confirmed'),
(6, 7, 'Confirmed');

-- Insert attendance
INSERT INTO attendance (member_id, event_id, attendance_status, checked_in_by) VALUES
(1, 1, 'Present', 4),
(4, 1, 'Present', 4),
(6, 1, 'Present', 4),
(2, 2, 'Present', 5),
(5, 2, 'Present', 5),
(3, 3, 'Present', 3),
(9, 3, 'Present', 3),
(7, 4, 'Present', 9),
(9, 4, 'Present', 9);

-- Insert user roles
INSERT INTO user_roles (member_id, system_role) VALUES
(11, 'Administrator'),
(12, 'Administrator'),
(1, 'Manager'),
(2, 'Manager'),
(4, 'Manager'),
(5, 'Manager'),
(7, 'Manager'),
(10, 'Manager'),
(3, 'EndUser'),
(6, 'EndUser'),
(8, 'EndUser'),
(9, 'EndUser');

-- =====================================================================
-- VIEWS (REPORTING & ANALYTICS)
-- =====================================================================

-- Club roster view
CREATE VIEW vw_club_roster AS
SELECT 
    c.club_id,
    c.club_name,
    c.category,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email,
    m.major,
    m.year,
    ms.role,
    ms.join_date
FROM club c
JOIN membership ms ON c.club_id = ms.club_id
JOIN member m ON ms.member_id = m.member_id
WHERE ms.membership_status = 'Active'
ORDER BY c.club_name, ms.role DESC, m.last_name;

-- Event attendance summary
CREATE VIEW vw_event_summary AS
SELECT 
    e.event_id,
    e.event_name,
    e.event_date,
    c.club_name,
    e.capacity,
    COUNT(DISTINCT r.member_id) AS total_rsvps,
    COUNT(DISTINCT a.member_id) AS total_attended,
    ROUND((COUNT(DISTINCT a.member_id) / NULLIF(COUNT(DISTINCT r.member_id), 0)) * 100, 2) AS attendance_rate
FROM event e
JOIN club c ON e.club_id = c.club_id
LEFT JOIN rsvp r ON e.event_id = r.event_id
LEFT JOIN attendance a ON e.event_id = a.event_id
GROUP BY e.event_id;

-- Member participation
CREATE VIEW vw_member_activity AS
SELECT 
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email,
    m.major,
    m.year,
    COUNT(DISTINCT ms.club_id) AS clubs_joined,
    COUNT(DISTINCT r.event_id) AS events_rsvped,
    COUNT(DISTINCT a.event_id) AS events_attended
FROM member m
LEFT JOIN membership ms ON m.member_id = ms.member_id AND ms.membership_status = 'Active'
LEFT JOIN rsvp r ON m.member_id = r.member_id
LEFT JOIN attendance a ON m.member_id = a.member_id
GROUP BY m.member_id;

-- Campus engagement by category
CREATE VIEW vw_campus_stats AS
SELECT 
    c.category,
    COUNT(DISTINCT c.club_id) AS total_clubs,
    COUNT(DISTINCT ms.member_id) AS total_members,
    COUNT(DISTINCT e.event_id) AS total_events
FROM club c
LEFT JOIN membership ms ON c.club_id = ms.club_id AND ms.membership_status = 'Active'
LEFT JOIN event e ON c.club_id = e.club_id
WHERE c.club_status = 'Active'
GROUP BY c.category;

-- =====================================================================
-- SAMPLE REPORT QUERIES (FROM TEAMMATE'S SCRIPT)
-- =====================================================================

-- View all active clubs with member counts
SELECT 
    c.club_name,
    c.category,
    c.meeting_schedule,
    COUNT(m.member_id) AS members
FROM club c
LEFT JOIN membership ms ON c.club_id = ms.club_id AND ms.membership_status = 'Active'
LEFT JOIN member m ON ms.member_id = m.member_id
WHERE c.club_status = 'Active'
GROUP BY c.club_id
ORDER BY members DESC;

-- Upcoming events
SELECT 
    e.event_name,
    c.club_name,
    e.event_date,
    e.location,
    e.capacity,
    COUNT(r.rsvp_id) AS rsvps,
    (e.capacity - COUNT(r.rsvp_id)) AS spots_left
FROM event e
JOIN club c ON e.club_id = c.club_id
LEFT JOIN rsvp r ON e.event_id = r.event_id AND r.rsvp_status = 'Confirmed'
WHERE e.event_date > NOW() AND e.event_status = 'Scheduled'
GROUP BY e.event_id
ORDER BY e.event_date;

-- =====================================================================
-- PHASE 2 – PART I: CRUD + TESTING + REPORT QUERIES (ADDED)
-- =====================================================================

-- Make sure we are in the correct database
USE ClubEventManagement;

---------------------------------------------------------------
-- D. CREATE / READ / UPDATE / DELETE EXAMPLES
---------------------------------------------------------------

-- D1. CREATE: add a new member and membership (basic end-user action)
INSERT INTO member (member_id_number, first_name, last_name, email, phone, major, year, location, role)
VALUES ('STU011', 'Noah', 'King', 'noah.king@university.edu', '336-555-0111',
        'Computer Science', 'Sophomore', 'Smith Hall 210', 'Student');

INSERT INTO membership (member_id, club_id, role, join_date, membership_status)
VALUES (LAST_INSERT_ID(), 1, 'Member', CURDATE(), 'Active');

-- D2. READ: view roster for a specific club (uses roster view)
SELECT *
FROM vw_club_roster
WHERE club_name = 'Computer Science Club';

-- D3. UPDATE: mark a few memberships as Inactive and set an end_date
-- (manager-level operation)
UPDATE membership
SET membership_status = 'Inactive',
    end_date = CURDATE()
WHERE membership_id IN (3, 7, 15);

-- Verify the update
SELECT membership_id, member_id, club_id, membership_status, end_date
FROM membership
WHERE membership_id IN (3, 7, 15);

-- D4. DELETE: remove a test RSVP record (specific primary key)
DELETE FROM rsvp
WHERE rsvp_id = 15;

-- Verify the delete
SELECT rsvp_id, member_id, event_id, rsvp_status
FROM rsvp
WHERE rsvp_id = 15;

---------------------------------------------------------------
-- E. TESTING THE DATABASE
---------------------------------------------------------------

-- Quick row-count sanity check across core tables
SELECT 'member'     AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'club',       COUNT(*) FROM club
UNION ALL
SELECT 'membership', COUNT(*) FROM membership
UNION ALL
SELECT 'event',      COUNT(*) FROM event
UNION ALL
SELECT 'rsvp',       COUNT(*) FROM rsvp
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance;

-- Show sample upcoming events (for testing SELECT / Read)
SELECT event_id, event_name, event_date, location, capacity
FROM event
WHERE event_date > NOW()
ORDER BY event_date
LIMIT 10;

---------------------------------------------------------------
-- F. REPORT GENERATION QUERIES (MAPPED TO PHASE 2 PROMPTS)
---------------------------------------------------------------

-- F1. "Currently available information":
--     Active clubs with their active member counts
SELECT 
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
ORDER BY active_members DESC, c.club_name;

-- F2. "Overdue or late information":
--     Members who RSVP'd but have NO recorded attendance
--     for past events (event date before NOW).
SELECT 
    e.event_name,
    e.event_date,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email
FROM event e
JOIN rsvp r       ON e.event_id = r.event_id
JOIN member m     ON r.member_id = m.member_id
LEFT JOIN attendance a
       ON a.event_id = e.event_id
      AND a.member_id = r.member_id
WHERE e.event_date < NOW()
  AND r.rsvp_status = 'Confirmed'
  AND a.attendance_id IS NULL
ORDER BY e.event_date, member_name;

-- F3. "Frequently used information / popularity":
--     Most popular events based on RSVP count
SELECT 
    e.event_name,
    c.club_name,
    e.event_date,
    COUNT(DISTINCT r.member_id) AS total_rsvps
FROM event e
JOIN club c ON e.club_id = c.club_id
LEFT JOIN rsvp r ON e.event_id = r.event_id
GROUP BY e.event_id, c.club_name
ORDER BY total_rsvps DESC, e.event_date;

-- F4. "Track participation / engagement":
--     Member-level engagement summary (builds on vw_member_activity)
SELECT *
FROM vw_member_activity
ORDER BY events_attended DESC, events_rsvped DESC;

-- F5. "Customer (member) insight into participation patterns":
--     Club category engagement across campus
SELECT *
FROM vw_campus_stats
ORDER BY total_members DESC, total_clubs DESC;

/* =====================================================================
   END OF ClubEventManagement Phase 2 SQL SCRIPT
   ===================================================================== */
