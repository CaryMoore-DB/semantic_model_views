-- Fact Table: Claims
-- Contains claim transaction information with extended dimensions for legal proceedings

CREATE OR REPLACE TABLE ${catalog}.${schema}.fact_claims AS
SELECT 
    -- Surrogate key
    ca.claim_amount_id as claim_transaction_key,
    
    -- Dimension foreign keys
    ca.claim_id as claim_key,
    c.insurable_object_id as risk_key,
    
    -- Policy relationship (through claim coverage)
    cc.policy_coverage_detail_id,
    pcd.policy_id as policy_key,
    
    -- Group foreign key (from policy agreement)
    apr_group.party_id as group_key,
    
    -- Date foreign key
    ca.event_date as transaction_date_key,
    c.claim_open_date as claim_open_date_key,
    c.claim_close_date as claim_close_date_key,
    c.claim_reported_date as claim_reported_date_key,
    
    -- Attorney dimension (from litigation/arbitration party roles)
    lit_att.attorney_id as attorney_key,
    
    -- Court dimension
    lit.court_jurisdiction_id as court_key,
    
    -- Outcome dimension
    CASE 
        WHEN lit.litigation_id IS NOT NULL THEN 'L-' || CAST(lit.litigation_id AS STRING)
        WHEN arb.arbitration_id IS NOT NULL THEN 'A-' || CAST(arb.arbitration_id AS STRING)
        ELSE NULL
    END as outcome_key,
    
    -- Claim offer information
    ca.claim_offer_id,
    co.settlement_offer_amount,
    co.settlement_offer_provision_description,
    
    -- Date/time information
    ca.event_date,
    c.claim_open_date,
    c.claim_close_date,
    c.claim_reported_date,
    
    -- Claim identifiers
    c.company_claim_number,
    c.company_subclaim_number,
    c.claim_status_code,
    
    -- Transaction classification
    ca.insurance_type_code,
    ca.amount_type_code,
    
    -- Transaction type indicators
    CASE WHEN cp.claim_payment_id IS NOT NULL THEN 1 ELSE 0 END as is_payment,
    CASE WHEN cr.claim_reserve_id IS NOT NULL THEN 1 ELSE 0 END as is_reserve,
    CASE WHEN rec.recovery_id IS NOT NULL THEN 1 ELSE 0 END as is_recovery,
    
    -- Payment type breakdown
    CASE WHEN lp.loss_payment_id IS NOT NULL THEN 1 ELSE 0 END as is_loss_payment,
    CASE WHEN ep.expense_payment_id IS NOT NULL THEN 1 ELSE 0 END as is_expense_payment,
    
    -- Reserve type breakdown
    CASE WHEN lr.loss_reserve_id IS NOT NULL THEN 1 ELSE 0 END as is_loss_reserve,
    CASE WHEN er.expense_reserve_id IS NOT NULL THEN 1 ELSE 0 END as is_expense_reserve,
    
    -- Recovery type breakdown
    CASE WHEN lrec.loss_recovery_id IS NOT NULL THEN 1 ELSE 0 END as is_loss_recovery,
    CASE WHEN sal.salvage_id IS NOT NULL THEN 1 ELSE 0 END as is_salvage,
    CASE WHEN sub.subrogation_id IS NOT NULL THEN 1 ELSE 0 END as is_subrogation,
    CASE WHEN rr.reinsurance_recovery_id IS NOT NULL THEN 1 ELSE 0 END as is_reinsurance_recovery,
    
    -- Direct vs. assumed vs. ceded
    CASE WHEN dca.direct_claim_amount_id IS NOT NULL THEN 1 ELSE 0 END as is_direct,
    CASE WHEN aca.assumed_claim_amount_id IS NOT NULL THEN 1 ELSE 0 END as is_assumed,
    CASE WHEN cca.ceded_claim_amount_id IS NOT NULL THEN 1 ELSE 0 END as is_ceded,
    
    -- Credit/debit indicator
    CASE WHEN crca.credit_claim_amount_id IS NOT NULL THEN 'Credit' ELSE 'Debit' END as transaction_type,
    
    -- Litigation/Arbitration indicators
    CASE WHEN lit.litigation_id IS NOT NULL THEN 1 ELSE 0 END as has_litigation,
    CASE WHEN arb.arbitration_id IS NOT NULL THEN 1 ELSE 0 END as has_arbitration,
    
    -- Amounts (FACTS - MEASURES)
    ca.claim_amount as total_claim_amount,
    
    -- Net amount calculation
    CASE 
        WHEN crca.credit_claim_amount_id IS NOT NULL THEN -1 * ca.claim_amount 
        ELSE ca.claim_amount 
    END as net_claim_amount,
    
    -- Breakdown by transaction type
    CASE WHEN cp.claim_payment_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as payment_amount,
    CASE WHEN cr.claim_reserve_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as reserve_amount,
    CASE WHEN rec.recovery_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as recovery_amount,
    
    -- Loss vs. expense breakdown
    CASE WHEN lp.loss_payment_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as loss_payment_amount,
    CASE WHEN ep.expense_payment_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as expense_payment_amount,
    CASE WHEN lr.loss_reserve_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as loss_reserve_amount,
    CASE WHEN er.expense_reserve_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as expense_reserve_amount,
    
    -- Direct, assumed, ceded breakdown
    CASE WHEN dca.direct_claim_amount_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as direct_claim_amount,
    CASE WHEN aca.assumed_claim_amount_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as assumed_claim_amount,
    CASE WHEN cca.ceded_claim_amount_id IS NOT NULL THEN ca.claim_amount ELSE 0 END as ceded_claim_amount,
    
    -- Calculated metrics
    DATEDIFF(COALESCE(c.claim_close_date, CURRENT_DATE()), c.claim_open_date) as days_claim_open,
    DATEDIFF(ca.event_date, c.claim_open_date) as days_since_claim_open,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.claim_amount ca
