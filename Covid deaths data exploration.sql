select * from CovidDeaths;

--1.select locations and their number of cases and numbe rof deaths
select iso_code,location,date,total_cases,new_cases,total_deaths,population from CovidDeaths order by 1,3;

--2. select the sum of cases by country for the year of 2020
select iso_code,location,sum(total_cases) as'Total Cases' from CovidDeaths where YEAR(date)='2020' 
group by iso_code,location order by sum(total_cases) desc;
--3.GTotal deaths vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'Percentage DeathsToCases' from CovidDeaths

order by location,date
;

select count(*) from CovidDeaths;


--4.Deaths and cases in China

select distinct location from CovidDeaths WHERE continent='Asia' group by location;

select location,date,total_cases,total_deaths from CovidDeaths
where location like 'China'
order by location,date;

select distinct continent from CovidDeaths;
--5.Deaths in India
select location,date,total_cases,total_deaths from CovidDeaths where iso_code='IND' order by 2;


--6. Deaths in United States

select location,date,total_cases,total_deaths,(total_deaths/total_cases)  from CovidDeaths
where location like '%states%' or iso_code like 'USA' order by 2;
;

select date,new_cases,(total_deaths/total_cases) as 'Deaths to Cases Ratio' 
from CovidDeaths where iso_code='USA' order by 1 asc ,3 desc;

--Looking at countries with highest infection rate
select location,max(total_cases) as 'Highest Infection Count',max(total_cases/population)*100  as 'Infection Rate' from CovidDeaths
where date between '2020-01-01' AND '2020-12-31'
group by location
order  by location

;
--Death Rate
--Removed the following values because they are not represntative of the countries

select location,max(cast(total_deaths as int)) as HighestDeathCount,max(total_deaths/population)*100 as 'Death Rate' from CovidDeaths
where location not in ('Africa','Asia','Europe','Oceania','North America','South America','World') and location is not null
group by location
order by location,HighestDeathCount

;


--



select date from CovidDeaths

select location from CovidDeaths where location='World' ;
select distinct continent from CovidDeaths;
select distinct location from CovidDeaths order by location;

--filter death counts by continent

select location,max(cast(total_deaths as int)) as HighestDeathCount from CovidDeaths where continent is null
and location not in ('Upper middle income','Lower middle income','High income','Low income','European Union')
group by location
order by HighestDeathCount desc
;
--Check that the death count in USA should not match that of North America
 select location,max(cast(total_deaths as int)) as HighestDeathCount
 from CovidDeaths
 where location='United States'
 group by location
 ;

 --death rates per million for different countries for 2020
 select location,sum(cast(total_deaths_per_million as numeric)) as DeathsPerMillion from CovidDeaths
 group by location
 order by location
 ;

 --world death rates by continent
 select continent,sum(cast(total_deaths_per_million as numeric)) as DeathsPerMillion from CovidDeaths 
 where continent is not null
 group by continent
 order by DeathsPerMillion desc
 ;
 --country wise reproduction rate of virus

 select location,avg(cast(reproduction_rate as float)) as ReproductionRate from CovidDeaths
 group by location
 order by ReproductionRate desc
 ;

 ---Covid Vaccinations
select * from CovidVaccinations;
select * from CovidVaccinations a join CovidDeaths b on
a.location=b.location
AND
a.date=b.date;

--Looking at total populations vs vaccinations
select a.location,a.population,sum(cast(b.total_vaccinations as bigint)) as TotalVaccinations from CovidDeaths a inner join CovidVaccinations b on
a.location=b.location and a.date=b.date
group by a.location,a.population
order by location,TotalVaccinations desc
;

select sum(cast(new_vaccinations as numeric)) from CovidVaccinations where
location='Albania';

select date,sum(CONVERT(int,new_vaccinations)) 
from CovidVaccinations where location='Albania'
group by date
order by date
;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProj..CovidDeaths dea
Join PortfolioProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location='Albania'
order by 2,3;


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea Join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location='Albania'
order by dea.location,dea.date
;

select location,date,count(CONVERT(bigint,CovidVaccinations.new_vaccinations)) from CovidVaccinations
where location='Albania'
group by location,date
order by date
;

--create a temp table using
--Common Table Expression


With CTEVaccinations (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as

(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.date) 
as RollingPeopleVaccinated from
CovidDeaths dea
Join
CovidVaccinations vac
on
dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and dea.location='Albania'
)
Select *, (RollingPeopleVaccinated/Population)*100
From CTEVaccinations

--VIEWS
--Cases,Deaths,Rates,Vaccinations in India
CREATE View CovidStatsIndia as 
(select dea.date,dea.population,dea.total_cases,dea.new_cases,
vac.new_vaccinations,vac.total_vaccinations from CovidDeaths dea join 
CovidVaccinations vac on
dea.location=vac.location

where dea.location='India'
--order by dea.date
)
select * from CovidStatsIndia;
drop view CovidStatsIndia;

--select * from CovidVaccinations;
--select CovidDeaths.population,total_tests,CovidDeaths.population,total_tests_per_thousand from 
--CovidVaccinations,CovidDeaths where CovidDeaths.location='India';
--select population from CovidDeaths where location='India';

select * from CovidDeaths where location='India';

select CovidDeaths.location,CovidVaccinations.date,
CovidVaccinations.total_vaccinations,CovidDeaths.population,
sum(total_vaccinations/population)*100 as 'PercentagePopVaccinated'  
from CovidDeaths,CovidVaccinations where 
CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date
and
CovidDeaths.location='India'
group by CovidDeaths.location,CovidVaccinations.date
order by CovidDeaths.date,CovidVaccinations.total_vaccinations
;
