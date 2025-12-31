-- Dimension: Risk (Insurable Object)
-- Contains information about what is being insured

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_risk AS
SELECT 
    io.insurable_object_id as risk_key,
    io.insurable_object_type_code,
    
    -- Vehicle information
    v.vehicle_id,
    v.vehicle_identification_number as vin,
    v.vehicle_make_name,
    v.vehicle_model_name,
    v.vehicle_model_year,
    
    -- Automobile specifics
    CASE WHEN auto.automobile_id IS NOT NULL THEN 'Automobile'
         WHEN truck.truck_id IS NOT NULL THEN 'Truck'
         WHEN van.van_id IS NOT NULL THEN 'Van'
         WHEN mc.motorcycle_id IS NOT NULL THEN 'Motorcycle'
         WHEN rv.recreational_vehicle_id IS NOT NULL THEN 'RV'
         WHEN boat.boat_id IS NOT NULL THEN 'Boat'
         WHEN bus.bus_id IS NOT NULL THEN 'Bus'
         WHEN trailer.trailer_id IS NOT NULL THEN 'Trailer'
         ELSE NULL
    END as vehicle_type,
    
    -- Structure information
    str.structure_id,
    CASE WHEN cs.commercial_structure_id IS NOT NULL THEN 'Commercial'
         WHEN rs.residential_structure_id IS NOT NULL THEN 'Residential'
         WHEN comb.combination_structure_id IS NOT NULL THEN 'Combination'
         ELSE NULL
    END as structure_type,
    
    -- Dwelling specifics
    dw.dwelling_id,
    mh.mobile_home_id,
    
    -- Farm equipment
    fe.farm_equipment_id,
    CASE WHEN tr.tractor_id IS NOT NULL THEN 'Tractor'
         WHEN comb_eq.combine_id IS NOT NULL THEN 'Combine'
         WHEN mm.milking_machine_id IS NOT NULL THEN 'Milking Machine'
         ELSE NULL
    END as farm_equipment_type,
    
    -- Workers comp
    wc.workers_comp_class_id,
    
    -- Transportation
    tc.transportation_class_id,
    
    -- Geographic location of the risk
    io.geographic_location_id,
    gl.location_name,
    gl.location_code,
    gl.state_code,
    s.state_name,
    
    -- Physical address
    la.location_address_id,
    la.line_1_address,
    la.line_2_address,
    la.municipality_name,
    la.postal_code,
    
    -- Risk category
    CASE 
        WHEN v.vehicle_id IS NOT NULL THEN 'Vehicle'
        WHEN str.structure_id IS NOT NULL THEN 'Structure'
        WHEN fe.farm_equipment_id IS NOT NULL THEN 'Farm Equipment'
        WHEN wc.workers_comp_class_id IS NOT NULL THEN 'Workers Comp'
        WHEN tc.transportation_class_id IS NOT NULL THEN 'Transportation'
        ELSE 'Other'
    END as risk_category,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.insurable_object io
LEFT JOIN ${catalog}.${schema}.vehicle v ON io.insurable_object_id = v.insurable_object_id
LEFT JOIN ${catalog}.${schema}.automobile auto ON v.vehicle_id = auto.vehicle_id
LEFT JOIN ${catalog}.${schema}.truck truck ON v.vehicle_id = truck.vehicle_id
LEFT JOIN ${catalog}.${schema}.van van ON v.vehicle_id = van.vehicle_id
LEFT JOIN ${catalog}.${schema}.motorcycle mc ON v.vehicle_id = mc.vehicle_id
LEFT JOIN ${catalog}.${schema}.recreational_vehicle rv ON v.vehicle_id = rv.vehicle_id
LEFT JOIN ${catalog}.${schema}.boat boat ON v.vehicle_id = boat.vehicle_id
LEFT JOIN ${catalog}.${schema}.bus bus ON v.vehicle_id = bus.vehicle_id
LEFT JOIN ${catalog}.${schema}.trailer trailer ON v.vehicle_id = trailer.vehicle_id
LEFT JOIN ${catalog}.${schema}.structure str ON io.insurable_object_id = str.insurable_object_id
LEFT JOIN ${catalog}.${schema}.commercial_structure cs ON str.structure_id = cs.structure_id
LEFT JOIN ${catalog}.${schema}.residential_structure rs ON str.structure_id = rs.structure_id
LEFT JOIN ${catalog}.${schema}.combination_structure comb ON str.structure_id = comb.structure_id
LEFT JOIN ${catalog}.${schema}.dwelling dw ON rs.residential_structure_id = dw.residential_structure_id
LEFT JOIN ${catalog}.${schema}.mobile_home mh ON rs.residential_structure_id = mh.residential_structure_id
LEFT JOIN ${catalog}.${schema}.farm_equipment fe ON io.insurable_object_id = fe.insurable_object_id
LEFT JOIN ${catalog}.${schema}.tractor tr ON fe.farm_equipment_id = tr.farm_equipment_id
LEFT JOIN ${catalog}.${schema}.combine comb_eq ON fe.farm_equipment_id = comb_eq.farm_equipment_id
LEFT JOIN ${catalog}.${schema}.milking_machine mm ON fe.farm_equipment_id = mm.farm_equipment_id
LEFT JOIN ${catalog}.${schema}.workers_comp_class wc ON io.insurable_object_id = wc.insurable_object_id
LEFT JOIN ${catalog}.${schema}.transportation_class tc ON io.insurable_object_id = tc.insurable_object_id
LEFT JOIN ${catalog}.${schema}.geographic_location gl ON io.geographic_location_id = gl.geographic_location_id
LEFT JOIN ${catalog}.${schema}.state s ON gl.state_code = s.state_code
LEFT JOIN ${catalog}.${schema}.location_address la ON gl.location_address_id = la.location_address_id;
