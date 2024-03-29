create table if not exists byu_cs_course(
	course_id varchar(10) not null,
	prereq_id varchar(10));
	
delete from byu_cs_course;

insert into byu_cs_course values
	('CS-100',null),
	('CS-142',null),
	('CS-201R','CS-142'),
	('CS-224','CS-142'),
	('CS-235','CS-142'),
	('CS-236','CS-235'),
	('CS-240','CS-236'),
	('CS-252','CS-236'),
	('CS-256','CS-142'),
	('CS-312','CS-240'),
	('CS-330','CS-240'),
	('CS-340','CS-240'),
	('CS-345','CS-240'),
	('CS-355','CS-240'),
	('CS-360','CS-240'),
	('CS-404','ENGL-316'),
	('CS-405','ENGL-316'),
	('CS-418','CS-240'),
	('CS-450','CS-312'),
	('CS-452','CS-240'),
	('CS-455','CS-355'),
	('CS-465','CS-360'),
	('CS-470','CS-312'),
	('CS-478','CS-312'),
	('CS-484','CS-360'),
	('CS-498R','CS-240'),
	('CS-513','CS-313'),
	('CS-557','CS-240'),
	('CS-611','CS-252'),
	('CS-650','CS-450'),
	('CS-653','CS-236');