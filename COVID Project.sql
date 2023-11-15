select *
from [COVIDProject]..CovidDeaths
where location like 'High Income'
order by 3,4

--select *
--from [COVIDProject]..CovidVaccinations
--order by 3,41

-- Select data to be used

select location, date, total_cases, new_cases, total_deaths, population
from [COVIDProject]..CovidDeaths
order by 1,2

--Convert Total Cases & Total Deaths to FLOAT
ALTER TABLE COVIDProject.dbo.CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE COVIDProject.dbo.CovidDeaths
ALTER COLUMN total_cases FLOAT;

--Total Cases vs Total Deaths, by country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
from [COVIDProject]..CovidDeaths
where location like '%brazil%'
order by 1,2

--Total Cases vs Population
select location, date, total_cases, population, (total_cases/population) * 100 AS InfectedPercentage
from [COVIDProject]..CovidDeaths
order by 1,2

--Highest Infection rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 AS InfectedPercentage
from [COVIDProject]..CovidDeaths
GROUP BY Location, Population
order by InfectedPercentage desc;

--Highest Death Count per Population
select location, MAX(total_deaths) as TotalDeathCount
from [COVIDProject]..CovidDeaths
where continent is not null
GROUP BY Location
order by TotalDeathCount desc;

--Continents with the highest death count per pop

select location, MAX(total_deaths) as TotalDeathCount
from [COVIDProject]..CovidDeaths
where continent is null
GROUP BY location
order by TotalDeathCount desc;

--Global Numbers
select date, SUM(new_cases) as 'New Cases', SUM(new_deaths) as 'New Deaths', 
	CASE WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)/SUM(new_cases)*100 
	ELSE NULL
	END as DeathPercentage
from [COVIDProject]..CovidDeaths
where continent is not null
Group by date
order by 1,2

--Total Population vs Vaccinations

--CTE
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RolllingPeopleVaccinated
from [COVIDProject]..CovidDeaths dea
join [COVIDProject]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from PopvsVac

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RolllingPeopleVaccinated
from [COVIDProject]..CovidDeaths dea
join [COVIDProject]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RolllingPeopleVaccinated
from [COVIDProject]..CovidDeaths dea
join [COVIDProject]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from PopvsVac

select *
from COVIDProject..PercentPopulationVaccinated
