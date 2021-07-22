select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Likelihood of death by covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'india'
order by total_deaths desc

-- Looking at Total Cases vs Population
-- % of Population that got Covid

select location, date, total_cases,  population, (total_cases/population)*100 as CasesPerPopulation
From PortfolioProject..CovidDeaths
--where location = 'india'
order by 1,2

-- Looking at countries with highestinfection rate vs Population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'india'
Group by location, population
order by PercentPopulationInfected desc

-- Looking at countries with highest Death counts per population
-- nvarchar255 (total_deaths) datatype causes a datatype issue when reading with Max() so we need to cast it 

select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location = 'india' or location= 'asia'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Continent Breakdown
select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location = 'india' or location= 'asia'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers by Day

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date 
order by 1,2

--Golbal Numbers

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date 
order by 1,2


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinationsPerDay
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

--Adding a cumulative Vaccinations per day data column (Rolling Count)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinationsPerDay
, SUM(cast(vac.new_vaccinations as int) ) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingNewVaccinationsPerDay
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopulationVsVax (Continent, Location, Date, Population, new_vaccinations, RollingNewVaccinationsPerDay)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinationsPerDay
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingNewVaccinationsPerDay
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingNewVaccinationsPerDay/Population)*100 as VaccinatedPercenatge
From PopulationVsVax


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingNewVaccinationsPerDay numeric)


Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinationsPerDay
, SUM(cast(vac.new_vaccinations as int) ) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingNewVaccinationsPerDay
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

Select *, (RollingNewVaccinationsPerDay/Population)*100 as VaccinatedPercenatge
From #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

Use PortfolioProject
GO
Create View PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinationsPerDay
, SUM(cast(vac.new_vaccinations as int) ) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingNewVaccinationsPerDay
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

