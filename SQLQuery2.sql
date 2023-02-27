select * from CovidDeaths
where continent is not null
order by 3,4

select * from CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, 
population
from CovidDeaths
order by 1,2

-- Looking at  Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as death_percent
from CovidDeaths
where location like '%viet%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of infected population
Select Location, date, total_cases, population, 
(total_cases/population)*100 as infected_percent
from CovidDeaths
where location like '%Vietnam%'
order by infected_percent desc

-- Countries with highest infection rate compared to population

Select Location, population, 
max(total_cases) as HighestInfectionCount, 
max((total_cases)/population)*100 as infected_percent
from CovidDeaths
--where location like '%Vietnam%'
group by location, population
order by infected_percent desc

-- Showing countries with Highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
-- where location like '%Vietnam%'
group by location
order by TotalDeathCount desc

-- Showing the continent with the highest death count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
-- where location like '%Vietnam%'
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, sum(new_cases), sum(cast(new_deaths as int)) as TotalDeath,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from CovidDeaths
--where location like '%viet%'
where continent is not null
Group by date
order by 1,2

Select sum(new_cases), sum(cast(new_deaths as int)) as TotalDeath,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from CovidDeaths
--where location like '%viet%'
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE

with popvsvac (Continent, Location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
from popvsvac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3
Select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

-- Creating Views to store data for visualization

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select * from PercentPopulationVaccinated