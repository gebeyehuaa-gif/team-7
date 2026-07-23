const express = require('express');
const path = require('path');
const fs = require('fs');
const mysql = require('mysql2/promise');
const app = express();

app.use(express.json());

// 1. Logger Middleware - Ignores health checks & favicons to keep terminal clean
app.use((req, res, next) => {
  if (req.url !== '/health' && req.url !== '/favicon.ico') {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
  }
  next();
});

// 2. Database Connection Pool setup
const pool = mysql.createPool({
  host: '10.0.4.220',
  user: 'admin',
  password: 'info465crs',
  database: 'CoursePortal',
  connectTimeout: 5000,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// ====================================================
// HEALTH CHECK
// ====================================================
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// ====================================================
// API ENDPOINTS
// ====================================================

// --- AUTHENTICATION ---
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Please enter email and password." });
  }

  try {
    const [users] = await pool.query(
      `SELECT user_id, first_name, last_name, email, role_id 
       FROM Users 
       WHERE email = ? AND password_hash = ?`,
      [email, password]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: "Invalid email or password." });
    }

    const user = users[0];

    res.json({
      message: "Login successful!",
      user: {
        userId: user.user_id,
        user_id: user.user_id,
        first_name: user.first_name,
        last_name: user.last_name,
        name: `${user.first_name} ${user.last_name}`,
        email: user.email,
        roleId: user.role_id,
        role_id: user.role_id
      }
    });

  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ error: "Database error during login process." });
  }
});

// --- COURSES & DEPARTMENTS ---
app.get('/api/courses', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        c.course_id, 
        c.course_code, 
        c.course_name, 
        d.department_name, 
        c.credits, 
        c.capacity, 
        c.enrolled_count,
        CONCAT(u.first_name, ' ', u.last_name) AS instructor_name,
        cs.section_id,
        cs.section_number,
        cs.building,
        cs.room_number,
        cs.days_of_week,
        cs.start_time,
        cs.end_time
      FROM Courses c 
      LEFT JOIN Departments d ON c.department_id = d.department_id
      LEFT JOIN Course_Sections cs ON c.course_id = cs.course_id
      LEFT JOIN Instructors i ON cs.instructor_id = i.instructor_id
      LEFT JOIN Users u ON i.user_id = u.user_id;
    `);
    res.json(rows);
  } catch (error) {
    console.error("Database Error:", error);
    res.status(500).json({ error: "Failed to fetch courses from database" });
  }
});

app.get('/api/departments', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM Departments');
    res.json(rows);
  } catch (error) {
    console.error("Database Error:", error);
    res.status(500).json({ error: "Failed to fetch departments" });
  }
});

// Fetch system users directory
app.get('/api/students', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT u.user_id, u.user_id AS student_id, u.first_name, u.last_name, u.email, u.role_id
      FROM Users u
    `);
    res.json(rows);
  } catch (error) {
    console.error("Database Error:", error);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// --- STUDENT SCHEDULE & REGISTRATION ---

// Get active enrolled courses for a given student ID
app.get('/api/student/courses/:studentId', async (req, res) => {
  const { studentId } = req.params;

  try {
    const [stuMatch] = await pool.query(
      'SELECT student_id FROM Students WHERE student_id = ? OR user_id = ? LIMIT 1',
      [studentId, studentId]
    );

    const actualStudentId = stuMatch.length > 0 ? stuMatch[0].student_id : studentId;

    const [rows] = await pool.query(`
      SELECT c.course_id, c.course_code, c.course_name, c.credits, d.department_name, r.status, r.grade
      FROM Registrations r
      JOIN Course_Sections cs ON r.section_id = cs.section_id
      JOIN Courses c ON cs.course_id = c.course_id
      LEFT JOIN Departments d ON c.department_id = d.department_id
      WHERE r.student_id = ? AND r.status = 'Registered'
    `, [actualStudentId]);

    res.json(rows);
  } catch (error) {
    console.error("Error fetching student schedule:", error);
    res.status(500).json({ error: "Failed to fetch student courses." });
  }
});

// Standard Course Registration
app.post('/api/register', async (req, res) => {
  const { studentId, courseId } = req.body;

  try {
    const [stuMatch] = await pool.query(
      'SELECT student_id FROM Students WHERE student_id = ? OR user_id = ? LIMIT 1',
      [studentId, studentId]
    );
    const actualStudentId = stuMatch.length > 0 ? stuMatch[0].student_id : studentId;

    const [courseRows] = await pool.query(
      'SELECT capacity, enrolled_count FROM Courses WHERE course_id = ?', [courseId]
    );

    if (courseRows.length === 0) {
      return res.status(404).json({ error: "Course not found" });
    }

    const course = courseRows[0];
    if (course.enrolled_count >= course.capacity) {
      return res.status(400).json({ error: "Course is full! Requires advisor override." });
    }

    const [sectionRows] = await pool.query(
      'SELECT section_id FROM Course_Sections WHERE course_id = ? LIMIT 1', [courseId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({ error: "No active sections found for this course." });
    }

    const sectionId = sectionRows[0].section_id;

    await pool.query(
      'INSERT INTO Registrations (student_id, section_id, registration_date, status) VALUES (?, ?, CURDATE(), "Registered")',
      [actualStudentId, sectionId]
    );

    await pool.query(
      'UPDATE Courses SET enrolled_count = enrolled_count + 1 WHERE course_id = ?',
      [courseId]
    );

    res.json({ message: "Registration successful!" });
  } catch (error) {
    console.error(error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: "You are already registered for this course section!" });
    }
    res.status(500).json({ error: "Registration failed." });
  }
});

