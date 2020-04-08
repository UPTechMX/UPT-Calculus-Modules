/*
This function calculates the population close to an ementiy class
and the percentage of the total population close to the amenity class
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_atm)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of amenity to be used
 */
CREATE OR REPLACE FUNCTION urbper_indicator_renewable_energy (scenario_par INT, result_name text)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  localren_energy double precision;
  ren_energy double precision;
  ua_consumpt double precision;
  bio_gen double precision;
  sol_gen double precision;
  win_gen double precision;
  hyd_gen double precision;
BEGIN

  SELECT
    coalesce(value,0) INTO bio_gen
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'ghg_emissions'
    AND assumptions.name = 'bio_gen';

  SELECT
    coalesce(value,0) INTO sol_gen
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'ghg_emissions'
    AND assumptions.name = 'sol_gen';

  SELECT
    coalesce(value,0) INTO win_gen
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'ghg_emissions'
    AND assumptions.name = 'win_gen';

  SELECT
    coalesce(value,0) INTO hyd_gen
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'ghg_emissions'
    AND assumptions.name = 'hyd_gen';
  
  SELECT
    value INTO ua_consumpt
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    and category= 'ghg_emissions'
    AND assumptions.name = 'ua_consumpt';
  
  if ua_consumpt is null THEN
    SELECT
      coalesce(value,1) INTO ua_consumpt
    FROM
      results
    WHERE
      scenario_id = scenario_par
      AND results.name = 'energy_consumption';

  end if;

  localren_energy = coalesce(bio_gen,0)+ coalesce(sol_gen,0) + coalesce(win_gen,0) + coalesce(hyd_gen,0);
  ren_energy = ( localren_energy / ua_consumpt ) * 100;

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, ren_energy) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = EXCLUDED.value;
END;
$$;

