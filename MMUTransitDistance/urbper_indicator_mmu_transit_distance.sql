CREATE OR REPLACE FUNCTION urbper_indicator_mmu_transit_distance (scenario_par integer DEFAULT 0, offset_par integer DEFAULT 0, limit_par integer DEFAULT 0)
    RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    status_par boolean;
    mmu_data record;
BEGIN
    status_par = TRUE;
    
    
    DROP TABLE IF EXISTS buffer_squares;

    CREATE temp TABLE buffer_squares AS
    SELECT
        *
    FROM (
        SELECT
            mmu.mmu_id,
            mmu.scenario_id,
            mmu.location,
            null::float as transit_distance,
            null::character varying(100) as prox_to_transit_fclass
        FROM
            mmu
            inner join mmu_info using(mmu_id)
            inner join classification on classification.name=mmu_info.name
            and classification.fclass= 'population'
            and classification.category='mmu'
        WHERE
            mmu.scenario_id = scenario_par
            AND mmu.mmu_id >= offset_par -- restricción para segmentar los datos del calculo en paralelo
            AND mmu.mmu_id <= limit_par -- restricción para segmentar los datos del calculo en paralelo)
            and mmu_info.value > 0
    ) c1;
    
    UPDATE
        buffer_squares
    SET
        transit_distance = c1.transit_distance,
        prox_to_transit_fclass = c1.fclass
    FROM (
        WITH s AS (
            SELECT
                mmu_id as pk
                ,location::geography AS LOCATION
            FROM
                buffer_squares
        ),
        tra AS (
            SELECT
                transit.location::geography AS LOCATION,
                fclass
            FROM
                transit
            WHERE
                scenario_id = scenario_par
        ),
        reg AS (
            SELECT
                s.pk,
                tra.fclass,
                min(ST_Distance(s.location, tra.location)) AS transit_distance
            FROM
                s,
                tra
            GROUP BY
                s.pk,
                tra.fclass
        ),
        reg2 AS (
            SELECT
                reg.pk,
                min(reg.transit_distance) AS transit_distance
            FROM
                reg
            GROUP BY
                reg.pk
        )
        SELECT
            reg.pk,
            reg.fclass,
            reg.transit_distance
        FROM
            reg
            INNER JOIN reg2 USING (pk, transit_distance)
    ) c1
    WHERE
        c1.pk = buffer_squares.mmu_id;
    
    for mmu_data in(
        select mmu_id,transit_distance,prox_to_transit_fclass from buffer_squares
    )
    loop
        insert into mmu_info(mmu_id,name,value)
		values(mmu_data.mmu_id,'transit_distance',mmu_data.transit_distance)
		on CONFLICT(mmu_id,name)  do update
		set value=EXCLUDED.value;

        -- insert into mmu_info(mmu_id,name,value)
		-- values(mmu_data.mmu_id,'prox_to_transit_fclass',mmu_data.prox_to_transit_fclass)
		-- on CONFLICT(mmu_id,name)  do update
		-- set value=EXCLUDED.value;
    end loop;
    
    RETURN status_par;
END;
$$;