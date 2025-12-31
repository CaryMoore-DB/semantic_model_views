-- Fact Table: Premium Payments
-- Contains transactional premium payment information with foreign keys to dimensions

CREATE OR REPLACE TABLE ${catalog}.${schema}.fact_premium_payments AS
SELECT 
    -- Surrogate key
    pa.policy_amount_id as premium_payment_key,
    
    -- Dimension foreign keys
    pa.policy_id as policy_key,
    pa.insurable_object_id as risk_key,
    pa.geographic_location_id as location_key,
    pa.earning_begin_date as begin_date_key,
    pa.earning_end_date as end_date_key,
    
    -- Group foreign key (from agreement party roles)
    apr_group.party_id as group_key,
    
    -- Policy coverage detail
    pa.policy_coverage_detail_id,
    
    -- Date/time information
    pa.earning_begin_date,
    pa.earning_end_date,
    DATEDIFF(pa.earning_end_date, pa.earning_begin_date) as earning_period_days,
    
    -- Premium type classification
    pa.insurance_type_code,
    pa.amount_type_code,
    
    -- Premium type indicator
    CASE WHEN prem.premium_id IS NOT NULL THEN 1 ELSE 0 END as is_premium,
    CASE WHEN tax.tax_id IS NOT NULL THEN 1 ELSE 0 END as is_tax,
    CASE WHEN sc.surcharge_id IS NOT NULL THEN 1 ELSE 0 END as is_surcharge,
    CASE WHEN fee.fee_id IS NOT NULL THEN 1 ELSE 0 END as is_fee,
    
    -- Direct vs. assumed vs. ceded
    CASE WHEN dpa.direct_policy_amount_id IS NOT NULL THEN 1 ELSE 0 END as is_direct,
    CASE WHEN apa.assumed_policy_amount_id IS NOT NULL THEN 1 ELSE 0 END as is_assumed,
    CASE WHEN cpa.ceded_policy_amount_id IS NOT NULL THEN 1 ELSE 0 END as is_ceded,
    
    -- Credit/debit indicator
    CASE WHEN crpa.credit_policy_amount_id IS NOT NULL THEN 'Credit' ELSE 'Debit' END as transaction_type,
    
    -- Amounts (FACTS - MEASURES)
    pa.policy_amount as premium_amount,
    
    -- Separate amounts by type for easier aggregation
    CASE WHEN prem.premium_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as premium_only_amount,
    CASE WHEN tax.tax_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as tax_amount,
    CASE WHEN sc.surcharge_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as surcharge_amount,
    CASE WHEN fee.fee_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as fee_amount,
    
    -- Net premium calculation
    CASE 
        WHEN crpa.credit_policy_amount_id IS NOT NULL THEN -1 * pa.policy_amount 
        ELSE pa.policy_amount 
    END as net_premium_amount,
    
    -- Direct, assumed, ceded breakdown
    CASE WHEN dpa.direct_policy_amount_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as direct_premium_amount,
    CASE WHEN apa.assumed_policy_amount_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as assumed_premium_amount,
    CASE WHEN cpa.ceded_policy_amount_id IS NOT NULL THEN pa.policy_amount ELSE 0 END as ceded_premium_amount,
    
    -- Coverage details
    pcd.coverage_id,
    pcd.coverage_part_code,
    pcd.coverage_description,
    
    -- Deductible and limit information
    (SELECT AVG(pd.deductible_value) 
     FROM ${catalog}.${schema}.policy_deductible pd 
     WHERE pd.policy_coverage_detail_id = pa.policy_coverage_detail_id) as avg_deductible,
    
    (SELECT AVG(pl.limit_value) 
     FROM ${catalog}.${schema}.policy_limit pl 
     WHERE pl.policy_coverage_detail_id = pa.policy_coverage_detail_id) as avg_limit,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.policy_amount pa
LEFT JOIN ${catalog}.${schema}.premium prem ON pa.policy_amount_id = prem.policy_amount_id
LEFT JOIN ${catalog}.${schema}.tax tax ON pa.policy_amount_id = tax.policy_amount_id
LEFT JOIN ${catalog}.${schema}.surcharge sc ON pa.policy_amount_id = sc.policy_amount_id
LEFT JOIN ${catalog}.${schema}.fee fee ON pa.policy_amount_id = fee.policy_amount_id
LEFT JOIN ${catalog}.${schema}.direct_policy_amount dpa ON pa.policy_amount_id = dpa.policy_amount_id
LEFT JOIN ${catalog}.${schema}.assumed_policy_amount apa ON pa.policy_amount_id = apa.policy_amount_id
LEFT JOIN ${catalog}.${schema}.ceded_policy_amount cpa ON pa.policy_amount_id = cpa.policy_amount_id
LEFT JOIN ${catalog}.${schema}.credit_policy_amount crpa ON pa.policy_amount_id = crpa.policy_amount_id
LEFT JOIN ${catalog}.${schema}.debit_policy_amount dbpa ON pa.policy_amount_id = dbpa.policy_amount_id
LEFT JOIN ${catalog}.${schema}.policy_coverage_detail pcd ON pa.policy_coverage_detail_id = pcd.policy_coverage_detail_id
LEFT JOIN ${catalog}.${schema}.policy pol ON pa.policy_id = pol.policy_id
LEFT JOIN ${catalog}.${schema}.agreement agr ON pol.agreement_id = agr.agreement_id
LEFT JOIN ${catalog}.${schema}.agreement_party_role apr_group 
    ON agr.agreement_id = apr_group.agreement_id 
    AND apr_group.party_role_code = 'GROUP';
