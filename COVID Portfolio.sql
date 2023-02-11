select *
from PortfolioProject_1..CovidDeaths

--select *
--from PortfolioProject_1..CovidVac

-- Select Data
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject_1..CovidDeaths
order by 1, 2


-- Total cases vs Total deaths
-- Likelihood of death if COVID is contracted in Nigeria (or any other selected country)
select location, date, total_cases, total_deaths, 
		(total_deaths*1.0/total_cases)*100 as death_perc
from PortfolioProject_1..CovidDeaths
where location not in ('Africa', 'Asia', 'Europe', 'North America', 'South America') and location = 'Nigeria'
order by location

-- Total cases vs Population
-- What percentage of population got COVID?
select location, date, population, total_cases, 
		(total_cases*1.0/population)*100 as cases_percentage
from PortfolioProject_1..CovidDeaths
where location not in ('Africa', 'Asia', 'Europe', 'North America', 'South America') and location = 'Israel'
order by 1, 2

-- Countries with the highest infection rate
select location, population, max(total_cases) as HighestInfetionCount, 
		max((total_cases*1.0/population))*100 as HighestInfectionPercentage
from PortfolioProject_1..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

-- Countries with the highest death rate
select location, max(total_deaths) as HighestDeathCount 
from PortfolioProject_1..CovidDeaths
where continent is not null
group by location
order by 2 desc

-- CONTINENTAL NUMBERS

-- Continents with the highest death rate
select continent, max(total_deaths) as HighestDeathCount 
from PortfolioProject_1..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Continents with the highest case counts
select continent, max(total_cases) as HighestCaseCount 
from PortfolioProject_1..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Total cases vs Total deaths
-- Likelihood of death if COVID is contracted in Africa
select continent, date, total_cases, total_deaths, 
		(total_deaths*1.0/total_cases)*100 as death_perc
from PortfolioProject_1..CovidDeaths
where continent is not null
order by location desc

-- Total cases vs Population
-- What percentage of population got COVID?
select continent, date, population, total_cases, 
		(total_cases*1.0/population)*100 as cases_percentage
from PortfolioProject_1..CovidDeaths
where continent is not null
order by 1, 2

-- Countries with the highest infection rate
select continent, population, max(total_cases) as HighestInfetionCount, 
		max((total_cases*1.0/population))*100 as HighestInfectionPercentage
from PortfolioProject_1..CovidDeaths
where continent is not null
group by continent, population
order by 4 desc

-- GLOBAL NUMBERS

-- Total cases vs Total deaths
-- Percentage of deaths in each day
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
			(sum(new_deaths)*1.0/sum(new_cases))*100 as DeathPercentage
from PortfolioProject_1..CovidDeaths
where continent is not null
group by date
order by 1, 2 desc

-- Total Percentage of Deaths
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
			(sum(new_deaths)*1.0/sum(new_cases))*100 as DeathPercentage
from PortfolioProject_1..CovidDeaths
where continent is not null


-- JOIN THE DEATH AND VACCINATION TABLES
select dth.continent, dth.date, dth.location, dth.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProject_1..CovidDeaths dth
join PortfolioProject_1..CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 3, 2

-- CTE to calculate the rate of vaccination

with PopvsVac (Continent, Location, date, Population, NewVaccinations, RollingPeopleVaccinated)
as 
(
select dth.continent, dth.date, dth.location, dth.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProject_1..CovidDeaths dth
join PortfolioProject_1..CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 3, 2
)
select *, (RollingPeopleVaccinated*1.0/Population)*100
from PopvsVac


--Using TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
date datetime,
location nvarchar(255),
population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dth.continent, dth.date, dth.location, dth.population, vac.new_vaccinations,
		sum(new_vaccinations) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProject_1..CovidDeaths dth
join PortfolioProject_1..CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 3, 2

select *, (RollingPeopleVaccinated*1.0/population)*100
from #PercentPopulationVaccinated


-- Create View To store data for later visualizations
create view PercentPopVaccinated as
select dth.continent, dth.date, dth.location, dth.population, vac.new_vaccinations,
		sum(new_vaccinations) over (partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from PortfolioProject_1..CovidDeaths dth
join PortfolioProject_1..CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 3, 2