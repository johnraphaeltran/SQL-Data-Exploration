
-- gets rid of null for continent 
Select *
From PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 3,4

/************
Select *
From PortfolioProject..['COvid Vacinations$']
order by 3,4

-- Select Data That we are going to be using
*******/

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
--Using and here for visual purpoes 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['Covid Deaths$']
Where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population 
-- Shows what percentage of population got covid
Select Location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate to Population
Select Location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per population
-- taking total_death snvarchar(255) and converting it to an integer
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Categorize by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--showing continenets with the highest death count per population 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid Deaths$']
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global numebers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..['Covid Deaths$']
where continent is not null
Group By date
order by 1,2

-- Total 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..['Covid Deaths$']
where continent is not null
--Group By date
order by 1,2

-- Looking at total Population vs Vaccinations
-- partition by the location because we need to break it up if we do it by continent the numbers will be completly off
-- we need to do it by location. Every time it gets to a new location, we want the count to start over need the SUM to keep runnning
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.Date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['COvid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['COvid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
--Creating a temporary table
-- Making alterations , no need to delete the temp table. Built on top and is easy to maintain

Drop Table if exists #PercentagePopulationVaccinated
create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['COvid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (PeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated



-- Creating View to store data for visualizations later

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as PeopleVaccinated
-- , (PeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['COvid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagePopulationVaccinated