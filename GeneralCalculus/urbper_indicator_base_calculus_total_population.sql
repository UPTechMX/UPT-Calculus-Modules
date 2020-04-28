CREATE OR REPLACE FUNCTION urbper_indicator_base_calculus_total_population (scenario_par integer DEFAULT 0, base_scenario_par integer DEFAULT 0)
    RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    tot_pop_var double precision;
    status_par boolean;
    study_area geometry;
    footprint_base geometry;
    hu_tot_par double PRECISION;
BEGIN
    status_par = TRUE;
    SELECT
        st_collectionextract (st_makevalid (footprint.location), 3) INTO footprint_base
    FROM
        footprint
        INNER JOIN classification ON classification.name = footprint.name
    WHERE
        classification.fclass = 'footprint_base'
        AND classification.category = 'footprint'
        AND scenario_id = scenario_par;
    SELECT
        st_collectionextract (st_makevalid (footprint.location), 3) INTO study_area
    FROM
        footprint
        INNER JOIN classification ON classification.name = footprint.name
    WHERE
        classification.fclass = 'study_area'
        AND classification.category = 'footprint'
        AND scenario_id = scenario_par;
    
    WITH squares_intersected AS (
        SELECT
            p.value AS population,
            s.location
        FROM
            mmu_info p
            INNER JOIN mmu s USING (mmu_id)
            INNER JOIN classification ON classification.name = p.name
        WHERE
            classification.category = 'mmu'
            AND s.scenario_id = scenario_par
            AND st_contains (study_area, s.location)
            AND classification.fclass = 'population'
)
    SELECT
        sum(population) population INTO tot_pop_var
    FROM
        squares_intersected;
    --Delete previous results
    DELETE FROM results
    WHERE scenario_id = scenario_par;
    INSERT INTO results ("scenario_id", "name", "value")
        VALUES (scenario_par, 'pop_total', tot_pop_var)
    ON CONFLICT ("scenario_id", "name")
        DO UPDATE SET
            "value" = excluded.value;
    SELECT
        sum(value) INTO hu_tot_par
    FROM
        mmu
        INNER JOIN mmu_info USING (mmu_id)
        INNER JOIN classification ON classification.name = mmu_info.name
            AND classification.category = 'mmu'
            AND classification.fclass = 'hu'
    WHERE
        mmu.scenario_id = scenario_par;
    INSERT INTO results (scenario_id, name, value)
        VALUES (scenario_par, 'hu_tot', CASE WHEN (hu_tot_par) IS NULL THEN
                0
            ELSE
                (hu_tot_par)
            END)
    ON CONFLICT (scenario_id, name)
        DO UPDATE SET
            value = excluded.value;
    INSERT INTO results (scenario_id, name, value)
        VALUES (scenario_par, 'pop_expan', CASE WHEN (
                SELECT
                    sum(c1.population)
                FROM (
                    SELECT
                        value AS population,
                        LOCATION
                    FROM
                        mmu
                        INNER JOIN mmu_info USING (mmu_id)
                        INNER JOIN classification ON classification.name = mmu_info.name
                    WHERE
                        classification.category = 'mmu'
                        AND classification.fclass = 'population'
                        AND scenario_id = scenario_par) c1
                WHERE
                    NOT st_contains (footprint_base, c1.location)) IS NULL THEN
                0
            ELSE
                (
                    SELECT
                        sum(c1.population)
                    FROM (
                        SELECT
                            value AS population,
                            LOCATION
                        FROM
                            mmu
                            INNER JOIN mmu_info USING (mmu_id)
                            INNER JOIN classification ON classification.name = mmu_info.name
                        WHERE
                            classification.category = 'mmu'
                            AND classification.fclass = 'population'
                            AND scenario_id = scenario_par) c1
                    WHERE
                        NOT st_contains (footprint_base, c1.location))
            END)
ON CONFLICT (scenario_id,
    name)
    DO UPDATE SET
        value = excluded.value;
    RETURN status_par;
END;
$$;

