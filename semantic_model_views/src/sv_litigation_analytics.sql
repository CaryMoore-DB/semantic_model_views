-- Semantic View: Litigation Analytics
-- Focused view on claims with legal proceedings

CREATE OR REPLACE VIEW ${catalog}.${schema}.sv_litigation_analytics AS
SELECT 
    -- Claim information
    fc.claim_key,
    dcl.company_claim_number,
    dcl.claim_description,
    dcl.claim_open_date,
    dcl.claim_close_date,
    dcl.claim_status_code,
    dcl.days_open,
    
    -- Policy information
    dp.policy_number,
    dp.product_name,
    dp.line_of_business_name,
    dp.state_code as policy_state,
    
    -- Legal proceedings type
    fc.has_litigation,
    fc.has_arbitration,
    CASE 
        WHEN fc.has_litigation = 1 AND fc.has_arbitration = 1 THEN 'Both'
        WHEN fc.has_litigation = 1 THEN 'Litigation Only'
        WHEN fc.has_arbitration = 1 THEN 'Arbitration Only'
        ELSE 'None'
    END as legal_proceeding_type,
    
    -- Attorney information
    da.attorney_key,
    da.attorney_name,
    da.law_firm_name,
    da.first_name as attorney_first_name,
    da.last_name as attorney_last_name,
    da.city as attorney_city,
    da.state_code as attorney_state,
    
    -- Court information
    dc.court_key,
    dc.legal_jurisdiction_name,
    dc.court_level,
    dc.court_location,
    
    -- Outcome information
    do.outcome_key,
    do.outcome_type,
    do.litigation_description,
    do.outcome_status_code,
    do.outcome_result,
    do.judgment_amount,
    do.settlement_amount,
    do.outcome_date,
    
    -- Financial impact
    SUM(fc.total_claim_amount) as total_legal_claim_amount,
    SUM(fc.payment_amount) as total_legal_payments,
    SUM(fc.expense_payment_amount) as total_legal_expenses,
    SUM(fc.loss_payment_amount) as total_legal_loss_paid,
    SUM(fc.recovery_amount) as total_legal_recoveries,
    fc.settlement_offer_amount,
    
    -- Time metrics
    dcl.claim_open_date,
    dcl.claim_close_date,
    DATEDIFF(COALESCE(dcl.claim_close_date, CURRENT_DATE()), dcl.claim_open_date) as litigation_duration_days,
    
    -- Outcome effectiveness
    CASE 
        WHEN SUM(fc.recovery_amount) > 0 
        THEN ROUND((SUM(fc.recovery_amount) / NULLIF(SUM(fc.payment_amount), 0)) * 100, 2)
        ELSE 0 
    END as recovery_ratio_pct
FROM ${catalog}.${schema}.fact_claims fc
INNER JOIN ${catalog}.${schema}.dim_claim dcl ON fc.claim_key = dcl.claim_key
LEFT JOIN ${catalog}.${schema}.dim_policy dp ON fc.policy_key = dp.policy_key
LEFT JOIN ${catalog}.${schema}.dim_attorney da ON fc.attorney_key = da.attorney_key
LEFT JOIN ${catalog}.${schema}.dim_court dc ON fc.court_key = dc.court_key
LEFT JOIN ${catalog}.${schema}.dim_outcome do ON fc.outcome_key = do.outcome_key
WHERE fc.has_litigation = 1 OR fc.has_arbitration = 1
GROUP BY 
    fc.claim_key, dcl.company_claim_number, dcl.claim_description, dcl.claim_open_date,
    dcl.claim_close_date, dcl.claim_status_code, dcl.days_open, dp.policy_number,
    dp.product_name, dp.line_of_business_name, dp.state_code, fc.has_litigation,
    fc.has_arbitration, da.attorney_key, da.attorney_name, da.law_firm_name,
    da.first_name, da.last_name, da.city, da.state_code, dc.court_key,
    dc.legal_jurisdiction_name, dc.court_level, dc.court_location, do.outcome_key,
    do.outcome_type, do.litigation_description, do.outcome_status_code, do.outcome_result,
    do.judgment_amount, do.settlement_amount, do.outcome_date, fc.settlement_offer_amount;
