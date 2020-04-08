/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 road_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_road_infrastructure_in_risk (scenario_par INT, result_name text, road_list TEXT[], risk_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total double precision;
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
,roads_temp as(
  select 
    st_intersection(risk_polygons.geom,roads.location) as geom
  from 
    roads,risk_polygons
  where 
    scenario_id=scenario_par and fclass= ANY (road_list)
)
SELECT
  sum(st_length(geom::geography))/1000 INTO total
FROM
  roads_temp;
  

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = excluded.value;
END;
$$;



--'{worship, health, high_school}'