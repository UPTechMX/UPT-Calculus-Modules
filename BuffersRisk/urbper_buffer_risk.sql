/*
This function calculates a buffer  for each ementiy usign the amenity class to define the radius of the buffer
 */
CREATE OR REPLACE FUNCTION urbper_buffer_risk
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
  where assumptions.category='risk'
  and assumptions.scenario_id=scenario_par;

  with buffers as(
      select risk.risk_id, st_setsrid(st_buffer(risk."location"::geography,intern_assumptions."value",25)::geometry,4326) as buffer from risk
      -- this is a temporary projection fix
      --select risk.risk_id, st_transform(st_buffer(st_transform(risk."location",900913),intern_assumptions."value",25),4326) as buffer from risk
      inner join intern_assumptions on 
      intern_assumptions.name = risk.fclass
      --and intern_assumptions.category='criteria'
      and risk.scenario_id = intern_assumptions.scenario_id
      and intern_assumptions.scenario_id = scenario_par
      and risk.buffer is null
  ) update risk
  set buffer=buffers.buffer
  from buffers
  where buffers.risk_id = risk.risk_id; 
  truncate table intern_assumptions;
END;
$$;
