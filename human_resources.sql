----------------------------------------------------------------------
--                    Data In Motion
--            SQL Case Study 2: Human Resources
--                Solutions by Monika Riehn
----------------------------------------------------------------------

----------------------------------------------------------------------
--1. Find the longest ongoing project for each department.
----------------------------------------------------------------------

SELECT
	d.name AS dept_name,
	p.name AS project_name,
	concat ( ( end_date - start_date ) || ' ' || 'days' ) AS duration
FROM
	projects p
JOIN departments d ON
	p.department_id = d.id
ORDER BY
	duration DESC ;


dept_name|project_name   |duration|
---------+---------------+--------+
Sales    |Sales Project 1|183 days|
HR       |HR Project 1   |180 days|
IT       |IT Project 1   |180 days|


----------------------------------------------------------------------
--2. Find all employees who are not managers.
----------------------------------------------------------------------

SELECT
	e.id AS employee_id,
	e.name AS employee_name,
	e.job_title ,
	d.manager_id AS employees_manager
FROM
	employees e
JOIN departments d ON
	e.department_id = d.id
WHERE
	e.id != d.manager_id ;


employee_id|employee_name|job_title      |employees_manager|
-----------+-------------+---------------+-----------------+
          4|Bob Miller   |HR Associate   |                1|
          5|Charlie Brown|IT Associate   |                2|
          6|Dave Davis   |Sales Associate|                3|


----------------------------------------------------------------------
--3. Find all employees who have been hired after the start of a project in their department.
----------------------------------------------------------------------
          
SELECT
	e.name AS employee_name,
	e.hire_date AS hire_date,
	p.start_date AS project_start
FROM
	departments d
JOIN employees e ON
	e.department_id = d.id
JOIN projects p ON
	d.id = p.department_id
WHERE
	e.hire_date > p.start_date ;


employee_name|hire_date |project_start|
-------------+----------+-------------+
Dave Davis   |2023-03-15|   2023-03-01|


----------------------------------------------------------------------
--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).
----------------------------------------------------------------------

SELECT
	d.name AS dept_name,
	e.name AS emp_name,
	e.hire_date
FROM
	employees e
JOIN departments d ON
	e.department_id = d.id
ORDER BY
	d.id,
	hire_date;


dept_name|emp_name     |hire_date |
---------+-------------+----------+
HR       |John Doe     |2018-06-20|
HR       |Bob Miller   |2021-04-30|
IT       |Jane Smith   |2019-07-15|
IT       |Charlie Brown|2022-10-01|
Sales    |Alice Johnson|2020-01-10|
Sales    |Dave Davis   |2023-03-15|
          

----------------------------------------------------------------------
--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
----------------------------------------------------------------------

SELECT
	e.department_id AS dept_id,
	e.id AS emp_id,
	e.name AS emp_name,
	e.hire_date,
	/* The PARTITION BY clause distributes rows into departments (or partitions), specified by e.department_id.
	 * The ORDER BY clause sorts rows within each department_id by hire_date in ascending order.
	 * The LEAD() function returns the next_hire_date after the hire_date of the employee before within that department*/
	LEAD(e.hire_date) OVER (
		PARTITION BY e.department_id
		ORDER BY e.hire_date
			)
			AS next_hire_date,
	/* Calculate the duration between the hire date of the current employee and the next employee.
	 * Note, that next_hire_date is not known as column yet, so you have to repeat the LEAD()-function for the calculation!*/
	LEAD(e.hire_date) OVER (
    	PARTITION BY e.department_id
		ORDER BY e.hire_date 
			) - e.hire_date 
    		AS duration
FROM
	employees e
ORDER BY
	e.department_id,
	e.hire_date;


dept_id|emp_id|emp_name     |hire_date |next_hire_date|duration|
-------+------+-------------+----------+--------------+--------+
      1|     1|John Doe     |2018-06-20|    2021-04-30|    1045|
      1|     4|Bob Miller   |2021-04-30|              |        |
      2|     2|Jane Smith   |2019-07-15|    2022-10-01|    1174|
      2|     5|Charlie Brown|2022-10-01|              |        |
      3|     3|Alice Johnson|2020-01-10|    2023-03-15|    1160|
      3|     6|Dave Davis   |2023-03-15|              |        |


----------------------------------------------------------------------
-- For training purposes:
-- Find the duration between start of one and the next project
----------------------------------------------------------------------

SELECT
  name,
  start_date,
  LEAD(start_date) OVER (
  	ORDER BY start_date
  	) AS next_start_date,
  LEAD(start_date) OVER (
  	ORDER BY start_date
  	) - start_date AS difference
FROM
  projects
ORDER BY
  start_date;

 
name           |start_date|next_start_date|difference|
---------------+----------+---------------+----------+
HR Project 1   |2023-01-01|     2023-02-01|        31|
IT Project 1   |2023-02-01|     2023-03-01|        28|
Sales Project 1|2023-03-01|               |          |

