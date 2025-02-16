select * from hr_data

select termdate from hr_data
order by termdate desc

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME,LEFT(termdate, 19),120), 'yyyy-mm-dd')

ALTER TABLE hr_data
ADD new_termdate DATE

--COPYING CONVERTED TIME VALUES FROM TERMDATE TO NEW_TERMDATE , #ISDATE (TERMDATE)=1 MEANS DATA IS ABLE TO  BE CONVERTED TO THE DATE FORMAT

UPDATE hr_data
SET new_termdate = CASE WHEN termdate IS NOT NULL AND  ISDATE(termdate) = 1 THEN CAST(termdate AS DATETIME)
                   ELSE NULL END


-- CREATING A NEW COLUMN 'AGE'
ALTER TABLE hr_data
ADD age nvarchar(50) 

--populating new column with age
UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT age from hr_data

--Questions to answer from the data

--1) What's the age distribution in the company? 

-- age distribution

select min(age) as youngest, MAX(age) as oldest from hr_data

select age_group, count(*) as count
from (select CASE WHEN age between 23 and 30 then '23 to 30'
                  WHEN age between 31 and 40 then '31 to 40'
			      WHEN age between 41 and 50 then '41 to 50'
			      ELSE '50+' END AS age_group from hr_data where new_termdate is null) as subquery
group by age_group
order by age_group

-- age group by gender
select * from hr_data
select age_group, gender,count(*) as cnt
from (select CASE WHEN age between 23 and 30 then '23 to 30'
                  WHEN age between 31 and 40 then '31 to 40'
			      WHEN age between 41 and 50 then '41 to 50'
			      ELSE '50+' END AS age_group, gender from hr_data where new_termdate is null) as subquery
group by age_group, gender
order by age_group, gender

use HR
SELECT 
    age_group,
    gender,age,
    COUNT(*) AS cnt
FROM (
    SELECT 
        CASE 
            WHEN age BETWEEN 23 AND 30 THEN '23 to 30'
            WHEN age BETWEEN 31 AND 40 THEN '31 to 40'
            WHEN age BETWEEN 41 AND 50 THEN '41 to 50'
            ELSE '50+' 
        END AS age_group,
        CASE 
            WHEN age BETWEEN 23 AND 30 THEN 1
            WHEN age BETWEEN 31 AND 40 THEN 2
            WHEN age BETWEEN 41 AND 50 THEN 3
            ELSE 4 
        END AS age) as subquery


--2) What is the gender breakdown in the company?
select gender , count(gender) as count from hr_data
group by gender
order by count asc

--3) How does gender vary across departments and job titles?
-- departments
select department, gender, count(gender) as count_of_gender
from hr_data
group by department, gender 
order by count_of_gender desc
select * from hr_data 
select department, gender ,jobtitle ,count (gender) as count
from hr_data
where new_termdate is null
group by department, gender,jobtitle
order by department, gender,jobtitle asc

--4) What is the the race distribution in the company?
select race, count(race) as count from hr_data
where new_termdate is null
group by race
order by count desc 

--5)What's the average length of employment in the company?
select avg( DATEDIFF(year, hire_date,new_termdate)) as avg_length_employment
from hr_data
where new_termdate is not null and new_termdate <= GETDATE();

--6) Which department has the highest turnover rate?

select * from hr_data
select department,
	( ROUND( (CAST(terminated_count AS FLOAT)/total_count), 2))*100 as turnover_rate
       
from
		(select department, count(*) as total_count , 
		sum(CASE WHEN new_termdate is not null and new_termdate <= Getdate() THEN 1 ELSE 0 END )AS terminated_count
		from hr_data
		group by department )as subquery
order by turnover_rate DESC


--7) What is the average of length of employment distribution for each department?

select department, avg( DATEDIFF(year, hire_date,new_termdate)) as avg_length_employment
from hr_data
where new_termdate is not null and new_termdate <= GETDATE()
group by department
order by avg_length_employment desc

--8) How many employees work remotely ?
use HR
select location, count(*) as employee_number 
from hr_data
where new_termdate is null
group by location

--9) What is the distribution of employees across different states?
select location_state , count(*) as number_employee
from hr_data
where new_termdate is null
group by location_state
order by number_employee desc

--10) How are the job titles distributed in the company?
 
 select jobtitle, count(*) as number_employee
 from hr_data
 where new_termdate is null
 group by jobtitle
 order by number_employee desc

 -- 11) How have employee hire counts varied over time?
 -- calculate hires
 -- calculate terminations
 -- (hire-terminations)/hires percent hire change
 use HR
  SELECT  hire_year, hires,terminations,hires-terminations as net_change,ROUND(CAST(hires-terminations AS FLOAT)/hires, 2)*100 as percent_hire_change
  FROM (select year(hire_date) as hire_year, count(*) as hires,
  SUM(CASE WHEN new_termdate is not null and new_termdate<=  GETDATE() THEN 1 
      ELSE 0 END) AS terminations
  from hr_data
  Group by year(hire_date)) as  subquery

  select * from hr_data 
select department, gender,count (gender) as count
from hr_data
where new_termdate is null
group by gender, department
order by count asc