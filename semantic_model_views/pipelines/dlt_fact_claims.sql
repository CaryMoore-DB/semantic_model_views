-- ============================================================================
-- fact_claims - Claims Fact
-- Group resolved through party_relationship
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW fact_claims (
  CONSTRAINT valid_claim_id EXPECT (claim_id IS NOT NULL),
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL),
  CONSTRAINT valid_risk_id EXPECT (risk_id IS NOT NULL),
  CONSTRAINT valid_date_key EXPECT (claim_date_key IS NOT NULL)
)
COMMENT "Claims fact table - group resolved via party_relationship"
AS
SELECT
  c.claim_id,
  pol.policy_id,
  -- Resolve group through party_relationship (MEMBER_OF relationship)
  COALESCE(pr.related_party_id, 0) as group_id,
  pcd.policy_coverage_detail_id as risk_id,
  0 as attorney_id,
  0 as court_id,
  0 as outcome_id,
  CAST(date_format(c.claim_open_date, 'yyyyMMdd') AS INT) as claim_date_key,
  CAST(date_format(c.claim_reported_date, 'yyyyMMdd') AS INT) as reported_date_key,
  CAST(date_format(COALESCE(c.claim_close_date, current_date()), 'yyyyMMdd') AS INT) as close_date_key,
  CAST(date_format(occ.occurrence_begin_date, 'yyyyMMdd') AS INT) as occurrence_date_key,
  -- Estimated claim amounts (would come from claim_amount table if populated)
  CASE 
    WHEN c.claim_status_code = 'CLOSED' THEN 
      CASE 
        WHEN cat.catastrophe_id IS NOT NULL THEN lim.limit_value * 0.75
        ELSE lim.limit_value * 0.35
      END
    ELSE lim.limit_value * 0.20
  END as incurred_amount,
  CASE 
    WHEN c.claim_status_code = 'CLOSED' THEN 
      CASE 
        WHEN cat.catastrophe_id IS NOT NULL THEN lim.limit_value * 0.70
        ELSE lim.limit_value * 0.30
      END
    ELSE 0
  END as paid_amount,
  CASE 
    WHEN c.claim_status_code = 'OPEN' THEN lim.limit_value * 0.20
    ELSE 0
  END as reserve_amount,
  CASE WHEN c.claim_status_code = 'CLOSED' THEN 1 ELSE 0 END as closed_claim_count,
  CASE WHEN c.claim_status_code = 'OPEN' THEN 1 ELSE 0 END as open_claim_count,
  1 as claim_count,
  datediff(COALESCE(c.claim_close_date, current_date()), c.claim_open_date) as days_to_close,
  datediff(c.claim_reported_date, c.claim_open_date) as report_lag_days,
  current_timestamp() as load_date
FROM cmoore_user.pcdm_test.claim c
JOIN cmoore_user.pcdm_test.occurrence occ ON c.occurrence_id = occ.occurrence_id
LEFT JOIN cmoore_user.pcdm_test.catastrophe cat ON c.catastrophe_id = cat.catastrophe_id
JOIN cmoore_user.pcdm_test.claim_coverage cc ON c.claim_id = cc.claim_id
JOIN cmoore_user.pcdm_test.policy_coverage_detail pcd ON cc.policy_coverage_detail_id = pcd.policy_coverage_detail_id
JOIN cmoore_user.pcdm_test.policy pol ON pcd.policy_id = pol.policy_id
JOIN cmoore_user.pcdm_test.agreement agr ON pol.agreement_id = agr.agreement_id
-- Get the policyholder (INSURED) from agreement_party_role
JOIN cmoore_user.pcdm_test.agreement_party_role apr ON agr.agreement_id = apr.agreement_id AND apr.party_role_code = 'INSURED'
-- Find group membership through party_relationship
LEFT JOIN cmoore_user.pcdm_test.party_relationship pr ON apr.party_id = pr.party_id AND pr.relationship_type_code = 'MEMBER_OF'
LEFT JOIN cmoore_user.pcdm_test.policy_limit lim ON pcd.policy_coverage_detail_id = lim.policy_coverage_detail_id;
