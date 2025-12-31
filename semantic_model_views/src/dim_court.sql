-- Dimension: Court
-- Contains court and legal jurisdiction information

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_court AS
SELECT 
    cj.court_jurisdiction_id as court_key,
    cj.court_id,
    cj.jurisdiction_id,
    
    -- Legal jurisdiction information
    lj.legal_jurisdiction_id,
    lj.legal_jurisdiction_name,
    lj.legal_jurisdiction_description,
    lj.rules_preference_description,
    
    -- Court type derived from litigation
    CASE 
        WHEN lj.legal_jurisdiction_name LIKE '%Federal%' THEN 'Federal'
        WHEN lj.legal_jurisdiction_name LIKE '%State%' THEN 'State'
        WHEN lj.legal_jurisdiction_name LIKE '%County%' THEN 'County'
        WHEN lj.legal_jurisdiction_name LIKE '%Municipal%' THEN 'Municipal'
        ELSE 'Other'
    END as court_level,
    
    -- Approximate court location (would need additional tables for full detail)
    -- This is a simplified version
    lj.legal_jurisdiction_name as court_location,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.court_jurisdiction cj
LEFT JOIN ${catalog}.${schema}.legal_jurisdiction lj ON cj.jurisdiction_id = lj.legal_jurisdiction_id;
