CREATE OR REPLACE FUNCTION urbper_indicator_water_consumption(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare
	  city_code_par float;
    country_code_par float;    
    GBC_pen float;
    HU_water1 float;
    HU_water0 float;
    others_water float;
    tot_water_par float;
    tot_pop float;
	  tot_pop_b float;
    base_scenario int;
    
    HU_existing float;
    HU_new float;
	  HU_size float;
    status BOOLEAN;
    rwh float;
begin
    
    
  select min(scenario_id) into base_scenario from scenario where is_base=1 and study_area=(select min(study_area) from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);
  -- obtener los valores de las constantes para el cálculo de consumo de agua
  select value into HU_water1 from assumptions where scenario_id=scenario_par and category='green_b_code' and name='HU_water1';
  select value into HU_water0 from assumptions where scenario_id=scenario_par and category='green_b_code'  and name='HU_water0';
  select value into GBC_pen from assumptions where scenario_id=scenario_par and category='green_b_code'  and name='GBC_pen';
  select value into others_water from assumptions where scenario_id=scenario_par and category='green_b_code'  and name='others_water';
    
	select value into HU_size from assumptions where scenario_id=scenario_par and category='general'  and name='hu_size';

  select value into rwh from assumptions where scenario_id = scenario_par and category='green_b_code'  and name='rwh';
  select value into HU_existing from results where name='hu_tot' and scenario_id = base_scenario; -- HU_existing = HU_tot_b
  select value - hu_existing into HU_new from results where  name='hu_tot' and scenario_id = scenario_par; -- HU_new = HU_tot_h - HU_tot_b
  select value into tot_pop from results where name='pop_total' and scenario_id = scenario_par; -- HU_new = HU_tot_h - HU_tot_b
	select value into tot_pop_b from results where name='pop_total' and scenario_id = base_scenario; -- HU_new = HU_tot_h - HU_tot_b
    -- calcular el cosumo de agua
    
  tot_water_par=( COALESCE(HU_existing * HU_water0,0) + ( COALESCE(HU_new * (1-GBC_pen/100) * HU_water0, 0) + COALESCE(HU_new * (GBC_pen/100) * (HU_water1 - rwh),0) ) + COALESCE(others_water, 0)*(tot_pop/tot_pop_b)) / tot_pop;
  -- guardar el valor obtenido en la tabla resultados
  insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'tot_water', tot_water_par )
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
  return true;
end;

$$;
