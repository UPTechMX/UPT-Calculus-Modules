/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_telecom_infrastructure_in_risk (scenario_par INT, result_name text, amenity_list TEXT[], risk_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total int;
BEGIN
  -- get risk polygons with fclass in risks
  WITH risk_polygons AS (
    SELECT
      st_union (LOCATION) AS geom
    FROM
      risk
    WHERE
      scenario_id = scenario_par
      AND fclass = ANY (risk_list)
  )
  -- get amenities WITH fclass in amenities
  -- high school
  SELECT
    count(amenities_id) INTO total
  FROM
    amenities,
    risk_polygons
  WHERE
    scenario_id = scenario_par
    AND fclass = ANY (amenity_list)
    AND st_contains (risk_polygons.geom,amenities.location);

  delete from results where scenario_id=scenario_par and name=result_name;
  
  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = total;
END;
$$;



--'{worship, health, high_school}'