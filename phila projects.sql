Select *
From [phila portfolio]..CovidDeaths$
order by 3,4 

Select *
From [phila portfolio]..CovidVaccinations$
order by 3,4 

select Location, date, total_cases, new_cases, total_deaths, population 
From [phila portfolio]..CovidDeaths$
order by 1,2
 
--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [phila portfolio]..CovidDeaths$
where location like '%south africa%'
order by 1,2

--looking at total cases vs total population

select location, date, total_cases, population, (total_cases/population)*100 as infectedpopulation
From [phila portfolio]..CovidDeaths$
where location like '%south africa%'
order by 1,2

--countries with highest infection compared to population

select location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases/population)*100 as percentpopulationinfected 
From [phila portfolio]..CovidDeaths$
--where location like '%south africa%'
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count 

select location, MAX(cast(total_deaths as int)) as totaldeathcount
From [phila portfolio]..CovidDeaths$
--where location like '%south africa%'
where continent is not null
group by location
order by totaldeathcount desc

--global numbers of deaths
 
 select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as percentagetotaldeaths
 From [phila portfolio]..CovidDeaths$
 where continent is not null
 group by date
 order by 1,2

 --looking at total population vs vaccinations
    
	--use CTE

	with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as
	(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from [phila portfolio]..CovidDeaths$ dea
 join [phila portfolio]..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (RollingPeopleVaccinated/population)*100
 from popvsvac

 --temp table

 Drop table if exists #percentofpopulationvaccinated
Create table #percentofpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentofpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from [phila portfolio]..CovidDeaths$ dea
 join [phila portfolio]..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select *, (RollingPeopleVaccinated/population)*100
 from #percentofpopulationvaccinated

 --creating view to store for later visualization

 create view percentofpopulationvaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from [phila portfolio]..CovidDeaths$ dea
 join [phila portfolio]..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select *
 from percentofpopulationvaccinated



 


