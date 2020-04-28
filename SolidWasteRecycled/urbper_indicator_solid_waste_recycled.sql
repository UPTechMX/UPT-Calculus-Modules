/*
This function counts the number of facilities located in risk areas
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable(edu_risk)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of the amenties to be counted
 risk_list:text[] array with the class of the risk to be used as risk areas
 */
CREATE OR REPLACE FUNCTION urbper_indicator_solid_waste_recycled (scenario_par INT)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  total_pop double precision;
  rec_cap double precision;
  truck_coverage double precision;
  waste_per double precision;
  trucks_collect double precision;
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
    value INTO rec_cap
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    AND assumptions.category = 'waste'
    AND assumptions.name = 'rec_cap';

  SELECT
    value INTO truck_coverage
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'truck_coverage';
  
  SELECT
    value INTO waste_per
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    AND assumptions.category = 'waste'
    AND assumptions.name = 'waste_per';

  SELECT truck_coverage*waste_per*total_pop
     INTO trucks_collect;
  --save data into results
  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, 'waste_recycled', (rec_cap*100)/trucks_collect/*trucks_collect/rec_cap*/) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = excluded.value;

END;
$$;

