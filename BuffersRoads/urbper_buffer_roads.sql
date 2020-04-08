/*
This function calculates a buffer  for each ementiy usign the amenity class to define the radius of the buffer
 */
CREATE OR REPLACE FUNCTION urbper_buffer_roads
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
  where assumptions.category='roads'
  and assumptions.scenario_id=scenario_par;

  with buffers as(
      --select roads.roads_id, st_transform(st_buffer(st_transform(roads."location",900913),assumptions."value",25),4326) as buffer from roads
      select roads.roads_id, st_setsrid(st_buffer(roads."location"::geography,intern_assumptions."value",25)::geometry,4326) as buffer from roads
      inner join intern_assumptions on 
      intern_assumptions.name = roads.fclass
      ---and intern_assumptions.category='criteria'
      and roads.scenario_id = intern_assumptions.scenario_id
      and intern_assumptions.scenario_id = scenario_par
      and roads.buffer is null
  ) update roads
  set buffer=buffers.buffer
  from buffers
  where buffers.roads_id = roads.roads_id;  
  truncate table intern_assumptions;
END;
$$;

