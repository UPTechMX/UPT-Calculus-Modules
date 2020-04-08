/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_population_in_slums (scenario_par INT,slums_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total int;
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
  -- load slum polygons
  WITH slum_polygons AS (
    SELECT
      st_union (location) AS geom
    FROM
      risk
    WHERE
      scenario_id = scenario_par
      AND fclass = ANY (slums_list)
  )
  --sum population inside slums
  SELECT
    sum(value) INTO total
  FROM
    mmu
    INNER JOIN mmu_info USING (mmu_id)
    inner join classification on classification.name=mmu_info.name
      and classification.fclass= 'population'
      and classification.category='mmu',
    slum_polygons
  WHERE
    scenario_id = scenario_par
    AND st_contains (slum_polygons.geom, mmu.location);
  --save data into results
  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'pop_slums', total) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = total;

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'perc_pop_slums', total / total_pop * 100) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = total / total_pop * 100;
END;
$$;

