CREATE DATABASE IF NOT EXISTS final;
USE final;

-- ==========================================================
-- CREATE TABLES
-- ==========================================================

CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Students (
    StudentID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(150),
    BirthDate DATE,
    EnrollmentDate DATE
);

CREATE TABLE Courses (
    CourseID INT AUTO_INCREMENT PRIMARY KEY,
    CourseName VARCHAR(150),
    DepartmentID INT,
    Credits INT,
    CONSTRAINT fk_courses_dept 
        FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Instructors (
    InstructorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(150),
    DepartmentID INT,
    CONSTRAINT fk_instructors_dept 
        FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE Enrollments (
    EnrollmentID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE,
    CONSTRAINT fk_enrollments_student 
        FOREIGN KEY (StudentID) 
        REFERENCES Students(StudentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_course 
        FOREIGN KEY (CourseID) 
        REFERENCES Courses(CourseID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ==========================================================
-- INSERT DATA
-- ==========================================================

INSERT INTO Departments (DepartmentName) VALUES
('Computer Science'),
('Business Intelligence');

INSERT INTO Students (FirstName, LastName, Email, BirthDate, EnrollmentDate) VALUES
('Rohan', 'Verma', 'rohan.verma@campus.com', '2001-08-15', '2023-07-12'),
('Ishita', 'Gupta', 'ishita.gupta@campus.com', '2000-11-20', '2022-05-18'),
('Kabir', 'Singh', 'kabir.singh@campus.com', '2002-03-09', '2024-01-10');

INSERT INTO Courses (CourseName, DepartmentID, Credits) VALUES
('SQL Essentials', 1, 4),
('Business Statistics', 2, 3),
('AI Foundations', 1, 5);

INSERT INTO Instructors (FirstName, LastName, Email, DepartmentID) VALUES
('Tanvi', 'Rathore', 'tanvi.rathore@faculty.com', 1),
('Arjun', 'Desai', 'arjun.desai@faculty.com', 2),
('Maya', 'Nair', 'maya.nair@faculty.com', 1);

INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDate) VALUES
(1, 1, '2023-07-12'),
(2, 2, '2022-05-18'),
(1, 2, '2024-02-02');

-- ==========================================================
-- UPDATES
-- ==========================================================

UPDATE Students 
SET Email = 'rohan.v@campus.com'
WHERE StudentID = 1;

UPDATE Courses 
SET Credits = 6 
WHERE CourseID = 3;

UPDATE Instructors 
SET Email = 'tanvi.r@faculty.com'
WHERE InstructorID = 1;

ALTER TABLE Instructors ADD COLUMN Salary DECIMAL(10,2);

UPDATE Instructors
SET Salary = CASE
    WHEN InstructorID = 1 THEN 92000
    WHEN InstructorID = 2 THEN 78000
    ELSE 70000
			END;

-- ==========================================================
-- QUERIES
-- ==========================================================

SELECT * FROM Departments;

SELECT StudentID, FirstName, LastName, EnrollmentDate
FROM Students
WHERE EnrollmentDate > '2022-12-31';

SELECT C.CourseID, C.CourseName, C.Credits
FROM Courses C
JOIN Departments D ON C.DepartmentID = D.DepartmentID
WHERE D.DepartmentName = 'Business Intelligence'
LIMIT 5;

SELECT C.CourseID, C.CourseName, COUNT(E.StudentID) AS StudentCount
FROM Courses C
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
GROUP BY C.CourseID, C.CourseName
HAVING COUNT(E.StudentID) > 5;

SELECT S.StudentID, S.FirstName, S.LastName
FROM Students S
WHERE S.StudentID IN (
    SELECT StudentID
    FROM Enrollments
    WHERE CourseID IN (1, 2)
    GROUP BY StudentID
    HAVING COUNT(DISTINCT CourseID) = 2
);

SELECT DISTINCT S.StudentID, S.FirstName, S.LastName
FROM Students S
JOIN Enrollments E ON S.StudentID = E.StudentID
WHERE E.CourseID IN (1, 2);

SELECT ROUND(AVG(Credits),2) AS AvgCredits FROM Courses;

SELECT MAX(I.Salary) AS MaxSalaryCS
FROM Instructors I
JOIN Departments D ON I.DepartmentID = D.DepartmentID
WHERE D.DepartmentName = 'Computer Science';

SELECT D.DepartmentID, D.DepartmentName, COUNT(DISTINCT E.StudentID) AS StudentsInDept
FROM Departments D
LEFT JOIN Courses C ON D.DepartmentID = C.DepartmentID
LEFT JOIN Enrollments E ON C.CourseID = E.CourseID
GROUP BY D.DepartmentID, D.DepartmentName;

SELECT S.StudentID, S.FirstName, S.LastName, C.CourseID, C.CourseName, E.EnrollmentDate
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON E.CourseID = C.CourseID;

SELECT S.StudentID, S.FirstName, S.LastName, C.CourseID, C.CourseName, E.EnrollmentDate
FROM Students S
LEFT JOIN Enrollments E ON S.StudentID = E.StudentID
LEFT JOIN Courses C ON E.CourseID = C.CourseID;

SELECT DISTINCT S.StudentID, S.FirstName, S.LastName
FROM Students S
WHERE S.StudentID IN (
    SELECT E.StudentID
    FROM Enrollments E
    WHERE E.CourseID IN (
        SELECT CourseID
        FROM Enrollments
        GROUP BY CourseID
        HAVING COUNT(StudentID) > 10
    )
);

SELECT StudentID, FirstName, LastName, YEAR(EnrollmentDate) AS EnrollmentYear
FROM Students;

SELECT InstructorID, CONCAT(FirstName, ' ', LastName) AS FullName, Email
FROM Instructors;

SELECT EnrollmentID, EnrollmentDate, StudentID, CourseID,
       COUNT(*) OVER (ORDER BY EnrollmentDate, EnrollmentID 
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningEnrollmentCount
FROM Enrollments
ORDER BY EnrollmentDate, EnrollmentID;

SELECT StudentID, FirstName, LastName, EnrollmentDate,
       CASE
         WHEN TIMESTAMPDIFF(YEAR, EnrollmentDate, CURDATE()) > 4 THEN 'Senior'
         ELSE 'Junior'
       END AS StudentLevel
FROM Students;
