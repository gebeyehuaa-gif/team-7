-- Course Portal Database
CREATE DATABASE CoursePortal;
USE CoursePortal;
-- Departments
-- Stores academic departments
CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);
-- Roles
-- Stores user roles such as Student
-- Instructor and Administrator
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);
-- Users
-- Stores login and account information
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,

    FOREIGN KEY (role_id)
        REFERENCES Roles(role_id)
);
-- Students
-- Stores student specific information
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    major VARCHAR(100),
    class_level VARCHAR(20),

    FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
);
-- Instructors
-- Stores instructor specific information
CREATE TABLE Instructors (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    department_id INT NOT NULL,

    FOREIGN KEY (user_id)
        REFERENCES Users(user_id),

    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
);
-- Courses
-- Stores course information
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    credits TINYINT NOT NULL,

    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
);
-- Course sections
-- Stores individual sections of courses
CREATE TABLE Course_Sections (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    semester ENUM('Spring','Summer','Fall') NOT NULL,
    year INT NOT NULL,
    modality ENUM('In Person','Online','Hybrid') NOT NULL,
    capacity INT NOT NULL,
    room VARCHAR(50),
    meeting_days VARCHAR(20),
    start_time TIME,
    end_time TIME,

    FOREIGN KEY (course_id)
        REFERENCES Courses(course_id),

    FOREIGN KEY (instructor_id)
        REFERENCES Instructors(instructor_id)
);
-- Registrations
-- Stores student enrollmenst
CREATE TABLE Registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    registration_date DATE,
    status ENUM('Registered','Dropped','Waitlisted') NOT NULL,

    FOREIGN KEY (student_id)
        REFERENCES Students(student_id),

    FOREIGN KEY (section_id)
        REFERENCES Course_Sections(section_id),

    UNIQUE (student_id, section_id)
);
-- Prerequisites
-- Stores prerequisite relationships
CREATE TABLE Prerequisites (
    prerequisite_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    required_course_id INT NOT NULL,

    FOREIGN KEY (course_id)
        REFERENCES Courses(course_id),

    FOREIGN KEY (required_course_id)
        REFERENCES Courses(course_id)
);

-- Load Test Data
-- Adds realistic sample data for the course portal database.
START TRANSACTION;

-- Departments
INSERT INTO Departments (department_id, department_name)
VALUES
    (1, 'Information Systems'),
    (2, 'Marketing');

-- Roles
INSERT INTO Roles (role_id, role_name)
VALUES
    (1, 'Student'),
    (2, 'Instructor'),
    (3, 'Administrator');

-- Users
INSERT INTO Users (user_id, role_id, first_name, last_name, email, password_hash)
VALUES
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
    (15, 2, 'Victor', 'Santos', 'vsantos@courseportal.edu', 'hashed_password_015');

-- Students
INSERT INTO Students (student_id, user_id, major, class_level)
VALUES
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

-- Instructors
INSERT INTO Instructors (instructor_id, user_id, department_id)
VALUES
    (1, 11, 1),
    (2, 12, 1),
    (3, 13, 1),
    (4, 14, 2),
    (5, 15, 2);

-- Courses
INSERT INTO Courses (course_id, department_id, course_code, course_name, description, credits)
VALUES
    (1, 1, 'INFO 465', 'Database Design and Implementation', 'Covers relational database design, SQL, normalization, and implementation.', 3),
    (2, 1, 'INFO 350', 'Business Systems Analysis', 'Introduces systems analysis, requirements gathering, and process modeling.', 3),
    (3, 1, 'INFO 320', 'Cybersecurity Fundamentals', 'Explores basic cybersecurity concepts, risks, and security controls.', 3),
    (4, 2, 'MKTG 302', 'Consumer Behavior', 'Studies how consumers make purchasing decisions and respond to marketing strategies.', 3),
    (5, 2, 'MKTG 410', 'Digital Marketing Strategy', 'Focuses on digital campaigns, analytics, content strategy, and online branding.', 3);

-- Course Sections
INSERT INTO Course_Sections (
    section_id,
    course_id,
    instructor_id,
    semester,
    year,
    modality,
    capacity,
    room,
    meeting_days,
    start_time,
    end_time
)
VALUES
    (1, 1, 1, 'Fall', 2026, 'In Person', 30, 'BIS 201', 'MW', '09:30:00', '10:45:00'),
    (2, 2, 2, 'Fall', 2026, 'Hybrid', 25, 'BIS 118', 'TR', '11:00:00', '12:15:00'),
    (3, 3, 3, 'Fall', 2026, 'Online', 40, 'Online', NULL, NULL, NULL),
    (4, 4, 4, 'Fall', 2026, 'In Person', 35, 'BUS 210', 'MW', '13:00:00', '14:15:00'),
    (5, 5, 5, 'Fall', 2026, 'Hybrid', 28, 'BUS 145', 'TR', '14:30:00', '15:45:00');

-- Registrations
-- Student 1 is registered for two sections.
-- At least five other students are registered for one section.
INSERT INTO Registrations (registration_id, student_id, section_id, registration_date, status)
VALUES
    (1, 1, 1, '2026-08-20', 'Registered'),
    (2, 1, 4, '2026-08-20', 'Registered'),
    (3, 2, 1, '2026-08-21', 'Registered'),
    (4, 3, 2, '2026-08-21', 'Registered'),
    (5, 4, 4, '2026-08-22', 'Registered'),
    (6, 5, 3, '2026-08-22', 'Registered'),
    (7, 6, 5, '2026-08-23', 'Registered'),
    (8, 7, 2, '2026-08-23', 'Registered'),
    (9, 8, 5, '2026-08-24', 'Registered'),
    (10, 9, 3, '2026-08-24', 'Registered');

-- Prerequisites
INSERT INTO Prerequisites (prerequisite_id, course_id, required_course_id)
VALUES
    (1, 1, 2),
    (2, 3, 2),
    (3, 5, 4);

COMMIT;
