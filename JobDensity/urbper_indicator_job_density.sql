CREATE OR REPLACE FUNCTION urbper_indicator_job_density(scenario_par integer DEFAULT 0, offset_par integer DEFAULT 0, limit_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 	
	area_par float;
	job_min_dens float;
	radius float;
    status BOOLEAN=false;
	square record;
begin
    
	
  	select "value" into job_min_dens from assumptions where category='criteria' and name='job_min_dens' and scenario_id = scenario_par; 
	--get the buffer area, the radius of the buffer is in the assumptions table
	select "value" into radius from assumptions where category='criteria' and name='job' and scenario_id = scenario_par;
	area_par = (select radius*radius*PI()/1e+4);
	
	--drop temp table if exists
	drop table if exists b2;
	-- create a table with needed data
	create temp table b2 as
		select  
			jobs_id, 
			value as job_density_avge, 
			location::geography as buffer
		from 
			jobs 
			left join jobs_info using (jobs_id)
		where 
			jobs.scenario_id = scenario_par
			and name='job_density_avge';
	create index on b2 using gist(buffer);
	--get gob density for each study_area point
	--loop
	--begin
	create temp table study_point as
		select mmu_id, location::geography 
		from mmu
		where mmu_id >= offset_par and mmu_id <=limit_par
		and mmu.scenario_id=scenario_par;
	
	create temp table t1 as
		select b1.mmu_id,b2.job_density_avge from study_point as b1, b2
		where ST_DWithin(b1.location,b2.buffer,radius)
	;

	for square in (
		select t1.mmu_id,avg(t1.job_density_avge) as jobs 
		from t1  
		group by t1.mmu_id
	)
	loop
		insert into mmu_info(mmu_id,name,value)
		values(square.mmu_id,'job_density_avge',square.jobs)
		on CONFLICT(mmu_id,name)  do update
		set value=EXCLUDED.value;
	end loop;

	status = true;
	
	return status;
end;

$$;