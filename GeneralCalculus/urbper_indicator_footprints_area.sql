CREATE OR REPLACE FUNCTION urbper_indicator_footprints_area
(scenario_par integer DEFAULT 0) RETURNS void
    LANGUAGE plpgsql
    AS $$

declare 
    study_area geometry;
begin
    
    select location
    into study_area
    from footprint
    inner join classification on classification.name=footprint.name
    where 
        classification.category='footprint'
        and classification.fclass='study_area'
        and scenario_id = scenario_par;

    update footprint
        set "value" = st_area( st_intersection(st_collectionextract(
        st_makevalid(study_area),3),
        st_collectionextract(
            st_makevalid(location),3))
    ::geography)/1e6
    where scenario_id=scenario_par and value is null;
end;
$$;
