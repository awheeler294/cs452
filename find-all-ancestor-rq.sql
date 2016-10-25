with recursive ancestor(ancestor_id) as (
        select CS.parent_id from parent_child_db.parent_child CS
        where child_id = 'LFDN-3X3'
    union
        select CS.parent_id
        from ancestor, parent_child_db.parent_child CS
        where ancestor.ancestor_id = CS.child_id
    )
select ancestor_id from ancestor;

with recursive ancestor(ancestor_id) as (
  select CS.parent_id from parent_child_db.parent_child CS
  where child_id = 'LFDN-3NN'
  union
  select CS.parent_id
  from ancestor, parent_child_db.parent_child CS
  where ancestor.ancestor_id = CS.child_id
)
select ancestor_id from ancestor;

SET SEARCH_PATH = parent_child_db;
CREATE OR REPLACE VIEW descendant(A, D, L) AS (
  WITH RECURSIVE r_descendant(ancestor_id, desc_id, level) AS (
    SELECT
      parent_id,
      child_id,
      1 AS level
    FROM parent_child
    UNION
    SELECT
      parent_child.parent_id,
      r_descendant.desc_id,
      level + 1
    FROM parent_child, r_descendant
    WHERE parent_child.child_id = r_descendant.ancestor_id
  )
  SELECT
    ancestor_id AS A,
    desc_id     AS D,
    level       AS L
  FROM r_descendant
);

SELECT *
FROM descendant
WHERE A = 'LFDN-3NN'
AND L = 15;