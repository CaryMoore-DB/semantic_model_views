-- Semantic View: Claims Summary
-- Provides business-friendly view of claims with all dimension attributes including legal proceedings

CREATE OR REPLACE VIEW ${catalog}.${schema}.sv_claims_summary AS
SELECT 
    -- Claim facts
    fc.claim_transaction_key,
    fc.event_date as transaction_date,
    fc.transaction_type as claim_transaction_type,
    
    -- Claim amounts
    fc.total_claim_amount,
    fc.net_claim_amount,
    fc.payment_amount,
    fc.reserve_amount,
    fc.recovery_amount,
    fc.loss_payment_amount,
    fc.expense_payment_amount,
    fc.loss_reserve_amount,
    fc.expense_reserve_amount,
    fc.direct_claim_amount,
    fc.assumed_claim_amount,
    fc.ceded_claim_amount,
    
    -- Transaction indicators
    fc.is_payment,
    fc.is_reserve,
    fc.is_recovery,
    fc.is_loss_payment,
    fc.is_expense_payment,
    fc.is_loss_reserve,
    fc.is_expense_reserve,
    fc.is_loss_recovery,
    fc.is_salvage,
    fc.is_subrogation,
    fc.is_direct,
    fc.is_assumed,
    fc.is_ceded,
    fc.has_litigation,
    fc.has_arbitration,
    
    -- Settlement information
    fc.settlement_offer_amount,
    fc.settlement_offer_provision_description,
    
    -- Time metrics
    fc.days_claim_open,
    fc.days_since_claim_open,
    
    -- Claim dimension
    dcl.company_claim_number,
    dcl.company_subclaim_number,
    dcl.claim_description,
    dcl.claim_open_date,
    dcl.claim_close_date,
    dcl.claim_reported_date,
    dcl.claim_status_code,
    dcl.is_closed as claim_is_closed,
    dcl.is_reopened as claim_is_reopened,
    dcl.is_open as claim_is_open,
    dcl.reporting_lag_days,
    dcl.is_catastrophe,
    dcl.catastrophe_name,
    dcl.catastrophe_type_code,
    dcl.occurrence_begin_date,
    dcl.occurrence_location_name,
    dcl.occurrence_state_code,
    dcl.occurrence_state_name,
    
    -- Policy dimension
    dp.policy_number,
    dp.effective_date as policy_effective_date,
    dp.expiration_date as policy_expiration_date,
    dp.product_name,
    dp.line_of_business_name,
    dp.line_of_business_group_name,
    dp.insurance_class_name,
    dp.state_code as policy_state,
    dp.state_name as policy_state_name,
    
    -- Group dimension
    dg.group_key,
    dg.grouping_name,
    dg.group_type,
    dg.organization_name,
    
    -- Risk dimension
    dr.risk_category,
    dr.vehicle_type,
    dr.vin,
    dr.vehicle_make_name,
    dr.vehicle_model_name,
    dr.vehicle_model_year,
    dr.structure_type,
    dr.state_code as risk_state,
    dr.state_name as risk_state_name,
    dr.line_1_address as risk_address,
    dr.municipality_name as risk_city,
    
    -- Attorney dimension (if applicable)
    da.attorney_name,
    da.law_firm_name,
    da.law_firm_type_code,
    da.first_name as attorney_first_name,
    da.last_name as attorney_last_name,
    da.city as attorney_city,
    da.state_code as attorney_state,
    da.state_name as attorney_state_name,
    
    -- Court dimension (if applicable)
    dc.legal_jurisdiction_name,
    dc.court_level,
    dc.court_location,
    
    -- Outcome dimension (if applicable)
    do.outcome_type,
    do.litigation_description as outcome_description,
    do.outcome_status_code,
    do.outcome_result,
    do.judgment_amount,
    do.settlement_amount as outcome_settlement_amount,
    do.outcome_date,
    
    -- Date dimensions
    dd_trans.year as transaction_year,
    dd_trans.quarter as transaction_quarter,
    dd_trans.month as transaction_month,
    dd_trans.month_name as transaction_month_name,
    dd_trans.fiscal_quarter as transaction_fiscal_quarter,
    
    dd_open.year as claim_open_year,
    dd_open.quarter as claim_open_quarter,
    dd_open.month as claim_open_month,
    dd_open.month_name as claim_open_month_name
FROM ${catalog}.${schema}.fact_claims fc
LEFT JOIN ${catalog}.${schema}.dim_claim dcl ON fc.claim_key = dcl.claim_key
LEFT JOIN ${catalog}.${schema}.dim_policy dp ON fc.policy_key = dp.policy_key
LEFT JOIN ${catalog}.${schema}.dim_group dg ON fc.group_key = dg.group_key
LEFT JOIN ${catalog}.${schema}.dim_risk dr ON fc.risk_key = dr.risk_key
LEFT JOIN ${catalog}.${schema}.dim_attorney da ON fc.attorney_key = da.attorney_key
LEFT JOIN ${catalog}.${schema}.dim_court dc ON fc.court_key = dc.court_key
LEFT JOIN ${catalog}.${schema}.dim_outcome do ON fc.outcome_key = do.outcome_key
LEFT JOIN ${catalog}.${schema}.dim_date dd_trans ON fc.transaction_date_key = dd_trans.date_key
LEFT JOIN ${catalog}.${schema}.dim_date dd_open ON fc.claim_open_date_key = dd_open.date_key;
