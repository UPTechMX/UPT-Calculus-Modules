CREATE OR REPLACE FUNCTION urbper_indicator_roads_km2(
	scenario_par integer DEFAULT 0)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $$

declare 
	city_code_par float;
	country_code_par float;
    water_fact float;
    footprint_par float;
    loss float;
    water_level_par float;
    base_scenario bigint;
    prim_road_km float;
    sec_road_km float;
    ter_road_km float;
    
begin
	select min(scenario_id) into base_scenario from scenario where is_base=1 and study_area=(select min(study_area) from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);
    -- Obtener de assumptions los valores de las variables necesarias    
    
    
  select value into prim_road_km
  from assumptions
  where
    name='prim_road_km'
    and category='general'
    and scenario_id=scenario_par; 

  select value into sec_road_km
  from assumptions
  where
    name='sec_road_km'
    and category='general'
    and scenario_id=scenario_par;

  select value into ter_road_km
  from assumptions
  where
    name='ter_road_km'
    and category='general'
    and scenario_id=scenario_par;

  
  select value into footprint_par 
    from results 
    where 
        name='footprint_km2' 
        and scenario_id= base_scenario;
  
 
  insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'prim_road_km2', prim_road_km/footprint_par )
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
    
  insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'sec_road_km2',sec_road_km/footprint_par )
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;

  insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'ter_road_km2', ter_road_km/footprint_par )
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;

    return true;
end;

$$;