LEFT JOIN ${catalog}.${schema}.claim c ON ca.claim_id = c.claim_id
LEFT JOIN ${catalog}.${schema}.claim_coverage cc ON c.claim_id = cc.claim_id
LEFT JOIN ${catalog}.${schema}.policy_coverage_detail pcd ON cc.policy_coverage_detail_id = pcd.policy_coverage_detail_id
LEFT JOIN ${catalog}.${schema}.policy pol ON pcd.policy_id = pol.policy_id
LEFT JOIN ${catalog}.${schema}.agreement agr ON pol.agreement_id = agr.agreement_id
LEFT JOIN ${catalog}.${schema}.agreement_party_role apr_group 
    ON agr.agreement_id = apr_group.agreement_id 
    AND apr_group.party_role_code = 'GROUP'
LEFT JOIN ${catalog}.${schema}.claim_offer co ON ca.claim_offer_id = co.claim_offer_id
LEFT JOIN ${catalog}.${schema}.claim_payment cp ON ca.claim_amount_id = cp.claim_amount_id
LEFT JOIN ${catalog}.${schema}.claim_reserve cr ON ca.claim_amount_id = cr.claim_amount_id
LEFT JOIN ${catalog}.${schema}.recovery rec ON ca.claim_amount_id = rec.claim_amount_id
LEFT JOIN ${catalog}.${schema}.loss_payment lp ON cp.claim_payment_id = lp.claim_payment_id
LEFT JOIN ${catalog}.${schema}.expense_payment ep ON cp.claim_payment_id = ep.claim_payment_id
LEFT JOIN ${catalog}.${schema}.loss_reserve lr ON cr.claim_reserve_id = lr.claim_reserve_id
LEFT JOIN ${catalog}.${schema}.expense_reserve er ON cr.claim_reserve_id = er.claim_reserve_id
LEFT JOIN ${catalog}.${schema}.loss_recovery lrec ON rec.recovery_id = lrec.recovery_id
LEFT JOIN ${catalog}.${schema}.salvage sal ON rec.recovery_id = sal.recovery_id
LEFT JOIN ${catalog}.${schema}.subrogation sub ON rec.recovery_id = sub.recovery_id
LEFT JOIN ${catalog}.${schema}.reinsurance_recovery rr ON rec.recovery_id = rr.recovery_id
LEFT JOIN ${catalog}.${schema}.direct_claim_amount dca ON ca.claim_amount_id = dca.claim_amount_id
LEFT JOIN ${catalog}.${schema}.assumed_claim_amount aca ON ca.claim_amount_id = aca.claim_amount_id
LEFT JOIN ${catalog}.${schema}.ceded_claim_amount cca ON ca.claim_amount_id = cca.claim_amount_id
LEFT JOIN ${catalog}.${schema}.credit_claim_amount crca ON ca.claim_amount_id = crca.claim_amount_id
LEFT JOIN ${catalog}.${schema}.claim_litigation cl ON c.claim_id = cl.claim_id
LEFT JOIN ${catalog}.${schema}.litigation lit ON cl.litigation_id = lit.litigation_id
LEFT JOIN ${catalog}.${schema}.claim_arbitration carb ON c.claim_id = carb.claim_id
LEFT JOIN ${catalog}.${schema}.arbitration arb ON carb.arbitration_id = arb.arbitration_id
LEFT JOIN ${catalog}.${schema}.litigation_party_role lpr 
    ON lit.litigation_id = lpr.litigation_id 
    AND lpr.party_role_code = 'ATTORNEY'
LEFT JOIN ${catalog}.${schema}.claim_party_role cpr_att ON lpr.party_id = cpr_att.party_id
LEFT JOIN ${catalog}.${schema}.party_role pr_att ON cpr_att.party_role_code = pr_att.party_role_code
LEFT JOIN ${catalog}.${schema}.provider prov_att ON pr_att.party_role_code = prov_att.party_role_code
LEFT JOIN ${catalog}.${schema}.attorney lit_att ON prov_att.provider_id = lit_att.provider_id;
