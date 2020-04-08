/*
This function calculates the population close to an ementiy class
and the percentage of the total population close to the amenity class
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_atm)
 result_name_pct:text name of the restulting variable in terms of % of population(atm_prox)
 amenity_list:text[] array with the class of amenity to be used
 */
CREATE OR REPLACE FUNCTION urbper_indicator_elementary_school_capacity (scenario_par INT, result_name text, amenity_list TEXT[])
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
DECLARE
  elestudent_area double precision;
  total double precision;
BEGIN
  SELECT
    value INTO elestudent_area
  FROM
    assumptions
  WHERE
    scenario_id = scenario_par
    AND assumptions.category = 'criteria'
    AND assumptions.name = 'elestudent_area';
  
  drop table if exists gross_area_t;
  create temp table gross_area_t as
  select name
  from classification
  where classification.category='amenities'
  and fclass='gross_area';

  drop table if exists shift_t;
  create temp table shift_t as
  select name
  from classification
  where classification.category='amenities'
  and fclass='shift';
  -- get risk polygons with fclass in risks
  SELECT
    sum(c1.value * c2.value / elestudent_area) into total
  FROM (
    SELECT
      amenities.amenities_id,
      amenities_info.value
    FROM
      amenities_info
      INNER JOIN amenities USING(amenities_id)
      inner join classification on classification.name = amenities.fclass
      and classification.category='amenities'
      and classification.fclass = any(amenity_list)
    WHERE
      amenities_info.name in (select name from gross_area_t)
      AND scenario_id = scenario_par
      ) c1
  INNER JOIN (
    SELECT
      amenities.amenities_id, amenities_info.value
    FROM
      amenities_info
      INNER JOIN amenities USING(amenities_id)
      inner join classification on classification.name = amenities.fclass
      and classification.category='amenities'
      and classification.fclass = any(amenity_list)
    WHERE
      amenities_info.name in (select name from shift_t)
      AND scenario_id = scenario_par
  ) c2 USING(amenities_id);

INSERT INTO results (scenario_id, name, value)
VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
DO
  UPDATE
SET
  VALUE = EXCLUDED.value;
END;
$$;

