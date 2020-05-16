-- Retirement eligibility
SELECT count(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--delete table
DROP TABLE retirement_info;
-- Create NTnew table for retiring employees
SELECT	de.dept_no, 
	d.dept_name,
	COUNT(emp.emp_no)
INTO retirement_info
FROM employees AS emp
LEFT JOIN dept_emp AS de
	ON emp.emp_no = de.emp_no 
INNER JOIN departments AS d
	ON de.dept_no = d.dept_no
WHERE (emp.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (emp.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01')
GROUP BY de.dept_no, d.dept_name;
-- Check the table
SELECT * FROM retirement_info;

-- delete tabel so it results can be replaced
DROP TABLE current_emp;
-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_emp AS de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
--display table results
SELECT * FROM current_emp;

-- Joining departments and dept_manager tables
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments AS d
INNER JOIN dept_manager AS dm
ON d.dept_no = dm.dept_no;


-- delete tabel so it results can be replaced
DROP TABLE retirements_by_dept;
-- Employee count by department number
SELECT de.dept_no AS "Department Number",
	COUNT(ce.emp_no) AS "Employee Count"
INTO retirements_by_dept
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
--display table results
SELECT * FROM retirements_by_dept;

--Current Employee Information Table
DROP TABLE emp_info;
SELECT e.emp_no, 
	e.first_name, 
	e.last_name, 
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees AS e
LEFT JOIN salaries AS S
	ON (e.emp_no = s.emp_no)
LEFT JOIN dept_emp AS de
	ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');
SELECT * FROM emp_info;

--Managers Info Table creation
DROP TABLE manager_info;
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
SELECT * FROM manager_info;

--Current Employees with departments added
DROP TABLE dept_info;
-- List of managers per department
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name	
INTO dept_info
FROM current_emp AS ce
    INNER JOIN dept_emp AS de
        ON (ce.emp_no = de.emp_no)
	INNER JOIN departments as d
		ON (de.dept_no = d.dept_no);
SELECT * FROM dept_info;

-- List of retiring personnel in sales department
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name	
FROM retirement_info AS ri
    INNER JOIN dept_emp AS de
        ON (ri.emp_no = de.emp_no)
	INNER JOIN departments as d
		ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales';

-- List of retiring personnel in sales and Development departments
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name	
FROM retirement_info AS ri
    INNER JOIN dept_emp AS de
        ON (ri.emp_no = de.emp_no)
	INNER JOIN departments as d
		ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales', 'Development');


--Table with Retiring employees with title that are still employed
SELECT e.emp_no
	, e.first_name
	, e.last_name
	, t.title
	, t.from_date
	, s.salary
INTO retiring_emp_w_title
FROM employees AS e
	INNER JOIN salaries AS S
		ON (e.emp_no = s.emp_no)
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;
SELECT * FROM retiring_emp_w_title;


--Create table with only the most recent titles
SELECT emp_no
	, first_name
	, last_name
	, title
	, from_date
	, salary
INTO current_retiring_emp_w_title
FROM
	(SELECT emp_no
	, first_name
	, last_name
	, title
	, from_date
	, salary
	, ROW_NUMBER() OVER(PARTITION BY(emp_no)
					 ORDER BY from_date DESC) AS rn
	FROM retiring_emp_w_title) AS tmp
WHERE rn = 1
ORDER BY emp_no;
SELECT * FROM current_retiring_emp_w_title;

--Table with number of Retiring Employees by Title
SELECT title
	, COUNT(emp_no) AS Count_Retiring_Employees
INTO number_retiring_by_title
FROM retiring_emp_w_title_recent
GROUP BY title;
SELECT * FROM number_retiring_by_title;

--Table of employees that are available for the mentorship role
SELECT e.emp_no
	, e.first_name
	, e.last_name
	, t.title
	, t.from_date
	, t.to_date
INTO mentorship_eligibility
FROM employees AS e
	INNER JOIN salaries AS S
		ON (e.emp_no = s.emp_no)
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND t.to_date = '9999-01-01'
ORDER BY e.emp_no;
SELECT * FROM mentorship_eligibility;

--Number of [titles] retiring
SELECT COUNT(title) AS Number_Title_Retiring
INTO number_titles_retiring
FROM number_retiring_by_title;