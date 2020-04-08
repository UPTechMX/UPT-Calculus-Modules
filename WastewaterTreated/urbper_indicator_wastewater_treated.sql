/*
This function calculates the population close to an ementiy class
and the percentage of the total population close to the amenity class
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_atm)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of amenity to be used
 */
CREATE OR REPLACE FUNCTION urbper_indicator_waste_water_treated (scenario_par INT)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  ww_factor DOUBLE PRECISION;
  wwtreated DOUBLE PRECISION;
  rwh DOUBLE PRECISION;
  GBC_pen DOUBLE PRECISION;
  tot_pop DOUBLE PRECISION;
  tot_water DOUBLE PRECISION;
  HU_existing DOUBLE PRECISION;
  hu_tot DOUBLE PRECISION;
  HU_new DOUBLE PRECISION;
  ww DOUBLE PRECISION;
  r DOUBLE PRECISION;
  base_scenario_par int;

BEGIN
  select min(scenario_id) into base_scenario_par from scenario where is_base=1 and study_area=(select min(study_area) from scenario where scenario_id=scenario_par) and owner_id=(select owner_id from scenario where scenario_id=scenario_par);

  SELECT 
    value 
  INTO 
    ww_factor 
  FROM 
    assumptions 
  WHERE 
    name = 'ww_factor' AND category = 'water' AND scenario_id=scenario_par;
  
  SELECT 
    value 
  INTO 
    wwtreated 
  FROM 
    assumptions 
  WHERE 
    name = 'wwtreated' AND category = 'water' AND scenario_id=scenario_par;
  
  SELECT 
    value 
  INTO 
    rwh 
  FROM 
    assumptions 
  WHERE 
    name = 'rwh' AND category = 'water' AND scenario_id=scenario_par;
  
  SELECT 
    value 
  INTO 
    GBC_pen 
  FROM 
    assumptions 
  WHERE 
    name = 'GBC_pen' AND category = 'water' AND scenario_id=scenario_par;


  --Find from table results

  SELECT 
    value 
  INTO 
    tot_water 
  FROM 
    results 
  WHERE 
    name = 'tot_water' AND scenario_id=scenario_par;

  SELECT 
    value 
  INTO 
    tot_pop 
  FROM 
    results 
  WHERE 
    name = 'pop_total' AND scenario_id=scenario_par;

  SELECT 
    value 
  INTO 
    hu_tot 
  FROM 
    results 
  WHERE 
    name = 'hu_tot' AND scenario_id=scenario_par;

  SELECT 
    value 
  INTO 
    HU_existing 
  FROM 
    results 
  WHERE 
    name = 'hu_tot' AND scenario_id=base_scenario_par;
  
  --Result
  HU_new = hu_tot - hu_existing;
  ww = (ww_factor / 100) * (tot_water * tot_pop + COALESCE(rwh,0)*COALESCE(HU_new,0)*(COALESCE(GBC_pen,0)/100));
  r =  (wwtreated / ww) * 100;

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'wwt_pct', r) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = EXCLUDED.value;

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'ww', ww) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = EXCLUDED.value;

END;
$$;

