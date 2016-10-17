-- 1.
-- For the database of 4.11, write a query to find those employees with no manager. Note that an employee may simply
-- have no manager listed or may have a null manager.
--
--  Write your using an outer join.
--
--  You can use the schema and data from Assignment #3. There are two employees without managers.
SELECT employee.employee_name, employee.city, employee.street
FROM employee_db.employee
LEFT OUTER JOIN employee_db.manages ON employee.employee_name = manages.employee_name
WHERE manages.manager_name IS NULL;

-- 2.
-- Rewrite the query from problem #1 without using an outer join.
--
--  Hint: Practice exercises 4.1b and 4.2 show different ways expressing queries with and without outer joins.
SELECT employee.employee_name, employee.city, employee.street
FROM employee_db.employee EXCEPT (
  SELECT employee.employee_name, employee.city, employee.street
  FROM employee_db.employee
  JOIN employee_db.manages ON employee.employee_name = manages.employee_name);

-- 3.
-- Define a view tot_credits(year, num_credits), giving the total number of credits taken by students in each year.
-- (i.e. the total number of credits from all students for each year).
--
--  Show the definition of the view and the results of the query
--
--  select * from tot_credits;
CREATE VIEW tot_credits(year, num_credits) AS
  SELECT takes.year, sum(course.credits) AS num_credits
  FROM  takes INNER JOIN course ON takes.course_id = course.course_id
  GROUP BY takes.year;

select * from tot_credits;


-- 4.
-- Using the university database, write an SQL query to find the names of instructors and the names of the students
-- they advise. Include all instructors, even if they are not advising any students.
SELECT instructor.name AS instructor, student.name AS advises
FROM instructor
  LEFT OUTER JOIN advisor ON instructor.id = advisor.i_id
  LEFT OUTER JOIN student ON advisor.s_id = student.id;

-- 5.
-- Outer joins frequently produce null values. SQL provides a few ways to translate null values to more meaninful
-- strings. One of these ways is uses the coalesce function. (Other ways include using the
-- case ... when ... then ... end structure and in some databases the decode function).
--
--  The coalesce function takes a list of values and examines each value in the list. It returns the first non-null
--  value, or null if all values in the list are null.
--
--  Example:
--
--  coalesce(a, b, 'hello')
-- returns the value of a if a is not null, or
--
-- the value of b if a is null and b is not null, or
--  'hello' if both a and b are null.
--
--  Use the coalesce function to modify the query you previously wrote for problem #4 to substitute the
--  string 'unassigned' for any null values that appear in the student name column.
SELECT instructor.name AS instructor, coalesce(student.name, 'unassigned') AS advises
FROM instructor
  LEFT OUTER JOIN advisor ON instructor.id = advisor.i_id
  LEFT OUTER JOIN student ON advisor.s_id = student.id;


-- 6.
-- Consider the following definitions and statments-

create domain sizes as varchar(10) check(value in ('s','m','l'));
create domain days as varchar(10) check(value in ('s','m','t','w','th','f','sa'));

create table T1(size sizes);

create table T2(day days);

insert into T1 values('s'), ('m'), ('l');
insert into T2 values('sa'), ('t'), ('m'), ('w'), ('s');

--  What will happen when we execute the following query?

select *
from T1, T2
where T1.size = T2.day;


-- 7.
-- Consider the table

create table T(id serial, name varchar(20));


-- and the following insert statements -

insert into T(name) values('name1');
insert into T(name) values('name2');

--  will the following insert statement succeed or fail?

insert into T values(1,'name3');
