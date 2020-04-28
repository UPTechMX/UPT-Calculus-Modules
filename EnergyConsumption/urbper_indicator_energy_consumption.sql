/*
This function calculates the population close to an ementiy class
and the percentage of the total population close to the amenity class
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_atm)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of amenity to be used
 */
CREATE OR REPLACE FUNCTION urbper_indicator_energy_consumption (scenario_par INT, result_name text)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  energy_water double precision;
  energy_lighting double precision;
  energy_swaste double precision;
  energy_buildings double precision;
  energy_transport double precision;
  energy_wwt double precision;
  tot_ener double precision;
BEGIN

  SELECT
    coalesce(value,0) INTO energy_water
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'energy_water';

  SELECT
    coalesce(value,0) INTO energy_lighting
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'energy_lighting';

  SELECT
    coalesce(value,0) INTO energy_swaste
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'energy_swaste';

  SELECT
    coalesce(value,0) INTO energy_buildings
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'energy_buildings';

  SELECT
    coalesce(value,0) INTO energy_transport
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'energy_transport';

  SELECT
    coalesce(value,0) INTO energy_wwt
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND results.name = 'energy_wwt';

  tot_ener=(coalesce(energy_water,0)+coalesce(energy_lighting,0)+coalesce(energy_swaste,0)+coalesce(energy_buildings,0)+coalesce(energy_transport,0)+coalesce(energy_wwt,0));

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, tot_ener) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = EXCLUDED.value;
END;
$$;