// Advisor Override Registration
app.post('/api/register/override', async (req, res) => {
  const { studentId, courseId, overrideCode } = req.body;

  if (overrideCode !== 'OVERRIDE2026') {
    return res.status(403).json({ error: "Invalid Advisor Override Code." });
  }

  try {
    const [stuMatch] = await pool.query(
      'SELECT student_id FROM Students WHERE student_id = ? OR user_id = ? LIMIT 1',
      [studentId, studentId]
    );
    const actualStudentId = stuMatch.length > 0 ? stuMatch[0].student_id : studentId;

    const [sectionRows] = await pool.query(
      'SELECT section_id FROM Course_Sections WHERE course_id = ? LIMIT 1', [courseId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({ error: "No active sections found for this course." });
    }

    const sectionId = sectionRows[0].section_id;

    await pool.query(
      'INSERT INTO Registrations (student_id, section_id, registration_date, status) VALUES (?, ?, CURDATE(), "Registered")',
      [actualStudentId, sectionId]
    );

    await pool.query(
      'UPDATE Courses SET enrolled_count = enrolled_count + 1 WHERE course_id = ?',
      [courseId]
    );

    res.json({ message: "Advisor override successful! Student registered." });
  } catch (error) {
    console.error(error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: "You are already registered for this course section!" });
    }
    res.status(500).json({ error: "Override registration failed." });
  }
});

