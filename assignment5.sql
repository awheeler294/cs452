-- Part I - Questions 1-4
--
-- Download the two files that comprise the data set for this assignment -
--
-- id-gender-list.csv
--
-- parent-child-list.csv
--
--
-- Write a Java JDBC (or equivalent) program, using PreparedStatements to create two tables and insert the data from the files into them. The table schemas are found in the Part I section of the accompanying assignment description.
--
--
-- After successfully creating and loading the database, answer questions 1 - 4

--  1.
--  How many children are there who have an 'X' in their id whose parent(s) have a '9' in their ids.
--
--  Hint: A child may appear more than once in the table with a parent whose id matches the criteria.

SELECT COUNT(*)
FROM (SELECT DISTINCT parent_child_db.parent_child.child_id
      FROM parent_child_db.parent_child
      WHERE parent_child.child_id LIKE '%X%' AND parent_child.parent_id LIKE '%9%') AS r;

-- 2.
-- How many parents of children who have an 'X' in their identifier are female?
SELECT COUNT(*)
FROM (SELECT DISTINCT parent_child_db.parent_child.child_id
      FROM parent_child_db.parent_child
            INNER JOIN parent_child_db.id_gender ON parent_child.parent_id = id_gender.person_id
      WHERE parent_child.child_id LIKE '%X%' AND id_gender.gender = 'f') AS r;


-- 3.
-- The parent_child table contains parents who are at the "end of the line" in the pedigree. That is, these
-- parents do not appear as children in the parent_child table. How many of these "end of line" parents are there in the table?
--
-- Try to do this with one query. You might think about using the "except" clause.
--
-- Hint: parents can appear multiple times in the table. We are asking for how many parents, not how many rows.
SELECT COUNT(*)
FROM (SELECT DISTINCT parent_child_db.parent_child.parent_id
      FROM parent_child_db.parent_child EXCEPT (SELECT DISTINCT parent_child_db.parent_child.child_id
        FROM parent_child_db.parent_child)) AS t;



-- 4.
-- The data includes many ids that are distinct, yet represent the same real individuals.
-- This leads to some unusual situations. For instance, a child may ony have two real parents,
-- but because of duplication, they may be associated with many more than two parent ids.
--
-- Find the id of the child who is associated with the most parents, i.e. direct parental relationships.
--
-- What is the id of the child and how many parents are associated with her or him?

-- KN4X-T2M : 331


-- Part II - Questions 5 - 10
--
-- Implement a FindAllAncestors function 4 ways:
--
-- Using a Java JDBC (or equivalent) program. You can easily modify the FindAllPrereq class,
-- runJavaTest method to do this.
--
-- Using a stored database function. You should be able to easily modify the find_all_prereq_f.sql file that
-- accompanies this assignment to do that.
--
-- Using a recursive query. The supplied find_all_prereq_rq.sql file is easily modified to work with the
-- parent_child table.
--
-- Using a stored database function that uses the recursive query you just defined. Again,
-- the find_all_prereq_f_rq.sql file is where you will want to start.

-- Questions 6, 7, and 8 ask you to run a query and time its execution. If you are executing queries in pgAminII
-- Query tool, the execution time appears in the bottom right-hand corner of the status bar. If you are using the psql
-- console, you can enable timing by typing timing on at the prompt. The execution time will be displayed after the
-- results of the query. It's not important which method you use so long as you are consistent.


-- 5 - Using your Java JDBC (or equivalent) program, how many ancestors does 'LFDN-3X3' have? (Do not include the seed id in your count)

-- 37506

-- 6.
-- Use your SQL stored function to find the number of ancestors of LFDN-3NN that have either a 'Z' or an '8'
-- in their person identifier. How many are there?
--
-- Write down the time it took to execute the query somewhere.
-- SELECT COUNT(*)
SELECT *
FROM find_all_ancestor_f('LFDN-3NN') AS ancestors
WHERE ancestors.ancestor_id LIKE '%Z%'
OR ancestors.ancestor_id LIKE '%9%';
-- 1.2s

-- 7.
-- Verify your answer to question #6 using your SQL recursive query.
-- (You will need to modify the final select statement)
--
-- Did it agree?
--
-- Write down the execution time somewhere.
with recursive ancestor(ancestor_id) as (
  select CS.parent_id from parent_child_db.parent_child CS
  where child_id = 'LFDN-3NN'
  union
  select CS.parent_id
  from ancestor, parent_child_db.parent_child CS
  where ancestor.ancestor_id = CS.child_id
)
select ancestor_id from ancestor
WHERE ancestor.ancestor_id LIKE '%Z%'
OR ancestor.ancestor_id LIKE '%9%';
-- 526ms

-- 8.
-- Use your SQL stored function that uses the recursive query to verify your answers to questions 6 and 7.
--
-- Does it agree?
--
-- Write down the execution time somewhere.
SELECT *
FROM find_all_ancestor_rc('LFDN-3NN') AS ancestors
WHERE ancestors.ancestor_id LIKE '%Z%'
      OR ancestors.ancestor_id LIKE '%9%';
-- 629ms

-- 11.
-- Part III - Questions 11 - 14
--
-- Modify your SQL stored function to include the generation of each ancestor that is returned in the result table.
-- See the Assignment description, Part III for details and guidelines. When you have completed the modification,
-- use the modified SQL stored function to answer the following questions.
--
--
-- 11 - Using your modified SQL stored function, find how many ancestors 'LFDN-3NN' has at generation 15.
-- How many are there?