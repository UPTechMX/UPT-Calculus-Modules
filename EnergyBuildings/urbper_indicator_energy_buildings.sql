CREATE OR REPLACE FUNCTION urbper_indicator_energy_buildings(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
	city_code_par float;
	country_code_par float;
    footprint_par float;
    ener_baseline float;
    green_b_code_level_par float;
    base_scenario int;
    HU_existing float;
    HU_new float;
    GBC_pen float;
    GBC_ener float;
    tot_pop float;
    
    status BOOLEAN=true;
begin
	select min(scenario_id) into base_scenario from scenario where is_base=1 and study_area=(select study_area from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);

    select coalesce(value,0) into ener_baseline from assumptions where name='ener_baseline' and category='green_b_code' and scenario_id=scenario_par;
    select coalesce(value,0) into GBC_pen from assumptions where name='GBC_pen' and category='green_b_code' and scenario_id=scenario_par;
    select coalesce(value,0) into GBC_ener from assumptions where name='GBC_ener' and category='green_b_code' and scenario_id=scenario_par;
    -- obtener los km lineales de vialidades desde la tabla de assumptions, a futuro estas distancias se calcularán en el sistema
    
    select value into HU_existing from results where name='hu_tot' and scenario_id = base_scenario; -- HU_existing = HU_tot_b
    select value - HU_existing into HU_new from results where  name='hu_tot' and scenario_id = scenario_par; -- HU_new = HU_tot_h - HU_tot_b
    select value into tot_pop from results where  name='pop_total' and scenario_id = scenario_par; 
	-- calcular energy building

    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'energy_buildings',(((HU_existing*ener_baseline) + (HU_new * (1-GBC_pen/100) * ener_baseline + (HU_new*GBC_pen/100*GBC_ener) ) ) / tot_pop ))
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
    
    return status;
end;

$$;
