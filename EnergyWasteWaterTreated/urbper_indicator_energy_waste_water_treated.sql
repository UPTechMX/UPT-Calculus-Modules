CREATE OR REPLACE FUNCTION urbper_indicator_energy_waste_water_treated(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

DECLARE
    status BOOLEAN = TRUE;
    --Data from scenario
    city_code_par INTEGER;
    country_code_par INTEGER;
    water_level_par INTEGER;
    --Data from assumptions
    wwt_ener_par FLOAT;
    wwtreated_par FLOAT;
    --Data from results
    tot_pop FLOAT;
    ww_par FLOAT;
    r FLOAT;
BEGIN
    --Find the country and city from scenario 
    SELECT value INTO wwt_ener_par FROM assumptions WHERE name = 'wwt_ener' AND category = 'water' AND scenario_id=scenario_par;
    SELECT value INTO wwtreated_par FROM assumptions WHERE name = 'wwtreated' AND category = 'water' AND scenario_id=scenario_par;

    SELECT
        value INTO tot_pop
    FROM
        results
    WHERE
        scenario_id = scenario_par
        AND results.name = 'pop_total';
    
    SELECT
        value INTO ww_par
    FROM
        results
    WHERE
        scenario_id = scenario_par
        AND results.name = 'ww';
    

    IF ww_par > wwtreated_par THEN
        r = wwt_ener_par * wwtreated_par / tot_pop;
    ELSE
        r = wwt_ener_par * ww_par / tot_pop;
    END IF;
    

    INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, 'energy_wwt', r) ON CONFLICT (scenario_id, name)
    DO
    UPDATE
    SET
      VALUE = EXCLUDED.value;

    RETURN status;
END
$$;
