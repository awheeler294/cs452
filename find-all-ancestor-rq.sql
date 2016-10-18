with recursive ancestor(ancestor_id) as (
        select CS.parent_id from parent_child_db.parent_child CS
        where child_id = 'LFDN-3X3'
    union
        select CS.parent_id
        from ancestor, parent_child_db.parent_child CS
        where ancestor.ancestor_id = CS.child_id
    )
select ancestor_id from ancestor;