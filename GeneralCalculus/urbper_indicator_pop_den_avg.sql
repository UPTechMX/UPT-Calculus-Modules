/*
This function calculates the average population close to the mmu
 */
CREATE OR REPLACE FUNCTION urbper_indicator_pop_den_avg (scenario_par integer DEFAULT 0, offset_par integer DEFAULT 0, limit_par integer DEFAULT 0)
    RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    area_par float;
    radius float;
    status BOOLEAN = FALSE;
    data_population record;
BEGIN
    --get the buffer area, the radius of the buffer is in the criteria table
    SELECT
        "value" INTO radius
    FROM
        assumptions
    WHERE
        category='mmu'
        and name = 'pop_den_r'
        AND scenario_id = scenario_par;
    area_par = (
        SELECT
            radius * radius * PI() / 1e+4);
    --check if the jobs table has preprocessed the job density
    FOR data_population IN (
        SELECT
            c1.id,
            sum(mmu_info.value) AS population
        FROM (
            SELECT
                a.mmu_id as id,
                b.mmu_id AS id2
            FROM
                mmu AS a,
                mmu AS b
            WHERE
                a.scenario_id = scenario_par
                AND a.mmu_id >= offset_par
                AND a.mmu_id <= limit_par
                AND b.scenario_id = scenario_par
                AND ST_DWithin (a.location::geography, b.location::geography, radius)) c1
            INNER JOIN mmu_info ON mmu_info.mmu_id = c1.id2
            inner join classification on classification.name=mmu_info.name
            where 
                classification.category='mmu'
                and classification.fclass='population'
        GROUP BY
            c1.id)
    LOOP
        INSERT INTO mmu_info (mmu_id, name, value)
        VALUES (data_population.id, 'pop_density_avge', data_population.population) ON CONFLICT (mmu_id, name)
        DO
            UPDATE
        SET
            VALUE = data_population.population;
    END LOOP;
END;
$$;

