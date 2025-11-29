# Club Event Management – Phase 3 Demo

COMP 267 – Database Design
Team: SQL Squad

This project is a working demo for our ClubEventManagement database.
It includes:

A Node.js + Express web server

EJS front-end pages

MySQL database backend

Login functionality

Member activity dashboard

Event creation

No-Show analytics report

**Before starting, you must have MySQL installed on your computer.**

# 1. Setup Instructions

1.1 Unzip the project

Extract the provided project folder, then open a terminal inside it:

cd club-event-demo

# 2.Install Dependencies

Install all required Node packages using:

npm install


This installs:

express

ejs

mysql2

express-session

dotenv

# 3. Configure Your Database Connection**

In the project folder, create a .env file:
 
**Mac/Linux:** 
touch .env

**Windows PowerShell:**
ni .env -ItemType File


Inside .env, add your own MySQL username & password:

DB_HOST=localhost

DB_USER=your_mysql_username

DB_PASSWORD=your_mysql_password

DB_NAME=ClubEventManagement


**Do NOT use someone else's password.**

Each teammate enters their own MySQL credentials here.

# 4. Create the Database

If you do not already have the database created, run:

**Option A - Command Line**

mysql -u your_mysql_username -p


Then inside MySQL:

CREATE DATABASE ClubEventManagement;
USE ClubEventManagement;
SOURCE path/to/ClubEventManagement.sql;


(Use the full file path on Windows.)

**Option B - MySQL Workbench**

Open MySQL Workbench

Connect to your server

Create schema: ClubEventManagement

Open ClubEventManagement.sql

Select ClubEventManagement as default schema

Run the script (lightning bolt)

# 5. (Optional) Create a Separate MySQL Account for This Project

Instead of using root, you can create a project-specific user:

Inside MySQL:

CREATE USER 'club_user'@'localhost' IDENTIFIED BY 'club_pass_123';
GRANT ALL PRIVILEGES ON ClubEventManagement.* TO 'club_user'@'localhost';
FLUSH PRIVILEGES;


Then update .env:

DB_USER=club_user
DB_PASSWORD=club_pass_123

# 6. Run the Demo Web Server

From the project folder:

npm start


Or:

node server.js


You should see:

Server running at http://localhost:3000

# 7. Notes

.env is not included in the submission for security reasons.

Each teammate must create their own .env using their own MySQL credentials.

The demo uses EJS templates and matches the design documented in Phase 2.

Only the backend prototype is required — this is not a full production app.

# 8. What is included in the demo 

Login page:
Enter any member email from your database (from the table vw_club_roster)

# Notes

If you want to delete the temp SQL user after the demo is done, type into the SQL terminal:

DROP USER 'club_user'@'localhost';
