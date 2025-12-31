-- Dimension: Policy
-- Contains policy-level information including coverage details and status

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_policy AS
SELECT 
    p.policy_id as policy_key,
    p.policy_number,
    p.effective_date,
    p.expiration_date,
    p.status_code,
    
    -- Agreement information
    a.agreement_id,
    a.agreement_name,
    a.agreement_type_code,
    a.agreement_original_inception_date,
    
    -- Product details
    prod.product_id,
    prod.licensed_product_name as product_name,
    prod.product_description,
    
    -- Line of business
    lob.line_of_business_id,
    lob.line_of_business_name,
    lob.line_of_business_code,
    lob.line_of_business_description,
    
    -- Line of business group
    lobg.line_of_business_group_id,
    lobg.line_of_business_group_name,
    
    -- Insurance class
    ic.insurance_class_id,
    ic.insurance_class_name,
    
    -- Coverage parts
    COUNT(DISTINCT pcp.coverage_part_code) as coverage_part_count,
    
    -- Geographic location
    p.geographic_location_id,
    gl.location_name,
    gl.state_code,
    s.state_name,
    
    -- Policy duration in days
    DATEDIFF(p.expiration_date, p.effective_date) as policy_term_days,
    
    -- Policy age in days
    DATEDIFF(CURRENT_DATE(), p.effective_date) as policy_age_days,
    
    -- Active indicator
    CASE 
        WHEN p.status_code = 'ACTIVE' 
         AND CURRENT_DATE() BETWEEN p.effective_date AND p.expiration_date 
        THEN 1 
        ELSE 0 
    END as is_active,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.policy p
LEFT JOIN ${catalog}.${schema}.agreement a ON p.agreement_id = a.agreement_id
LEFT JOIN ${catalog}.${schema}.product prod ON a.product_id = prod.product_id
LEFT JOIN ${catalog}.${schema}.line_of_business lob ON prod.line_of_business_id = lob.line_of_business_id
LEFT JOIN ${catalog}.${schema}.line_of_business_group lobg ON lob.line_of_business_group_id = lobg.line_of_business_group_id
LEFT JOIN ${catalog}.${schema}.insurance_class ic ON lob.insurance_class_id = ic.insurance_class_id
LEFT JOIN ${catalog}.${schema}.policy_coverage_part pcp ON p.policy_id = pcp.policy_id
LEFT JOIN ${catalog}.${schema}.geographic_location gl ON p.geographic_location_id = gl.geographic_location_id
LEFT JOIN ${catalog}.${schema}.state s ON gl.state_code = s.state_code
GROUP BY 
    p.policy_id, p.policy_number, p.effective_date, p.expiration_date, p.status_code,
    a.agreement_id, a.agreement_name, a.agreement_type_code, a.agreement_original_inception_date,
    prod.product_id, prod.licensed_product_name, prod.product_description,
    lob.line_of_business_id, lob.line_of_business_name, lob.line_of_business_code, lob.line_of_business_description,
    lobg.line_of_business_group_id, lobg.line_of_business_group_name,
    ic.insurance_class_id, ic.insurance_class_name,
    p.geographic_location_id, gl.location_name, gl.state_code, s.state_name;
