CREATE OR REPLACE FUNCTION urbper_indicator_energy_solid_waste(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
	city_code_par double precision;
	country_code_par double precision;
    waste_level_par double precision;
    total_pop double precision;
    landf_energy double precision;
    tot_wvol double precision;
    land_ef double precision;
    truck3_ef double precision;
    
    TS_energy double precision;
    energy_tonTS double precision;
    
    transport_energy_par double precision;
    truck1_ef double precision;
    diesel_den double precision;
    diesel_cv double precision;
    truck1_cap double precision;
    dist_land double precision;
    dist_ts double precision;
    truck2_ef double precision;
    truck2_cap double precision;
    dist_tsland double precision;
    
    collection_energy_par double precision;
    prim_road_km2_par double precision;
    prim_road_fact double precision;
    sec_road_km2_par double precision;
    sec_road_fact double precision;
    ter_road_km2_par double precision;
    ter_road_fact double precision;
    collections double precision;
    footprint_km2_par double precision;
    comp_ef double precision;
    waste_density double precision;
    waste_per double precision;
    status BOOLEAN = TRUE;
begin
	
    -- obtener de la base de datos los valores de todas las variables necesarias para el cálculo
    select value into land_ef from assumptions where name='land_ef' and category='waste' and scenario_id=scenario_par;
    select value into truck3_ef from assumptions where name='truck3_ef' and category='waste' and scenario_id=scenario_par;
    
    select value into energy_tonTS from assumptions where name='energy_tonTS' and category='waste' and scenario_id=scenario_par;    
    
    select value into truck1_ef from assumptions where name='truck1_ef' and category='waste' and scenario_id=scenario_par;
    select value into diesel_den from assumptions where name='diesel_den' and category='general' and scenario_id=scenario_par;
    select value into diesel_cv from assumptions where name='diesel_cv' and category='general' and scenario_id=scenario_par;
    select value into truck1_cap from assumptions where name='truck1_cap' and category='waste' and scenario_id=scenario_par;
    select value into dist_land from assumptions where name='dist_land' and category='waste' and scenario_id=scenario_par;
    select value into dist_ts from assumptions where name='dist_ts' and category='waste' and scenario_id=scenario_par;
    select value into truck2_ef from assumptions where name='truck2_ef' and category='waste' and scenario_id=scenario_par;
    select value into truck2_cap from assumptions where name='truck2_cap' and category='waste' and scenario_id=scenario_par;
    select value into dist_tsland from assumptions where name='dist_tsland' and category='waste' and scenario_id=scenario_par;
    
    select value into prim_road_fact from assumptions where name='prim_road_fact' and category='waste' and scenario_id=scenario_par;
    select value into sec_road_fact from assumptions where name='sec_road_fact' and category='waste' and scenario_id=scenario_par;
    select value into ter_road_fact from assumptions where name='ter_road_fact' and category='waste' and scenario_id=scenario_par;
    select value into collections from assumptions where name='collections' and category='waste' and scenario_id=scenario_par;
    select value into comp_ef from assumptions where name='comp_ef' and category='waste' and scenario_id=scenario_par;
    select value into waste_density from assumptions where name='waste_density' and category='waste' and scenario_id=scenario_par;
    select value into waste_per from assumptions where name='waste_per' and category='waste' and scenario_id=scenario_par;

    select value into ter_road_km2_par 
    from results 
    where scenario_id= scenario_par and name='ter_road_km2';

    select value into prim_road_km2_par
    from results 
    where scenario_id= scenario_par and name='prim_road_km2';

    select value into sec_road_km2_par
    from results 
    where scenario_id= scenario_par and name='sec_road_km2';

    select value into footprint_km2_par
    from results 
    where scenario_id= scenario_par and name='footprint_km2';

    select value into total_pop 
    from results 
    where scenario_id= scenario_par and name='pop_total';
    
    -- Realizar el cálculo de solid waste
    /*loop
    begin*/
    landf_energy = COALESCE(((total_pop*waste_per*365)/1000::double precision/land_ef::double precision)*truck3_ef,0);
        /*exit;
        EXCEPTION WHEN deadlock_detected THEN status=false; exit;
        when others then landf_energy =0; exit;
    end;
    end loop;*/
    
    /*loop
    begin*/
    TS_energy = COALESCE((total_pop*waste_per*365/1000::double precision)*energy_tonTS,0);
   		/*exit;
        EXCEPTION WHEN deadlock_detected THEN status=false; exit;
        when others then TS_energy = 0; exit;
    end;
    end loop;*/
    /*loop
    begin*/
    transport_energy_par = COALESCE(((truck1_ef/1000::double precision)*diesel_den*diesel_cv)*((total_pop*waste_per*365/1000::double precision)/truck1_cap::double precision)*dist_land,0)+    	
        COALESCE(((truck1_ef/1000::double precision)*diesel_den*diesel_cv)*((total_pop*waste_per*365/1000::double precision)/truck1_cap::double precision)*dist_ts,0)+
        COALESCE(((truck2_ef/1000::double precision)*diesel_den*diesel_cv)*((total_pop*waste_per*365/1000::double precision)/truck2_cap::double precision)*dist_tsland,0);    
        /*exit;
        EXCEPTION WHEN deadlock_detected THEN status=false; exit;
        when others then transport_energy_par = 0; exit;
    end;
    end loop;*/
    /*loop
    begin*/
    collection_energy_par = ( COALESCE((((truck1_ef/1000::double precision)*diesel_den*diesel_cv)*( COALESCE(prim_road_km2_par*prim_road_fact/100::double precision,0)+
        COALESCE(sec_road_km2_par *sec_road_fact/100,0)+
        COALESCE(ter_road_km2_par*ter_road_fact/100,0))*collections*52)* footprint_km2_par,0)+
        COALESCE((((comp_ef/1000::double precision)*diesel_den)*diesel_cv)*((total_pop*waste_per*365)/waste_density::double precision),0));
        /*exit;
        EXCEPTION WHEN deadlock_detected THEN status=false; exit;
        when others then collection_energy_par = 0; exit;
	end;
    end loop;*/
    -- Guardar el resultado obtenido en la tabla de results

    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'energy_swaste',(( COALESCE(collection_energy_par,0) + COALESCE(transport_energy_par,0) + COALESCE(TS_energy,0) + COALESCE(landf_energy,0)) / total_pop::double precision))
        ,(scenario_par,'collection_energy',collection_energy_par)
        ,(scenario_par,'transport_energy',transport_energy_par)
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;

    /*insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'collection_energy',collection_energy_par)
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
    
    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'transport_energy',transport_energy_par)
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;*/
        
    return status;
end;

$$;
