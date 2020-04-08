CREATE OR REPLACE FUNCTION urbper_indicator_energy_transport_t (scenario_par integer DEFAULT 0)
  RETURNS boolean
  LANGUAGE plpgsql
  AS $$
DECLARE
  status boolean = TRUE;
  tot_pop float;
  e_g float;
  e_d float;
BEGIN
  SELECT
    value INTO tot_pop
  FROM
    results
  WHERE
    name = 'pop_total'
    AND scenario_id = scenario_par;

  SELECT
    sum(value) INTO e_g
  FROM
    mmu
    INNER JOIN mmu_info USING (mmu_id)
  WHERE
    mmu.scenario_id = scenario_par
    AND mmu_info.name = 'energy_gasoline';

  SELECT
    sum(value) INTO e_d
  FROM
    mmu
    INNER JOIN mmu_info USING (mmu_id)
  WHERE
    mmu.scenario_id = scenario_par
    AND mmu_info.name = 'energy_diesel';

  INSERT INTO results ("scenario_id", "name", "value")
    VALUES (scenario_par, 'energy_transport', ((e_g + e_d) / tot_pop))
    ON CONFLICT ("scenario_id", "name")
      DO UPDATE SET
        "value" = excluded.value;

  INSERT INTO results ("scenario_id", "name", "value")
    VALUES (scenario_par, 'energy_gasoline', (e_g / tot_pop))
    ON CONFLICT ("scenario_id", "name")
      DO UPDATE SET
        "value" = excluded.value;

  INSERT INTO results ("scenario_id", "name", "value")
    VALUES (scenario_par, 'energy_diesel', (e_d / tot_pop))
    ON CONFLICT ("scenario_id", "name")
      DO UPDATE SET
        "value" = excluded.value;
        
  RETURN status;
END;
$$;

