-- ============================================================================
-- dim_group - Group Dimension (SCD Type 1 with APPLY CHANGES)
-- ============================================================================

-- Source stream for group dimension
CREATE OR REFRESH STREAMING TABLE dim_group_source (
  CONSTRAINT valid_group_id EXPECT (group_id IS NOT NULL)
)
COMMENT "Source stream for group dimension changes"
AS
-- Add "No Group" record for referential integrity

-- Actual groups from source data
SELECT
  g.grouping_id as group_id,
  p.party_name as group_name,
  p.party_type_code as group_type
FROM STREAM(cmoore_user.pcdm_test.grouping) g
JOIN STREAM(cmoore_user.pcdm_test.party) p ON g.party_id = p.party_id;

-- Apply changes with SCD Type 1 (upsert without history)
CREATE OR REFRESH STREAMING TABLE dim_group;

APPLY CHANGES INTO dim_group
FROM STREAM(LIVE.dim_group_source)
KEYS (group_id)
SEQUENCE BY group_id;
