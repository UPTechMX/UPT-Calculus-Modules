CREATE OR REPLACE FUNCTION urbper_indicator_energy_lighting(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
	city_code_par float;
	country_code_par float;
    footprint_km2 float;
    carbon_par float;
    public_lighting_level_par float;
    ped_road_km float;
    energy_lighting_par float;
    num_bulb float;
    num_led float;
    tot_bulb float;
    volt_led float;
    volt_bulb float;
    total_pop float;
    led_pen float;
    h float;
    interpost float;

    ter_road_km2 float;
    prim_road_km2 float;
    sec_road_km2 float;

    ter_road_km float;
    prim_road_km float;
    sec_road_km float;
    
    base_scenario bigint;
    status BOOLEAN=true;
begin
    
    select min(scenario_id) into base_scenario from scenario where is_base=1 and study_area=(select study_area from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);
    
    select value into interpost from assumptions where name='interpost' and category='public_lighting'   and scenario_id=scenario_par;
    select value into num_bulb from assumptions where name='num_bulb' and category='public_lighting'   and scenario_id=scenario_par;
    select value into num_led from assumptions where name='num_led' and category='public_lighting'   and scenario_id=scenario_par;
    select value into tot_bulb from assumptions where name='tot_bulb' and category='public_lighting'   and scenario_id=scenario_par;
    select value into ped_road_km from assumptions where name='ped_road_km' and category='general' and scenario_id=scenario_par;
    select value into volt_led from assumptions where name='volt_led' and category='public_lighting'   and scenario_id=scenario_par;
    select value into volt_bulb from assumptions where name='volt_bulb' and category='public_lighting'   and scenario_id=scenario_par;
    select value into led_pen from assumptions where name='led_pen' and category='public_lighting'   and scenario_id=scenario_par;
    select value into h from assumptions where name='hours_day' and category='public_lighting'   and scenario_id=scenario_par;
    
    
    
    -- El footprint se calcúla en transit_proximity, proximamente se hará el cálculo en una procedimiento almacenado con cálculos base similar a base_calculus_transit
    select value into footprint_km2 
    from results 
    where scenario_id= base_scenario and name='footprint_km2';

    select value into total_pop 
    from results 
    where scenario_id= scenario_par and name='pop_total';

    select value into ter_road_km2 
    from results 
    where scenario_id= scenario_par and name='ter_road_km2';

    select value into prim_road_km2 
    from results 
    where scenario_id= scenario_par and name='prim_road_km2';

    select value into sec_road_km2 
    from results 
    where scenario_id= scenario_par and name='sec_road_km2';

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

    select value into total_pop 
    from results 
    where scenario_id= scenario_par and name='pop_total';
        
	
    if tot_bulb is null
    then
        --revisar porque interpost vale 0
        select (COALESCE(prim_road_km+sec_road_km+ter_road_km+ped_road_km,0)/ COALESCE(interpost/1000,1)) into tot_bulb from results where scenario_id=scenario_par ;
        select (COALESCE(tot_bulb * led_pen/100,0)) into num_led;
    end if;

    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'energy_lighting', (( COALESCE((tot_bulb-num_led)*volt_bulb,0) + COALESCE(num_led*volt_led,0) ) * COALESCE(h,0) * 365/ COALESCE(prim_road_km+sec_road_km+ter_road_km+ped_road_km,0) * COALESCE(prim_road_km2+sec_road_km2+ter_road_km2,0)*footprint_km2/total_pop))
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
    
    
    return status;
end;

$$;
