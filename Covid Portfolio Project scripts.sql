Select *
From PortfolioProject..CovidDeaths$
where continent is not NULL
order by 3,4


Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
order by 1,2

--total deaths vs total cases
--Shows likelihood of dying if you contract covid in India

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1,2

--Total cases vs population
--Shows what percentage of population got covid

Select location,date,population,total_cases,(total_cases/population)*100 as CovidAffectedPercentage
From PortfolioProject..CovidDeaths$
--where location like '%India%'
where continent is not NULL
order by 1,2

--Looking at Countries with highest infection rate compared to population

Select location,population,MAX(total_cases),MAX((total_cases/population))*100 as CovidAffectedPercentage
From PortfolioProject..CovidDeaths$
--where location like '%India%'
where continent is not NULL
group by location,population
order by CovidAffectedPercentage desc

--Countries with highest death count

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by location
order by TotalDeathCount desc

--Continents with Highest Death Count

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by continent
order by TotalDeathCount desc

--Global Numbers

Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not NULL
group by date
order by 1,2 desc

--Total Vaccinations per day vs Population

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--TOTAL POP VS PER DAY VACCINATIONS
--CTE

With PopvsVac (continent,location,date,population, new_vaccinations,SumOfPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
)
Select *,(SumOfPeopleVaccinated/population)*100
From PopvsVac

--TEMPTABLE

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
SumOfPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL

Select *,(SumOfPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--View

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as
SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL

Select *
From PercentPopulationVaccinated