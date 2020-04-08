CREATE OR REPLACE FUNCTION urbper_buffer_job_and_job_density(
    scenario_par INTEGER,
    offset_par          integer DEFAULT 0, 
    limit_par           integer DEFAULT 0
)   RETURNS boolean
    LANGUAGE plpgsql
AS $$
    declare 	
        area_par float;
        job_min_dens float;
        radius float;
        status BOOLEAN=false;
        job record;
    begin

        create temp table if not exists intern_assumptions as 
        select assumptions.scenario_id,assumptions.category,assumptions.value,assumptions.name  from assumptions
        where assumptions.category='jobs'
        and assumptions.scenario_id=scenario_par;
        
        --get the min job density required to tell a square has job access
        select "value" into job_min_dens from intern_assumptions where name='job_min_dens'; 
        --get the buffer area, the radius of the buffer is in the criteria table
        select "value" into radius from intern_assumptions where name='job';
        area_par=(select radius*radius*PI()/1e+4);
        --check if the jobs table has preprocessed the job density 

        with buffers as(
            --select jobs.jobs_id, st_transform(st_buffer(st_transform(jobs."location",900913),assumptions."value",25),4326) as buffer from jobs
            select jobs.jobs_id,
                st_setsrid(st_buffer(jobs."location"::geography,intern_assumptions."value",25)::geometry,4326) as buffer 
            from jobs
                inner join intern_assumptions on 
                intern_assumptions.name = 'job'
                --and intern_assumptions.category='criteria'
                and jobs.scenario_id = intern_assumptions.scenario_id
                and intern_assumptions.scenario_id = scenario_par
                and jobs.buffer is null
        ) update jobs
            set buffer=buffers.buffer
        from buffers
        where buffers.jobs_id = jobs.jobs_id;         

        --drop temp table if exists
        drop table if exists b2;
        -- create a table with needed data
        create temp table b2 as
        select  
            jobs_id, 
            value as jobs, 
            location::geography as buffer
        from 
            jobs 
            left join jobs_info using (jobs_id)
            inner join classification on classification.name=jobs_info.name
            and classification.fclass= 'jobs'
            and classification.category='jobs_info'
        where 
            jobs.scenario_id = scenario_par;

        create index on b2 using gist(buffer);

        create temp table study_point as
        select  
            jobs_id,  
            location::geography
        from 
            jobs 
        where 
            jobs.jobs_id>=offset_par 
            and jobs.jobs_id <=limit_par
            and jobs.scenario_id = scenario_par;


        create temp table  t1 as
        select b1.jobs_id,b2.jobs 
        from study_point as b1, b2
        where ST_DWithin(b1.location,b2.buffer,radius);
        

        for job in (
            select t1.jobs_id,sum(t1.jobs) as jobs 
            from t1 group by t1.jobs_id 
        )
        loop
            insert into jobs_info(jobs_id,name,value)
            values(job.jobs_id,'job_density_avge',(job.jobs/area_par))
            on CONFLICT(jobs_id,name)  do update
            set value=EXCLUDED.value;

            insert into jobs_info(jobs_id,name,value)
            values(job.jobs_id,'jobs_in1km',job.jobs)
            on CONFLICT(jobs_id,name)  do update
            set value=EXCLUDED.value;
        end loop;
        truncate table intern_assumptions;
        status = true;
        return status;
    end;
$$;
