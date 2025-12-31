-- Semantic View: Policy Analytics
-- Aggregated view for policy-level premium and claims analysis

CREATE OR REPLACE VIEW ${catalog}.${schema}.sv_policy_analytics AS
WITH premium_summary AS (
    SELECT 
        policy_key,
        SUM(net_premium_amount) as total_net_premium,
        SUM(direct_premium_amount) as total_direct_premium,
        SUM(premium_only_amount) as total_premium_only,
        SUM(tax_amount) as total_tax,
        COUNT(DISTINCT premium_payment_key) as premium_transaction_count,
        MIN(earning_begin_date) as first_premium_date,
        MAX(earning_end_date) as last_premium_date
    FROM ${catalog}.${schema}.fact_premium_payments
    GROUP BY policy_key
),
claims_summary AS (
    SELECT 
        policy_key,
        COUNT(DISTINCT claim_key) as claim_count,
        SUM(CASE WHEN is_payment = 1 THEN net_claim_amount ELSE 0 END) as total_paid,
        SUM(CASE WHEN is_reserve = 1 THEN net_claim_amount ELSE 0 END) as total_reserved,
        SUM(CASE WHEN is_recovery = 1 THEN net_claim_amount ELSE 0 END) as total_recovered,
        SUM(CASE WHEN is_loss_payment = 1 THEN net_claim_amount ELSE 0 END) as total_loss_paid,
        SUM(CASE WHEN is_expense_payment = 1 THEN net_claim_amount ELSE 0 END) as total_expense_paid,
        MAX(CASE WHEN has_litigation = 1 THEN 1 ELSE 0 END) as has_any_litigation,
        MAX(CASE WHEN has_arbitration = 1 THEN 1 ELSE 0 END) as has_any_arbitration,
        COUNT(DISTINCT claim_transaction_key) as claim_transaction_count
    FROM ${catalog}.${schema}.fact_claims
    GROUP BY policy_key
)
SELECT 
    -- Policy information
    dp.policy_key,
    dp.policy_number,
    dp.effective_date,
    dp.expiration_date,
    dp.status_code,
    dp.product_name,
    dp.line_of_business_name,
    dp.line_of_business_group_name,
    dp.insurance_class_name,
    dp.state_code,
    dp.state_name,
    dp.policy_term_days,
    dp.is_active,
    
    -- Premium metrics
    COALESCE(ps.total_net_premium, 0) as total_net_premium,
    COALESCE(ps.total_direct_premium, 0) as total_direct_premium,
    COALESCE(ps.total_premium_only, 0) as total_premium_only,
    COALESCE(ps.total_tax, 0) as total_tax,
    COALESCE(ps.premium_transaction_count, 0) as premium_transaction_count,
    ps.first_premium_date,
    ps.last_premium_date,
    
    -- Claims metrics
    COALESCE(cs.claim_count, 0) as claim_count,
    COALESCE(cs.total_paid, 0) as total_claims_paid,
    COALESCE(cs.total_reserved, 0) as total_claims_reserved,
    COALESCE(cs.total_recovered, 0) as total_claims_recovered,
    COALESCE(cs.total_loss_paid, 0) as total_loss_paid,
    COALESCE(cs.total_expense_paid, 0) as total_expense_paid,
    COALESCE(cs.has_any_litigation, 0) as has_any_litigation,
    COALESCE(cs.has_any_arbitration, 0) as has_any_arbitration,
    COALESCE(cs.claim_transaction_count, 0) as claim_transaction_count,
    
    -- Calculated ratios
    CASE 
        WHEN COALESCE(ps.total_net_premium, 0) > 0 
        THEN ROUND((COALESCE(cs.total_paid, 0) / ps.total_net_premium) * 100, 2)
        ELSE 0 
    END as loss_ratio_pct,
    
    CASE 
        WHEN COALESCE(ps.total_net_premium, 0) > 0 
        THEN ROUND(((COALESCE(cs.total_paid, 0) + COALESCE(cs.total_reserved, 0)) / ps.total_net_premium) * 100, 2)
        ELSE 0 
    END as incurred_loss_ratio_pct,
    
    -- Risk indicators
    CASE 
        WHEN cs.claim_count > 3 THEN 'High Frequency'
        WHEN cs.claim_count > 1 THEN 'Medium Frequency'
        WHEN cs.claim_count = 1 THEN 'Single Claim'
        ELSE 'No Claims'
    END as claim_frequency_category,
    
    CASE 
        WHEN COALESCE(cs.total_paid, 0) > 100000 THEN 'High Severity'
        WHEN COALESCE(cs.total_paid, 0) > 10000 THEN 'Medium Severity'
        WHEN COALESCE(cs.total_paid, 0) > 0 THEN 'Low Severity'
        ELSE 'No Claims'
    END as claim_severity_category
FROM ${catalog}.${schema}.dim_policy dp
LEFT JOIN premium_summary ps ON dp.policy_key = ps.policy_key
LEFT JOIN claims_summary cs ON dp.policy_key = cs.policy_key;
