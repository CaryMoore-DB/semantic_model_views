-- Dimension: Group
-- Contains information about groupings (organizations, households, professional groups)
-- for retail insurance policies

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_group AS
SELECT 
    g.grouping_id as group_key,
    g.grouping_name,
    g.party_id,
    p.party_name,
    p.party_type_code,
    
    -- Identify group type
    CASE 
        WHEN h.household_id IS NOT NULL THEN 'Household'
        WHEN pg.professional_group_id IS NOT NULL THEN 'Professional Group'
        WHEN pr.project_id IS NOT NULL THEN 'Project'
        WHEN t.team_id IS NOT NULL THEN 'Team'
        ELSE 'General Group'
    END as group_type,
    
    -- Organization details if applicable
    o.organization_id,
    o.organization_name,
    o.organization_type_code,
    o.industry_type_code,
    
    -- Dates
    p.begin_date as group_begin_date,
    p.end_date as group_end_date,
    
    CURRENT_TIMESTAMP() as last_updated
FROM ${catalog}.${schema}.grouping g
LEFT JOIN ${catalog}.${schema}.party p ON g.party_id = p.party_id
LEFT JOIN ${catalog}.${schema}.household h ON g.grouping_id = h.grouping_id
LEFT JOIN ${catalog}.${schema}.professional_group pg ON g.grouping_id = pg.grouping_id
LEFT JOIN ${catalog}.${schema}.project pr ON g.grouping_id = pr.grouping_id
LEFT JOIN ${catalog}.${schema}.team t ON g.grouping_id = t.grouping_id
LEFT JOIN ${catalog}.${schema}.organization o ON p.party_id = o.party_id;
