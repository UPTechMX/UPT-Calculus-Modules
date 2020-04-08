CREATE OR REPLACE FUNCTION urbper_indicator_energy_transport(scenario_par integer DEFAULT 0, offset_par integer DEFAULT 0, limit_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
	city_code_par float;
	country_code_par float;
    transport_energy_level_par float;
	pop_level_par int;
        
    JDMXN_exrate float;
    avge_inflation float;
    hu_size float;
    gasoline_transp_frac float;
    diesel_transp_frac float;
    gasoline_cv float;
    gasoline_cost float;
    gasoline_density float;
    diesel_cv float;
    diesel_cost float;
    diesel_density float;
    
    transport_cost float;
    transport_cost_gasoline float;
    transport_cost_diesel float;
    energy_gasoline_par float;
    energy_diesel_par float;
    energy_transport_par float;
	socio_eco_par int;
    square record;
    status BOOLEAN=true;
begin
	
    select value into hu_size from assumptions where name='hu_size' and category='general' and scenario_id = scenario_par ;
    select value into jdmxn_exrate from assumptions where name='JDMXN_exrate' and category='general' and scenario_id = scenario_par ;
    select value into gasoline_cv from assumptions where name='gasoline_cv' and category='general' and scenario_id = scenario_par ;
    select value into diesel_cost from assumptions where name='diesel_cost' and category='costs' and scenario_id = scenario_par ;
    select value into diesel_density from assumptions where name='diesel_den' and category='general' and scenario_id = scenario_par ;
    select value into diesel_cv from assumptions where name='diesel_cv' and category='general' and scenario_id = scenario_par ;
    select value into gasoline_cost from assumptions where name='gasoline_cost' and category='general' and scenario_id = scenario_par ;
    select value into gasoline_density from assumptions where name='gasoline_den' and category='general' and scenario_id = scenario_par ;
    select value into gasoline_transp_frac from assumptions where name='gasoline_transp_frac' and category='transport_energy' and scenario_id = scenario_par;
    select value into diesel_transp_frac from assumptions where name='diesel_transp_frac' and category='transport_energy' and scenario_id = scenario_par;
    select value into avge_inflation from assumptions where name='avge_inflation' and category='general' and scenario_id = scenario_par;
	select value into socio_eco_par from assumptions where name='socioeco_level' and category='general' and scenario_id = scenario_par;
    
    -- obtener los km lineales de vialidades desde la tabla de assumptions, a futuro estas distancias se calcularán en el sistema
    for square in (
        select mmu_id,transit_distance,job_density_avge,pop_density_avge,avge_area,population,socio_eco_par
        from (
            select mmu_id,value as transit_distance
            from mmu
            inner join mmu_info using(mmu_id)
            where mmu.scenario_id=scenario_par
            and mmu_info.name='transit_distance'
            and mmu.mmu_id >= offset_par -- restricción para segmentar los datos del calculo en paralelo
            and mmu.mmu_id <= limit_par-- restricción para segmentar los datos del calculo en paralelo),|
        ) q1
        full outer join
        (
            select mmu_id,value as job_density_avge
            from mmu
            inner join mmu_info using(mmu_id)
            where mmu.scenario_id=scenario_par
            and mmu_info.name='job_density_avge'
            and mmu.mmu_id >= offset_par -- restricción para segmentar los datos del calculo en paralelo
            and mmu.mmu_id <= limit_par-- restricción para segmentar los datos del calculo en paralelo),
        ) q2 USING(mmu_id)
        full outer join
        (
            select mmu_id,value as pop_density_avge
            from mmu
            inner join mmu_info using(mmu_id)
            where mmu.scenario_id=scenario_par
            and mmu_info.name='pop_density_avge'
            and mmu.mmu_id >= offset_par -- restricción para segmentar los datos del calculo en paralelo
            and mmu.mmu_id <= limit_par-- restricción para segmentar los datos del calculo en paralelo),
        ) q3 USING(mmu_id)
        full outer join
        (
            select mmu_id,value as avge_area
            from mmu
            inner join mmu_info using(mmu_id)
            where mmu.scenario_id=scenario_par
            and mmu_info.name='avge_area'
            and mmu.mmu_id >= offset_par -- restricción para segmentar los datos del calculo en paralelo
            and mmu.mmu_id <= limit_par-- restricción para segmentar los datos del calculo en paralelo),
        ) q4 USING(mmu_id)
        full outer join
        (
            select mmu_id,value as population
            from mmu
            inner join mmu_info using(mmu_id)
            inner join classification 
                on classification.name=mmu_info.name
                and classification.fclass= 'population'
                and classification.category='mmu'
            where mmu.scenario_id=scenario_par
                and mmu.mmu_id >= offset_par -- restricción para segmentar los datos del calculo en paralelo
                and mmu.mmu_id <= limit_par-- restricción para segmentar los datos del calculo en paralelo),

        ) q5 USING(mmu_id)
    )
    loop
    begin
        transport_cost = greatest(0 ,  ( 4 / jdmxn_exrate * ( 1 + avge_inflation/100 ) * ( -4030.06 + 3.06 * COALESCE(square.transit_distance,0) + ( -19.10 ) * COALESCE(square.job_density_avge,0) + ( -0.69 ) * COALESCE(square.pop_density_avge,0) + 213.09 * COALESCE(square.avge_area,0) + 661.16 * socio_eco_par ) ) / hu_size );
        transport_cost_gasoline = transport_cost * gasoline_transp_frac/100;
        transport_cost_diesel = transport_cost * diesel_transp_frac/100;
        energy_gasoline_par = square.population*transport_cost_gasoline * ( gasoline_cv / gasoline_cost * gasoline_density / 1000 );
        energy_diesel_par = square.population*transport_cost_diesel * ( diesel_cv / diesel_cost * diesel_density / 1000 );
        energy_transport_par = COALESCE(energy_diesel_par,0) + COALESCE(energy_gasoline_par,0);

        insert into 
            mmu_info ("mmu_id","name","value")
        values
            (square.mmu_id,'energy_transport',energy_transport_par)
        on conflict 
            ("mmu_id", "name")
        do update set
            "value"= excluded.value;
        
        insert into 
            mmu_info ("mmu_id","name","value")
        values
            (square.mmu_id,'energy_gasoline',energy_gasoline_par)
        on conflict 
            ("mmu_id", "name")
        do update set
            "value"= excluded.value;

        insert into 
            mmu_info ("mmu_id","name","value")
        values
            (square.mmu_id,'energy_diesel',energy_diesel_par)
        on conflict 
            ("mmu_id", "name")
        do update set
            "value"= excluded.value;
    end;
    end loop;

    return status;
end;

$$;