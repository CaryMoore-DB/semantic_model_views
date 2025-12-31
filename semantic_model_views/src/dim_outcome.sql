-- Dimension: Outcome
-- Contains information about litigation and arbitration outcomes

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_outcome AS
SELECT 
    -- Create a combined outcome dimension from both litigation and arbitration
    'L-' || CAST(lit.litigation_id AS STRING) as outcome_key,
    'Litigation' as outcome_type,
    lit.litigation_id as outcome_id,
    lit.litigation_description,
    lit.court_jurisdiction_id,
    
    -- Outcome status (would typically come from related tables)
    NULL as outcome_status_code,
    NULL as outcome_result,
    NULL as judgment_amount,
    NULL as settlement_amount,
    NULL as outcome_date,
    
    -- Court information
    cj.court_id,
    cj.jurisdiction_id,
    lj.legal_jurisdiction_name,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.litigation lit
LEFT JOIN ${catalog}.${schema}.court_jurisdiction cj ON lit.court_jurisdiction_id = cj.court_jurisdiction_id
LEFT JOIN ${catalog}.${schema}.legal_jurisdiction lj ON cj.jurisdiction_id = lj.legal_jurisdiction_id

UNION ALL

SELECT 
    'A-' || CAST(arb.arbitration_id AS STRING) as outcome_key,
    'Arbitration' as outcome_type,
    arb.arbitration_id as outcome_id,
    arb.arbitration_description as litigation_description,
    NULL as court_jurisdiction_id,
    
    -- Outcome status
    NULL as outcome_status_code,
    NULL as outcome_result,
    NULL as judgment_amount,
    NULL as settlement_amount,
    NULL as outcome_date,
    
    -- No court for arbitration
    NULL as court_id,
    NULL as jurisdiction_id,
    NULL as legal_jurisdiction_name,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.arbitration arb;
