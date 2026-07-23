DROP DATABASE IF EXISTS CoursePortal;
CREATE DATABASE CoursePortal;
USE CoursePortal;

-- Departments
CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Roles
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Users
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- Students
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    major VARCHAR(100),
    class_level VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Instructors
CREATE TABLE Instructors (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    department_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Courses
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    credits TINYINT NOT NULL,
    capacity INT DEFAULT 30,
    enrolled_count INT DEFAULT 0,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Course Sections
CREATE TABLE Course_Sections (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    section_number VARCHAR(10) DEFAULT '001',
    semester ENUM('Spring','Summer','Fall') NOT NULL,
    year INT NOT NULL,
    modality ENUM('In Person','Online','Hybrid') NOT NULL,
    capacity INT NOT NULL,
    building VARCHAR(50),
    room_number VARCHAR(20),
    days_of_week VARCHAR(20),
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

-- Registrations
CREATE TABLE Registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    registration_date DATE,
    status ENUM('Registered','Dropped','Waitlisted') NOT NULL,
    grade VARCHAR(5) DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (section_id) REFERENCES Course_Sections(section_id),
    UNIQUE (student_id, section_id)
);

-- Prerequisites
CREATE TABLE Prerequisites (
    prerequisite_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    required_course_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (required_course_id) REFERENCES Courses(course_id)
);

-- Administrators
CREATE TABLE Administrators (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    department_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Advisor Overrides
CREATE TABLE Advisor_Overrides (
    override_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    admin_user_id INT NOT NULL,
    override_code VARCHAR(50) NOT NULL,
    reason TEXT,
    granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (section_id) REFERENCES Course_Sections(section_id),
    FOREIGN KEY (admin_user_id) REFERENCES Users(user_id)
);

-- Override Requests
CREATE TABLE Override_Requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    request_type VARCHAR(100) NOT NULL,
    justification TEXT,
    status ENUM('Pending', 'Approved', 'Denied') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- ====================================================
-- LOAD SEED DATA
-- ====================================================
START TRANSACTION;

INSERT INTO Departments (department_id, department_name) VALUES
    (1, 'Information Systems'),
    (2, 'Marketing');

INSERT INTO Roles (role_id, role_name) VALUES
    (1, 'Student'),
    (2, 'Instructor'),
    (3, 'Administrator');

INSERT INTO Users (user_id, role_id, first_name, last_name, email, password_hash) VALUES
    (1, 1, 'Jordan', 'Ellis', 'jellis@student.courseportal.edu', 'hashed_password_001'),
    (2, 1, 'Maya', 'Patel', 'mpatel@student.courseportal.edu', 'hashed_password_002'),
    (3, 1, 'Ethan', 'Coleman', 'ecoleman@student.courseportal.edu', 'hashed_password_003'),
    (4, 1, 'Sofia', 'Ramirez', 'sramirez@student.courseportal.edu', 'hashed_password_004'),
    (5, 1, 'Noah', 'Kim', 'nkim@student.courseportal.edu', 'hashed_password_005'),
    (6, 1, 'Olivia', 'Grant', 'ogrant@student.courseportal.edu', 'hashed_password_006'),
    (7, 1, 'Liam', 'Harris', 'lharris@student.courseportal.edu', 'hashed_password_007'),
    (8, 1, 'Ava', 'Thompson', 'athompson@student.courseportal.edu', 'hashed_password_008'),
    (9, 1, 'Caleb', 'Morgan', 'cmorgan@student.courseportal.edu', 'hashed_password_009'),
    (10, 1, 'Grace', 'Walker', 'gwalker@student.courseportal.edu', 'hashed_password_010'),
    (11, 2, 'Alicia', 'Nguyen', 'anguyen@courseportal.edu', 'hashed_password_011'),
    (12, 2, 'Marcus', 'Reed', 'mreed@courseportal.edu', 'hashed_password_012'),
    (13, 2, 'Priya', 'Shah', 'pshah@courseportal.edu', 'hashed_password_013'),
    (14, 2, 'Danielle', 'Brooks', 'dbrooks@courseportal.edu', 'hashed_password_014'),
    (15, 2, 'Victor', 'Santos', 'vsantos@courseportal.edu', 'hashed_password_015'),
    (16, 3, 'Sarah', 'Conner', 'sconner@courseportal.edu', 'hashed_password_016');

INSERT INTO Students (student_id, user_id, major, class_level) VALUES
    (1, 1, 'Information Systems', 'Senior'),
    (2, 2, 'Information Systems', 'Junior'),
    (3, 3, 'Information Systems', 'Senior'),
    (4, 4, 'Marketing', 'Junior'),
    (5, 5, 'Information Systems', 'Sophomore'),
    (6, 6, 'Marketing', 'Senior'),
    (7, 7, 'Information Systems', 'Junior'),
    (8, 8, 'Marketing', 'Sophomore'),
    (9, 9, 'Information Systems', 'Senior'),
    (10, 10, 'Marketing', 'Junior');

-- Updated instructor_id values to match their respective user_id
INSERT INTO Instructors (instructor_id, user_id, department_id) VALUES
    (11, 11, 1),
    (12, 12, 1),
    (13, 13, 1),
    (14, 14, 2),
    (15, 15, 2);

INSERT INTO Administrators (admin_id, user_id, department_id) VALUES
    (1, 16, 1);

INSERT INTO Courses (course_id, department_id, course_code, course_name, description, credits, capacity, enrolled_count) VALUES
    (1, 1, 'INFO 465', 'Database Design and Implementation', 'Covers relational database design, SQL, normalization, and implementation.', 3, 30, 2),
    (2, 1, 'INFO 350', 'Business Systems Analysis', 'Introduces systems analysis, requirements gathering, and process modeling.', 3, 25, 2),
    (3, 1, 'INFO 320', 'Cybersecurity Fundamentals', 'Explores basic cybersecurity concepts, risks, and security controls.', 3, 40, 2),
    (4, 2, 'MKTG 302', 'Consumer Behavior', 'Studies how consumers make purchasing decisions and respond to marketing strategies.', 3, 35, 2),
    (5, 2, 'MKTG 410', 'Digital Marketing Strategy', 'Focuses on digital campaigns, analytics, content strategy, and online branding.', 3, 28, 2);

-- Updated instructor_id references to match new Instructors IDs (11-15)
INSERT INTO Course_Sections (section_id, course_id, instructor_id, section_number, semester, year, modality, capacity, building, room_number, days_of_week, start_time, end_time) VALUES
    (1, 1, 11, '001', 'Fall', 2026, 'In Person', 30, 'BIS', '201', 'MW', '09:30:00', '10:45:00'),
    (2, 2, 12, '001', 'Fall', 2026, 'Hybrid', 25, 'BIS', '118', 'TR', '11:00:00', '12:15:00'),
    (3, 3, 13, '001', 'Fall', 2026, 'Online', 40, 'Online', 'N/A', 'Online', NULL, NULL),
    (4, 4, 14, '001', 'Fall', 2026, 'In Person', 35, 'BUS', '210', 'MW', '13:00:00', '14:15:00'),
    (5, 5, 15, '001', 'Fall', 2026, 'Hybrid', 28, 'BUS', '145', 'TR', '14:30:00', '15:45:00');

INSERT INTO Registrations (registration_id, student_id, section_id, registration_date, status, grade) VALUES
    (1, 1, 1, '2026-08-20', 'Registered', 'A'),
    (2, 1, 4, '2026-08-20', 'Registered', 'B+'),
    (3, 2, 1, '2026-08-21', 'Registered', NULL),
    (4, 3, 2, '2026-08-21', 'Registered', NULL),
    (5, 4, 4, '2026-08-22', 'Registered', NULL),
    (6, 5, 3, '2026-08-22', 'Registered', NULL),
    (7, 6, 5, '2026-08-23', 'Registered', NULL),
    (8, 7, 2, '2026-08-23', 'Registered', NULL),
    (9, 8, 5, '2026-08-24', 'Registered', NULL),
    (10, 9, 3, '2026-08-24', 'Registered', NULL);

INSERT INTO Prerequisites (prerequisite_id, course_id, required_course_id) VALUES
    (1, 1, 2),
    (2, 3, 2),
    (3, 5, 4);

INSERT INTO Advisor_Overrides (override_id, student_id, section_id, admin_user_id, override_code, reason) VALUES
    (1, 1, 1, 16, 'OVERRIDE2026', 'Senior track graduation requirement bypass.');

INSERT INTO Override_Requests (request_id, student_id, course_id, request_type, justification, status) VALUES
    (1, 2, 1, 'Capacity Bypass', 'Needs course to fulfill senior graduation requirement.', 'Pending'),
    (2, 5, 3, 'Prerequisite Override', 'Completed equivalent transfer coursework at community college.', 'Pending'),
    (3, 4, 5, 'Capacity Bypass', 'Schedule conflict with required core courses.', 'Approved');

COMMIT;