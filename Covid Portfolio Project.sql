Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs. population
--ALTER TABLE PortfolioProject..CovidDeaths
--ALTER COLUMN total_cases int

Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by location, population
order by 3 desc

--Looking at countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by Location
Order by TotalDeathCount desc


--Looking at continents with Highest Death Count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by continent
Order by TotalDeathCount desc  

--Global Numbers
Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Population vs. Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select cd.continent, cd.location, cd.date, population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent IS NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
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
Select cd.continent, cd.location, cd.date, population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for tableau usage

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, population, cv.new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) 
OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv ON cd.location = cv.location
	and cd.date = cv.date
Where cd.continent IS NOT NULL


Select *
From PercentPopulationVaccinated