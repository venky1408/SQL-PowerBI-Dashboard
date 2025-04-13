-- Data Cleaning

create table layoffs_stage like layoffs_table;

select * from layoffs_stage;
insert layoffs_stage
select * from layoffs_table;

-- Standarized Data

select company, trim(company)
from layoffs_stage;
update layoffs_stage
set company = trim(company);

select distinct industry from layoffs_stage 
order by 1;
update layoffs_stage
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country, trim(trailing '.' from country)
from layoffs_stage order by 1;

update layoffs_stage set country = trim(trailing '.' from country)
where country like 'United States%';

select date, str_to_date(date,'%m/%d/%Y') from layoffs_stage
order by 1;
update layoffs_stage set date = str_to_date(date,'%m/%d/%Y');
select * from layoffs_stage;
alter table layoffs_stage
modify column date date;

-- remove or replace empty

select company,industry from layoffs_stage order by industry;

select * from layoffs_stage
where company like "Airbnb";

update layoffs_stage set industry = 'Travel'
where industry is null and company = 'Airbnb';

update layoffs_stage set industry = null
where industry = '';

select * from layoffs_stage;


-- delete rows or columns

delete from layoffs_stage
where total_laid_off is null and
percentage_laid_off is null;

select * from layoffs_stage
where total_laid_off is null and
percentage_laid_off is null;

select * from layoffs_stage;


-- Expolatry Data Analysis (EDA)

-- Maximum laid_off in one Day

select max(total_laid_off) from layoffs_stage ;

select * from layoffs_stage where percentage_laid_off = 1 
order by funds_raised_millions desc;
select * from layoffs_stage where percentage_laid_off = 1 
order by total_laid_off desc;


select min(date), max(date) from layoffs_stage;

-- Total laid-off by Company

select company, sum(total_laid_off) 
from layoffs_stage group by company order by 2 desc;

-- Total laid-off by Industry

select industry, sum(total_laid_off)
from layoffs_stage group by industry order by 2 desc;

-- Total Laid_off by Country

select country, sum(total_laid_off)
from layoffs_stage group by country order by 2 desc;

-- Total laid-off by years

select year(date), sum(total_laid_off)
from layoffs_stage group by  year(date) order by 2 desc;

select stage, sum(total_laid_off)
from layoffs_stage group by stage order by 2 desc;

select substring(date,1,7) as month, sum(total_laid_off)
from layoffs_stage
where substring(date,1,7) is not null 
group by month order by sum(total_laid_off) desc ;

-- Total laid_off by each month

select substring(date,1,7) as month, sum(total_laid_off) as total_off
from layoffs_stage
where substring(date,1,7) is not null 
group by month order by month ;

-- Total Rolling

with Rolling_Total as 
(select substring(date,1,7) as month, sum(total_laid_off) as total_off
from layoffs_stage
where substring(date,1,7) is not null 
group by month order by month)
select month,total_off, sum(total_off) over(order by month) as rolling
from Rolling_Total;


-- Top 5 companies maximum laid_off rankings in each year 

with rank_over as
(with company_year(company, years, total_laid_off) as
(select company, year(date), sum(total_laid_off) as total_off
from layoffs_stage group by company, year(date) order by total_off desc)
select * from company_year), 
ranking_over as
(select *,dense_rank() over(partition by years order by total_laid_off desc)
as ranking 
from rank_over where years is not null)
select * from ranking_over where ranking <= 5;


-- Top 5 industries maximum laid_off rankings in each year 

with rank_over as
(with industry_year(industry, years, total_laid_off) as
(select industry, year(date), sum(total_laid_off) as total_off
from layoffs_stage group by industry, year(date) order by total_off desc)
select * from industry_year), 
ranking_over as
(select *,dense_rank() over(partition by years order by total_laid_off desc)
as ranking 
from rank_over where years is not null)
select * from ranking_over where ranking <= 5;

-- create view top Industries

create view top_industry_layoffs as
with rank_over as
(with industry_year(industry, years, total_laid_off) as
(select industry, year(date), sum(total_laid_off) as total_off
from layoffs_stage group by industry, year(date) order by total_off desc)
select * from industry_year), 
ranking_over as
(select *,dense_rank() over(partition by years order by total_laid_off desc)
as ranking 
from rank_over where years is not null)
select * from ranking_over where ranking <= 5;

-- create view top companies

create view top_company_layoffs as
with rank_over as
(with company_year(company, years, total_laid_off) as
(select company, year(date), sum(total_laid_off) as total_off
from layoffs_stage group by company, year(date) order by total_off desc)
select * from company_year), 
ranking_over as
(select *,dense_rank() over(partition by years order by total_laid_off desc)
as ranking 
from rank_over where years is not null)
select * from ranking_over where ranking <= 5;

drop view top_company_layoffs;





















