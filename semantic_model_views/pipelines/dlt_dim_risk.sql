-- ============================================================================
-- dim_risk - Risk Dimension (SCD Type 2)
-- Risk is based on policy_coverage_detail (the coverage on a specific insurable object)
-- This unions all insurable object types (vehicles, structures, etc.) into one dimension
-- ============================================================================

-- Source stream for risk dimension
CREATE OR REFRESH STREAMING TABLE dim_risk_source (
  CONSTRAINT valid_risk_id EXPECT (risk_id IS NOT NULL),
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL)
)
COMMENT "Source stream for risk dimension - based on policy_coverage_detail and insurable_objects"
AS
SELECT
  pcd.policy_coverage_detail_id as risk_id,
  pcd.policy_id,
  pcd.coverage_id,
  cov.coverage_name,
  COALESCE(io.insurable_object_type_code, 0) as insurable_object_type_code,
  CASE 
    WHEN io.insurable_object_type_code IS NULL THEN 'No Insurable Object'
    WHEN v.vehicle_id IS NOT NULL THEN 'Vehicle'
    WHEN s.structure_id IS NOT NULL THEN 'Structure'
    ELSE 'Other'
  END as risk_type,
  COALESCE(v.vehicle_make_name, 'N/A') as vehicle_make,
  COALESCE(v.vehicle_model_name, 'N/A') as vehicle_model,
  COALESCE(v.vehicle_model_year, 0) as vehicle_year,
  COALESCE(v.vehicle_identification_number, 'N/A') as vehicle_vin,
  CASE 
    WHEN cs.commercial_structure_id IS NOT NULL THEN 'Commercial'
    WHEN rs.residential_structure_id IS NOT NULL THEN 'Residential'
    WHEN s.structure_id IS NOT NULL THEN 'Other Structure'
    ELSE 'N/A'
  END as structure_type,
  io.geographic_location_id as risk_location_id,
  pcd.effective_date
FROM cmoore_user.pcdm_test.policy_coverage_detail pcd
JOIN cmoore_user.pcdm_test.coverage cov ON pcd.coverage_id = cov.coverage_id
LEFT JOIN cmoore_user.pcdm_test.insurable_object io ON pcd.insurable_object_id = io.insurable_object_id
LEFT JOIN cmoore_user.pcdm_test.vehicle v ON io.insurable_object_id = v.insurable_object_id
LEFT JOIN cmoore_user.pcdm_test.structure s ON io.insurable_object_id = s.insurable_object_id
LEFT JOIN cmoore_user.pcdm_test.commercial_structure cs ON s.structure_id = cs.structure_id
LEFT JOIN cmoore_user.pcdm_test.residential_structure rs ON s.structure_id = rs.structure_id;

-- Apply SCD Type 2 to dim_risk
CREATE OR REFRESH STREAMING TABLE dim_risk;

APPLY CHANGES INTO dim_risk
FROM STREAM(LIVE.dim_risk_source)
KEYS (risk_id)
SEQUENCE BY effective_date
STORED AS SCD TYPE 2;
