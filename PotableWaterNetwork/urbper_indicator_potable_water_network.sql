/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_potable_water_network (scenario_par INT)
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
  -- get all mmu's with con_elec
  WITH pop_water AS (
    SELECT
      mmu_id
    FROM
      mmu
      INNER JOIN mmu_info USING (mmu_id)
      inner join classification on classification.name=mmu_info.name
      and classification.fclass= 'water_net'
      and classification.category='mmu'
    WHERE
      mmu.scenario_id = scenario_par
      AND mmu_info.value = 1
  )
  SELECT
    sum(mmu_info.value) INTO total
  FROM
    mmu_info
    inner join classification on classification.name = mmu_info.name
      and classification.fclass= 'population'
      and classification.category='mmu'
    INNER JOIN pop_water USING (mmu_id);

  INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, 'pop_water_net', total) 
  ON CONFLICT (scenario_id, name)
    DO
    UPDATE
    SET
      VALUE = total;

  INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, 'perc_water_net', total / total_pop * 100) 
  ON CONFLICT (scenario_id, name)
    DO
    UPDATE
    SET
      VALUE = total / total_pop * 100;
END;
$$;

--'{worship, health, high_school}'
