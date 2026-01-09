-- Sample Mart Model
-- Demonstrates ROI calculation methodology

{{ config(materialized='table') }}

with issue_estimates as (
    -- Aggregate issues by type
    select 
        issue_subtype,
        fix_owner_team,
        issue_severity,
        
        count(*) as occurrence_count,
        
        -- Fix cost estimation
        case fix_complexity
            when 'simple' then 15000    -- 3 days
            when 'moderate' then 50000  -- 2 weeks
            when 'complex' then 100000  -- 1 month
        end as estimated_fix_cost_inr
        
    from decomposed_issues
    group by issue_subtype, fix_owner_team, issue_severity, fix_complexity
),

impact_calculation as (
    select 
        *,
        
        -- Business impact by severity
        occurrence_count * 
        case issue_severity
            when 'critical' then 3600
            when 'high' then 2400
            when 'medium' then 1200
            else 600
        end as estimated_business_impact,
        
        -- ROI calculation
        round(
            (occurrence_count * 
             case issue_severity
                 when 'critical' then 3600
                 when 'high' then 2400
                 when 'medium' then 1200
                 else 600
             end)::numeric / 
            estimated_fix_cost_inr, 
            2
        ) as roi_ratio
        
    from issue_estimates
)

select * from impact_calculation
order by roi_ratio desc
