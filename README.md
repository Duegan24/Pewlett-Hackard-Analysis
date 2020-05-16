# Pewlett-Hackard-Analysis
## Challeng Problem Overview
The objective of this analysis was to better understand the number of employees that will be retiring, how many from each title, and how many titles were going to be effected.  The next step was to identify who could participate in a mentorship program.

## Step Performed in the Analysis
The very first step before any of the delieverables could completed was to review all of the data tables and to develop an Entity Relationship Diagram (ERD).  Below I have shown the results of that review:

!["ERD of Employee Data"](https://github.com/Duegan24/Pewlett-Hackard-Analysis/blob/master/EmployeeDB.png)

### Deliverables 1:
#### 1:  Determine the employees that are retiring and thier titles
The first step was to create a table of current employees that are expected to retire in the near future and including their titles.  This was achieved by using the informaiton provided in three tables, the Employee, Title, and Salary tables.  This was accomplished by using the follow query:

--Create table with retiring employees with title that are still employed
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

#### 2:  Remove all extra positions that an employee had and only display their current title
With a quick overview of the results from step 1, it was clear that employees were showing up on the list more than once.  The reason is that the titles table included previous titles and not just their most recient one.  It was necessary to order the titles by the from_date with the most recent date first, and then for only that title be included in the final table.  To make this possible, it was necessary to partition the list by the employee number and selct the first occurance.  The code was used to achive this objective.

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

#### 3: Determine number of employees retiring by title
Based on the results provided in part 2 above, it was then easy to perform another query where I grouped the employees by title and counted the number of employees with that title.  The below code was used to achieve this objective:

--Table with number of Retiring Employees by Title
SELECT title
	, COUNT(emp_no) AS Count_Retiring_Employees
INTO number_retiring_by_title
FROM retiring_emp_w_title_recent
GROUP BY title;
SELECT * FROM number_retiring_by_title; 

#### 4:  Determine number of titles that were effected
The final step of the process was to determine the number of titles that were going to be effected.  This was done simply by taking the results from the previous section and counting the number of titles that were present.  The below code was used to achive this objective:

--Number of [titles] retiring
SELECT COUNT(title) AS Number_Title_Retiring
INTO number_titles_retiring
FROM number_retiring_by_title;

### Deliverables 2:
In this deliverable, the only objective was to identify those employees that would be able to participate in the mentorship program.  For this objective it was necessary to use the data tables, Employee and Titles.  The date ranges were provided, the only addition was to make sure that they were currently employeed, and to achieve that I selected that the title to_date would be '9999-01-01' indicating that they are currently in that  position.  The below code was used to compile the list of employees that could participate in the mentorship program.

--Table of employees that are available for the mentorship role
SELECT e.emp_no
	, e.first_name
	, e.last_name
	, t.title
	, t.from_date
	, t.to_date
INTO mentorship_eligibility
FROM employees AS e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND t.to_date = '9999-01-01'
ORDER BY e.emp_no;
SELECT * FROM mentorship_eligibility;

## Results
After the analysis above it was found that there were a total of 72,458 employees that would be retiring, below is how those employees were distributed over the 7 titles that were effected.

| Title | Count of Retiring Employees|
| --- | --- |
| Engineer | 9,285 |
| Senior Engineer | 25,916 |
| Manager | 2 |
| Assistant Engineer | 1,090 |
| Staff | 7,636 |
| Senior Staff | 24,926 |
| Technique Leader | 3,603 |

The final step was to identify the number of employees that could participate in the mentorship program.  There were a total of 1,549 current employees that are of the appropriate age.  

### Next Steps
Now that the mentorship list has been generated the next step is to evaluate which titles those employees can start training for.  In some cases the positions that will be vacated by retiring employees do not need speciallized training; however, for those that do it will be important to evaluate which personnel would be best suited to train for those positions.  