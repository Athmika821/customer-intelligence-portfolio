-- Sample Staging Model
-- Demonstrates data quality and standardization approach

{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw_data', 'reviews') }}
),

cleaned as (
    select 
        id,
        lower(trim(review_text)) as review_text,
        rating,
        reviewer_name,
        review_date,
        
        -- Data quality flags
        length(review_text) as review_length,
        case 
            when company_reply is not null then 1 
            else 0 
        end as has_company_response,
        
        current_timestamp as processed_at
        
    from source
    where review_text is not null
      and length(trim(review_text)) > 0
)

select * from cleaned
