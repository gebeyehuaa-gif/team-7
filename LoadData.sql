-- Load Test Data
-- MySQL seed script for a course registration application.
-- Run this after your CREATE TABLE statements.

START TRANSACTION;

-- Departments: at least 2 departments
INSERT INTO Departments (department_id, department_name)
VALUES
  (1, 'Information Systems'),
  (2, 'Marketing');

-- Courses: at least 5 courses, each tied to a department
INSERT INTO Courses (course_id, department_id, course_code, course_title, credits)
VALUES
  (1, 1, 'INFO 465', 'Database Design and Implementation', 3),
  (2, 1, 'INFO 350', 'Business Systems Analysis', 3),
  (3, 1, 'INFO 320', 'Cybersecurity Fundamentals', 3),
  (4, 2, 'MKTG 302', 'Consumer Behavior', 3),
  (5, 2, 'MKTG 410', 'Digital Marketing Strategy', 3);

-- Instructors: at least 5 instructors
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email)
VALUES
  (1, 1, 'Alicia', 'Nguyen', 'anguyen@university.edu'),
  (2, 1, 'Marcus', 'Reed', 'mreed@university.edu'),
  (3, 1, 'Priya', 'Shah', 'pshah@university.edu'),
  (4, 2, 'Danielle', 'Brooks', 'dbrooks@university.edu'),
  (5, 2, 'Victor', 'Santos', 'vsantos@university.edu');

-- Students: at least 10 students
INSERT INTO Students (student_id, first_name, last_name, email, major_department_id)
VALUES
  (1, 'Jordan', 'Ellis', 'jellis@student.university.edu', 1),
  (2, 'Maya', 'Patel', 'mpatel@student.university.edu', 1),
  (3, 'Ethan', 'Coleman', 'ecoleman@student.university.edu', 1),
  (4, 'Sofia', 'Ramirez', 'sramirez@student.university.edu', 2),
  (5, 'Noah', 'Kim', 'nkim@student.university.edu', 1),
  (6, 'Olivia', 'Grant', 'ogrant@student.university.edu', 2),
  (7, 'Liam', 'Harris', 'lharris@student.university.edu', 1),
  (8, 'Ava', 'Thompson', 'athompson@student.university.edu', 2),
  (9, 'Caleb', 'Morgan', 'cmorgan@student.university.edu', 1),
  (10, 'Grace', 'Walker', 'gwalker@student.university.edu', 2);

-- Sessions: at least 5 sessions referencing valid Courses
-- Modalities and capacities vary across rows.
INSERT INTO Sessions (
  session_id,
  course_id,
  instructor_id,
  term,
  section_number,
  modality,
  max_capacity,
  meeting_days,
  start_time,
  end_time
)
VALUES
  (1, 1, 1, 'Fall 2026', '001', 'In Person', 30, 'MW', '09:30:00', '10:45:00'),
  (2, 2, 2, 'Fall 2026', '001', 'Hybrid', 25, 'TR', '11:00:00', '12:15:00'),
  (3, 3, 3, 'Fall 2026', '001', 'Online', 40, NULL, NULL, NULL),
  (4, 4, 4, 'Fall 2026', '001', 'In Person', 35, 'MW', '13:00:00', '14:15:00'),
  (5, 5, 5, 'Fall 2026', '001', 'Hybrid', 28, 'TR', '14:30:00', '15:45:00');

-- Enrollments:
-- Student 1 is enrolled in two sessions.
-- At least 5 other students are enrolled in one session.
INSERT INTO Enrollments (enrollment_id, student_id, session_id, enrollment_date, enrollment_status)
VALUES
  (1, 1, 1, '2026-08-20', 'Enrolled'),
  (2, 1, 4, '2026-08-20', 'Enrolled'),
  (3, 2, 1, '2026-08-21', 'Enrolled'),
  (4, 3, 2, '2026-08-21', 'Enrolled'),
  (5, 4, 4, '2026-08-22', 'Enrolled'),
  (6, 5, 3, '2026-08-22', 'Enrolled'),
  (7, 6, 5, '2026-08-23', 'Enrolled'),
  (8, 7, 2, '2026-08-23', 'Enrolled'),
  (9, 8, 5, '2026-08-24', 'Enrolled'),
  (10, 9, 3, '2026-08-24', 'Enrolled');

COMMIT;
