-- Active: 1760622789442@@127.0.0.1@3306@job
use job;
select * from job;

/* ===========================================================
   Job Placement – Medium SQL Set (Q1–Q10)
   Table: job_placement
   Columns:
     id, name, gender, age, degree, stream, college_name,
     placement_status, salary, gpa, years_of_experience
   -----------------------------------------------------------
   Dialect notes:
   - Row limiting:
       Standard SQL:           FETCH FIRST N ROWS ONLY
       PostgreSQL/MySQL/SQLite: LIMIT N
       SQL Server:             TOP (N)
   - Variance:
       Standard/Postgres/SQL Server: VAR_SAMP(col)
       MySQL 8+:                    VARIANCE(col) (sample variance)
       SQLite:                      no built-in; use AVG(x*x)-AVG(x)^2 * N/(N-1)
   =========================================================== */

-- Create database
CREATE DATABASE job;

-- Switch to the database (syntax varies slightly by RDBMS)
-- PostgreSQL / MySQL:
USE job;


-- Create table
CREATE TABLE job (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    degree VARCHAR(50),
    stream VARCHAR(100),
    college_name VARCHAR(150),
    placement_status VARCHAR(20),
    salary INT,
    gpa DECIMAL(3,2),
    years_of_experience INT
);



/* -----------------------------------------------------------
   Q1) Average Salary of Placed Students
   ----------------------------------------------------------- */
WITH placed AS (
  SELECT salary
  FROM job
  WHERE placement_status = 'Placed'
)
SELECT ROUND(AVG(salary), 2) AS avg_salary_placed
FROM placed;


/* -----------------------------------------------------------
   Q2) Gender-Based Placement Rate
   ----------------------------------------------------------- */
WITH base AS (
  SELECT gender, placement_status
  FROM job
),
counts AS (
  SELECT
    gender,
    COUNT(*) AS total,
    SUM(CASE WHEN placement_status = 'Placed' THEN 1 ELSE 0 END) AS placed
  FROM base
  GROUP BY gender
)
SELECT
  gender,
  total,
  placed,
  ROUND(100.0 * placed / NULLIF(total, 0), 2) AS placement_rate_pct
FROM counts
ORDER BY gender;


/* -----------------------------------------------------------
   Q3) College with Highest Avg GPA among Placed
   ----------------------------------------------------------- */
WITH placed AS (
  SELECT college_name, gpa
  FROM job
  WHERE placement_status = 'Placed'
),
avg_gpa AS (
  SELECT college_name, AVG(gpa) AS avg_gpa
  FROM placed
  GROUP BY college_name
)
SELECT college_name, ROUND(avg_gpa, 3) AS avg_gpa
FROM avg_gpa
ORDER BY avg_gpa DESC
limit 1;    -- or: LIMIT 1 / SELECT TOP 1 ...


/* -----------------------------------------------------------
   Q4) Most Popular Stream by Placement Count
   ----------------------------------------------------------- */
WITH placed AS (
  SELECT stream
  FROM job
  WHERE placement_status = 'Placed'
),
counts AS (
  SELECT stream, COUNT(*) AS placed_count
  FROM placed
  GROUP BY stream
)
SELECT stream, placed_count
FROM counts
ORDER BY placed_count DESC
limit 1;      -- or: LIMIT 1 / SELECT TOP 1 ...


/* -----------------------------------------------------------
   Q5) Salary Comparison by Degree Type (Placed Only)
   ----------------------------------------------------------- */
WITH placed AS (
  SELECT degree, salary
  FROM job
  WHERE placement_status = 'Placed'
)
SELECT degree, ROUND(AVG(salary), 2) AS avg_salary
FROM placed
GROUP BY degree
ORDER BY avg_salary DESC;


/* -----------------------------------------------------------
   Q6) Top 5 Highest Paid Students (Placed Only)
   ----------------------------------------------------------- */
SELECT
  name, college_name, stream, salary
FROM job
WHERE placement_status = 'Placed'
ORDER BY salary DESC
limit 5;     -- or: LIMIT 5 / SELECT TOP 5 ...


/* -----------------------------------------------------------
   Q7) Placement Status by Years of Experience
   ----------------------------------------------------------- */
WITH base AS (
  SELECT years_of_experience, placement_status
  FROM job
)
SELECT
  years_of_experience,
  SUM(CASE WHEN placement_status = 'Placed' THEN 1 ELSE 0 END) AS placed,
  SUM(CASE WHEN placement_status <> 'Placed' THEN 1 ELSE 0 END) AS not_placed
FROM base
GROUP BY years_of_experience
ORDER BY years_of_experience;


/* -----------------------------------------------------------
   Q8) Avg GPA: Placed vs Not Placed
   ----------------------------------------------------------- */
SELECT
  placement_status,
  ROUND(AVG(gpa), 4) AS avg_gpa
FROM job
GROUP BY placement_status
ORDER BY placement_status;


/* -----------------------------------------------------------
   Q9) Age-Group Placement Rate
   ----------------------------------------------------------- */
WITH placement_rate AS (
  SELECT
    CASE
      WHEN age < 23 THEN '<23'
      WHEN age BETWEEN 23 AND 25 THEN '23-25'
      ELSE '>25'
    END AS age_group,
    placement_status
  FROM job
),
agegroup AS (
  SELECT
    age_group,
    COUNT(*) AS total,
    SUM(CASE WHEN placement_status = 'Placed' THEN 1 ELSE 0 END) AS placed
  FROM placement_rate
  GROUP BY age_group
)
SELECT
  age_group,
  total,
  placed,
  ROUND(100.0 * placed / NULLIF(total, 0), 2) AS placement_rate_percent
FROM agegroup
ORDER BY CASE age_group WHEN '<23' THEN 1 WHEN '23-25' THEN 2 ELSE 3 END;


/* -----------------------------------------------------------
   Q10) Colleges with Highest Average Salary (Placed Only)
   ----------------------------------------------------------- */

SELECT
    college_name,
    ROUND(AVG(salary), 2) AS avg_salary
FROM job
WHERE placement_status = 'Placed'
GROUP BY college_name
ORDER BY avg_salary DESC
LIMIT 3;  -- Use TOP 3 for SQL Server
