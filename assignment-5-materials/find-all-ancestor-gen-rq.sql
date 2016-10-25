WITH RECURSIVE ancestor(ancestor_id, gen, path) AS (
  SELECT DISTINCT
    PC.parent_id,
    2,
    cast(ARRAY [] AS VARCHAR(10) []) || PC.parent_id
  FROM parent_child PC
  WHERE PC.child_id = 'LFDN-3X3'
  UNION
  SELECT DISTINCT
    PC.parent_id,
    A.gen + 1,
    A.path || PC.parent_id
  FROM ancestor A
    JOIN parent_child PC ON A.ancestor_id = PC.child_id
  WHERE (PC.parent_id IS NOT NULL) AND (PC.parent_id != ALL (path))
)
SELECT DISTINCT
  A.ancestor_id,
  A.gen
FROM ancestor A;



WITH RECURSIVE ancestor(ancestor_id, gen, path) AS (
  SELECT DISTINCT
    PC.parent_id,
    2,
    cast(ARRAY [] AS VARCHAR(10) []) || PC.parent_id
  FROM parent_child PC
  WHERE PC.child_id = 'LFDN-3NN'
  UNION
  SELECT DISTINCT
    PC.parent_id,
    A.gen + 1,
    A.path || PC.parent_id
  FROM ancestor A
    JOIN parent_child PC ON A.ancestor_id = PC.child_id
  WHERE (PC.parent_id IS NOT NULL) AND (PC.parent_id != ALL (path))
)
SELECT
  A.ancestor_id,
  A.gen
FROM ancestor A;