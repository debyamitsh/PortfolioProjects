/*
CovidDeaths
*/

select *
from CovidDeaths
where continent is not null
order by 3,4


--Select data we need

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
-- show the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from CovidDeaths
where continent is not null and location like 'Democratic%'
order by 1,2


--Looking at Total Cases Vs Population
--shows percentage of population got covid

select location, date, total_cases, total_deaths, (total_cases/ population)* 100 as InfectionPercentage
from CovidDeaths
where continent is not null
--where location like 'Democratic%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as InfectionPercentage
from CovidDeaths
where continent is not null
--where location like 'Democratic%'
group by location, population
order by InfectionPercentage desc


----Looking at countries with Highest Death Rate compared to population

select location, population, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population))* 100 as PercentagePopulationDeath
from CovidDeaths
where continent is not null
--where location like 'Democratic%'
group by location, population
order by HighestDeathCount desc

-- BREAK DOWN BY CONTINENT
/*
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
--where location like 'Democratic%'
group by continent
order by TotalDeathCount desc
*/

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
--where location like 'Democratic%'
group by continent
order by TotalDeathCount desc

--Show continent with the highest death rate compare to population

select continent, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population))* 100 as PercentagePopulationDeath
from CovidDeaths
where continent is not null
--where location like 'Democratic%'
group by continent
order by HighestDeathCount desc


--GLOBAL NUMBERS

select date,sum(new_cases) totalNewCases, sum(cast(new_deaths as int)) totalNewDeaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercentage 
from CovidDeaths
where continent is not null --and location like 'Democratic%'
group by date
order by 1,2

select sum(new_cases) totalNewCases, sum(cast(new_deaths as int)) totalNewDeaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercentage 
from CovidDeaths
where continent is not null --and location like 'Democratic%'
--group by date
order by 1,2


/*
CovidVaccinations
*/

select *
from CovidVaccinations

select * 
from CovidDeaths dea
join CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from CovidDeaths dea
join CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null )
select *, (RollingPeopleVaccinated / Population) * 100
from PopvsVac


-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated


--Creating View to store data for visualizatiom

create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated