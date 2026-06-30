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