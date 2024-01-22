Select * 
FROM Portfolio..CovidDeaths
Where Continent is not null
order by 3,4

--Select * 
--FROM Portfolio..CovidVaccinations
--order by 3,4


Select Location, date, total_cases, New_cases, total_deaths, population
From Portfolio.. CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From Portfolio.. CovidDeaths
Where Location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, Population, (Total_cases/population)*100 as DeathPercentage
From Portfolio.. CovidDeaths
Where Location like '%Argentina%'
order by 1,2


-- Looking at countries with highest infection Rate compared to population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio.. CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio.. CovidDeaths
Where Continent is not null
Group by Location
order by TotalDeathCount desc

-- Break down by continent
-- Showing the continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio.. CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio.. CovidDeaths
Where continent is not null
--Group by date 
order by 1,2


-- Looking at Total populatoin vs Vaccionations

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date),
as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*10
From Portfolio.. CovidDeaths dea
Join Portfolio.. CovidVaccinations vac
On dea.Location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From Portfolio.. CovidDeaths dea
Join Portfolio.. CovidVaccinations vac
On dea.Location = vac.location
and dea.date = vac.date
where dea.continent is not null

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From Portfolio.. CovidDeaths dea
Join Portfolio.. CovidVaccinations vac
On dea.Location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From Portfolio.. CovidDeaths dea
Join Portfolio.. CovidVaccinations vac
On dea.Location = vac.location
and dea.date = vac.date
where dea.continent is not null
