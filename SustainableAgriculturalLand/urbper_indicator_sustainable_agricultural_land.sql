/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_sustainable_agricultural_land (scenario_par INT, agricultural_sus_list TEXT[],agricultural_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  agric_sus geometry;
  agric geometry;
BEGIN
  -- load sustainable agricultural polygons
  SELECT
    st_union(location) into agric_sus
  FROM
    footprint
  WHERE
    scenario_id = scenario_par
    AND name = ANY (agricultural_sus_list);
  -- load agricultural polygons
  SELECT
    st_union(location) into agric
  FROM
    footprint
  WHERE
    scenario_id = scenario_par
    AND name = ANY (agricultural_list);

  
  --save data into results
  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'agric_sus', (st_area(st_intersection(agric_sus,agric)::geography)/1E6) ) ,(scenario_par, 'agric_sustainable_pct', ( ((st_area(agric_sus::geography)/1E6) / (st_area(agric::geography)/1E6)) *100 )) 
  ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = excluded.value;

  /*INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'agric_sustainable_pct', ( (st_area(agric_sus::geography)/st_area(agric::geography)) *100 )) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = ( (st_area(agric_sus::geography)/st_area(agric::geography)) *100);*/
END;
$$;