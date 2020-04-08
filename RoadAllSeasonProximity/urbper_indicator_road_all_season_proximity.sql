/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 road_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_road_all_season_proximity (scenario_par INT, result_name text, result_name_pct text, road_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total int;
  total_pop float;
BEGIN
  SELECT
    value INTO total_pop
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'pop_total';
  -- get risk polygons with fclass in risks
  WITH roads_buffer_polygon AS (
      SELECT
        st_union (buffer) AS geom
      FROM
        roads
      WHERE
        scenario_id = scenario_par
        AND fclass = ANY (road_list)
  )
  -- get amenities WITH fclass in amenities
  -- high school
  SELECT
    sum(value) INTO total
  FROM
    mmu
    INNER JOIN mmu_info USING (mmu_id)
    inner join classification on classification.name=mmu_info.name
      and classification.fclass= 'population'
      and classification.category='mmu',
    roads_buffer_polygon
  WHERE
    scenario_id = scenario_par
    --AND st_contains (LOCATION)
    AND st_contains (roads_buffer_polygon.geom,mmu.location);

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = excluded.value;

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name_pct, total / total_pop * 100) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = excluded.value;

END;
$$;



--'{worship, health, high_school}'