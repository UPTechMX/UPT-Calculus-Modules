/*
This function calculates the population close to a transit location
and the percentage of the total population close to the transit location
 scenario_par:integer identifier of the scenario(1)
 result_name:text name of the restulting variable in terms of population(pop_prox_transit)
 result_name_pct:text name of the restulting variable in terms of % of population(transit_prox)
 */
CREATE OR REPLACE FUNCTION urbper_indicator_pop_transit_prox (scenario_par INT, result_name text, result_name_pct text)
    RETURNS void
    LANGUAGE 'plpgsql'
    VOLATILE
    AS $$
DECLARE
    total int;
    total_pop double precision;
BEGIN
    SELECT
        value INTO total_pop
    FROM
        results
    WHERE
        scenario_id = scenario_par
        AND results.name = 'pop_total';
    -- get risk polygons with fclass in risks
    WITH transit_buffer_polygon AS (
        SELECT
            st_union (buffer) AS geom
        FROM
            transit
        WHERE
            scenario_id = scenario_par
    )
    -- get amenities WITH fclass in amenities
    -- high school
    SELECT
        sum(value) INTO total
    FROM
        mmu
        INNER JOIN mmu_info USING (mmu_id)
        inner join classification on classification.name=mmu_info.name
        and classification.category='mmu'
        and classification.fclass='population',
        transit_buffer_polygon
    WHERE
        scenario_id = scenario_par
        AND st_contains (transit_buffer_polygon.geom, mmu.location);
        
    INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, result_name, total) ON CONFLICT (scenario_id, name)
    DO
    UPDATE
        SET
            VALUE = total;

    INSERT INTO results (scenario_id, name, value)
    VALUES (scenario_par, result_name_pct, total / total_pop * 100) ON CONFLICT (scenario_id, name)
    DO
    UPDATE
        SET
            VALUE = total / total_pop * 100;
END;
$$;