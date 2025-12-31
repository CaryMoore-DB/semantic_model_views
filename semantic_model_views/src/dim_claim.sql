-- Dimension: Claim
-- Contains claim-level information including occurrence and catastrophe details

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_claim AS
SELECT 
    c.claim_id as claim_key,
    c.company_claim_number,
    c.company_subclaim_number,
    c.claim_description,
    c.claim_open_date,
    c.claim_close_date,
    c.claim_reopen_date,
    c.claim_status_code,
    c.claim_reported_date,
    c.claims_made_date,
    
    -- Claim lifecycle indicators
    CASE WHEN c.claim_close_date IS NOT NULL THEN 1 ELSE 0 END as is_closed,
    CASE WHEN c.claim_reopen_date IS NOT NULL THEN 1 ELSE 0 END as is_reopened,
    CASE WHEN c.claim_status_code = 'OPEN' THEN 1 ELSE 0 END as is_open,
    
    -- Days calculations
    DATEDIFF(COALESCE(c.claim_close_date, CURRENT_DATE()), c.claim_open_date) as days_open,
    DATEDIFF(c.claim_reported_date, c.claim_open_date) as reporting_lag_days,
    
    -- Occurrence information
    o.occurrence_id,
    o.occurrence_begin_date,
    o.occurrence_begin_time,
    o.occurrence_end_date,
    o.occurrence_end_time,
    o.catastrophic_event_indicator,
    
    -- Occurrence location
    ogl.geographic_location_id as occurrence_location_id,
    ogl.location_name as occurrence_location_name,
    ogl.state_code as occurrence_state_code,
    os.state_name as occurrence_state_name,
    
    -- Catastrophe information
    cat.catastrophe_id,
    cat.catastrophe_name,
    cat.catastrophe_type_code,
    cat.industry_catastrophe_code,
    cat.company_catastrophe_code,
    CASE WHEN cat.catastrophe_id IS NOT NULL THEN 1 ELSE 0 END as is_catastrophe,
    
    -- Insurable object (risk)
    c.insurable_object_id,
    
    -- Claim coverage count
    (SELECT COUNT(*) FROM ${catalog}.${schema}.claim_coverage cc WHERE cc.claim_id = c.claim_id) as coverage_count,
    
    -- Litigation indicators
    CASE WHEN EXISTS (
        SELECT 1 FROM ${catalog}.${schema}.claim_litigation cl WHERE cl.claim_id = c.claim_id
    ) THEN 1 ELSE 0 END as has_litigation,
    
    -- Arbitration indicators
    CASE WHEN EXISTS (
        SELECT 1 FROM ${catalog}.${schema}.claim_arbitration ca WHERE ca.claim_id = c.claim_id
    ) THEN 1 ELSE 0 END as has_arbitration,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.claim c
LEFT JOIN ${catalog}.${schema}.occurrence o ON c.occurrence_id = o.occurrence_id
LEFT JOIN ${catalog}.${schema}.geographic_location ogl ON o.geographic_location_id = ogl.geographic_location_id
LEFT JOIN ${catalog}.${schema}.state os ON ogl.state_code = os.state_code
LEFT JOIN ${catalog}.${schema}.catastrophe cat ON c.catastrophe_id = cat.catastrophe_id;
