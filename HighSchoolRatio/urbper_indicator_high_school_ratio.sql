/*
This function calculates the population close to an ementiy class
and the percentage of the total population close to the amenity class
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_atm)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of amenity to be used
 */
CREATE OR REPLACE FUNCTION urbper_indicator_high_school_ratio (scenario_par INT, result_name text)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  highpop_perc double precision;
  pop_high double precision;
  highschool_capacity double precision;
BEGIN
  SELECT
    value INTO highpop_perc
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    AND assumptions.category = 'criteria'
    AND assumptions.name = 'highpop_perc';

  SELECT
    value INTO highschool_capacity
  FROM
    results
  WHERE
    scenario_id = scenario_par
    AND name = 'highschool_capacity';
  
  if highpop_perc is null then
    select sum(mmu_info.value) into  pop_high
    from mmu
    inner join mmu_info using(mmu_id)
    inner join classification on classification.name = mmu_info.name
      and classification.category='mmu'
      and classification.fclass ='highpop'
    where mmu.scenario_id=scenario_par;
  else
    select results.value * highpop_perc/100  into  pop_high
    from results
    where results.scenario_id=scenario_par
    and results.name='pop_total';
  end if;    

  INSERT INTO results (scenario_id, name, value)
  VALUES (scenario_par, result_name, highschool_capacity/pop_high*100) ON CONFLICT (scenario_id, name)
  DO
    UPDATE
  SET
    VALUE = EXCLUDED.value;
END;
$$;

