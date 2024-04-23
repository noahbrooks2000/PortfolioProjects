/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



  Select *
  From portfolioproject..Covid#Deaths$
  Where continent is not null
  order by 3,4
  
  
  Select Location, date, total_cases, new_cases, total_deaths, population
  From portfolioproject..Covid#Deaths$
  Where continent is not null
  Order by 1,2

  -- Looking at Total Cases vs Total Deaths
  -- Shows the likelihood of dying if you contract covid in your country

  Select Location, date, total_cases, total_deaths, (convert(float,total_deaths)) / (convert(float, total_cases)) *100 as DeathPercentage
  From portfolioproject..Covid#Deaths$
  Where continent is not null
  and location like '%states%'
  Order by 1,2


  -- Looking at total cases vs population
  -- Shows what percentage of people got covid

  Select Location, date, total_cases, population, (convert(float, total_cases)) / (convert(float, population)) *100 as CovidPercentage
  From portfolioproject..Covid#Deaths$
  Where continent is not null
  and location like '%states%'
  Order by 1,2


  --Looking at countries with highest infection rate compared to population

  Select Location, MAX(total_cases) as HighestInfectionCount, population, (convert(float, MAX(total_cases))) / (convert(float, population)) *100 as PercentPopulationInfected
  From portfolioproject..Covid#Deaths$
  --Where location like '%states%'
  Where continent is not null
  Group By Location, population
  Order by PercentPopulationInfected desc

  -- Showing the countries with the highest death count per population

  Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
  From portfolioproject..Covid#Deaths$
  --Where location like '%states%'
  Where continent is not null
  Group By Location
  Order by TotalDeathCount desc

  -- Breaking the above query by continent instead of country

   Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
  From portfolioproject..Covid#Deaths$
  --Where location like '%states%'
  Where continent is not null
  Group By continent
  Order by TotalDeathCount desc

  -- Global Numbers

   Select location, date, total_cases, total_deaths, (convert(float,total_deaths)) / (convert(float, total_cases)) *100 as DeathPercentage
  From portfolioproject..Covid#Deaths$
  Where continent is not null 
  --and location like '%states%'
  Order by 1,2

  -- looking at total population vs vaccinations

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from portfolioproject..Covid#Deaths$ dea
  join portfolioproject..CovidVAccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  order by 2,3

  -- using a cte
  With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
  as
   ( Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from portfolioproject..Covid#Deaths$ dea
  join portfolioproject..CovidVAccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  --order by 2,3
  )
  select *, (RollingPeopleVaccinated/population)*100
  from PopvsVac

  --using a temp table

  Drop table if exists #percentpopulationvaccinated
  create table #percentpopulationvaccinated
  (
  continent nvarchar(255), 
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  insert into #percentpopulationvaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from portfolioproject..Covid#Deaths$ dea
  join portfolioproject..CovidVAccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  --order by 2,3

  select *, (RollingPeopleVaccinated/population)*100
  from #percentpopulationvaccinated

  -- creating view to store data for later visualizations
  use portfolioproject
  go
  create view PercentPopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from portfolioproject..Covid#Deaths$ dea
  join portfolioproject..CovidVAccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  --order by 2,3
