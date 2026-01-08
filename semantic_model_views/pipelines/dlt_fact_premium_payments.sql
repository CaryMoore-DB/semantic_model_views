-- ============================================================================
-- fact_premium_payments - Premium Payments Fact
-- Group resolved through party_relationship
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW fact_premium_payments (
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL),
  CONSTRAINT valid_risk_id EXPECT (risk_id IS NOT NULL),
  CONSTRAINT valid_premium_amount EXPECT (premium_amount >= 0),
  CONSTRAINT valid_date_key EXPECT (transaction_date_key IS NOT NULL)
)
COMMENT "Premium payments fact table - group resolved via party_relationship"
AS
SELECT
  pol.policy_id,
  -- Resolve group through party_relationship (MEMBER_OF relationship)
  COALESCE(pr.related_party_id, 0) as group_id,
  pcd.policy_coverage_detail_id as risk_id,
  CAST(date_format(pcd.effective_date, 'yyyyMMdd') AS INT) as transaction_date_key,
  CAST(date_format(pol.effective_date, 'yyyyMMdd') AS INT) as policy_effective_date_key,
  CAST(date_format(pol.expiration_date, 'yyyyMMdd') AS INT) as policy_expiration_date_key,
  -- Generate estimated premium based on coverage
  CASE 
    WHEN cov.coverage_name LIKE '%Liability%' THEN lim.limit_value * 0.005
    WHEN cov.coverage_name LIKE '%Property%' THEN lim.limit_value * 0.010
    WHEN cov.coverage_name LIKE '%Auto%' THEN lim.limit_value * 0.008
    ELSE lim.limit_value * 0.006
  END as premium_amount,
  lim.limit_value as coverage_limit,
  COALESCE(ded.deductible_value, 0) as deductible_amount,
  cov.coverage_name as coverage_type,
  pcd.coverage_part_code,
  1 as policy_count,
  current_timestamp() as load_date
FROM cmoore_user.pcdm_test.policy_coverage_detail pcd
JOIN cmoore_user.pcdm_test.policy pol ON pcd.policy_id = pol.policy_id
JOIN cmoore_user.pcdm_test.agreement agr ON pol.agreement_id = agr.agreement_id
-- Get the policyholder (INSURED) from agreement_party_role
JOIN cmoore_user.pcdm_test.agreement_party_role apr ON agr.agreement_id = apr.agreement_id AND apr.party_role_code = 'INSURED'
-- Find group membership through party_relationship
LEFT JOIN cmoore_user.pcdm_test.party_relationship pr ON apr.party_id = pr.party_id AND pr.relationship_type_code = 'MEMBER_OF'
JOIN cmoore_user.pcdm_test.coverage cov ON pcd.coverage_id = cov.coverage_id
LEFT JOIN cmoore_user.pcdm_test.policy_limit lim ON pcd.policy_coverage_detail_id = lim.policy_coverage_detail_id
LEFT JOIN cmoore_user.pcdm_test.policy_deductible ded ON pcd.policy_coverage_detail_id = ded.policy_coverage_detail_id;
