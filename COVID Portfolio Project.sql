--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeath
order by 1,2

--looking at total cases vs total deaths
--show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeath
WHERE location like '%states%'
order by 1,2

--looking at total case vs population - percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
order by 1,2

--lookgin at countries with highest infecttion rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
group by location, population
order by PercentPopulationInfected desc

ALTER TABLE PortfolioProject.dbo.CovidDeath ALTER COLUMN x nvarchar(255)

--showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Break things down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--showing continent with the highest death count per population 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeath
--WHERE location like '%states%'
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccination



With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVSVac

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *
FROM PercentPopulationVaccinated