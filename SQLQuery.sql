use [COVIDPROJECT]
select * 
from [dbo].[Covid_Deaths]
order by 3,5;

--select * 
--from [dbo].[Covid_Vaccination_Data]
--order by 3,5;
 
select
[location],
[date],
[total_cases],
[new_cases],
[total_deaths],
[population]
 from [dbo].[Covid_Deaths]
 where [location] = 'France'
 order by 1, 2 ;

 -- Total Cases VS Total Deaths
 select
[location],
[date],
[total_cases],
[total_deaths],
(total_deaths/total_cases)*100 as 'Death %'
 from [dbo].[Covid_Deaths]
 where 
[location] = 'France'
 order by 1, 2 ;

 -- Total Cases VS Population
select
[location],
[date],
[total_cases],
population,
(total_cases/population)*100 as 'Cases per popln %'
 from [dbo].[Covid_Deaths]
 where 
[location] = 'France'
 order by 1, 2 ;

 -- Country with Highest Infection Rate
 select
[location],
max(total_cases) as highest_infection_count,
population,
max((total_cases/population)*100) as  '%population_infected'
 from [dbo].[Covid_Deaths]
 group by location, population
 --where 
--[location] = 'France'
 order by  '%population_infected' desc ;


-- Countries with highest death count per population
  select
[location],
max(cast (total_deaths as int)) as Total_death_count
 from [dbo].[Covid_Deaths]
 where 
[continent] is not null
group by location
 order by Total_death_count desc ;

-- By Continents
select
[location],
max(cast (total_deaths as int)) as Total_death_count
from [dbo].[Covid_Deaths]
where 
continent is null
group by location
order by Total_death_count desc ;

--Showing Continents with highest death count
select
[continent] ,
max(cast (total_deaths as int)) as Total_death_count
from [dbo].[Covid_Deaths]
where 
continent is not null
group by [continent]
order by Total_death_count desc ;

-- Global Numbers new cases and deaths
select [date], sum([new_cases]) as Total_Newcases,
sum(cast([new_deaths] as int)) as Total_Newdeaths,
(sum(cast([new_deaths] as int))/sum([new_cases]))*100 as Death_percentage
 from [dbo].[Covid_Deaths]
 where [continent] is not null
 group by [date]
 order by 1,2  ;

--global total
 select  sum([new_cases]) as Total_Newcases,
sum(cast([new_deaths] as int)) as Total_Newdeaths,
(sum(cast([new_deaths] as int))/sum([new_cases]))*100 as Death_percentage
 from [dbo].[Covid_Deaths]
 where [continent] is not null
 order by 1,2  ;


 --Joining Coviddeaths and covid vaccination tables
select * 
from 
[dbo].[Covid_Deaths] deaths join
[dbo].[Covid_Vaccination_Data] vacc 
on deaths.location = vacc.location and
deaths.date = vacc.date

-- Total Population VS Vaccination

select 
deaths.location,
deaths.continent,
deaths.date,
deaths.population,
vacc.new_vaccinations
from 
[dbo].[Covid_Deaths] deaths join
[dbo].[Covid_Vaccination_Data] vacc 
on deaths.location = vacc.location and
deaths.date = vacc.date
where deaths.continent is not null
order by 1,2,3 ;

-- Use CTE bcos if u want to call a column which you have alias names then you should use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[Covid_Deaths] dea
Join [dbo].[Covid_Vaccination_Data] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  --and dea.location = 'India'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

---------------TEMP TABLE---------------------

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  [dbo].[Covid_Deaths] dea
Join [dbo].[Covid_Vaccination_Data] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
--------------------------------------------------------------------

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  [dbo].[Covid_Deaths] dea
Join [dbo].[Covid_Vaccination_Data] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
