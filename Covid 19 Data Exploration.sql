/*

Covid 19 Data Exploration 
Skills used: Joins, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types

*/

Select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2


---Total Cases Vs Total Deaths for United States and India

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location in ('united states', 'india')
and continent is not null
order by 1,2


---Total Cases Vs Population for North America

Select Continent, location, date, total_cases, population, (total_cases/population)*100 As InfectedPopulationpercentage
from Coviddeaths
where continent ='North America'
order by location, date

---Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount ,max((total_cases/population)*100) as PercentagePopulationInfected
from CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

---List Countries and Total death Count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc


---List continent and total death count for each

--using Temp Table

drop table if exists #continent_death
create table #continent_death 
(
Continent varchar (100),
location varchar(100),
TotalDeathCount numeric
)

insert into #continent_death
select continent ,location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent, location
order by continent,TotalDeathCount desc

select *  from #continent_death
order by Continent, TotalDeathCount desc


select continent, sum(totaldeathcount) as TotalDeaths
from #continent_death
group by Continent
order by TotalDeaths desc
 
 ----Global Numbers - total cases, total deaths, case to death percentage

 select sum(new_cases) as totalcases, sum(convert(int,new_deaths)) as totaldeaths,(sum(convert(int,new_deaths)) /sum(new_cases) )*100 as DeathPercentage
 from coviddeaths
 order by deathpercentage desc


 ---Percentage of Population that has recieved at least one Covid Vaccine

 --Using Joins, Partition By,CTE

 select CD.continent, CD.location , CD.date, CD.population, CV.new_vaccinations,
  SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location) as RollingPeopleVaccinated
  from CovidDeaths CD
 join CovidVaccinations CV
 on CD.location = CV.location
 and CD.date=CV.date
 where CD.continent is not null
 ----group by cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
 order by 1,2,3 desc

 ----CTE 

 With PopVsVac (continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
  as
  (select CD.continent, CD.location , CD.date, CD.population, CV.new_vaccinations,
  SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location) as RollingPeopleVaccinated
  from CovidDeaths CD
 join CovidVaccinations CV
 on CD.location = CV.location
 and CD.date=CV.date
 where CD.continent is not null
 )
 Select *, (RollingPeopleVaccinated/Population)*100 as PercentageofPeopleVaccinated
From PopvsVac


----Creating View

  
Create View PeopleVaccinated as

select CD.continent, CD.location , CD.date, CD.population, CV.new_vaccinations,
  SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location) as RollingPeopleVaccinated
  from CovidDeaths CD
 join CovidVaccinations CV
 on CD.location = CV.location
 and CD.date=CV.date
 where CD.continent is not null
