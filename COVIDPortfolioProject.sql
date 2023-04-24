--Select *
--From CovidPortfolioProject..CovidDeaths
--Order By 3,4


--Select *
--From CovidPortfolioProject..CovidVaccinations
--Order By 3,4


--Select Data for use


Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Order By 1,2


--Total Cases vs Total Deaths
-- Shows Chances of Dying if you get COVID

Select Location, date, total_cases, total_deaths, (cast(total_deaths AS float) / cast(total_cases AS float))*100 AS DeathPercentage
From CovidPortfolioProject..CovidDeaths
where location like '%states%'
Order By 1,2


--Total Cases vs Population
-- % of Population that got COVID

Select Location, date, population, cast(total_cases as bigint) as total_cases, (cast(total_cases AS real) / cast(population as real))*100 AS InfectedPercentage
From CovidPortfolioProject..CovidDeaths
where location like '%states%'
Order By 1,2


--Countries with Highest Infection Rate Compared to Population


Select Location, population, MAX (cast(total_cases as bigint)) as HighestInfectionCount, MAX((cast(total_cases AS real) / cast(population as real)))*100 AS
InfectionRate
From CovidPortfolioProject..CovidDeaths
--where location like '%states%'
Group By location, population
Order By InfectionRate desc


-- Countries with highest death count per population


Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group By location 
Order By TotalDeathCount desc


--- Continents with highest death count


Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group By continent 
Order By TotalDeathCount desc


--- Global Numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths , SUM(cast(new_deaths as real))/SUM(cast(new_cases as real))*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
Order By 1,2



--Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--- Use CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac



--Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated