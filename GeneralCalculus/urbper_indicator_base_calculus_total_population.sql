
CREATE OR REPLACE FUNCTION urbper_indicator_base_calculus_total_population(scenario_par integer DEFAULT 0,base_scenario_par integer DEFAULT 0) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
	city_code_par integer;
	country_code_par integer;
    tot_pop_var double precision;
    pop_total_temp double precision;
	pop_level_par integer;
	prioritize_tod_level_par integer;
	vacant_hu_level_par integer;
    status_par BOOLEAN;
    political_boundary geometry;
    footprint_horizon geometry;
    footprint_base geometry;
	priority1_poligon geometry;
    intersected geometry;
    level_par integer;
    --base_scenario_par INTEGER;
	
	hu_tot_par double PRECISION;
    vhu_tot_par double PRECISION;
	b_hu_tot_par double PRECISION;
    b_vhu_tot_par double PRECISION;

    vhu_rate_par double PRECISION;
    vhu_reduction double PRECISION;
	min_vhu_rate double PRECISION;
begin
	status_par = TRUE;

	select 
		value
	into 
		prioritize_tod_level_par 
	from 
		assumptions
	where
		scenario_id=scenario_par
		and category='prioritize_tod'
		and name='prioritize_tod';

	--vacant_hu must be established in 0 to indicate that the population is equivalent to level 0
	select 
		value
	into 
		vacant_hu_level_par 
	from 
		assumptions
	where
		scenario_id=scenario_par
		and category='vacant_hu'
		and name='vacant_hu';
	
	select 
		value 
	into 
		min_vhu_rate 
	from 
		assumptions 
	where 
		category='vacant_hu' 
		and name='min_vhu_rate' 
		and scenario_id=scenario_par;
	-- select footprint_level into level_par from scenario where scenario_id=scenario_par;
    
    select 
		st_collectionextract(st_makevalid(footprint.location),3)  
	into 
		footprint_base 
	from 
		footprint
		inner join classification on classification.name=footprint.name
	where 
		classification.fclass= 'footprint_base'
		and classification.category='footprint'
		and scenario_id = scenario_par;
	
    select 
		st_collectionextract(st_makevalid(footprint.location),3)  
	into 
		political_boundary 
	from 
		footprint
		inner join classification on classification.name=footprint.name
	where 
		classification.fclass= 'study_area'
		and classification.category='footprint'
		and scenario_id = scenario_par;
    
	-- select 
	-- 	scenario_id 
	-- into 
	-- 	base_scenario_par 
	-- from 
	-- 	scenario 
	-- where 
	-- 	lower(scenario_name)= 'base' ;
    
	select 
		st_collectionextract(st_makevalid(footprint.location),3)
	into 
		footprint_horizon 
	from 
		footprint
		inner join classification on classification.name=footprint.name
	where 
		classification.fclass=  'footprint_horizon' 
		and classification.category='footprint'
		and scenario_id = scenario_par;
    
-- Obtener la poblacion total del escenario, este cálculo se moverá a un procedimiento almacenado similar base_calculus_transit
	with squares_intersected as(
		select 
			p.value as population,s.location
		from
			mmu_info p
		inner join
			mmu s using(mmu_id)
		inner join
			classification on classification.name=p.name
		where  
			classification.category='mmu'
			and s.scenario_id=scenario_par
			and st_contains(political_boundary,s.location)
			and classification.fclass='population'
	)
		select 
			sum(population) population
		into
			tot_pop_var 
		from
			squares_intersected
	;
	
	--Delete previous results
	delete from 
		results 
	where 
		scenario_id=scenario_par;
	
	insert into 
		results ("scenario_id","name","value")
	values
		(scenario_par,'pop_total',tot_pop_var)
	on conflict 
		("scenario_id","name")
	do update set
		"value"= excluded.value;
	
	-- Calculate the total infill area
	select 
		st_collectionextract(st_makevalid("location"),3) 
		into priority1_poligon 
	from 
		footprint
		inner join
			classification on classification.name=footprint.name
	where 
		classification.fclass=  'footprint_horizon' 
		and classification.category='footprint'
		and scenario_id=scenario_par;
	
	DROP TABLE IF EXISTS changed_squares; 
	
	create temp table changed_squares as(
		select
			population.mmu_id,
			population.oskari_code, 
			case when (
				(
					prioritize_tod_level_par=2  
					and st_contains(priority1_poligon,population.location)
					and not st_contains(footprint_base,population.location) 
					and population.area=0
				)
				or 
				(
					population.population> c1.population 
					and not st_contains(footprint_base,population.location)
				)
			)
			then
				area
			else
				-1
			end as "area",
			population.location
			,c1.population 
		from 
			(
				select 
					oskari_code, 
					mmu_info.value as population 
				from 
					mmu
				inner join
					mmu_info using(mmu_id)
				inner join
					classification on classification.name=mmu_info.name
				where  
					classification.category='mmu'
					and classification.fclass='population'
					and scenario_id= base_scenario_par
			)c1
			inner join
			(
				select
						S1.mmu_id,
						S1.oskari_code,
						S1.location,
						S1.population,
						S2.area
				from
					(
						select
							mmu_id,
							oskari_code,
							mmu.location,
							mmu_info.value as population 
						from 
							mmu
						inner join
							mmu_info using(mmu_id)
						inner join
							classification on classification.name=mmu_info.name
						where  
							classification.category='mmu'
							and classification.fclass='population'
							and scenario_id= base_scenario_par
					)S1
					inner join
					(
						select
							mmu_id,
							mmu_info.value as area 
						from 
							mmu
						inner join
							mmu_info using(mmu_id)
						inner join
							classification on classification.name=mmu_info.name
						where  
							classification.category='mmu'
							and classification.fclass='area'
							and scenario_id= base_scenario_par
					)S2 using(mmu_id)

			) population
			using (oskari_code)
	);
	
	update 
		mmu_info 
	set 
		value=changed_squares.area 
	from 
		changed_squares
	where mmu_info.mmu_id=changed_squares.mmu_id -- esto garantiza que solo los mmu del escenario
		and changed_squares.area >= 0;
	
	select 
		sum(value)
	into 
		hu_tot_par
	from 
		mmu
	inner join 
		mmu_info using(mmu_id)
	inner join classification on classification.name=mmu_info.name
        and classification.category='mmu'
        and classification.fclass='hu'
	where 
		mmu.scenario_id=scenario_par;
	
	select 
		sum(value)
	into 
		vhu_tot_par 
	from 
		mmu
	inner join 
		mmu_info using(mmu_id)
	inner join classification on classification.name=mmu_info.name
        and classification.category='mmu'
        and classification.fclass='vhu'
	where 
		mmu.scenario_id=scenario_par
		and mmu_info.name='vhu';
	
	select 
		sum(value)
	into 
		b_hu_tot_par
	from 
		mmu
	inner join 
		mmu_info using(mmu_id)
	inner join classification on classification.name=mmu_info.name
        and classification.category='mmu'
        and classification.fclass='hu'
	where 
		mmu.scenario_id=base_scenario_par
		and mmu_info.name='hu';
	
	select 
		sum(value)
	into 
		b_vhu_tot_par 
	from 
		mmu
	inner join 
		mmu_info using(mmu_id)
	inner join classification on classification.name=mmu_info.name
        and classification.category='mmu'
        and classification.fclass='hu'
	where 
		mmu.scenario_id=base_scenario_par
		and mmu_info.name='hu';
	
	select 
		vhu_tot_par/hu_tot_par 
	into 
		vhu_rate_par;

	if vacant_hu_level_par=0 then
		min_vhu_rate=vhu_rate_par;
	end if;
	

	insert into 
		results(
			scenario_id,
			name,
			value
		)
	values(
		scenario_par,
		'infill_area_km2',
		case when (
			select 
				sum(c2.area)/100::float
			from
				(
					select
						oskari_code,
						value as population
					from
						mmu
					inner join
						mmu_info
						using(mmu_id)
					inner join
							classification on classification.name=mmu_info.name
					where  
						classification.category='mmu'
						and classification.fclass='population'
						and scenario_id=base_scenario_par
				)c1
				inner join
				(
					select 
						S1.mmu_id,
						S1.oskari_code,
						S1.population,
						S1.location,
						S2.area
					from
						(
							select 
								mmu_id,
								oskari_code,
								value as population,
								location
							from
								mmu
							inner join
								mmu_info
								using(mmu_id)
							inner join
								classification on classification.name=mmu_info.name
							where  
								classification.category='mmu'
								and classification.fclass='population'
								and scenario_id=scenario_par
						)S1
						inner JOIN
						(
							select 
								mmu_id,
								value as area
							from
								mmu
							inner join
								mmu_info
								using(mmu_id)
							inner join
								classification on classification.name=mmu_info.name
							where  
								classification.category='mmu'
								and classification.fclass='population'
								and scenario_id=scenario_par
						)S2 using(mmu_id)
				)c2
				using(oskari_code)
			where
				c2.population > c1.population * 2
				and st_contains(footprint_base, c2.location)
		) is null then 0 else (
			select 
				sum(c2.area)/100::float
			from
				(
					select
						oskari_code,
						value as population
					from
						mmu
					inner join
						mmu_info
						using(mmu_id)
					inner join
						classification on classification.name=mmu_info.name
					where  
						classification.category='mmu'
						and classification.fclass='population'
						and scenario_id=base_scenario_par
				)c1
				inner join
				(
					select 
						S1.mmu_id,
						S1.oskari_code,
						S1.population,
						S1.location,
						S2.area
					from
						(
							select 
								mmu_id,
								oskari_code,
								value as population,
								location
							from
								mmu
							inner join
								mmu_info
								using(mmu_id)
							inner join
								classification on classification.name=mmu_info.name
							where  
								classification.category='mmu'
								and classification.fclass='population'
								and scenario_id=scenario_par
						)S1
						inner JOIN
						(
							select 
								mmu_id,
								value as area
							from
								mmu
							inner join
								mmu_info
								using(mmu_id)
							inner join
								classification on classification.name=mmu_info.name
							where  
								classification.category='mmu'
								and classification.fclass='population'
								and scenario_id=scenario_par
						)S2 using(mmu_id)
				)c2
				using(oskari_code)
			where
				c2.population > c1.population * 2
				and st_contains(footprint_base, c2.location)
		) end
	)
	ON CONFLICT (scenario_id,name)
	do update
	set 
		value= excluded.value;


		insert into 
			results(
				scenario_id,
				name,
				value
			)
		values(
			scenario_par,
			'pop_infill',
			case when (
				select 
					sum(c2.population-c1.population)
				from
					(
						select
							oskari_code,
							value as population
						from
							mmu
						inner join
							mmu_info
							using(mmu_id)
						inner join
							classification on classification.name=mmu_info.name
						where  
							classification.category='mmu'
							and classification.fclass='population'
							and scenario_id=base_scenario_par
					)c1
					inner join
					(
						select
							oskari_code,
							value as population,
							location
						from
							mmu
						inner join
							mmu_info
							using(mmu_id)
						inner join
							classification on classification.name=mmu_info.name
						where  
							classification.category='mmu'
							and classification.fclass='population'
							and scenario_id=scenario_par
					)c2
					using(oskari_code)
				where
					st_contains(footprint_base, c2.location)
			) is null then 0 else (
				select 
					sum(c2.population-c1.population)
				from
					(
						select
							oskari_code,
							value as population
						from
							mmu
						inner join
							mmu_info
							using(mmu_id)
						inner join
							classification on classification.name=mmu_info.name
						where  
							classification.category='mmu'
							and classification.fclass='population'
							and scenario_id=base_scenario_par
					)c1
					inner join
					(
						select
							oskari_code,
							value as population,
							location
						from
							mmu
						inner join
							mmu_info
							using(mmu_id)
						inner join
							classification on classification.name=mmu_info.name
						where  
							classification.category='mmu'
							and classification.fclass='population'
							and scenario_id=scenario_par
					)c2
					using(oskari_code)
				where
					st_contains(footprint_base, c2.location)
			) end
		)
		ON CONFLICT (scenario_id,name)
		do update
		set 
			value= excluded.value;

		-- Aquí hay que revisarlo
		insert into 
			results(
				scenario_id,
				name,
				value
			)
		values(
			scenario_par,
			'vhu_tot',
			case  when (
				vhu_tot_par+(
					hu_tot_par- b_hu_tot_par
				) * (
					min_vhu_rate/100::float
				)
			) is null then 0 else (
				vhu_tot_par+(
					hu_tot_par- b_hu_tot_par
				) * (
					min_vhu_rate/100::float
				)
			) end
		)
		ON CONFLICT (scenario_id,name)
		do update
		set 
			value= excluded.value;
		
		insert into 
			results(
				scenario_id,
				name,
				value
			)
		values(
			scenario_par,
			'hu_tot',
			case when(
				hu_tot_par
			) is null then 0 else (
				hu_tot_par
			) end
		)
		ON CONFLICT (scenario_id,name)
		do update
		set 
			value= excluded.value;
		
		insert into 
			results(
				scenario_id,
				name,
				value
			)
		values(
			scenario_par,
			'vhu_rate',
			case when (
				(
					vhu_tot_par+(
						hu_tot_par- b_hu_tot_par
					) * (
						min_vhu_rate/100::float
					)
				)/hu_tot_par
			) is null then 0 else (
				(
					vhu_tot_par+(
						hu_tot_par- b_hu_tot_par
					) * (
						min_vhu_rate/100::float
					)
				)/hu_tot_par
			) end
		)
		ON CONFLICT (scenario_id,name)
		do update
		set 
			value= excluded.value;

	insert into 
		results(
			scenario_id,
			name,
			value
		)
	values(
		scenario_par,
		'pop_expan',
		case when (
			select 
				sum(c1.population)
			from
				(
					select
						value as population,
						location
					from
						mmu
					inner join
						mmu_info
						using(mmu_id)
					inner join
						classification on classification.name=mmu_info.name
					where  
						classification.category='mmu'
						and classification.fclass='population'
						and scenario_id=scenario_par
						
				)c1
			where
				not st_contains(footprint_base, c1.location)
		) is null then 0 else (
			select 
				sum(c1.population)
			from
				(
					select
						value as population,
						location
					from
						mmu
					inner join
						mmu_info
						using(mmu_id)
					inner join
						classification on classification.name=mmu_info.name
					where  
						classification.category='mmu'
						and classification.fclass='population'
						and scenario_id=scenario_par
				)c1
			where
				not st_contains(footprint_base, c1.location)
		) end
	)
	on conflict(
		scenario_id,
		name
	) 
	do update set
		value=excluded.value;

    return status_par;
end;

$$;
