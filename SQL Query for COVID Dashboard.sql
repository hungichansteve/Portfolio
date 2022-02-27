--Queries used for Data Visualization Project

--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeath
--Where location Like '%states%'
Where continent is not null
--Group By date
Order By 1,2

--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location Like '%states%'
Where continent is null AND
location Not In ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group By location
Order By TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc