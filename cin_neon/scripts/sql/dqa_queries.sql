-- =============================================================================
-- CIN Neonatal DQA Queries
-- Description: Comprehensive data quality assessment for neonatal records
-- =============================================================================

WITH

    -- document_source checks
    missing_document_source AS (
      SELECT
        id,
        date_today,
        'document_source' AS variable,
        'Missing document_source' AS issue,
        nar_used AS current_value
      FROM neonatal_core
      WHERE (nar_used IS NULL OR TRIM(nar_used) = '')
        AND CAST(date_today AS TIMESTAMP) >= '2025-05-08 10:47:19'
    ),


        -- hosp_id checks
    missing_hosp_id AS (
      SELECT
        id,
        date_today,
        'hosp_id' AS variable,
        'Missing hosp_id' AS issue,
        hosp_id AS current_value
      FROM neonatal_core
      WHERE (hosp_id IS NULL OR TRIM(hosp_id) = '')
        AND CAST(date_today AS TIMESTAMP) >= '2025-05-08 10:47:19'
    ),
































    -- combine all checks
    all_issues AS (
      SELECT * FROM missing_document_source
      UNION ALL
      SELECT * FROM missing_hosp_id
      








    )

  SELECT *
  FROM all_issues
  WHERE CAST(date_today AS TIMESTAMP) >= '{start_date}'
    AND CAST(date_today AS TIMESTAMP) <= '{end_date}'
  ORDER BY id, variable