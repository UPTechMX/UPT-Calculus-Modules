CREATE OR REPLACE FUNCTION urbper_indicator_land_consumption(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
    tot_area double precision;
    tot_base_area double precision;
	pop_level_par integer;
	prioritize_tod_level_par integer;
	vacant_hu_level_par integer;
    status_par BOOLEAN;
    study_area_par geometry;
	base_scenario_par integer;
    
begin
	status_par = TRUE;   
	select 
		st_collectionextract(st_makevalid(footprint.location),3)  
	into 
		study_area_par 
	FROM
      footprint
      inner join classification on classification.name=footprint.name
    where 
      classification.fclass= 'study_area'
      and classification.category='footprint'
      and scenario_id = scenario_par;
	
	select min(scenario_id) into base_scenario_par from scenario where is_base=1 and study_area=(select study_area from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);
		
    
-- Obtener la poblacion total del escenario, este cálculo se moverá a un procedimiento almacenado similar base_calculus_transit
	select 
		sum(value) into tot_area
	from 
      mmu 
      inner join mmu_info on mmu.mmu_id = mmu_info.mmu_id
      inner join classification on classification.name=mmu_info.name
      and classification.fclass= 'area'
      and classification.category='mmu'
    where 
      mmu.scenario_id = scenario_par
      and st_contains(study_area_par, mmu.location);


	select 
		sum(value) into tot_base_area
	from 
      mmu 
      inner join mmu_info on mmu.mmu_id = mmu_info.mmu_id
      inner join classification on classification.name=mmu_info.name
      and classification.fclass= 'area'
      and classification.category='mmu'
    where 
      mmu.scenario_id = base_scenario_par
      and st_contains(study_area_par, mmu.location);
	
	insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'land_consumption_km', tot_area -tot_base_area )
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;

    return status_par;
end;

$$;
