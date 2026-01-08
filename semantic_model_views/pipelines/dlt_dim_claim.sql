-- ============================================================================
-- dim_claim - Claim Dimension (SCD Type 2)
-- ============================================================================

-- Source stream for claim dimension
CREATE OR REFRESH STREAMING TABLE dim_claim_source (
  CONSTRAINT valid_claim_id EXPECT (claim_id IS NOT NULL),
  CONSTRAINT valid_claim_number EXPECT (claim_number IS NOT NULL),
  CONSTRAINT valid_claim_reported_date EXPECT (claim_reported_date IS NOT NULL)
)
COMMENT "Source stream for claim dimension changes"
AS
SELECT
  c.claim_id,
  c.company_claim_number as claim_number,
  c.claim_description,
  c.claim_status_code,
  c.claim_open_date,
  c.claim_close_date,
  c.claim_reported_date,
  CASE WHEN c.claim_close_date IS NOT NULL THEN 1 ELSE 0 END as is_closed,
  CASE WHEN c.catastrophe_id IS NOT NULL THEN 1 ELSE 0 END as is_catastrophe,
  cat.catastrophe_name,
  occ.occurrence_begin_date as occurrence_date,
  occ.geographic_location_id as occurrence_location_id
FROM cmoore_user.pcdm_test.claim c
JOIN cmoore_user.pcdm_test.occurrence occ ON c.occurrence_id = occ.occurrence_id
LEFT JOIN cmoore_user.pcdm_test.catastrophe cat ON c.catastrophe_id = cat.catastrophe_id;

-- Apply SCD Type 2 to dim_claim
CREATE OR REFRESH STREAMING TABLE dim_claim;

APPLY CHANGES INTO dim_claim
FROM STREAM(LIVE.dim_claim_source)
KEYS (claim_id)
SEQUENCE BY claim_reported_date
STORED AS SCD TYPE 2;
