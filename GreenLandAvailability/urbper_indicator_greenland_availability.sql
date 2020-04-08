/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 footprint:text[] array with the class of the amenties to be counted
 mountain:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_greenland_availability (scenario_par INT, result_name text, green_land TEXT[], protected_land TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total double precision;
BEGIN
  -- get risk polygons with fclass in risks
  WITH green AS (
      SELECT
        st_union (LOCATION) AS geom
      FROM
        footprint
      WHERE
        scenario_id = scenario_par
        AND name = ANY (green_land)
  )
  --get base polygon
  ,protected as (
    SELECT
        st_union (LOCATION) AS geom
      FROM
        footprint
      WHERE
        scenario_id = scenario_par
        AND name = ANY (protected_land)
  )
  SELECT
    st_area(green.geom)/st_area(protected.geom) INTO total
  FROM
    green,protected;

  INSERT INTO results(scenario_id, name, value)
  VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = excluded.value;
END;
$$;



--'{worship, health, high_school}'