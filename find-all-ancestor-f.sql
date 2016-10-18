create or replace function find_all_ancestor_f(seed_person_id varchar(10))
  returns table(ancestor_id varchar(10))
as $$	-- PostgreSQL requires the function body to be a quoted string
-- but to avoid quote confusion allows the 'double dollar' notation
begin
  --
  -- create local tables
  --
  create table res_table(person_id varchar(10) unique);   -- accumulates the prerequisites
  create table itr_table(like res_table including all);   -- the prerequisites for the current iteration
  create table tmp_table(like res_table including all);   -- used to temporarily hold prerequisites
  --
  -- initialize iteration table with prerequisites of seed_course_id
  --
  insert into itr_table
    select parent_child.parent_id
    from parent_child_db.parent_child
    where parent_child.child_id = seed_person_id;
  --
  -- main loop
  -- repeat until no more prerequisites are added to the result table
  --
  loop
    --
    -- this accumulates tuples (prerequisites to be returned)
    --
    insert into res_table
      select itr_table.person_id
      from itr_table;
    --
    -- clear out the temporary table
    -- then load it with the prerequisites of the courses in the iteration table, but don't select
    -- any courses that are already in the result table (using the 'except' condition)
    --
    delete from tmp_table;
    insert into tmp_table
      (
        select parent_child.parent_id
        from itr_table, parent_child_db.parent_child
        where itr_table.person_id = parent_child.child_id
      )
      except
      (
        select res_table.person_id
        from res_table
      );
    --
    -- clear out the iteration table
    -- and copy the temporary table tuples into the iteration table
    --
    delete from itr_table;
    insert into itr_table
      select tmp_table.person_id
      from tmp_table;
    --
    -- exit when no new prerequisites were selected
    --
    exit when not exists (select * from itr_table);
  end loop;
  --
  -- selects tuples to be returned, but does not exit the function
  --
  return query select res_table.person_id from res_table;
  --
  -- clean up the local tables
  --
  drop table res_table;
  drop table itr_table;
  drop table tmp_table;
  --
  -- exit the function
  --
  return;
end
$$ language plpgsql		    -- using the PostgreSQL Procedural language (PL/PSQL)
returns null on null input;	-- returns null if any input parameter is null