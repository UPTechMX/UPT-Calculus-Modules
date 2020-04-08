CREATE OR REPLACE FUNCTION urbper_indicator_energy_water(scenario_par integer DEFAULT 0, result_name text DEFAULT '') RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
	city_code_par float;
	country_code_par float;
    water_fact float;
    footprint_km2 float;
    loss float;
    water_level_par float;
    water_loss_level_par FLOAT;
    base_scenario bigint;

    prim_road_km2 FLOAT;
    sec_road_km2 FLOAT;
    ter_road_km2 FLOAT;
    pop_total  FLOAT;
    tot_water Float;
    -- general_level_par float;
begin
    
    select min(scenario_id) into base_scenario from scenario where is_base=1 and study_area=(select min(study_area) from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);
    
    -- Obtener de assumptions los valores de las variables necesarias
    select value into water_fact
    from assumptions
    where 
    name='water_factor'
    and category='water'
    and scenario_id = scenario_par;
    
    select value into loss
    from assumptions
    where 
    name='loss'
    and category='water_loss'
    and scenario_id = scenario_par;

    select value into prim_road_km2
    from results
    where
        name='prim_road_km2'
        and scenario_id=scenario_par; 

    select value into sec_road_km2
    from results
    where
        name='sec_road_km2'
        and scenario_id=scenario_par;

    select value into ter_road_km2
    from results
    where
        name='ter_road_km2'
        and scenario_id=scenario_par;
    
    select value into footprint_km2 
    from results 
    where 
        name='footprint_km2' 
        and scenario_id= scenario_par;
    
    select value into tot_water 
    from results 
    where 
        name='tot_water' 
        and scenario_id= scenario_par;

    select value into pop_total 
    from results 
    where name='pop_total' and scenario_id= base_scenario;
	
	-- calcular energy water

    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,result_name, (
        COALESCE(water_fact,0) * 
        (	
            COALESCE(tot_water,0) * COALESCE(pop_total,0) 
            
            + COALESCE(footprint_km2,0) * (
                COALESCE(prim_road_km2,0) 
                + COALESCE(sec_road_km2,0) 
                + COALESCE(ter_road_km2,0)
			) * COALESCE(loss,0)
        ) /pop_total) )
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
        
    return true;
end;

$$;
