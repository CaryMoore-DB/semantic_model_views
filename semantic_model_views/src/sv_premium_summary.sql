-- Semantic View: Premium Summary
-- Provides business-friendly view of premium payments with all dimension attributes

CREATE OR REPLACE VIEW ${catalog}.${schema}.sv_premium_summary AS
SELECT 
    -- Premium facts
    fp.premium_payment_key,
    fp.earning_begin_date,
    fp.earning_end_date,
    fp.earning_period_days,
    
    -- Premium amounts
    fp.premium_amount as total_premium,
    fp.premium_only_amount,
    fp.tax_amount,
    fp.surcharge_amount,
    fp.fee_amount,
    fp.net_premium_amount,
    fp.direct_premium_amount,
    fp.assumed_premium_amount,
    fp.ceded_premium_amount,
    
    -- Premium indicators
    fp.is_premium,
    fp.is_tax,
    fp.is_surcharge,
    fp.is_fee,
    fp.is_direct,
    fp.is_assumed,
    fp.is_ceded,
    fp.transaction_type as premium_transaction_type,
    
    -- Coverage details
    fp.coverage_id,
    fp.coverage_description,
    fp.avg_deductible,
    fp.avg_limit,
    
    -- Policy dimension
    dp.policy_number,
    dp.effective_date as policy_effective_date,
    dp.expiration_date as policy_expiration_date,
    dp.status_code as policy_status,
    dp.product_name,
    dp.line_of_business_name,
    dp.line_of_business_group_name,
    dp.insurance_class_name,
    dp.state_code as policy_state,
    dp.state_name as policy_state_name,
    dp.is_active as policy_is_active,
    dp.policy_term_days,
    
    -- Group dimension
    dg.group_key,
    dg.grouping_name,
    dg.group_type,
    dg.organization_name,
    dg.organization_type_code,
    
    -- Risk dimension
    dr.risk_category,
    dr.vehicle_type,
    dr.vin,
    dr.vehicle_make_name,
    dr.vehicle_model_name,
    dr.vehicle_model_year,
    dr.structure_type,
    dr.farm_equipment_type,
    dr.state_code as risk_state,
    dr.state_name as risk_state_name,
    dr.line_1_address as risk_address,
    dr.municipality_name as risk_city,
    dr.postal_code as risk_postal_code,
    
    -- Date dimensions
    dd_begin.year as earning_begin_year,
    dd_begin.quarter as earning_begin_quarter,
    dd_begin.month as earning_begin_month,
    dd_begin.month_name as earning_begin_month_name,
    dd_begin.fiscal_quarter as earning_begin_fiscal_quarter,
    
    dd_end.year as earning_end_year,
    dd_end.quarter as earning_end_quarter,
    dd_end.month as earning_end_month,
    dd_end.month_name as earning_end_month_name
FROM ${catalog}.${schema}.fact_premium_payments fp
LEFT JOIN ${catalog}.${schema}.dim_policy dp ON fp.policy_key = dp.policy_key
LEFT JOIN ${catalog}.${schema}.dim_group dg ON fp.group_key = dg.group_key
LEFT JOIN ${catalog}.${schema}.dim_risk dr ON fp.risk_key = dr.risk_key
LEFT JOIN ${catalog}.${schema}.dim_date dd_begin ON fp.begin_date_key = dd_begin.date_key
LEFT JOIN ${catalog}.${schema}.dim_date dd_end ON fp.end_date_key = dd_end.date_key;
