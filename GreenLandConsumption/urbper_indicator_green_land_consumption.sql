/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 footprint:text[] array with the class of the amenties to be counted
 green:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_green_land_consumption (scenario_par INT, result_name text, green TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total double precision;
BEGIN
  -- get risk polygons with fclass in risks
  WITH green_polygons AS (
      SELECT
        st_union (LOCATION) AS geom
      FROM
        footprint
      WHERE
        scenario_id = scenario_par
        AND name = ANY (green)
  )
  --get base polygon
  ,base_footprint as(
    SELECT
      location as geom
    FROM
      footprint
      inner join classification on classification.name=footprint.name
    where 
      classification.fclass= 'footprint_base'
      and classification.category='footprint'
      and scenario_id = scenario_par
  )
  --get MMU's
  ,mmu_scen as(
    select 
      mmu_info.value as area, mmu.location 
    from mmu
      inner join mmu_info on mmu.mmu_id = mmu_info.mmu_id
      inner join classification on classification.name=mmu_info.name
      and classification.fclass= 'area'
      and classification.category='mmu'
      ,green_polygons,base_footprint
    where mmu.scenario_id = scenario_par
      and st_contains(green_polygons.geom, mmu.location)
      and not st_contains(base_footprint.geom, mmu.location)
  )
  -- get mmu area within green polygons
  SELECT
    sum(mmu_scen.area) INTO total
  FROM
    mmu_scen;

  delete from results where scenario_id=scenario_par and name=result_name;

  INSERT INTO results(scenario_id, name, value)
  VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
  DO
  UPDATE
  SET
    VALUE = total;
END;
$$;



--'{worship, health, high_school}'