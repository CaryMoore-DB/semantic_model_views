-- Dimension: Attorney
-- Contains information about attorneys involved in claims

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_attorney AS
SELECT 
    att.attorney_id as attorney_key,
    
    -- Provider information
    pr.provider_id,
    prole.party_role_code as provider_party_role_code,
    
    -- Party information
    p.party_id,
    p.party_name as attorney_name,
    p.party_type_code,
    
    -- Person details (if attorney is a person)
    per.person_id,
    per.prefix_name,
    per.first_name,
    per.middle_name,
    per.last_name,
    per.suffix_name,
    per.full_legal_name,
    
    -- Organization details (if attorney is part of an organization)
    org.organization_id as law_firm_id,
    org.organization_name as law_firm_name,
    org.organization_type_code as law_firm_type_code,
    
    -- Contact information
    comm.communication_id,
    comm.communication_type_code,
    comm.communication_value,
    
    -- Location information
    la.location_address_id,
    la.line_1_address,
    la.line_2_address,
    la.municipality_name as city,
    la.state_code,
    s.state_name,
    la.postal_code,
    
    -- Active date range
    p.begin_date,
    p.end_date,
    CASE 
        WHEN p.end_date IS NULL OR p.end_date >= CURRENT_DATE() 
        THEN 1 
        ELSE 0 
    END as is_active,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.attorney att
LEFT JOIN ${catalog}.${schema}.provider pr ON att.provider_id = pr.provider_id
LEFT JOIN ${catalog}.${schema}.party_role prole ON pr.party_role_code = prole.party_role_code
LEFT JOIN ${catalog}.${schema}.claim_party_role cpr ON prole.party_role_code = cpr.party_role_code
LEFT JOIN ${catalog}.${schema}.party p ON cpr.party_id = p.party_id
LEFT JOIN ${catalog}.${schema}.person per ON p.party_id = per.party_id
LEFT JOIN ${catalog}.${schema}.organization org ON p.party_id = org.party_id
LEFT JOIN ${catalog}.${schema}.party_communication pcom ON p.party_id = pcom.party_id AND pcom.preference_sequence_number = 1
LEFT JOIN ${catalog}.${schema}.communication_identity comm ON pcom.communication_id = comm.communication_id
LEFT JOIN ${catalog}.${schema}.geographic_location gl ON comm.geographic_location_id = gl.geographic_location_id
LEFT JOIN ${catalog}.${schema}.location_address la ON gl.location_address_id = la.location_address_id
LEFT JOIN ${catalog}.${schema}.state s ON la.state_code = s.state_code;
