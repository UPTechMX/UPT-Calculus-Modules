CREATE OR REPLACE FUNCTION urbper_indicator_footprint_km2
(scenario_par integer DEFAULT 0) RETURNS void
    LANGUAGE plpgsql
    AS $$

declare 
    study_area geometry;
    footprint_km2 DOUBLE PRECISION;
begin
    select location
        into study_area
    from 
        footprint
        inner join classification on classification.name=footprint.name
    where 
        classification.category='footprint'
        and classification.fclass='study_area'
        and scenario_id = scenario_par;

    select 
        sum(mmu_info.value) into footprint_km2
    from
        mmu_info
        inner join mmu using(mmu_id)
        inner join classification on classification.name=mmu_info.name
        and classification.category='mmu'
        and classification.fclass='area'
    where 
        mmu.scenario_id=scenario_par
        and st_intersects(study_area,mmu.location);
    
    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'footprint_km2',footprint_km2)
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
end;
$$;