// Drop Course
app.delete('/api/register/:studentId/:courseId', async (req, res) => {
  const { studentId, courseId } = req.params;

  try {
    const [stuMatch] = await pool.query(
      'SELECT student_id FROM Students WHERE student_id = ? OR user_id = ? LIMIT 1',
      [studentId, studentId]
    );
    const actualStudentId = stuMatch.length > 0 ? stuMatch[0].student_id : studentId;

    const [sectionRows] = await pool.query(
      'SELECT section_id FROM Course_Sections WHERE course_id = ? LIMIT 1', [courseId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({ error: "Section not found." });
    }

    const sectionId = sectionRows[0].section_id;

    const [deleteResult] = await pool.query(
      'DELETE FROM Registrations WHERE student_id = ? AND section_id = ?',
      [actualStudentId, sectionId]
    );

    if (deleteResult.affectedRows > 0) {
      await pool.query(
        'UPDATE Courses SET enrolled_count = GREATEST(0, enrolled_count - 1) WHERE course_id = ?',
        [courseId]
      );
      return res.json({ message: "Successfully dropped course." });
    } else {
      return res.status(404).json({ error: "Registration record not found." });
    }

  } catch (error) {
    console.error("Drop Course Error:", error);
    res.status(500).json({ error: "Failed to drop course." });
  }
});

// --- INSTRUCTOR & ROSTER ---

app.get('/api/instructor/schedule/:instructorId', async (req, res) => {
  const { instructorId } = req.params;

  try {
    const [rows] = await pool.query(`
      SELECT cs.section_id, c.course_code, c.course_name, cs.section_number, cs.building, cs.room_number, cs.days_of_week, cs.start_time, cs.end_time
      FROM Course_Sections cs
      JOIN Courses c ON cs.course_id = c.course_id
      WHERE cs.instructor_id = ?
    `, [instructorId]);

    res.json(rows);
  } catch (error) {
    console.error("Error fetching instructor schedule:", error);
    res.status(500).json({ error: "Failed to fetch instructor schedule." });
  }
});

app.get('/api/instructor/roster/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const [roster] = await pool.query(`
      SELECT s.student_id, u.first_name, u.last_name, u.email, r.registration_date, r.status, r.grade
      FROM Registrations r
      JOIN Students s ON r.student_id = s.student_id
      JOIN Users u ON s.user_id = u.user_id
      JOIN Course_Sections cs ON r.section_id = cs.section_id
      WHERE cs.section_id = ? OR cs.course_id = ?
    `, [id, id]);

    res.json(roster);
  } catch (error) {
    console.error("Roster error:", error);
    res.status(500).json({ error: "Failed to fetch class roster." });
  }
});

app.post('/api/grades', async (req, res) => {
  const { courseId, studentId, grade } = req.body;

  try {
    const [stuMatch] = await pool.query(
      'SELECT student_id FROM Students WHERE student_id = ? OR user_id = ? LIMIT 1',
      [studentId, studentId]
    );
    const actualStudentId = stuMatch.length > 0 ? stuMatch[0].student_id : studentId;

    const [sectionRows] = await pool.query(
      'SELECT section_id FROM Course_Sections WHERE course_id = ? LIMIT 1', [courseId]
    );

    if (sectionRows.length === 0) {
      return res.status(404).json({ error: "Course section not found." });
    }

    const sectionId = sectionRows[0].section_id;

    await pool.query(
      'UPDATE Registrations SET grade = ? WHERE student_id = ? AND section_id = ?',
      [grade, actualStudentId, sectionId]
    );

    res.json({ message: "Grade updated successfully!" });
  } catch (error) {
    console.error("Grade update error:", error);
    res.status(500).json({ error: "Failed to update grade." });
  }
});

// --- ADMIN CONTROLS ---

// Fetch Override Requests (for usermanagement.html)
app.get('/api/overrides', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        o.request_id,
        o.student_id,
        CONCAT(u.first_name, ' ', u.last_name) AS student_name,
        c.course_code,
        o.request_type,
        o.justification,
        o.status,
        o.created_at
      FROM Override_Requests o
      LEFT JOIN Students s ON o.student_id = s.student_id
      LEFT JOIN Users u ON s.user_id = u.user_id
      LEFT JOIN Courses c ON o.course_id = c.course_id
      ORDER BY 
        CASE o.status 
          WHEN 'Pending' THEN 1 
          WHEN 'Approved' THEN 2 
          WHEN 'Denied' THEN 3 
          ELSE 4 
        END, 
        o.created_at DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error("Fetch Overrides Error:", error);
    res.status(500).json({ error: "Failed to fetch override requests." });
  }
});

// Update Override Request Status (Approve/Deny)
app.patch('/api/overrides/:id', async (req, res) => {
  const requestId = req.params.id;
  const { status } = req.body;

  if (!['Approved', 'Denied'].includes(status)) {
    return res.status(400).json({ error: "Invalid status update value." });
  }

  try {
    const [result] = await pool.query(
      `UPDATE Override_Requests SET status = ? WHERE request_id = ?`,
      [status, requestId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Override request not found." });
    }

    res.json({ message: `Override request marked as ${status}.` });
  } catch (error) {
    console.error("Update Override Error:", error);
    res.status(500).json({ error: "Failed to update override request." });
  }
});

// Add User Endpoint (for usermanagement.html)
app.post('/api/admin/users', async (req, res) => {
  const { firstName, lastName, email, password, roleId, adminRoleId } = req.body;

  if (Number(adminRoleId) !== 3) {
    return res.status(403).json({ error: "Access denied. Admin privileges required." });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO Users (first_name, last_name, email, password_hash, role_id) VALUES (?, ?, ?, ?, ?)',
      [firstName, lastName, email, password, roleId]
    );

    const newUserId = result.insertId;

    if (Number(roleId) === 1) {
      await pool.query(
        'INSERT INTO Students (user_id, first_name, last_name, email) VALUES (?, ?, ?, ?)',
        [newUserId, firstName, lastName, email]
      );
    }

    res.json({ message: "User account created successfully!", userId: newUserId });
  } catch (error) {
    console.error("Create User Error:", error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: "Email address is already in use." });
    }
    res.status(500).json({ error: "Failed to create user account." });
  }
});

// Add Course Endpoint
app.post('/api/admin/courses', async (req, res) => {
  const { departmentId, courseCode, courseName, description, credits, roleId } = req.body;

  if (Number(roleId) !== 3) {
    return res.status(403).json({ error: "Access denied. Admin privileges required." });
  }

  try {
    await pool.query(
      'INSERT INTO Courses (department_id, course_code, course_name, description, credits) VALUES (?, ?, ?, ?, ?)',
      [departmentId, courseCode, courseName, description, credits]
    );
    res.json({ message: "Course offering created successfully!" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to create course." });
  }
});

// Assign Instructor to Section Endpoint
app.post('/api/admin/assign-instructor', async (req, res) => {
  const { sectionId, instructorId, roleId } = req.body;

  if (Number(roleId) !== 3) {
    return res.status(403).json({ error: "Access denied. Admin privileges required." });
  }

  try {
    await pool.query(
      'UPDATE Course_Sections SET instructor_id = ? WHERE section_id = ?',
      [instructorId, sectionId]
    );
    res.json({ message: "Instructor successfully assigned to section!" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to assign instructor." });
  }
});

// ====================================================
// STATIC FILE SERVING & PAGE ROUTES
// ====================================================

// 1. Serve static assets first (CSS, JS, Images, HTML)
app.use(express.static(path.join(__dirname, 'ux-ui-assignment')));
app.use(express.static(__dirname));

const sendFileSafely = (filename, res) => {
  let filePath = path.join(__dirname, 'ux-ui-assignment', filename);

  if (!fs.existsSync(filePath)) {
    filePath = path.join(__dirname, filename);
  }

  if (fs.existsSync(filePath)) {
    return res.sendFile(filePath);
  }

  console.error(`⚠️ File missing on disk: ${filename}`);
  return res.status(404).send(`<h1>404 Not Found</h1><p>The file <b>${filename}</b> could not be located on disk.</p>`);
};

// 2. Explicit Clean URLs & Direct HTML Requests
app.get('/', (req, res) => sendFileSafely('login.html', res));
app.get('/login', (req, res) => sendFileSafely('login.html', res));
app.get('/login.html', (req, res) => sendFileSafely('login.html', res));

app.get('/home', (req, res) => sendFileSafely('Homes-screen.html', res));
app.get('/Homes-screen.html', (req, res) => sendFileSafely('Homes-screen.html', res));

app.get('/courses', (req, res) => sendFileSafely('coursesearch.html', res));
app.get('/coursesearch', (req, res) => sendFileSafely('coursesearch.html', res));
app.get('/coursesearch.html', (req, res) => sendFileSafely('coursesearch.html', res));

app.get('/register', (req, res) => sendFileSafely('studentregistration.html', res));
app.get('/studentregistration.html', (req, res) => sendFileSafely('studentregistration.html', res));

app.get('/mycourses', (req, res) => sendFileSafely('mycourses.html', res));
app.get('/mycourses.html', (req, res) => sendFileSafely('mycourses.html', res));

app.get('/instructorschedule', (req, res) => sendFileSafely('instructorschedule.html', res));
app.get('/instructorschedule.html', (req, res) => sendFileSafely('instructorschedule.html', res));

app.get('/classroster', (req, res) => sendFileSafely('classroster.html', res));
app.get('/classroster.html', (req, res) => sendFileSafely('classroster.html', res));

app.get('/reports', (req, res) => sendFileSafely('enrollmentreports.html', res));
app.get('/enrollmentreports.html', (req, res) => sendFileSafely('enrollmentreports.html', res));

app.get('/portal', (req, res) => sendFileSafely('courseportal.html', res));
app.get('/courseportal.html', (req, res) => sendFileSafely('courseportal.html', res));

app.get('/usermanagement', (req, res) => sendFileSafely('usermanagement.html', res));
app.get('/usermanagement.html', (req, res) => sendFileSafely('usermanagement.html', res));

// 3. Catch-all: Route unrecognized HTML files directly before falling back
app.use((req, res) => {
  if (req.path.startsWith('/api')) {
    return res.status(404).json({ error: "API route not found" });
  }

  // Extract filename from URL (e.g. /studentregistration.html -> studentregistration.html)
  const requestedFile = path.basename(req.path);
  
  if (requestedFile.endsWith('.html')) {
    return sendFileSafely(requestedFile, res);
  }

  sendFileSafely('login.html', res);
});

// Start Server
app.listen(80, () => {
  console.log('Server running on port 80');
});