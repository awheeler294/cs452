with recursive prereq(prereq_id) as (
        select CS.prereq_id from byu_cs_course CS
        where course_id = 'CS-650'
    union
        select CS.prereq_id
        from prereq, byu_cs_course CS
        where prereq.prereq_id = CS.course_id and CS.prereq_id is not null
    )
select prereq_id from prereq;