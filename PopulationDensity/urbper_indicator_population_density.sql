CREATE OR REPLACE FUNCTION urbper_indicator_population_density(scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
    pop_tot_var FLOAT;
    area_var double precision;
begin
	select value into area_var 
    from results 
    where scenario_id= scenario_par and name='footprint_km2';

    select value into pop_tot_var 
    from results 
    where scenario_id= scenario_par and name='pop_total';

    insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'pop_density', (pop_tot_var/area_var))
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;

	return true;
end;

$$;
