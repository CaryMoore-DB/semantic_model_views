-- ============================================================================
-- dim_outcome - Outcome Dimension (Static stub)
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW dim_outcome
COMMENT "Outcome dimension stub - static record"
AS
SELECT
  0 as outcome_id,
  'Unknown' as outcome_type,
  'Unknown' as outcome_description;
