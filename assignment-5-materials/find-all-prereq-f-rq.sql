create or replace function find_all_prereq_rc(seed_course_id varchar(10))
returns table(course_id varchar(10))
as $$	-- PostgreSQL requires the function body to be a quoted string
        -- but to avoid quote confusion allows the 'double dollar' notation
begin
	return query
	
	(with recursive prereq(prereq_id) as (
        select CS.prereq_id
		from byu_cs_course CS
        where CS.course_id = seed_course_id
    union
        select CS.prereq_id
        from prereq PR, byu_cs_course CS
        where PR.prereq_id = CS.course_id and
		      CS.prereq_id is not null
    )
	select prereq.prereq_id from prereq);

    return;
end
$$ language plpgsql		    -- using the PostgreSQL Procedural language (PL/PSQL)
returns null on null input;	-- returns null if any input parameter is null