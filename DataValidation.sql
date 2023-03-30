
use university; 
select 'Advisor' as `Table`, count(*) as Records from advisor
union
select 'Classroom' as `Table`, count(*) as Records from classroom
union
select 'Course' as `Table`, count(*) as Records from course
union
select 'Department' as `Table`, count(*) as Records from department
union
select 'Instructor' as `Table`, count(*) as Records from Instructor
union
select 'Prereq' as `Table`, count(*) as Records from prereq
union
select 'Section' as `Table`, count(*) as Records from Section
union
select 'Student' as `Table`, count(*) as Records from Student
union
select 'Takes' as `Table`, count(*) as Records from takes
union
select 'teaches' as `Table`, count(*) as Records from teaches
union
select 'Time_Slot' as `Table`, count(*) as Records from time_slot;