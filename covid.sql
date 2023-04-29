-- SELECT * FROM portfolioproject.coviddeaths
-- order by 3,4;

-- select Data 

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths;

-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths;

-- percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
-- from portfolioproject.coviddeaths 
-- where location like '%states%'

-- country with highest infection rate compared to population

from portfolioproject.coviddeaths 
-- where location like '%states%'
group by location, population
order by percentpopulationinfected DESC;

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location, MAX(cast(total_deaths as SIGNED int)) as totaldeathcount
from portfolioproject.coviddeaths 
-- where location like '%states%'
where continent is not null
group by location
order by totaldeathcount DESC;

-- breaking things down by continent
-- continent with the highest death count per population

select continent, MAX(cast(total_deaths as SIGNED int)) as totaldeathcount
from portfolioproject.coviddeaths 
-- where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount DESC;

-- global number of cases per day

select date, sum(new_cases) as totalcase, sum(cast(new_deaths as signed int)) as totaldeaths,sum(cast(new_deaths as signed int))/sum(new_cases)*100 as deathpercentage
from portfolioproject.coviddeaths
where continent is not null
group by date
order by 1,2;

-- joining tables
select * from 
portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;

-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed int)) over (partition by dea.location)
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
and dea.continent = vac.continent
-- where dea.continent is not null
-- order by 2,3
)
select *
from popvsvac;

-- creating view
create view deathcount as
select continent, MAX(cast(total_deaths as SIGNED int)) as totaldeathcount
from portfolioproject.coviddeaths 
-- where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount DESC;deathcount