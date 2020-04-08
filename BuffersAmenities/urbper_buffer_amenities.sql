/*
This function calculates a buffer  for each ementiy usign the amenity class to define the radius of the buffer
 */
CREATE OR REPLACE FUNCTION urbper_buffer_amenities
(scenario_par INT)
  RETURNS void
  LANGUAGE 'plpgsql'
  VOLATILE
  AS $$
BEGIN

  create temp table if not exists intern_assumptions as 
  select assumptions.scenario_id,assumptions.category,assumptions.value,classification.name  from assumptions
  inner join classification on classification.category= assumptions.category
  and classification.fclass=assumptions.name
  where assumptions.category='amenities'
  and assumptions.scenario_id=scenario_par;
  
  with buffers as(
      --select amenities.amenities_id,st_transform(st_buffer(st_transform(amenities."location",900913),assumptions."value",25),4326) as buffer from amenities
      select amenities.amenities_id, st_setsrid(st_buffer(amenities."location"::geography,intern_assumptions."value",25)::geometry,4326) as buffer from amenities
      
      inner join intern_assumptions on 
      intern_assumptions.name = amenities.fclass
      --and intern_assumptions.category='criteria'
      and amenities.scenario_id = intern_assumptions.scenario_id
      and intern_assumptions.scenario_id = scenario_par
      and amenities.buffer is null
  ) update amenities
  set buffer=buffers.buffer
  from buffers
  where buffers.amenities_id = amenities.amenities_id;  

  truncate table intern_assumptions;
END;
$$;

