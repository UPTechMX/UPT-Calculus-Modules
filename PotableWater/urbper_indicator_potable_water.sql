/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_potable_water (scenario_par INT)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  pop_water_net double precision;
  pop_water_well double precision;
  total_pop double precision;
BEGIN
  -- load total population
  SELECT
    value INTO total_pop
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'pop_total';
  
  SELECT
    value INTO pop_water_net
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'pop_water_net';
  
  SELECT
    value INTO pop_water_well
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'pop_water_well';
    
    INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, 'water_acc', (pop_water_net+pop_water_well)/total_pop*100) ON CONFLICT (scenario_id, name)
    DO
    UPDATE
    SET
      VALUE = excluded.value;
    
END;
$$;

--'{worship, health, high_school}'
