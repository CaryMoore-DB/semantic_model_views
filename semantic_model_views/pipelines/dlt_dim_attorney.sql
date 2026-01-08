-- ============================================================================
-- dim_attorney - Attorney Dimension (Static stub)
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW dim_attorney
COMMENT "Attorney dimension stub - static record"
AS
SELECT
  0 as attorney_id,
  'Unknown' as attorney_name,
  'Unknown' as law_firm,
  'Unknown' as attorney_type;
