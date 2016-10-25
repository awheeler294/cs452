DROP FUNCTION find_all_ancestor_f( CHARACTER VARYING );
CREATE OR REPLACE FUNCTION find_all_ancestor_f(seed_person_id VARCHAR(10))
  RETURNS TABLE(ancestor_id VARCHAR(10), level INTEGER)
AS $$  -- PostgreSQL requires the function body to be a quoted string
-- but to avoid quote confusion allows the 'double dollar' notation
DECLARE loop_counter INTEGER := 1;
BEGIN
  --
  -- create local tables
  --
  CREATE TABLE res_table (
    person_id VARCHAR(10) UNIQUE,
    level     INTEGER
  ); -- accumulates the prerequisites
  CREATE TABLE itr_table (LIKE res_table INCLUDING ALL
  ); -- the prerequisites for the current iteration
  CREATE TABLE tmp_table (LIKE res_table INCLUDING ALL
  ); -- used to temporarily hold prerequisites
  --
  -- initialize iteration table with prerequisites of seed_course_id
  --
  INSERT INTO itr_table
    SELECT parent_child.parent_id
    FROM parent_child_db.parent_child
    WHERE parent_child.child_id = seed_person_id;
  --
  -- main loop
  -- repeat until no more prerequisites are added to the result table
  --
  LOOP
    --
    -- this accumulates tuples (prerequisites to be returned)
    --
    INSERT INTO res_table
      SELECT
        itr_table.person_id,
        loop_counter
      FROM itr_table;
    --
    -- clear out the temporary table
    -- then load it with the prerequisites of the courses in the iteration table, but don't select
    -- any courses that are already in the result table (using the 'except' condition)
    --
    DELETE FROM tmp_table;
    INSERT INTO tmp_table
      (
        SELECT parent_child.parent_id
        FROM itr_table, parent_child_db.parent_child
        WHERE itr_table.person_id = parent_child.child_id
      )
      EXCEPT
      (
        SELECT res_table.person_id
        FROM res_table
      );
    --
    -- clear out the iteration table
    -- and copy the temporary table tuples into the iteration table
    --
    DELETE FROM itr_table;
    INSERT INTO itr_table
      SELECT tmp_table.person_id
      FROM tmp_table;
    --
    -- exit when no new prerequisites were selected
    --
    loop_counter := loop_counter + 1;
    EXIT WHEN NOT exists(SELECT *
                         FROM itr_table);
  END LOOP;
  --
  -- selects tuples to be returned, but does not exit the function
  --
  RETURN QUERY SELECT
                 res_table.person_id,
                 res_table.level
               FROM res_table;
  --
  -- clean up the local tables
  --
  DROP TABLE res_table;
  DROP TABLE itr_table;
  DROP TABLE tmp_table;
  --
  -- exit the function
  --
  RETURN;
END
$$ LANGUAGE plpgsql        -- using the PostgreSQL Procedural language (PL/PSQL)
RETURNS NULL ON NULL INPUT; -- returns null if any input parameter is null

SELECT *
FROM find_all_ancestor_f('LFDN-3NN')
WHERE level = 15;

SELECT *
FROM find_all_ancestor_f('LFDN-3X3')
ORDER BY level DESC;

SELECT count(*)
FROM find_all_ancestor_f('LFDN-3NN') a
  INNER JOIN id_gender ON id_gender.person_id = a.ancestor_id
WHERE id_gender.gender = 'f' AND level = 15;

WITH ancestor_count AS (
    SELECT
      count(ancestor_id) AS count,
      level
    FROM find_all_ancestor_f('LFDN-3X3')
    GROUP BY level
),
    max_ancestor_count AS (
      SELECT MAX(ancestor_count.count) AS max
      FROM ancestor_count
  )
SELECT level
FROM ancestor_count
WHERE count = (SELECT max
               FROM max_ancestor_count);