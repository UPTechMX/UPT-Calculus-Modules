/*
This function calculates the population close to an ementiy class
and the percentage of the total population close to the amenity class
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_atm)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of amenity to be used
 */
CREATE OR REPLACE FUNCTION urbper_indicator_pop_amenity_prox (scenario_par INT, result_name text, result_name_pct text, amenity_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total int;
  total_pop double precision;
BEGIN
  SELECT
    value INTO total_pop
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'pop_total';
  -- get risk polygons with fclass in risks
  WITH amenity_buffer_polygon AS (
      SELECT
        st_union (buffer) AS geom
      FROM
        amenities
        inner join classification on classification.name=amenities.fclass
      where 
        classification.fclass= ANY (amenity_list)
        and classification.category='amenities'
        and scenario_id = scenario_par
        --AND fclass = ANY (amenity_list)
  )
  -- get amenities WITH fclass in amenities
  -- high school
  SELECT
    sum(value) INTO total
  FROM
    mmu
    INNER JOIN mmu_info USING (mmu_id)
    inner join classification on classification.name=mmu_info.name,
    amenity_buffer_polygon
  WHERE
    classification.fclass= 'population'
    and classification.category='mmu'
    and scenario_id = scenario_par
    --AND st_contains (LOCATION)
    AND st_contains (amenity_buffer_polygon.geom,mmu.location);

    INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
    DO
    UPDATE
    SET
      VALUE = total;
    INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, result_name_pct, total / total_pop * 100) ON CONFLICT (scenario_id, name)
    DO
    UPDATE
    SET
      VALUE = total / total_pop * 100;
END;
$$;

