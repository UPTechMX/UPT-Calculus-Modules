/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 footprint:text[] array with the class of the amenties to be counted
 heritage:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_solid_waste_management_coverage (scenario_par INT, result_name text)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  truckcol_cap Double precision;
  truck_coverage Double precision;
  land_ef Double precision;
  truc1_quant Double precision;
  truck1_cap Double precision;
  waste_per Double precision;
  solidw_coverage Double precision;
  collections Double precision;
  tot_pop  Double precision;
  landfill_coverage Double precision;

BEGIN
  select 
    results.value into tot_pop
  from 
    results
  where 
    results.scenario_id=scenario_par
    and results.name='pop_total';

  SELECT
    coalesce(value,0) INTO truc1_quant
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'waste'
    AND assumptions.name = 'truck1_quant';
  
  SELECT
    coalesce(value,0) INTO truck1_cap
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'waste'
    AND assumptions.name = 'truck1_cap';
  
  SELECT
    coalesce(value,0) INTO collections
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'waste'
    AND assumptions.name = 'collections';
  
  SELECT
    coalesce(value,0) INTO waste_per
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'waste'
    AND assumptions.name = 'waste_per';
  
  SELECT
    coalesce(value,0) INTO land_ef
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'waste'
    AND assumptions.name = 'land_ef';


  truckcol_cap = truc1_quant * truck1_cap * 1000;

  IF (7 * waste_per * tot_pop) < (truckcol_cap * collections) THEN
    truck_coverage = 100;
  ELSE
    truck_coverage = (land_ef * collections) / (7 * waste_per * tot_pop) * 100;
  END IF;

  IF (land_ef*7*1000) < (waste_per * tot_pop*7) THEN
    landfill_coverage = 100;
  ELSE
    landfill_coverage = (land_ef *7* 1000) / (7 * waste_per * tot_pop) * 100;
  END IF;

  IF ((landfill_coverage=100) and (truck_coverage=100)) THEN
    solidw_coverage = 100;
  ELSIF (truck_coverage < landfill_coverage) THEN
    solidw_coverage = truck_coverage;
  else  
    solidw_coverage = landfill_coverage;
  END IF;

  --get mmu area within heritage polygons
  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, solidw_coverage),(scenario_par,'truck_coverage',truck_coverage) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = excluded.value;

END;
$$;