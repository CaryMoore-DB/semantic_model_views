-- ============================================================================
-- dim_court - Court Dimension (Static stub)
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW dim_court
COMMENT "Court dimension stub - static record"
AS
SELECT
  0 as court_id,
  'Unknown' as court_name,
  'Unknown' as court_type,
  'Unknown' as jurisdiction;
