CREATE OR REPLACE FUNCTION find_all_ancestor_rc(seed_person_id VARCHAR(10))
  RETURNS TABLE(ancestor_id VARCHAR(10))
AS $$  -- PostgreSQL requires the function body to be a quoted string
-- but to avoid quote confusion allows the 'double dollar' notation
BEGIN
  RETURN QUERY

  (WITH RECURSIVE ancestor(person_id) AS (
    SELECT CS.parent_id
    FROM parent_child_db.parent_child CS
    WHERE child_id = 'LFDN-3NN'
    UNION
    SELECT CS.parent_id
    FROM ancestor, parent_child_db.parent_child CS
    WHERE ancestor.person_id = CS.child_id
  )
   SELECT person_id
   FROM ancestor
  );

RETURN;
END
$$ LANGUAGE plpgsql        -- using the PostgreSQL Procedural language (PL/PSQL)
RETURNS NULL ON NULL INPUT; -- returns null if any input parameter is null