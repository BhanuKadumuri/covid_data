Select * from CovidDeaths
where continent is not null
order by 3,4

Select * from CovidVaccinations
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Total cases Vs Total Deaths

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases decimal;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths decimal;

--Shows the likelyhood of dying from covid
Select Location, date, total_cases, total_deaths,((total_deaths/total_cases)*100) As DeathPercentage
from CovidDeaths
where location like 'United states'
order by 1,2;

--Total Cases Vs Population

Select Location, date, total_cases, population,((total_cases/population)*100) As CasesPercentage
from CovidDeaths
where location like 'United states'
order by 1,2;

--Countries with Highest Infection Rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) As PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, population
order by PercentagePopulationInfected desc;

--Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
where continent is not null
Group by Location 
Order by TotalDeathCount desc

--Continents with Highest Death Count per Population

Select Continent, Max(cast(total_deaths as int))as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent 
Order by TotalDeathCount desc

-- Global Numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage --total_cases, total_deaths,((total_deaths/total_cases)*100) As DeathPercentage
from CovidDeaths
where Continent is not null
Group by date
Having(sum(new_cases) > 0)
order by 1,2;



---CovidVaccinations vs CovidDeaths

--USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(decimal,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

---TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(decimal,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later Visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(decimal,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join
CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated