with recursive ancestor(ancestor_id, gen, path) as (
        select distinct PC.parent_id, 2, cast(ARRAY[] as varchar(10)[]) || PC.parent_id
        from parent_child PC
        where PC.child_id = 'LFDN-3X3'
    union
        select distinct PC.parent_id, A.gen + 1, A.path || PC.parent_id
        from ancestor A join parent_child PC on A.ancestor_id = PC.child_id
        where (PC.parent_id is not null) and (PC.parent_id != ALL(path))
    )
select distinct A.ancestor_id, A.gen from ancestor A;