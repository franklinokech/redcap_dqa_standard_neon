WITH
    -- -------------------------------------------------------------------------
    -- document_source checks
    -- -------------------------------------------------------------------------
    missing_document_source AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'document_source'                AS variable,
        'No document source was recorded' AS issue,
        nar_used                         AS current_value
      FROM neonatal_core
      WHERE (nar_used IS NULL OR TRIM(nar_used) = '')
        AND CAST(date_today AS TIMESTAMP) >= '2025-05-08 10:47:19'
    ),

    -- -------------------------------------------------------------------------
    -- hosp_id checks
    -- -------------------------------------------------------------------------
    missing_hosp_id AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'hosp_id'                      AS variable,
        'No hospital identifier was recorded' AS issue,
        hosp_id                        AS current_value
      FROM neonatal_core
      WHERE (hosp_id IS NULL OR TRIM(hosp_id) = '')
        AND CAST(date_today AS TIMESTAMP) >= '2025-05-08 10:47:19'
    ),

    -- -------------------------------------------------------------------------
    -- ipno checks
    -- -------------------------------------------------------------------------
    missing_ipno AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'ipno'                                  AS variable,
        'No inpatient number (IPNO) was recorded' AS issue,
        ipno                                    AS current_value
      FROM neonatal_core
      WHERE (ipno IS NULL OR TRIM(ipno) = '')
        AND CAST(date_today AS TIMESTAMP) >= '2025-05-08 10:47:19'
    ),

    -- -------------------------------------------------------------------------
    -- multiple_delivery checks
    -- -------------------------------------------------------------------------
    missing_multiple_delivery AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'multiple_delivery'                                   AS variable,
        'No answer recorded for whether this was a multiple delivery' AS issue,
        multiple_delivery                                     AS current_value
      FROM neonatal_core
      WHERE (multiple_delivery IS NULL OR TRIM(multiple_delivery) = '')
    ),

    -- number_delivered checks (only when multiple_delivery = '1')
    missing_number_delivered AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'number_delivered'                                                  AS variable,
        'Number of babies delivered is missing (this was a multiple delivery)' AS issue,
        number_delivered                                                    AS current_value
      FROM neonatal_core
      WHERE (number_delivered IS NULL OR TRIM(number_delivered) = '')
        AND multiple_delivery = '1'
    ),

    -- -------------------------------------------------------------------------
    -- birth_wt checks
    -- -------------------------------------------------------------------------
    missing_birth_wt AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'birth_wt'                    AS variable,
        'No birth weight was recorded' AS issue,
        birth_wt                      AS current_value
      FROM neonatal_core
      WHERE (birth_wt IS NULL OR TRIM(birth_wt) = '')
    ),

    -- birth_wt plausibility checks
    implausible_birth_wt AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'birth_wt' AS variable,
        CASE
          WHEN birth_wt_units = '1' AND TRY_CAST(birth_wt AS DOUBLE) < 200
            THEN 'Birth weight (' || birth_wt || ' g) is below the plausible minimum of 200 g'
          WHEN birth_wt_units = '1' AND TRY_CAST(birth_wt AS DOUBLE) > 8000
            THEN 'Birth weight (' || birth_wt || ' g) exceeds the plausible maximum of 8000 g'
          WHEN birth_wt_units = '2' AND TRY_CAST(birth_wt AS DOUBLE) < 0.2
            THEN 'Birth weight (' || birth_wt || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN birth_wt_units = '2' AND TRY_CAST(birth_wt AS DOUBLE) > 8.0
            THEN 'Birth weight (' || birth_wt || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue,
        birth_wt AS current_value
      FROM neonatal_core
      WHERE birth_wt IS NOT NULL
        AND TRIM(birth_wt) <> ''
        AND birth_wt <> '-1'
        AND TRY_CAST(birth_wt AS DOUBLE) > 0
        AND birth_wt_units IN ('1', '2')
        AND (
              (birth_wt_units = '1' AND (TRY_CAST(birth_wt AS DOUBLE) < 200  OR TRY_CAST(birth_wt AS DOUBLE) > 8000))
           OR (birth_wt_units = '2' AND (TRY_CAST(birth_wt AS DOUBLE) < 0.2  OR TRY_CAST(birth_wt AS DOUBLE) > 8.0))
            )
    ),

    -- birth_wt_units checks (only when birth_wt is a real positive value, not placeholder)
    missing_birth_wt_units AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'birth_wt_units'                                               AS variable,
        'Birth weight unit (grams or kilograms) is missing even though a birth weight was entered' AS issue,
        birth_wt_units                                                 AS current_value
      FROM neonatal_core
      WHERE (birth_wt_units IS NULL OR TRIM(birth_wt_units) = '')
        AND birth_wt IS NOT NULL
        AND TRIM(birth_wt) <> ''
        AND birth_wt <> '-1'
        AND TRY_CAST(birth_wt AS DOUBLE) > 0
    ),

    -- -------------------------------------------------------------------------
    -- date_of_birth checks
    -- -------------------------------------------------------------------------
    missing_date_of_birth AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_of_birth'                  AS variable,
        'No date of birth was recorded'   AS issue,
        date_of_birth                    AS current_value
      FROM neonatal_core
      WHERE (date_of_birth IS NULL OR TRIM(date_of_birth) = '')
    ),

    -- -------------------------------------------------------------------------
    -- date_adm checks
    -- -------------------------------------------------------------------------
    missing_date_adm AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_adm'                          AS variable,
        'No date of admission was recorded'  AS issue,
        date_adm                            AS current_value
      FROM neonatal_core
      WHERE (date_adm IS NULL OR TRIM(date_adm) = '')
    ),

    -- -------------------------------------------------------------------------
    -- date_discharge checks
    -- -------------------------------------------------------------------------
    missing_date_discharge AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_discharge'                    AS variable,
        'No date of discharge was recorded'  AS issue,
        date_discharge                      AS current_value
      FROM neonatal_core
      WHERE (date_discharge IS NULL OR TRIM(date_discharge) = '')
    ),

    -- -------------------------------------------------------------------------
    -- t_seen checks
    -- -------------------------------------------------------------------------
    missing_t_seen AS (
      SELECT
        id,
        hosp_id,
        date_today,
        't_seen'                              AS variable,
        'No time of first review was recorded' AS issue,
        t_seen                                AS current_value
      FROM neonatal_core
      WHERE (t_seen IS NULL OR TRIM(t_seen) = '')
    ),

    -- =========================================================================
    -- TEMPORAL INCONSISTENCY CHECKS
    -- =========================================================================

    -- date_of_birth must not be after date_adm
    dob_after_adm AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_of_birth / date_adm' AS variable,
        'Date of birth (' || date_of_birth || ') is recorded after the date of admission (' || date_adm || '), which is not possible' AS issue,
        date_of_birth AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND date_of_birth <> '1914-01-01'
        AND date_adm      <> '1914-01-01'
        AND TRY_CAST(date_of_birth AS DATE) > TRY_CAST(date_adm AS DATE)
    ),

    -- date_adm must not be after date_discharge
    adm_after_discharge AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_adm / date_discharge' AS variable,
        'Date of admission (' || date_adm || ') is recorded after the date of discharge (' || date_discharge || '), which is not possible' AS issue,
        date_adm AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm       <> '1914-01-01'
        AND date_discharge <> '1914-01-01'
        AND TRY_CAST(date_adm AS DATE) > TRY_CAST(date_discharge AS DATE)
    ),

    -- date_of_birth must not be after date_discharge
    dob_after_discharge AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_of_birth / date_discharge' AS variable,
        'Date of birth (' || date_of_birth || ') is recorded after the date of discharge (' || date_discharge || '), which is not possible' AS issue,
        date_of_birth AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_of_birth  <> '1914-01-01'
        AND date_discharge <> '1914-01-01'
        AND TRY_CAST(date_of_birth AS DATE) > TRY_CAST(date_discharge AS DATE)
    ),

    -- date_adm must not be after date_today
    adm_after_today AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_adm / date_today' AS variable,
        'Date of admission (' || date_adm || ') is in the future relative to the record entry date (' || date_today || ')' AS issue,
        date_adm AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(date_today AS DATE) IS NOT NULL
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(date_adm AS DATE) > TRY_CAST(date_today AS DATE)
    ),

    -- date_discharge must not be after date_today
    discharge_after_today AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_discharge / date_today' AS variable,
        'Date of discharge (' || date_discharge || ') is in the future relative to the record entry date (' || date_today || ')' AS issue,
        date_discharge AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND TRY_CAST(date_today AS DATE) IS NOT NULL
        AND date_discharge <> '1914-01-01'
        AND TRY_CAST(date_discharge AS DATE) > TRY_CAST(date_today AS DATE)
    ),

    -- date_of_birth must not be after date_today
    dob_after_today AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_of_birth / date_today' AS variable,
        'Date of birth (' || date_of_birth || ') is in the future relative to the record entry date (' || date_today || ')' AS issue,
        date_of_birth AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_today AS DATE) IS NOT NULL
        AND date_of_birth <> '1914-01-01'
        AND TRY_CAST(date_of_birth AS DATE) > TRY_CAST(date_today AS DATE)
    ),

    -- neonatal age at admission implausibility: DOB to date_adm outside 0-28 days
    age_at_adm_implausible AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'date_of_birth / date_adm' AS variable,
        'Age at admission calculated from dates of birth and admission is ' ||
          CAST(DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE)) AS VARCHAR) ||
          ' days, which is outside the expected neonatal range of 0 to 28 days' AS issue,
        date_of_birth AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND date_of_birth <> '1914-01-01'
        AND date_adm      <> '1914-01-01'
        AND DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE)) NOT BETWEEN 0 AND 28
    ),

    -- =========================================================================
    -- age_recorded checks
    -- =========================================================================
    missing_age_recorded AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_recorded'                              AS variable,
        'No answer recorded for whether age was recorded' AS issue,
        age_recorded                                AS current_value
      FROM neonatal_core
      WHERE (age_recorded IS NULL OR TRIM(age_recorded) = '')
    ),

    -- -------------------------------------------------------------------------
    -- age_less_than_24hrs checks (only when age_recorded = '1')
    -- -------------------------------------------------------------------------
    missing_age_less_than_24hrs AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_less_than_24hrs'                                                        AS variable,
        'No answer recorded for whether the baby was less than 24 hours old at admission (age was recorded)' AS issue,
        age_less_than_24hrs                                                          AS current_value
      FROM neonatal_core
      WHERE (age_less_than_24hrs IS NULL OR TRIM(age_less_than_24hrs) = '')
        AND age_recorded = '1'
    ),

    -- -------------------------------------------------------------------------
    -- age_days checks (only when age_less_than_24hrs = '2' AND age_recorded = '1')
    -- -------------------------------------------------------------------------
    missing_age_days AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_days'                                                                         AS variable,
        'Age in days is missing (baby was recorded as 24 hours or older at admission and age was recorded)' AS issue,
        age_days                                                                           AS current_value
      FROM neonatal_core
      WHERE (age_days IS NULL OR TRIM(age_days) = '')
        AND age_less_than_24hrs = '2'
        AND age_recorded = '1'
    ),

    -- age_days plausibility: must be integer between 0 and 28
    implausible_age_days AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_days' AS variable,
        CASE
          WHEN TRY_CAST(age_days AS INTEGER) < 0
            THEN 'Age at admission (' || age_days || ' days) is negative, which is not possible'
          WHEN TRY_CAST(age_days AS INTEGER) > 28
            THEN 'Age at admission (' || age_days || ' days) exceeds 28 days, which is outside the neonatal period'
        END AS issue,
        age_days AS current_value
      FROM neonatal_core
      WHERE age_days IS NOT NULL
        AND TRIM(age_days) <> ''
        AND age_days <> '-1'
        AND age_less_than_24hrs = '2'
        AND age_recorded = '1'
        AND TRY_CAST(age_days AS INTEGER) IS NOT NULL
        AND (
              TRY_CAST(age_days AS INTEGER) < 0
           OR TRY_CAST(age_days AS INTEGER) > 28
            )
    ),

    -- age_days vs date_of_birth / date_adm consistency (tolerance �1 day)
    age_days_vs_dates_inconsistent AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_days / date_of_birth / date_adm' AS variable,
        'Recorded age at admission (' || age_days || ' days) does not match the difference between the date of admission and date of birth (' ||
          CAST(DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE)) AS VARCHAR) ||
          ' days); discrepancy exceeds the permitted tolerance of 1 day' AS issue,
        age_days AS current_value
      FROM neonatal_core
      WHERE age_days IS NOT NULL
        AND TRIM(age_days) <> ''
        AND age_days <> '-1'
        AND age_less_than_24hrs = '2'
        AND age_recorded = '1'
        AND TRY_CAST(age_days AS INTEGER) IS NOT NULL
        AND TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND date_of_birth <> '1914-01-01'
        AND date_adm      <> '1914-01-01'
        AND ABS(
              TRY_CAST(age_days AS INTEGER)
              - DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE))
            ) > 1
    ),

    -- age_less_than_24hrs = '1' (Yes) but date_adm - date_of_birth >= 1 day
    age_lt24hrs_contradicts_dates AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_less_than_24hrs / date_of_birth / date_adm' AS variable,
        'Baby was recorded as less than 24 hours old at admission, but the dates of birth and admission are ' ||
          CAST(DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE)) AS VARCHAR) ||
          ' day(s) apart (expected 0 days apart for a baby under 24 hours)' AS issue,
        age_less_than_24hrs AS current_value
      FROM neonatal_core
      WHERE age_less_than_24hrs = '1'
        AND age_recorded = '1'
        AND TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND date_of_birth <> '1914-01-01'
        AND date_adm      <> '1914-01-01'
        AND DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE)) >= 1
    ),

    -- age_less_than_24hrs = '2' (No) but date_adm - date_of_birth = 0 days
    age_gte24hrs_contradicts_dates AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'age_less_than_24hrs / date_of_birth / date_adm' AS variable,
        'Baby was recorded as 24 hours or older at admission, but the date of birth and date of admission are the same ? the baby was likely under 24 hours old' AS issue,
        age_less_than_24hrs AS current_value
      FROM neonatal_core
      WHERE age_less_than_24hrs = '2'
        AND age_recorded = '1'
        AND TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND date_of_birth <> '1914-01-01'
        AND date_adm      <> '1914-01-01'
        AND DATE_DIFF('day', TRY_CAST(date_of_birth AS DATE), TRY_CAST(date_adm AS DATE)) = 0
    ),

    -- =========================================================================
    -- child_sex checks
    -- =========================================================================
    missing_child_sex AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'child_sex'                  AS variable,
        'No sex of the child was recorded' AS issue,
        child_sex                    AS current_value
      FROM neonatal_core
      WHERE (child_sex IS NULL OR TRIM(child_sex) = '')
    ),

    invalid_child_sex AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'child_sex' AS variable,
        'Sex of the child has an unrecognised value (' || child_sex || '); expected Male (1), Female (2), or Indeterminate (3)' AS issue,
        child_sex   AS current_value
      FROM neonatal_core
      WHERE child_sex IS NOT NULL
        AND TRIM(child_sex) <> ''
        AND child_sex NOT IN ('1', '2', '3', '-1')
    ),

    -- =========================================================================
    -- referred_to_hospital checks
    -- =========================================================================
    missing_referred_to_hospital AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'referred_to_hospital'                                     AS variable,
        'No answer recorded for whether the baby was referred to this hospital' AS issue,
        referred_to_hospital                                       AS current_value
      FROM neonatal_core
      WHERE (referred_to_hospital IS NULL OR TRIM(referred_to_hospital) = '')
    ),

    invalid_referred_to_hospital AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'referred_to_hospital' AS variable,
        'Referral status has an unrecognised value (' || referred_to_hospital || '); expected Yes (1) or No (2)' AS issue,
        referred_to_hospital   AS current_value
      FROM neonatal_core
      WHERE referred_to_hospital IS NOT NULL
        AND TRIM(referred_to_hospital) <> ''
        AND referred_to_hospital NOT IN ('1', '2', '-1')
    ),

    -- -------------------------------------------------------------------------
    -- referral_info_available checks (only when referred_to_hospital = '1')
    -- -------------------------------------------------------------------------
    missing_referral_info_available AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'referral_info_available'                                                          AS variable,
        'No answer recorded for whether referral information is available (baby was referred to this hospital)' AS issue,
        referral_info_available                                                            AS current_value
      FROM neonatal_core
      WHERE (referral_info_available IS NULL OR TRIM(referral_info_available) = '')
        AND referred_to_hospital = '1'
    ),

    -- referral_info_available populated when referred_to_hospital != '1' (orphaned)
    orphaned_referral_info_available AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'referral_info_available' AS variable,
        'Referral information availability is filled in, but the baby was not recorded as referred to this hospital' AS issue,
        referral_info_available   AS current_value
      FROM neonatal_core
      WHERE referral_info_available IS NOT NULL
        AND TRIM(referral_info_available) <> ''
        AND (referred_to_hospital IS NULL OR referred_to_hospital <> '1')
    ),

    -- referred_from_which_facili populated when referred_to_hospital != '1' (orphaned)
    orphaned_referred_from_facility AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'referred_from_which_facili' AS variable,
        'Referring facility is filled in, but the baby was not recorded as referred to this hospital' AS issue,
        referred_from_which_facili   AS current_value
      FROM neonatal_core
      WHERE referred_from_which_facili IS NOT NULL
        AND TRIM(referred_from_which_facili) <> ''
        AND (referred_to_hospital IS NULL OR referred_to_hospital <> '1')
    ),

    -- =========================================================================
    -- GIS checks ? only applicable to KE hospitals
    -- (hosp_id IN: 53, 58, 41, 51, 45, 40, 71, 55, 52, 63, 76)
    -- =========================================================================
    missing_in_gis_avail_ke AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'in_gis_avail_ke'                                                          AS variable,
        'No answer recorded for whether GIS location data is available (required for this hospital)' AS issue,
        in_gis_avail_ke                                                            AS current_value
      FROM neonatal_core
      WHERE (in_gis_avail_ke IS NULL OR TRIM(in_gis_avail_ke) = '')
        AND hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
    ),

        -- =========================================================================
    -- SERIAL WEIGHT DQA (weight_doc section ? fields 40?119)
    -- Applies only to low-birth-weight babies with admission >= 7 days
    -- i.e. the same cohort for whom weight_doc is shown in the form
    -- =========================================================================

    -- Helper: identify records in scope for the weight_doc section
    -- (mirrors the show-field logic on weight_doc exactly)
    -- Used as a filter in every CTE below via a correlated condition

    -- -------------------------------------------------------------------------
    -- weight_doc: was weight documented after admission?
    -- Only checked when the record is in scope (LBW + stay >= 7 days)
    -- -------------------------------------------------------------------------
    missing_weight_doc AS (
      SELECT
        id,
        hosp_id,
        date_today,
        'weight_doc' AS variable,
        'No answer recorded for whether weight was documented after admission (baby was low birth weight and stayed 7 or more days)' AS issue,
        weight_doc AS current_value
      FROM neonatal_core
      WHERE (weight_doc IS NULL OR TRIM(weight_doc) = '')
        AND (
              (   birth_wt_units = '2'
              AND TRY_CAST(birth_wt AS DOUBLE) > 0
              AND TRY_CAST(birth_wt AS DOUBLE) < 2.5
              AND birth_wt <> '-1'
              )
           OR (   birth_wt_units = '1'
              AND TRY_CAST(birth_wt AS DOUBLE) > 0
              AND TRY_CAST(birth_wt AS DOUBLE) < 2500
              AND birth_wt <> '-1'
              )
            )
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm       <> '1914-01-01'
        AND date_discharge <> '1914-01-01'
        AND DATE_DIFF('day', TRY_CAST(date_adm AS DATE), TRY_CAST(date_discharge AS DATE)) >= 7
    ),

    -- =========================================================================
    -- For weights 1?20: when weight_doc = '1' (Yes), each serial weight entry
    -- requires:
    --   ? weight_N_units   ? must not be missing (unit required)
    --   ? weight_N         ? must not be missing; must be plausible
    --   ? date_N           ? must not be missing; must be within adm?discharge window
    --
    -- Visibility chain:
    --   weight 1        : weight_doc = '1'
    --   weight 2?20     : other_weight_(N-1) = '1'
    --   other_weight_N  : weight_doc = '1' (for N=1) or other_weight_(N-1) = '1'
    -- =========================================================================

    -- ----- WEIGHT 1 ----------------------------------------------------------
    missing_weight_1_units AS (
      SELECT id, hosp_id, date_today,
        'weight_1_units' AS variable,
        'Unit for weight one is missing (weight documentation was answered Yes)' AS issue,
        weight_1_units AS current_value
      FROM neonatal_core
      WHERE weight_doc = '1'
        AND (weight_1_units IS NULL OR TRIM(weight_1_units) = '')
    ),
    missing_weight_1 AS (
      SELECT id, hosp_id, date_today,
        'weight_1' AS variable,
        'Weight one value is missing (weight documentation was answered Yes)' AS issue,
        weight_1 AS current_value
      FROM neonatal_core
      WHERE weight_doc = '1'
        AND (weight_1 IS NULL OR TRIM(weight_1) = '')
    ),
    implausible_weight_1 AS (
      SELECT id, hosp_id, date_today,
        'weight_1' AS variable,
        CASE
          WHEN weight_1_units = '1' AND TRY_CAST(weight_1 AS DOUBLE) < 200
            THEN 'Weight one (' || weight_1 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_1_units = '1' AND TRY_CAST(weight_1 AS DOUBLE) > 8000
            THEN 'Weight one (' || weight_1 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_1_units = '2' AND TRY_CAST(weight_1 AS DOUBLE) < 0.2
            THEN 'Weight one (' || weight_1 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_1_units = '2' AND TRY_CAST(weight_1 AS DOUBLE) > 8.0
            THEN 'Weight one (' || weight_1 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue,
        weight_1 AS current_value
      FROM neonatal_core
      WHERE weight_doc = '1'
        AND weight_1 IS NOT NULL AND TRIM(weight_1) <> '' AND weight_1 <> '-1'
        AND weight_1_units IN ('1','2')
        AND TRY_CAST(weight_1 AS DOUBLE) IS NOT NULL
        AND (
              (weight_1_units = '1' AND (TRY_CAST(weight_1 AS DOUBLE) < 200  OR TRY_CAST(weight_1 AS DOUBLE) > 8000))
           OR (weight_1_units = '2' AND (TRY_CAST(weight_1 AS DOUBLE) < 0.2  OR TRY_CAST(weight_1 AS DOUBLE) > 8.0))
            )
    ),
    missing_date_1 AS (
      SELECT id, hosp_id, date_today,
        'date_1' AS variable,
        'Date for weight one is missing (weight documentation was answered Yes)' AS issue,
        date_1 AS current_value
      FROM neonatal_core
      WHERE weight_doc = '1'
        AND (date_1 IS NULL OR TRIM(date_1) = '')
    ),
    date_1_out_of_window AS (
      SELECT id, hosp_id, date_today,
        'date_1' AS variable,
        'Date for weight one (' || date_1 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_1 AS current_value
      FROM neonatal_core
      WHERE weight_doc = '1'
        AND date_1 IS NOT NULL AND TRIM(date_1) <> '' AND date_1 <> '1914-01-01'
        AND TRY_CAST(date_1 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm <> '1914-01-01' AND date_discharge <> '1914-01-01'
        AND (
              TRY_CAST(date_1 AS DATE) < TRY_CAST(date_adm AS DATE)
           OR TRY_CAST(date_1 AS DATE) > TRY_CAST(date_discharge AS DATE)
            )
    ),
    missing_other_weight_1 AS (
      SELECT id, hosp_id, date_today,
        'other_weight' AS variable,
        'No answer recorded for whether another weight after weight one was documented' AS issue,
        other_weight AS current_value
      FROM neonatal_core
      WHERE weight_doc = '1'
        AND (other_weight IS NULL OR TRIM(other_weight) = '')
    ),

    -- ----- WEIGHT 2 ----------------------------------------------------------
    missing_weight_2_units AS (
      SELECT id, hosp_id, date_today, 'weight_2_units' AS variable,
        'Unit for weight two is missing (a second weight was indicated)' AS issue,
        weight_2_units AS current_value
      FROM neonatal_core
      WHERE other_weight = '1'
        AND (weight_2_units IS NULL OR TRIM(weight_2_units) = '')
    ),
    missing_weight_2 AS (
      SELECT id, hosp_id, date_today, 'weight_2' AS variable,
        'Weight two value is missing (a second weight was indicated)' AS issue,
        weight_2 AS current_value
      FROM neonatal_core
      WHERE other_weight = '1'
        AND (weight_2 IS NULL OR TRIM(weight_2) = '')
    ),
    implausible_weight_2 AS (
      SELECT id, hosp_id, date_today, 'weight_2' AS variable,
        CASE
          WHEN weight_2_units = '1' AND TRY_CAST(weight_2 AS DOUBLE) < 200  THEN 'Weight two (' || weight_2 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_2_units = '1' AND TRY_CAST(weight_2 AS DOUBLE) > 8000 THEN 'Weight two (' || weight_2 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_2_units = '2' AND TRY_CAST(weight_2 AS DOUBLE) < 0.2  THEN 'Weight two (' || weight_2 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_2_units = '2' AND TRY_CAST(weight_2 AS DOUBLE) > 8.0  THEN 'Weight two (' || weight_2 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue,
        weight_2 AS current_value
      FROM neonatal_core
      WHERE other_weight = '1'
        AND weight_2 IS NOT NULL AND TRIM(weight_2) <> '' AND weight_2 <> '-1'
        AND weight_2_units IN ('1','2') AND TRY_CAST(weight_2 AS DOUBLE) IS NOT NULL
        AND ((weight_2_units='1' AND (TRY_CAST(weight_2 AS DOUBLE)<200 OR TRY_CAST(weight_2 AS DOUBLE)>8000))
          OR (weight_2_units='2' AND (TRY_CAST(weight_2 AS DOUBLE)<0.2 OR TRY_CAST(weight_2 AS DOUBLE)>8.0)))
    ),
    missing_date_2 AS (
      SELECT id, hosp_id, date_today, 'date_2' AS variable,
        'Date for weight two is missing (a second weight was indicated)' AS issue,
        date_2 AS current_value
      FROM neonatal_core
      WHERE other_weight = '1' AND (date_2 IS NULL OR TRIM(date_2) = '')
    ),
    date_2_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_2' AS variable,
        'Date for weight two (' || date_2 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_2 AS current_value
      FROM neonatal_core
      WHERE other_weight = '1'
        AND date_2 IS NOT NULL AND TRIM(date_2)<>'' AND date_2<>'1914-01-01'
        AND TRY_CAST(date_2 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_2 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_2 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_2 AS (
      SELECT id, hosp_id, date_today, 'other_weight_2' AS variable,
        'No answer recorded for whether another weight after weight two was documented' AS issue,
        other_weight_2 AS current_value
      FROM neonatal_core
      WHERE other_weight = '1' AND (other_weight_2 IS NULL OR TRIM(other_weight_2) = '')
    ),

    -- ----- WEIGHT 3 ----------------------------------------------------------
    missing_weight_3_units AS (
      SELECT id, hosp_id, date_today, 'weight_3_units' AS variable,
        'Unit for weight three is missing (a third weight was indicated)' AS issue,
        weight_3_units AS current_value
      FROM neonatal_core WHERE other_weight_2='1' AND (weight_3_units IS NULL OR TRIM(weight_3_units)='')
    ),
    missing_weight_3 AS (
      SELECT id, hosp_id, date_today, 'weight_3' AS variable,
        'Weight three value is missing (a third weight was indicated)' AS issue,
        weight_3 AS current_value
      FROM neonatal_core WHERE other_weight_2='1' AND (weight_3 IS NULL OR TRIM(weight_3)='')
    ),
    implausible_weight_3 AS (
      SELECT id, hosp_id, date_today, 'weight_3' AS variable,
        CASE
          WHEN weight_3_units='1' AND TRY_CAST(weight_3 AS DOUBLE)<200  THEN 'Weight three (' || weight_3 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_3_units='1' AND TRY_CAST(weight_3 AS DOUBLE)>8000 THEN 'Weight three (' || weight_3 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_3_units='2' AND TRY_CAST(weight_3 AS DOUBLE)<0.2  THEN 'Weight three (' || weight_3 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_3_units='2' AND TRY_CAST(weight_3 AS DOUBLE)>8.0  THEN 'Weight three (' || weight_3 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_3 AS current_value
      FROM neonatal_core
      WHERE other_weight_2='1' AND weight_3 IS NOT NULL AND TRIM(weight_3)<>'' AND weight_3<>'-1'
        AND weight_3_units IN ('1','2') AND TRY_CAST(weight_3 AS DOUBLE) IS NOT NULL
        AND ((weight_3_units='1' AND (TRY_CAST(weight_3 AS DOUBLE)<200 OR TRY_CAST(weight_3 AS DOUBLE)>8000))
          OR (weight_3_units='2' AND (TRY_CAST(weight_3 AS DOUBLE)<0.2 OR TRY_CAST(weight_3 AS DOUBLE)>8.0)))
    ),
    missing_date_3 AS (
      SELECT id, hosp_id, date_today, 'date_3' AS variable,
        'Date for weight three is missing (a third weight was indicated)' AS issue,
        date_3 AS current_value
      FROM neonatal_core WHERE other_weight_2='1' AND (date_3 IS NULL OR TRIM(date_3)='')
    ),
    date_3_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_3' AS variable,
        'Date for weight three (' || date_3 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_3 AS current_value
      FROM neonatal_core
      WHERE other_weight_2='1' AND date_3 IS NOT NULL AND TRIM(date_3)<>'' AND date_3<>'1914-01-01'
        AND TRY_CAST(date_3 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_3 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_3 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_3 AS (
      SELECT id, hosp_id, date_today, 'other_weight_3' AS variable,
        'No answer recorded for whether another weight after weight three was documented' AS issue,
        other_weight_3 AS current_value
      FROM neonatal_core WHERE other_weight_2='1' AND (other_weight_3 IS NULL OR TRIM(other_weight_3)='')
    ),

    -- ----- WEIGHT 4 ----------------------------------------------------------
    missing_weight_4_units AS (
      SELECT id, hosp_id, date_today, 'weight_4_units' AS variable,
        'Unit for weight four is missing (a fourth weight was indicated)' AS issue,
        weight_4_units AS current_value
      FROM neonatal_core WHERE other_weight_3='1' AND (weight_4_units IS NULL OR TRIM(weight_4_units)='')
    ),
    missing_weight_4 AS (
      SELECT id, hosp_id, date_today, 'weight_4' AS variable,
        'Weight four value is missing (a fourth weight was indicated)' AS issue,
        weight_4 AS current_value
      FROM neonatal_core WHERE other_weight_3='1' AND (weight_4 IS NULL OR TRIM(weight_4)='')
    ),
    implausible_weight_4 AS (
      SELECT id, hosp_id, date_today, 'weight_4' AS variable,
        CASE
          WHEN weight_4_units='1' AND TRY_CAST(weight_4 AS DOUBLE)<200  THEN 'Weight four (' || weight_4 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_4_units='1' AND TRY_CAST(weight_4 AS DOUBLE)>8000 THEN 'Weight four (' || weight_4 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_4_units='2' AND TRY_CAST(weight_4 AS DOUBLE)<0.2  THEN 'Weight four (' || weight_4 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_4_units='2' AND TRY_CAST(weight_4 AS DOUBLE)>8.0  THEN 'Weight four (' || weight_4 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_4 AS current_value
      FROM neonatal_core
      WHERE other_weight_3='1' AND weight_4 IS NOT NULL AND TRIM(weight_4)<>'' AND weight_4<>'-1'
        AND weight_4_units IN ('1','2') AND TRY_CAST(weight_4 AS DOUBLE) IS NOT NULL
        AND ((weight_4_units='1' AND (TRY_CAST(weight_4 AS DOUBLE)<200 OR TRY_CAST(weight_4 AS DOUBLE)>8000))
          OR (weight_4_units='2' AND (TRY_CAST(weight_4 AS DOUBLE)<0.2 OR TRY_CAST(weight_4 AS DOUBLE)>8.0)))
    ),
    missing_date_4 AS (
      SELECT id, hosp_id, date_today, 'date_4' AS variable,
        'Date for weight four is missing (a fourth weight was indicated)' AS issue,
        date_4 AS current_value
      FROM neonatal_core WHERE other_weight_3='1' AND (date_4 IS NULL OR TRIM(date_4)='')
    ),
    date_4_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_4' AS variable,
        'Date for weight four (' || date_4 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_4 AS current_value
      FROM neonatal_core
      WHERE other_weight_3='1' AND date_4 IS NOT NULL AND TRIM(date_4)<>'' AND date_4<>'1914-01-01'
        AND TRY_CAST(date_4 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_4 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_4 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_4 AS (
      SELECT id, hosp_id, date_today, 'other_weight_4' AS variable,
        'No answer recorded for whether another weight after weight four was documented' AS issue,
        other_weight_4 AS current_value
      FROM neonatal_core WHERE other_weight_3='1' AND (other_weight_4 IS NULL OR TRIM(other_weight_4)='')
    ),

    -- ----- WEIGHT 5 ----------------------------------------------------------
    missing_weight_5_units AS (
      SELECT id, hosp_id, date_today, 'weight_5_units' AS variable,
        'Unit for weight five is missing (a fifth weight was indicated)' AS issue,
        weight_5_units AS current_value
      FROM neonatal_core WHERE other_weight_4='1' AND (weight_5_units IS NULL OR TRIM(weight_5_units)='')
    ),
    missing_weight_5 AS (
      SELECT id, hosp_id, date_today, 'weight_5' AS variable,
        'Weight five value is missing (a fifth weight was indicated)' AS issue,
        weight_5 AS current_value
      FROM neonatal_core WHERE other_weight_4='1' AND (weight_5 IS NULL OR TRIM(weight_5)='')
    ),
    implausible_weight_5 AS (
      SELECT id, hosp_id, date_today, 'weight_5' AS variable,
        CASE
          WHEN weight_5_units='1' AND TRY_CAST(weight_5 AS DOUBLE)<200  THEN 'Weight five (' || weight_5 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_5_units='1' AND TRY_CAST(weight_5 AS DOUBLE)>8000 THEN 'Weight five (' || weight_5 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_5_units='2' AND TRY_CAST(weight_5 AS DOUBLE)<0.2  THEN 'Weight five (' || weight_5 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_5_units='2' AND TRY_CAST(weight_5 AS DOUBLE)>8.0  THEN 'Weight five (' || weight_5 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_5 AS current_value
      FROM neonatal_core
      WHERE other_weight_4='1' AND weight_5 IS NOT NULL AND TRIM(weight_5)<>'' AND weight_5<>'-1'
        AND weight_5_units IN ('1','2') AND TRY_CAST(weight_5 AS DOUBLE) IS NOT NULL
        AND ((weight_5_units='1' AND (TRY_CAST(weight_5 AS DOUBLE)<200 OR TRY_CAST(weight_5 AS DOUBLE)>8000))
          OR (weight_5_units='2' AND (TRY_CAST(weight_5 AS DOUBLE)<0.2 OR TRY_CAST(weight_5 AS DOUBLE)>8.0)))
    ),
    missing_date_5 AS (
      SELECT id, hosp_id, date_today, 'date_5' AS variable,
        'Date for weight five is missing (a fifth weight was indicated)' AS issue,
        date_5 AS current_value
      FROM neonatal_core WHERE other_weight_4='1' AND (date_5 IS NULL OR TRIM(date_5)='')
    ),
    date_5_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_5' AS variable,
        'Date for weight five (' || date_5 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_5 AS current_value
      FROM neonatal_core
      WHERE other_weight_4='1' AND date_5 IS NOT NULL AND TRIM(date_5)<>'' AND date_5<>'1914-01-01'
        AND TRY_CAST(date_5 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_5 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_5 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_5 AS (
      SELECT id, hosp_id, date_today, 'other_weight_5' AS variable,
        'No answer recorded for whether another weight after weight five was documented' AS issue,
        other_weight_5 AS current_value
      FROM neonatal_core WHERE other_weight_4='1' AND (other_weight_5 IS NULL OR TRIM(other_weight_5)='')
    ),

    -- ----- WEIGHT 6 ----------------------------------------------------------
    missing_weight_6_units AS (
      SELECT id, hosp_id, date_today, 'weight_6_units' AS variable,
        'Unit for weight six is missing (a sixth weight was indicated)' AS issue,
        weight_6_units AS current_value
      FROM neonatal_core WHERE other_weight_5='1' AND (weight_6_units IS NULL OR TRIM(weight_6_units)='')
    ),
    missing_weight_6 AS (
      SELECT id, hosp_id, date_today, 'weight_6' AS variable,
        'Weight six value is missing (a sixth weight was indicated)' AS issue,
        weight_6 AS current_value
      FROM neonatal_core WHERE other_weight_5='1' AND (weight_6 IS NULL OR TRIM(weight_6)='')
    ),
    implausible_weight_6 AS (
      SELECT id, hosp_id, date_today, 'weight_6' AS variable,
        CASE
          WHEN weight_6_units='1' AND TRY_CAST(weight_6 AS DOUBLE)<200  THEN 'Weight six (' || weight_6 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_6_units='1' AND TRY_CAST(weight_6 AS DOUBLE)>8000 THEN 'Weight six (' || weight_6 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_6_units='2' AND TRY_CAST(weight_6 AS DOUBLE)<0.2  THEN 'Weight six (' || weight_6 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_6_units='2' AND TRY_CAST(weight_6 AS DOUBLE)>8.0  THEN 'Weight six (' || weight_6 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_6 AS current_value
      FROM neonatal_core
      WHERE other_weight_5='1' AND weight_6 IS NOT NULL AND TRIM(weight_6)<>'' AND weight_6<>'-1'
        AND weight_6_units IN ('1','2') AND TRY_CAST(weight_6 AS DOUBLE) IS NOT NULL
        AND ((weight_6_units='1' AND (TRY_CAST(weight_6 AS DOUBLE)<200 OR TRY_CAST(weight_6 AS DOUBLE)>8000))
          OR (weight_6_units='2' AND (TRY_CAST(weight_6 AS DOUBLE)<0.2 OR TRY_CAST(weight_6 AS DOUBLE)>8.0)))
    ),
    missing_date_6 AS (
      SELECT id, hosp_id, date_today, 'date_6' AS variable,
        'Date for weight six is missing (a sixth weight was indicated)' AS issue,
        date_6 AS current_value
      FROM neonatal_core WHERE other_weight_5='1' AND (date_6 IS NULL OR TRIM(date_6)='')
    ),
    date_6_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_6' AS variable,
        'Date for weight six (' || date_6 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_6 AS current_value
      FROM neonatal_core
      WHERE other_weight_5='1' AND date_6 IS NOT NULL AND TRIM(date_6)<>'' AND date_6<>'1914-01-01'
        AND TRY_CAST(date_6 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_6 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_6 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_6 AS (
      SELECT id, hosp_id, date_today, 'other_weight_6' AS variable,
        'No answer recorded for whether another weight after weight six was documented' AS issue,
        other_weight_6 AS current_value
      FROM neonatal_core WHERE other_weight_5='1' AND (other_weight_6 IS NULL OR TRIM(other_weight_6)='')
    ),

    -- ----- WEIGHT 7 ----------------------------------------------------------
    missing_weight_7_units AS (
      SELECT id, hosp_id, date_today, 'weight_7_units' AS variable,
        'Unit for weight seven is missing (a seventh weight was indicated)' AS issue,
        weight_7_units AS current_value
      FROM neonatal_core WHERE other_weight_6='1' AND (weight_7_units IS NULL OR TRIM(weight_7_units)='')
    ),
    missing_weight_7 AS (
      SELECT id, hosp_id, date_today, 'weight_7' AS variable,
        'Weight seven value is missing (a seventh weight was indicated)' AS issue,
        weight_7 AS current_value
      FROM neonatal_core WHERE other_weight_6='1' AND (weight_7 IS NULL OR TRIM(weight_7)='')
    ),
    implausible_weight_7 AS (
      SELECT id, hosp_id, date_today, 'weight_7' AS variable,
        CASE
          WHEN weight_7_units='1' AND TRY_CAST(weight_7 AS DOUBLE)<200  THEN 'Weight seven (' || weight_7 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_7_units='1' AND TRY_CAST(weight_7 AS DOUBLE)>8000 THEN 'Weight seven (' || weight_7 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_7_units='2' AND TRY_CAST(weight_7 AS DOUBLE)<0.2  THEN 'Weight seven (' || weight_7 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_7_units='2' AND TRY_CAST(weight_7 AS DOUBLE)>8.0  THEN 'Weight seven (' || weight_7 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_7 AS current_value
      FROM neonatal_core
      WHERE other_weight_6='1' AND weight_7 IS NOT NULL AND TRIM(weight_7)<>'' AND weight_7<>'-1'
        AND weight_7_units IN ('1','2') AND TRY_CAST(weight_7 AS DOUBLE) IS NOT NULL
        AND ((weight_7_units='1' AND (TRY_CAST(weight_7 AS DOUBLE)<200 OR TRY_CAST(weight_7 AS DOUBLE)>8000))
          OR (weight_7_units='2' AND (TRY_CAST(weight_7 AS DOUBLE)<0.2 OR TRY_CAST(weight_7 AS DOUBLE)>8.0)))
    ),
    missing_date_7 AS (
      SELECT id, hosp_id, date_today, 'date_7' AS variable,
        'Date for weight seven is missing (a seventh weight was indicated)' AS issue,
        date_7 AS current_value
      FROM neonatal_core WHERE other_weight_6='1' AND (date_7 IS NULL OR TRIM(date_7)='')
    ),
    date_7_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_7' AS variable,
        'Date for weight seven (' || date_7 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_7 AS current_value
      FROM neonatal_core
      WHERE other_weight_6='1' AND date_7 IS NOT NULL AND TRIM(date_7)<>'' AND date_7<>'1914-01-01'
        AND TRY_CAST(date_7 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_7 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_7 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_7 AS (
      SELECT id, hosp_id, date_today, 'other_weight_7' AS variable,
        'No answer recorded for whether another weight after weight seven was documented' AS issue,
        other_weight_7 AS current_value
      FROM neonatal_core WHERE other_weight_6='1' AND (other_weight_7 IS NULL OR TRIM(other_weight_7)='')
    ),

    -- ----- WEIGHT 8 ----------------------------------------------------------
    missing_weight_8_units AS (
      SELECT id, hosp_id, date_today, 'weight_8_units' AS variable,
        'Unit for weight eight is missing (an eighth weight was indicated)' AS issue,
        weight_8_units AS current_value
      FROM neonatal_core WHERE other_weight_7='1' AND (weight_8_units IS NULL OR TRIM(weight_8_units)='')
    ),
    missing_weight_8 AS (
      SELECT id, hosp_id, date_today, 'weight_8' AS variable,
        'Weight eight value is missing (an eighth weight was indicated)' AS issue,
        weight_8 AS current_value
      FROM neonatal_core WHERE other_weight_7='1' AND (weight_8 IS NULL OR TRIM(weight_8)='')
    ),
    implausible_weight_8 AS (
      SELECT id, hosp_id, date_today, 'weight_8' AS variable,
        CASE
          WHEN weight_8_units='1' AND TRY_CAST(weight_8 AS DOUBLE)<200  THEN 'Weight eight (' || weight_8 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_8_units='1' AND TRY_CAST(weight_8 AS DOUBLE)>8000 THEN 'Weight eight (' || weight_8 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_8_units='2' AND TRY_CAST(weight_8 AS DOUBLE)<0.2  THEN 'Weight eight (' || weight_8 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_8_units='2' AND TRY_CAST(weight_8 AS DOUBLE)>8.0  THEN 'Weight eight (' || weight_8 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_8 AS current_value
      FROM neonatal_core
      WHERE other_weight_7='1' AND weight_8 IS NOT NULL AND TRIM(weight_8)<>'' AND weight_8<>'-1'
        AND weight_8_units IN ('1','2') AND TRY_CAST(weight_8 AS DOUBLE) IS NOT NULL
        AND ((weight_8_units='1' AND (TRY_CAST(weight_8 AS DOUBLE)<200 OR TRY_CAST(weight_8 AS DOUBLE)>8000))
          OR (weight_8_units='2' AND (TRY_CAST(weight_8 AS DOUBLE)<0.2 OR TRY_CAST(weight_8 AS DOUBLE)>8.0)))
    ),
    missing_date_8 AS (
      SELECT id, hosp_id, date_today, 'date_8' AS variable,
        'Date for weight eight is missing (an eighth weight was indicated)' AS issue,
        date_8 AS current_value
      FROM neonatal_core WHERE other_weight_7='1' AND (date_8 IS NULL OR TRIM(date_8)='')
    ),
    date_8_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_8' AS variable,
        'Date for weight eight (' || date_8 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_8 AS current_value
      FROM neonatal_core
      WHERE other_weight_7='1' AND date_8 IS NOT NULL AND TRIM(date_8)<>'' AND date_8<>'1914-01-01'
        AND TRY_CAST(date_8 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_8 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_8 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_8 AS (
      SELECT id, hosp_id, date_today, 'other_weight_8' AS variable,
        'No answer recorded for whether another weight after weight eight was documented' AS issue,
        other_weight_8 AS current_value
      FROM neonatal_core WHERE other_weight_7='1' AND (other_weight_8 IS NULL OR TRIM(other_weight_8)='')
    ),

    -- ----- WEIGHT 9 ----------------------------------------------------------
    missing_weight_9_units AS (
      SELECT id, hosp_id, date_today, 'weight_9_units' AS variable,
        'Unit for weight nine is missing (a ninth weight was indicated)' AS issue,
        weight_9_units AS current_value
      FROM neonatal_core WHERE other_weight_8='1' AND (weight_9_units IS NULL OR TRIM(weight_9_units)='')
    ),
    missing_weight_9 AS (
      SELECT id, hosp_id, date_today, 'weight_9' AS variable,
        'Weight nine value is missing (a ninth weight was indicated)' AS issue,
        weight_9 AS current_value
      FROM neonatal_core WHERE other_weight_8='1' AND (weight_9 IS NULL OR TRIM(weight_9)='')
    ),
    implausible_weight_9 AS (
      SELECT id, hosp_id, date_today, 'weight_9' AS variable,
        CASE
          WHEN weight_9_units='1' AND TRY_CAST(weight_9 AS DOUBLE)<200  THEN 'Weight nine (' || weight_9 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_9_units='1' AND TRY_CAST(weight_9 AS DOUBLE)>8000 THEN 'Weight nine (' || weight_9 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_9_units='2' AND TRY_CAST(weight_9 AS DOUBLE)<0.2  THEN 'Weight nine (' || weight_9 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_9_units='2' AND TRY_CAST(weight_9 AS DOUBLE)>8.0  THEN 'Weight nine (' || weight_9 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_9 AS current_value
      FROM neonatal_core
      WHERE other_weight_8='1' AND weight_9 IS NOT NULL AND TRIM(weight_9)<>'' AND weight_9<>'-1'
        AND weight_9_units IN ('1','2') AND TRY_CAST(weight_9 AS DOUBLE) IS NOT NULL
        AND ((weight_9_units='1' AND (TRY_CAST(weight_9 AS DOUBLE)<200 OR TRY_CAST(weight_9 AS DOUBLE)>8000))
          OR (weight_9_units='2' AND (TRY_CAST(weight_9 AS DOUBLE)<0.2 OR TRY_CAST(weight_9 AS DOUBLE)>8.0)))
    ),
    missing_date_9 AS (
      SELECT id, hosp_id, date_today, 'date_9' AS variable,
        'Date for weight nine is missing (a ninth weight was indicated)' AS issue,
        date_9 AS current_value
      FROM neonatal_core WHERE other_weight_8='1' AND (date_9 IS NULL OR TRIM(date_9)='')
    ),
    date_9_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_9' AS variable,
        'Date for weight nine (' || date_9 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_9 AS current_value
      FROM neonatal_core
      WHERE other_weight_8='1' AND date_9 IS NOT NULL AND TRIM(date_9)<>'' AND date_9<>'1914-01-01'
        AND TRY_CAST(date_9 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_9 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_9 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_9 AS (
      SELECT id, hosp_id, date_today, 'other_weight_9' AS variable,
        'No answer recorded for whether another weight after weight nine was documented' AS issue,
        other_weight_9 AS current_value
      FROM neonatal_core WHERE other_weight_8='1' AND (other_weight_9 IS NULL OR TRIM(other_weight_9)='')
    ),

    -- ----- WEIGHT 10 ---------------------------------------------------------
    missing_weight_10_units AS (
      SELECT id, hosp_id, date_today, 'weight_10_units' AS variable,
        'Unit for weight ten is missing (a tenth weight was indicated)' AS issue,
        weight_10_units AS current_value
      FROM neonatal_core WHERE other_weight_9='1' AND (weight_10_units IS NULL OR TRIM(weight_10_units)='')
    ),
    missing_weight_10 AS (
      SELECT id, hosp_id, date_today, 'weight_10' AS variable,
        'Weight ten value is missing (a tenth weight was indicated)' AS issue,
        weight_10 AS current_value
      FROM neonatal_core WHERE other_weight_9='1' AND (weight_10 IS NULL OR TRIM(weight_10)='')
    ),
    implausible_weight_10 AS (
      SELECT id, hosp_id, date_today, 'weight_10' AS variable,
        CASE
          WHEN weight_10_units='1' AND TRY_CAST(weight_10 AS DOUBLE)<200  THEN 'Weight ten (' || weight_10 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_10_units='1' AND TRY_CAST(weight_10 AS DOUBLE)>8000 THEN 'Weight ten (' || weight_10 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_10_units='2' AND TRY_CAST(weight_10 AS DOUBLE)<0.2  THEN 'Weight ten (' || weight_10 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_10_units='2' AND TRY_CAST(weight_10 AS DOUBLE)>8.0  THEN 'Weight ten (' || weight_10 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_10 AS current_value
      FROM neonatal_core
      WHERE other_weight_9='1' AND weight_10 IS NOT NULL AND TRIM(weight_10)<>'' AND weight_10<>'-1'
        AND weight_10_units IN ('1','2') AND TRY_CAST(weight_10 AS DOUBLE) IS NOT NULL
        AND ((weight_10_units='1' AND (TRY_CAST(weight_10 AS DOUBLE)<200 OR TRY_CAST(weight_10 AS DOUBLE)>8000))
          OR (weight_10_units='2' AND (TRY_CAST(weight_10 AS DOUBLE)<0.2 OR TRY_CAST(weight_10 AS DOUBLE)>8.0)))
    ),
    missing_date_10 AS (
      SELECT id, hosp_id, date_today, 'date_10' AS variable,
        'Date for weight ten is missing (a tenth weight was indicated)' AS issue,
        date_10 AS current_value
      FROM neonatal_core WHERE other_weight_9='1' AND (date_10 IS NULL OR TRIM(date_10)='')
    ),
    date_10_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_10' AS variable,
        'Date for weight ten (' || date_10 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_10 AS current_value
      FROM neonatal_core
      WHERE other_weight_9='1' AND date_10 IS NOT NULL AND TRIM(date_10)<>'' AND date_10<>'1914-01-01'
        AND TRY_CAST(date_10 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_10 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_10 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_10 AS (
      SELECT id, hosp_id, date_today, 'other_weight_10' AS variable,
        'No answer recorded for whether another weight after weight ten was documented' AS issue,
        other_weight_10 AS current_value
      FROM neonatal_core WHERE other_weight_9='1' AND (other_weight_10 IS NULL OR TRIM(other_weight_10)='')
    ),

    -- ----- WEIGHT 11 ---------------------------------------------------------
    missing_weight_11_units AS (
      SELECT id, hosp_id, date_today, 'weight_11_units' AS variable,
        'Unit for weight eleven is missing (an eleventh weight was indicated)' AS issue,
        weight_11_units AS current_value
      FROM neonatal_core WHERE other_weight_10='1' AND (weight_11_units IS NULL OR TRIM(weight_11_units)='')
    ),
    missing_weight_11 AS (
      SELECT id, hosp_id, date_today, 'weight_11' AS variable,
        'Weight eleven value is missing (an eleventh weight was indicated)' AS issue,
        weight_11 AS current_value
      FROM neonatal_core WHERE other_weight_10='1' AND (weight_11 IS NULL OR TRIM(weight_11)='')
    ),
    implausible_weight_11 AS (
      SELECT id, hosp_id, date_today, 'weight_11' AS variable,
        CASE
          WHEN weight_11_units='1' AND TRY_CAST(weight_11 AS DOUBLE)<200  THEN 'Weight eleven (' || weight_11 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_11_units='1' AND TRY_CAST(weight_11 AS DOUBLE)>8000 THEN 'Weight eleven (' || weight_11 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_11_units='2' AND TRY_CAST(weight_11 AS DOUBLE)<0.2  THEN 'Weight eleven (' || weight_11 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_11_units='2' AND TRY_CAST(weight_11 AS DOUBLE)>8.0  THEN 'Weight eleven (' || weight_11 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_11 AS current_value
      FROM neonatal_core
      WHERE other_weight_10='1' AND weight_11 IS NOT NULL AND TRIM(weight_11)<>'' AND weight_11<>'-1'
        AND weight_11_units IN ('1','2') AND TRY_CAST(weight_11 AS DOUBLE) IS NOT NULL
        AND ((weight_11_units='1' AND (TRY_CAST(weight_11 AS DOUBLE)<200 OR TRY_CAST(weight_11 AS DOUBLE)>8000))
          OR (weight_11_units='2' AND (TRY_CAST(weight_11 AS DOUBLE)<0.2 OR TRY_CAST(weight_11 AS DOUBLE)>8.0)))
    ),
    missing_date_11 AS (
      SELECT id, hosp_id, date_today, 'date_11' AS variable,
        'Date for weight eleven is missing (an eleventh weight was indicated)' AS issue,
        date_11 AS current_value
      FROM neonatal_core WHERE other_weight_10='1' AND (date_11 IS NULL OR TRIM(date_11)='')
    ),
    date_11_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_11' AS variable,
        'Date for weight eleven (' || date_11 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_11 AS current_value
      FROM neonatal_core
      WHERE other_weight_10='1' AND date_11 IS NOT NULL AND TRIM(date_11)<>'' AND date_11<>'1914-01-01'
        AND TRY_CAST(date_11 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_11 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_11 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_11 AS (
      SELECT id, hosp_id, date_today, 'other_weight_11' AS variable,
        'No answer recorded for whether another weight after weight eleven was documented' AS issue,
        other_weight_11 AS current_value
      FROM neonatal_core WHERE other_weight_10='1' AND (other_weight_11 IS NULL OR TRIM(other_weight_11)='')
    ),

    -- ----- WEIGHT 12 ---------------------------------------------------------
    missing_weight_12_units AS (
      SELECT id, hosp_id, date_today, 'weight_12_units' AS variable,
        'Unit for weight twelve is missing (a twelfth weight was indicated)' AS issue,
        weight_12_units AS current_value
      FROM neonatal_core WHERE other_weight_11='1' AND (weight_12_units IS NULL OR TRIM(weight_12_units)='')
    ),
    missing_weight_12 AS (
      SELECT id, hosp_id, date_today, 'weight_12' AS variable,
        'Weight twelve value is missing (a twelfth weight was indicated)' AS issue,
        weight_12 AS current_value
      FROM neonatal_core WHERE other_weight_11='1' AND (weight_12 IS NULL OR TRIM(weight_12)='')
    ),
    implausible_weight_12 AS (
      SELECT id, hosp_id, date_today, 'weight_12' AS variable,
        CASE
          WHEN weight_12_units='1' AND TRY_CAST(weight_12 AS DOUBLE)<200  THEN 'Weight twelve (' || weight_12 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_12_units='1' AND TRY_CAST(weight_12 AS DOUBLE)>8000 THEN 'Weight twelve (' || weight_12 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_12_units='2' AND TRY_CAST(weight_12 AS DOUBLE)<0.2  THEN 'Weight twelve (' || weight_12 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_12_units='2' AND TRY_CAST(weight_12 AS DOUBLE)>8.0  THEN 'Weight twelve (' || weight_12 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_12 AS current_value
      FROM neonatal_core
      WHERE other_weight_11='1' AND weight_12 IS NOT NULL AND TRIM(weight_12)<>'' AND weight_12<>'-1'
        AND weight_12_units IN ('1','2') AND TRY_CAST(weight_12 AS DOUBLE) IS NOT NULL
        AND ((weight_12_units='1' AND (TRY_CAST(weight_12 AS DOUBLE)<200 OR TRY_CAST(weight_12 AS DOUBLE)>8000))
          OR (weight_12_units='2' AND (TRY_CAST(weight_12 AS DOUBLE)<0.2 OR TRY_CAST(weight_12 AS DOUBLE)>8.0)))
    ),
    missing_date_12 AS (
      SELECT id, hosp_id, date_today, 'date_12' AS variable,
        'Date for weight twelve is missing (a twelfth weight was indicated)' AS issue,
        date_12 AS current_value
      FROM neonatal_core WHERE other_weight_11='1' AND (date_12 IS NULL OR TRIM(date_12)='')
    ),
    date_12_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_12' AS variable,
        'Date for weight twelve (' || date_12 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_12 AS current_value
      FROM neonatal_core
      WHERE other_weight_11='1' AND date_12 IS NOT NULL AND TRIM(date_12)<>'' AND date_12<>'1914-01-01'
        AND TRY_CAST(date_12 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_12 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_12 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_12 AS (
      SELECT id, hosp_id, date_today, 'other_weight_12' AS variable,
        'No answer recorded for whether another weight after weight twelve was documented' AS issue,
        other_weight_12 AS current_value
      FROM neonatal_core WHERE other_weight_11='1' AND (other_weight_12 IS NULL OR TRIM(other_weight_12)='')
    ),

    -- ----- WEIGHT 13 ---------------------------------------------------------
    missing_weight_13_units AS (
      SELECT id, hosp_id, date_today, 'weight_13_units' AS variable,
        'Unit for weight thirteen is missing (a thirteenth weight was indicated)' AS issue,
        weight_13_units AS current_value
      FROM neonatal_core WHERE other_weight_12='1' AND (weight_13_units IS NULL OR TRIM(weight_13_units)='')
    ),
    missing_weight_13 AS (
      SELECT id, hosp_id, date_today, 'weight_13' AS variable,
        'Weight thirteen value is missing (a thirteenth weight was indicated)' AS issue,
        weight_13 AS current_value
      FROM neonatal_core WHERE other_weight_12='1' AND (weight_13 IS NULL OR TRIM(weight_13)='')
    ),
    implausible_weight_13 AS (
      SELECT id, hosp_id, date_today, 'weight_13' AS variable,
        CASE
          WHEN weight_13_units='1' AND TRY_CAST(weight_13 AS DOUBLE)<200  THEN 'Weight thirteen (' || weight_13 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_13_units='1' AND TRY_CAST(weight_13 AS DOUBLE)>8000 THEN 'Weight thirteen (' || weight_13 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_13_units='2' AND TRY_CAST(weight_13 AS DOUBLE)<0.2  THEN 'Weight thirteen (' || weight_13 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_13_units='2' AND TRY_CAST(weight_13 AS DOUBLE)>8.0  THEN 'Weight thirteen (' || weight_13 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_13 AS current_value
      FROM neonatal_core
      WHERE other_weight_12='1' AND weight_13 IS NOT NULL AND TRIM(weight_13)<>'' AND weight_13<>'-1'
        AND weight_13_units IN ('1','2') AND TRY_CAST(weight_13 AS DOUBLE) IS NOT NULL
        AND ((weight_13_units='1' AND (TRY_CAST(weight_13 AS DOUBLE)<200 OR TRY_CAST(weight_13 AS DOUBLE)>8000))
          OR (weight_13_units='2' AND (TRY_CAST(weight_13 AS DOUBLE)<0.2 OR TRY_CAST(weight_13 AS DOUBLE)>8.0)))
    ),
    missing_date_13 AS (
      SELECT id, hosp_id, date_today, 'date_13' AS variable,
        'Date for weight thirteen is missing (a thirteenth weight was indicated)' AS issue,
        date_13 AS current_value
      FROM neonatal_core WHERE other_weight_12='1' AND (date_13 IS NULL OR TRIM(date_13)='')
    ),
    date_13_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_13' AS variable,
        'Date for weight thirteen (' || date_13 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_13 AS current_value
      FROM neonatal_core
      WHERE other_weight_12='1' AND date_13 IS NOT NULL AND TRIM(date_13)<>'' AND date_13<>'1914-01-01'
        AND TRY_CAST(date_13 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_13 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_13 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_13 AS (
      SELECT id, hosp_id, date_today, 'other_weight_13' AS variable,
        'No answer recorded for whether another weight after weight thirteen was documented' AS issue,
        other_weight_13 AS current_value
      FROM neonatal_core WHERE other_weight_12='1' AND (other_weight_13 IS NULL OR TRIM(other_weight_13)='')
    ),

    -- ----- WEIGHT 14 ---------------------------------------------------------
    missing_weight_14_units AS (
      SELECT id, hosp_id, date_today, 'weight_14_units' AS variable,
        'Unit for weight fourteen is missing (a fourteenth weight was indicated)' AS issue,
        weight_14_units AS current_value
      FROM neonatal_core WHERE other_weight_13='1' AND (weight_14_units IS NULL OR TRIM(weight_14_units)='')
    ),
    missing_weight_14 AS (
      SELECT id, hosp_id, date_today, 'weight_14' AS variable,
        'Weight fourteen value is missing (a fourteenth weight was indicated)' AS issue,
        weight_14 AS current_value
      FROM neonatal_core WHERE other_weight_13='1' AND (weight_14 IS NULL OR TRIM(weight_14)='')
    ),
    implausible_weight_14 AS (
      SELECT id, hosp_id, date_today, 'weight_14' AS variable,
        CASE
          WHEN weight_14_units='1' AND TRY_CAST(weight_14 AS DOUBLE)<200  THEN 'Weight fourteen (' || weight_14 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_14_units='1' AND TRY_CAST(weight_14 AS DOUBLE)>8000 THEN 'Weight fourteen (' || weight_14 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_14_units='2' AND TRY_CAST(weight_14 AS DOUBLE)<0.2  THEN 'Weight fourteen (' || weight_14 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_14_units='2' AND TRY_CAST(weight_14 AS DOUBLE)>8.0  THEN 'Weight fourteen (' || weight_14 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_14 AS current_value
      FROM neonatal_core
      WHERE other_weight_13='1' AND weight_14 IS NOT NULL AND TRIM(weight_14)<>'' AND weight_14<>'-1'
        AND weight_14_units IN ('1','2') AND TRY_CAST(weight_14 AS DOUBLE) IS NOT NULL
        AND ((weight_14_units='1' AND (TRY_CAST(weight_14 AS DOUBLE)<200 OR TRY_CAST(weight_14 AS DOUBLE)>8000))
          OR (weight_14_units='2' AND (TRY_CAST(weight_14 AS DOUBLE)<0.2 OR TRY_CAST(weight_14 AS DOUBLE)>8.0)))
    ),
    missing_date_14 AS (
      SELECT id, hosp_id, date_today, 'date_14' AS variable,
        'Date for weight fourteen is missing (a fourteenth weight was indicated)' AS issue,
        date_14 AS current_value
      FROM neonatal_core WHERE other_weight_13='1' AND (date_14 IS NULL OR TRIM(date_14)='')
    ),
    date_14_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_14' AS variable,
        'Date for weight fourteen (' || date_14 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_14 AS current_value
      FROM neonatal_core
      WHERE other_weight_13='1' AND date_14 IS NOT NULL AND TRIM(date_14)<>'' AND date_14<>'1914-01-01'
        AND TRY_CAST(date_14 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_14 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_14 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_14 AS (
      SELECT id, hosp_id, date_today, 'other_weight_14' AS variable,
        'No answer recorded for whether another weight after weight fourteen was documented' AS issue,
        other_weight_14 AS current_value
      FROM neonatal_core WHERE other_weight_13='1' AND (other_weight_14 IS NULL OR TRIM(other_weight_14)='')
    ),

    -- ----- WEIGHT 15 ---------------------------------------------------------
    missing_weight_15_units AS (
      SELECT id, hosp_id, date_today, 'weight_15_units' AS variable,
        'Unit for weight fifteen is missing (a fifteenth weight was indicated)' AS issue,
        weight_15_units AS current_value
      FROM neonatal_core WHERE other_weight_14='1' AND (weight_15_units IS NULL OR TRIM(weight_15_units)='')
    ),
    missing_weight_15 AS (
      SELECT id, hosp_id, date_today, 'weight_15' AS variable,
        'Weight fifteen value is missing (a fifteenth weight was indicated)' AS issue,
        weight_15 AS current_value
      FROM neonatal_core WHERE other_weight_14='1' AND (weight_15 IS NULL OR TRIM(weight_15)='')
    ),
    implausible_weight_15 AS (
      SELECT id, hosp_id, date_today, 'weight_15' AS variable,
        CASE
          WHEN weight_15_units='1' AND TRY_CAST(weight_15 AS DOUBLE)<200  THEN 'Weight fifteen (' || weight_15 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_15_units='1' AND TRY_CAST(weight_15 AS DOUBLE)>8000 THEN 'Weight fifteen (' || weight_15 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_15_units='2' AND TRY_CAST(weight_15 AS DOUBLE)<0.2  THEN 'Weight fifteen (' || weight_15 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_15_units='2' AND TRY_CAST(weight_15 AS DOUBLE)>8.0  THEN 'Weight fifteen (' || weight_15 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_15 AS current_value
      FROM neonatal_core
      WHERE other_weight_14='1' AND weight_15 IS NOT NULL AND TRIM(weight_15)<>'' AND weight_15<>'-1'
        AND weight_15_units IN ('1','2') AND TRY_CAST(weight_15 AS DOUBLE) IS NOT NULL
        AND ((weight_15_units='1' AND (TRY_CAST(weight_15 AS DOUBLE)<200 OR TRY_CAST(weight_15 AS DOUBLE)>8000))
          OR (weight_15_units='2' AND (TRY_CAST(weight_15 AS DOUBLE)<0.2 OR TRY_CAST(weight_15 AS DOUBLE)>8.0)))
    ),
    missing_date_15 AS (
      SELECT id, hosp_id, date_today, 'date_15' AS variable,
        'Date for weight fifteen is missing (a fifteenth weight was indicated)' AS issue,
        date_15 AS current_value
      FROM neonatal_core WHERE other_weight_14='1' AND (date_15 IS NULL OR TRIM(date_15)='')
    ),
    date_15_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_15' AS variable,
        'Date for weight fifteen (' || date_15 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_15 AS current_value
      FROM neonatal_core
      WHERE other_weight_14='1' AND date_15 IS NOT NULL AND TRIM(date_15)<>'' AND date_15<>'1914-01-01'
        AND TRY_CAST(date_15 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_15 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_15 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_15 AS (
      SELECT id, hosp_id, date_today, 'other_weight_15' AS variable,
        'No answer recorded for whether another weight after weight fifteen was documented' AS issue,
        other_weight_15 AS current_value
      FROM neonatal_core WHERE other_weight_14='1' AND (other_weight_15 IS NULL OR TRIM(other_weight_15)='')
    ),

    -- ----- WEIGHT 16 ---------------------------------------------------------
    missing_weight_16_units AS (
      SELECT id, hosp_id, date_today, 'weight_16_units' AS variable,
        'Unit for weight sixteen is missing (a sixteenth weight was indicated)' AS issue,
        weight_16_units AS current_value
      FROM neonatal_core WHERE other_weight_15='1' AND (weight_16_units IS NULL OR TRIM(weight_16_units)='')
    ),
    missing_weight_16 AS (
      SELECT id, hosp_id, date_today, 'weight_16' AS variable,
        'Weight sixteen value is missing (a sixteenth weight was indicated)' AS issue,
        weight_16 AS current_value
      FROM neonatal_core WHERE other_weight_15='1' AND (weight_16 IS NULL OR TRIM(weight_16)='')
    ),
    implausible_weight_16 AS (
      SELECT id, hosp_id, date_today, 'weight_16' AS variable,
        CASE
          WHEN weight_16_units='1' AND TRY_CAST(weight_16 AS DOUBLE)<200  THEN 'Weight sixteen (' || weight_16 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_16_units='1' AND TRY_CAST(weight_16 AS DOUBLE)>8000 THEN 'Weight sixteen (' || weight_16 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_16_units='2' AND TRY_CAST(weight_16 AS DOUBLE)<0.2  THEN 'Weight sixteen (' || weight_16 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_16_units='2' AND TRY_CAST(weight_16 AS DOUBLE)>8.0  THEN 'Weight sixteen (' || weight_16 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_16 AS current_value
      FROM neonatal_core
      WHERE other_weight_15='1' AND weight_16 IS NOT NULL AND TRIM(weight_16)<>'' AND weight_16<>'-1'
        AND weight_16_units IN ('1','2') AND TRY_CAST(weight_16 AS DOUBLE) IS NOT NULL
        AND ((weight_16_units='1' AND (TRY_CAST(weight_16 AS DOUBLE)<200 OR TRY_CAST(weight_16 AS DOUBLE)>8000))
          OR (weight_16_units='2' AND (TRY_CAST(weight_16 AS DOUBLE)<0.2 OR TRY_CAST(weight_16 AS DOUBLE)>8.0)))
    ),
    missing_date_16 AS (
      SELECT id, hosp_id, date_today, 'date_16' AS variable,
        'Date for weight sixteen is missing (a sixteenth weight was indicated)' AS issue,
        date_16 AS current_value
      FROM neonatal_core WHERE other_weight_15='1' AND (date_16 IS NULL OR TRIM(date_16)='')
    ),
    date_16_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_16' AS variable,
        'Date for weight sixteen (' || date_16 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_16 AS current_value
      FROM neonatal_core
      WHERE other_weight_15='1' AND date_16 IS NOT NULL AND TRIM(date_16)<>'' AND date_16<>'1914-01-01'
        AND TRY_CAST(date_16 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_16 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_16 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_16 AS (
      SELECT id, hosp_id, date_today, 'other_weight_16' AS variable,
        'No answer recorded for whether another weight after weight sixteen was documented' AS issue,
        other_weight_16 AS current_value
      FROM neonatal_core WHERE other_weight_15='1' AND (other_weight_16 IS NULL OR TRIM(other_weight_16)='')
    ),

    -- ----- WEIGHT 17 ---------------------------------------------------------
    missing_weight_17_units AS (
      SELECT id, hosp_id, date_today, 'weight_17_units' AS variable,
        'Unit for weight seventeen is missing (a seventeenth weight was indicated)' AS issue,
        weight_17_units AS current_value
      FROM neonatal_core WHERE other_weight_16='1' AND (weight_17_units IS NULL OR TRIM(weight_17_units)='')
    ),
    missing_weight_17 AS (
      SELECT id, hosp_id, date_today, 'weight_17' AS variable,
        'Weight seventeen value is missing (a seventeenth weight was indicated)' AS issue,
        weight_17 AS current_value
      FROM neonatal_core WHERE other_weight_16='1' AND (weight_17 IS NULL OR TRIM(weight_17)='')
    ),
    implausible_weight_17 AS (
      SELECT id, hosp_id, date_today, 'weight_17' AS variable,
        CASE
          WHEN weight_17_units='1' AND TRY_CAST(weight_17 AS DOUBLE)<200  THEN 'Weight seventeen (' || weight_17 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_17_units='1' AND TRY_CAST(weight_17 AS DOUBLE)>8000 THEN 'Weight seventeen (' || weight_17 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_17_units='2' AND TRY_CAST(weight_17 AS DOUBLE)<0.2  THEN 'Weight seventeen (' || weight_17 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_17_units='2' AND TRY_CAST(weight_17 AS DOUBLE)>8.0  THEN 'Weight seventeen (' || weight_17 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_17 AS current_value
      FROM neonatal_core
      WHERE other_weight_16='1' AND weight_17 IS NOT NULL AND TRIM(weight_17)<>'' AND weight_17<>'-1'
        AND weight_17_units IN ('1','2') AND TRY_CAST(weight_17 AS DOUBLE) IS NOT NULL
        AND ((weight_17_units='1' AND (TRY_CAST(weight_17 AS DOUBLE)<200 OR TRY_CAST(weight_17 AS DOUBLE)>8000))
          OR (weight_17_units='2' AND (TRY_CAST(weight_17 AS DOUBLE)<0.2 OR TRY_CAST(weight_17 AS DOUBLE)>8.0)))
    ),
    missing_date_17 AS (
      SELECT id, hosp_id, date_today, 'date_17' AS variable,
        'Date for weight seventeen is missing (a seventeenth weight was indicated)' AS issue,
        date_17 AS current_value
      FROM neonatal_core WHERE other_weight_16='1' AND (date_17 IS NULL OR TRIM(date_17)='')
    ),
    date_17_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_17' AS variable,
        'Date for weight seventeen (' || date_17 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_17 AS current_value
      FROM neonatal_core
      WHERE other_weight_16='1' AND date_17 IS NOT NULL AND TRIM(date_17)<>'' AND date_17<>'1914-01-01'
        AND TRY_CAST(date_17 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_17 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_17 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_17 AS (
      SELECT id, hosp_id, date_today, 'other_weight_17' AS variable,
        'No answer recorded for whether another weight after weight seventeen was documented' AS issue,
        other_weight_17 AS current_value
      FROM neonatal_core WHERE other_weight_16='1' AND (other_weight_17 IS NULL OR TRIM(other_weight_17)='')
    ),

    -- ----- WEIGHT 18 ---------------------------------------------------------
    missing_weight_18_units AS (
      SELECT id, hosp_id, date_today, 'weight_18_units' AS variable,
        'Unit for weight eighteen is missing (an eighteenth weight was indicated)' AS issue,
        weight_18_units AS current_value
      FROM neonatal_core WHERE other_weight_17='1' AND (weight_18_units IS NULL OR TRIM(weight_18_units)='')
    ),
    missing_weight_18 AS (
      SELECT id, hosp_id, date_today, 'weight_18' AS variable,
        'Weight eighteen value is missing (an eighteenth weight was indicated)' AS issue,
        weight_18 AS current_value
      FROM neonatal_core WHERE other_weight_17='1' AND (weight_18 IS NULL OR TRIM(weight_18)='')
    ),
    implausible_weight_18 AS (
      SELECT id, hosp_id, date_today, 'weight_18' AS variable,
        CASE
          WHEN weight_18_units='1' AND TRY_CAST(weight_18 AS DOUBLE)<200  THEN 'Weight eighteen (' || weight_18 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_18_units='1' AND TRY_CAST(weight_18 AS DOUBLE)>8000 THEN 'Weight eighteen (' || weight_18 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_18_units='2' AND TRY_CAST(weight_18 AS DOUBLE)<0.2  THEN 'Weight eighteen (' || weight_18 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_18_units='2' AND TRY_CAST(weight_18 AS DOUBLE)>8.0  THEN 'Weight eighteen (' || weight_18 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_18 AS current_value
      FROM neonatal_core
      WHERE other_weight_17='1' AND weight_18 IS NOT NULL AND TRIM(weight_18)<>'' AND weight_18<>'-1'
        AND weight_18_units IN ('1','2') AND TRY_CAST(weight_18 AS DOUBLE) IS NOT NULL
        AND ((weight_18_units='1' AND (TRY_CAST(weight_18 AS DOUBLE)<200 OR TRY_CAST(weight_18 AS DOUBLE)>8000))
          OR (weight_18_units='2' AND (TRY_CAST(weight_18 AS DOUBLE)<0.2 OR TRY_CAST(weight_18 AS DOUBLE)>8.0)))
    ),
    missing_date_18 AS (
      SELECT id, hosp_id, date_today, 'date_18' AS variable,
        'Date for weight eighteen is missing (an eighteenth weight was indicated)' AS issue,
        date_18 AS current_value
      FROM neonatal_core WHERE other_weight_17='1' AND (date_18 IS NULL OR TRIM(date_18)='')
    ),
    date_18_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_18' AS variable,
        'Date for weight eighteen (' || date_18 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_18 AS current_value
      FROM neonatal_core
      WHERE other_weight_17='1' AND date_18 IS NOT NULL AND TRIM(date_18)<>'' AND date_18<>'1914-01-01'
        AND TRY_CAST(date_18 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_18 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_18 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_18 AS (
      SELECT id, hosp_id, date_today, 'other_weight_18' AS variable,
        'No answer recorded for whether another weight after weight eighteen was documented' AS issue,
        other_weight_18 AS current_value
      FROM neonatal_core WHERE other_weight_17='1' AND (other_weight_18 IS NULL OR TRIM(other_weight_18)='')
    ),

    -- ----- WEIGHT 19 ---------------------------------------------------------
    missing_weight_19_units AS (
      SELECT id, hosp_id, date_today, 'weight_19_units' AS variable,
        'Unit for weight nineteen is missing (a nineteenth weight was indicated)' AS issue,
        weight_19_units AS current_value
      FROM neonatal_core WHERE other_weight_18='1' AND (weight_19_units IS NULL OR TRIM(weight_19_units)='')
    ),
    missing_weight_19 AS (
      SELECT id, hosp_id, date_today, 'weight_19' AS variable,
        'Weight nineteen value is missing (a nineteenth weight was indicated)' AS issue,
        weight_19 AS current_value
      FROM neonatal_core WHERE other_weight_18='1' AND (weight_19 IS NULL OR TRIM(weight_19)='')
    ),
    implausible_weight_19 AS (
      SELECT id, hosp_id, date_today, 'weight_19' AS variable,
        CASE
          WHEN weight_19_units='1' AND TRY_CAST(weight_19 AS DOUBLE)<200  THEN 'Weight nineteen (' || weight_19 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_19_units='1' AND TRY_CAST(weight_19 AS DOUBLE)>8000 THEN 'Weight nineteen (' || weight_19 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_19_units='2' AND TRY_CAST(weight_19 AS DOUBLE)<0.2  THEN 'Weight nineteen (' || weight_19 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_19_units='2' AND TRY_CAST(weight_19 AS DOUBLE)>8.0  THEN 'Weight nineteen (' || weight_19 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_19 AS current_value
      FROM neonatal_core
      WHERE other_weight_18='1' AND weight_19 IS NOT NULL AND TRIM(weight_19)<>'' AND weight_19<>'-1'
        AND weight_19_units IN ('1','2') AND TRY_CAST(weight_19 AS DOUBLE) IS NOT NULL
        AND ((weight_19_units='1' AND (TRY_CAST(weight_19 AS DOUBLE)<200 OR TRY_CAST(weight_19 AS DOUBLE)>8000))
          OR (weight_19_units='2' AND (TRY_CAST(weight_19 AS DOUBLE)<0.2 OR TRY_CAST(weight_19 AS DOUBLE)>8.0)))
    ),
    missing_date_19 AS (
      SELECT id, hosp_id, date_today, 'date_19' AS variable,
        'Date for weight nineteen is missing (a nineteenth weight was indicated)' AS issue,
        date_19 AS current_value
      FROM neonatal_core WHERE other_weight_18='1' AND (date_19 IS NULL OR TRIM(date_19)='')
    ),
    date_19_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_19' AS variable,
        'Date for weight nineteen (' || date_19 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_19 AS current_value
      FROM neonatal_core
      WHERE other_weight_18='1' AND date_19 IS NOT NULL AND TRIM(date_19)<>'' AND date_19<>'1914-01-01'
        AND TRY_CAST(date_19 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_19 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_19 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),
    missing_other_weight_19 AS (
      SELECT id, hosp_id, date_today, 'other_weight_19' AS variable,
        'No answer recorded for whether another weight after weight nineteen was documented' AS issue,
        other_weight_19 AS current_value
      FROM neonatal_core WHERE other_weight_18='1' AND (other_weight_19 IS NULL OR TRIM(other_weight_19)='')
    ),

    -- ----- WEIGHT 20 (terminal ? no other_weight_20 gate) --------------------
    missing_weight_20_units AS (
      SELECT id, hosp_id, date_today, 'weight_20_units' AS variable,
        'Unit for weight twenty is missing (a twentieth weight was indicated)' AS issue,
        weight_20_units AS current_value
      FROM neonatal_core WHERE other_weight_19='1' AND (weight_20_units IS NULL OR TRIM(weight_20_units)='')
    ),
    missing_weight_20 AS (
      SELECT id, hosp_id, date_today, 'weight_20' AS variable,
        'Weight twenty value is missing (a twentieth weight was indicated)' AS issue,
        weight_20 AS current_value
      FROM neonatal_core WHERE other_weight_19='1' AND (weight_20 IS NULL OR TRIM(weight_20)='')
    ),
    implausible_weight_20 AS (
      SELECT id, hosp_id, date_today, 'weight_20' AS variable,
        CASE
          WHEN weight_20_units='1' AND TRY_CAST(weight_20 AS DOUBLE)<200  THEN 'Weight twenty (' || weight_20 || ' g) is below the plausible minimum of 200 g'
          WHEN weight_20_units='1' AND TRY_CAST(weight_20 AS DOUBLE)>8000 THEN 'Weight twenty (' || weight_20 || ' g) exceeds the plausible maximum of 8000 g'
          WHEN weight_20_units='2' AND TRY_CAST(weight_20 AS DOUBLE)<0.2  THEN 'Weight twenty (' || weight_20 || ' kg) is below the plausible minimum of 0.2 kg'
          WHEN weight_20_units='2' AND TRY_CAST(weight_20 AS DOUBLE)>8.0  THEN 'Weight twenty (' || weight_20 || ' kg) exceeds the plausible maximum of 8.0 kg'
        END AS issue, weight_20 AS current_value
      FROM neonatal_core
      WHERE other_weight_19='1' AND weight_20 IS NOT NULL AND TRIM(weight_20)<>'' AND weight_20<>'-1'
        AND weight_20_units IN ('1','2') AND TRY_CAST(weight_20 AS DOUBLE) IS NOT NULL
        AND ((weight_20_units='1' AND (TRY_CAST(weight_20 AS DOUBLE)<200 OR TRY_CAST(weight_20 AS DOUBLE)>8000))
          OR (weight_20_units='2' AND (TRY_CAST(weight_20 AS DOUBLE)<0.2 OR TRY_CAST(weight_20 AS DOUBLE)>8.0)))
    ),
    missing_date_20 AS (
      SELECT id, hosp_id, date_today, 'date_20' AS variable,
        'Date for weight twenty is missing (a twentieth weight was indicated)' AS issue,
        date_20 AS current_value
      FROM neonatal_core WHERE other_weight_19='1' AND (date_20 IS NULL OR TRIM(date_20)='')
    ),
    date_20_out_of_window AS (
      SELECT id, hosp_id, date_today, 'date_20' AS variable,
        'Date for weight twenty (' || date_20 || ') falls outside the admission-to-discharge window (' || date_adm || ' to ' || date_discharge || ')' AS issue,
        date_20 AS current_value
      FROM neonatal_core
      WHERE other_weight_19='1' AND date_20 IS NOT NULL AND TRIM(date_20)<>'' AND date_20<>'1914-01-01'
        AND TRY_CAST(date_20 AS DATE) IS NOT NULL AND TRY_CAST(date_adm AS DATE) IS NOT NULL AND TRY_CAST(date_discharge AS DATE) IS NOT NULL
        AND date_adm<>'1914-01-01' AND date_discharge<>'1914-01-01'
        AND (TRY_CAST(date_20 AS DATE)<TRY_CAST(date_adm AS DATE) OR TRY_CAST(date_20 AS DATE)>TRY_CAST(date_discharge AS DATE))
    ),

        -- =========================================================================
    -- MATERNAL / TRANSFER SECTION DQA (fields 21, 122?145)
    -- =========================================================================

    -- -------------------------------------------------------------------------
    -- 21: transfer_form ? only shown when referred_to_hospital = '2' (No)
    -- -------------------------------------------------------------------------
    missing_transfer_form AS (
      SELECT id, hosp_id, date_today,
        'transfer_form' AS variable,
        'No answer recorded for whether a transfer form was used (patient was not referred to hospital)' AS issue,
        transfer_form AS current_value
      FROM neonatal_core
      WHERE referred_to_hospital = '2'
        AND (transfer_form IS NULL OR TRIM(transfer_form) = '')
    ),

    -- -------------------------------------------------------------------------
    -- 122: mothers_ipno ? always shown, -1 is valid
    -- -------------------------------------------------------------------------
    missing_mothers_ipno AS (
      SELECT id, hosp_id, date_today,
        'mothers_ipno' AS variable,
        'No mother inpatient number (IPNo) was recorded and no placeholder (-1) was entered' AS issue,
        mothers_ipno AS current_value
      FROM neonatal_core
      WHERE mothers_ipno IS NULL OR TRIM(mothers_ipno) = ''
    ),

    -- -------------------------------------------------------------------------
    -- 123: mar_redcap_id ? always shown, -1 is valid
    -- -------------------------------------------------------------------------
    missing_mar_redcap_id AS (
      SELECT id, hosp_id, date_today,
        'mar_redcap_id' AS variable,
        'No MAR REDCap ID was recorded and no placeholder (-1) was entered' AS issue,
        mar_redcap_id AS current_value
      FROM neonatal_core
      WHERE mar_redcap_id IS NULL OR TRIM(mar_redcap_id) = ''
    ),

    -- -------------------------------------------------------------------------
    -- 124: mothers_age ? shown when is_minimum = '0'; -1 valid; range 0?49
    -- -------------------------------------------------------------------------
    missing_mothers_age AS (
      SELECT id, hosp_id, date_today,
        'mothers_age' AS variable,
        'Mother''s age is missing (entry is required for non-minimum dataset records)' AS issue,
        mothers_age AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (mothers_age IS NULL OR TRIM(mothers_age) = '')
    ),
    implausible_mothers_age AS (
      SELECT id, hosp_id, date_today,
        'mothers_age' AS variable,
        'Mother''s age (' || mothers_age || ') is outside the plausible range of 0 to 49 years' AS issue,
        mothers_age AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND mothers_age IS NOT NULL AND TRIM(mothers_age) <> '' AND mothers_age <> '-1'
        AND TRY_CAST(mothers_age AS DOUBLE) IS NOT NULL
        AND (TRY_CAST(mothers_age AS DOUBLE) < 0 OR TRY_CAST(mothers_age AS DOUBLE) > 49)
    ),

    -- -------------------------------------------------------------------------
    -- 125: gravity ? show logic is is_minimum='0' AND is_minimum='1' which is
    --      always FALSE (a field cannot be both simultaneously), so this field
    --      is never visible. No DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 126: parity_live_birth ? shown when is_minimum = '0'; -1 valid; range 0?10
    -- -------------------------------------------------------------------------
    missing_parity_live_birth AS (
      SELECT id, hosp_id, date_today,
        'parity_live_birth' AS variable,
        'Parity (live births) is missing (entry is required for non-minimum dataset records)' AS issue,
        parity_live_birth AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (parity_live_birth IS NULL OR TRIM(parity_live_birth) = '')
    ),
    implausible_parity_live_birth AS (
      SELECT id, hosp_id, date_today,
        'parity_live_birth' AS variable,
        'Parity live births (' || parity_live_birth || ') is outside the plausible range of 0 to 10' AS issue,
        parity_live_birth AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND parity_live_birth IS NOT NULL AND TRIM(parity_live_birth) <> '' AND parity_live_birth <> '-1'
        AND TRY_CAST(parity_live_birth AS DOUBLE) IS NOT NULL
        AND (TRY_CAST(parity_live_birth AS DOUBLE) < 0 OR TRY_CAST(parity_live_birth AS DOUBLE) > 10)
    ),

    -- -------------------------------------------------------------------------
    -- 127: parity_abortion ? shown when is_minimum = '0'; -1 valid; range 0?10
    -- -------------------------------------------------------------------------
    missing_parity_abortion AS (
      SELECT id, hosp_id, date_today,
        'parity_abortion' AS variable,
        'Parity (abortions) is missing (entry is required for non-minimum dataset records)' AS issue,
        parity_abortion AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (parity_abortion IS NULL OR TRIM(parity_abortion) = '')
    ),
    implausible_parity_abortion AS (
      SELECT id, hosp_id, date_today,
        'parity_abortion' AS variable,
        'Parity abortions (' || parity_abortion || ') is outside the plausible range of 0 to 10' AS issue,
        parity_abortion AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND parity_abortion IS NOT NULL AND TRIM(parity_abortion) <> '' AND parity_abortion <> '-1'
        AND TRY_CAST(parity_abortion AS DOUBLE) IS NOT NULL
        AND (TRY_CAST(parity_abortion AS DOUBLE) < 0 OR TRY_CAST(parity_abortion AS DOUBLE) > 10)
    ),

    -- -------------------------------------------------------------------------
    -- 128: maternal_hiv ? always shown; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_maternal_hiv AS (
      SELECT id, hosp_id, date_today,
        'maternal_hiv' AS variable,
        'PMTCT / maternal HIV status was not recorded' AS issue,
        maternal_hiv AS current_value
      FROM neonatal_core
      WHERE maternal_hiv IS NULL OR TRIM(maternal_hiv) = ''
    ),
    invalid_maternal_hiv AS (
      SELECT id, hosp_id, date_today,
        'maternal_hiv' AS variable,
        'PMTCT / maternal HIV status has an unrecognised value (' || maternal_hiv || '); expected 1 (Positive), 2 (Negative), or -1 (Empty)' AS issue,
        maternal_hiv AS current_value
      FROM neonatal_core
      WHERE maternal_hiv IS NOT NULL AND TRIM(maternal_hiv) <> ''
        AND maternal_hiv NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 129: mother_anten_corti ? always shown; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_mother_anten_corti AS (
      SELECT id, hosp_id, date_today,
        'mother_anten_corti' AS variable,
        'No answer recorded for whether the mother was given antenatal corticosteroids before delivery' AS issue,
        mother_anten_corti AS current_value
      FROM neonatal_core
      WHERE mother_anten_corti IS NULL OR TRIM(mother_anten_corti) = ''
    ),
    invalid_mother_anten_corti AS (
      SELECT id, hosp_id, date_today,
        'mother_anten_corti' AS variable,
        'Antenatal corticosteroids field has an unrecognised value (' || mother_anten_corti || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_anten_corti AS current_value
      FROM neonatal_core
      WHERE mother_anten_corti IS NOT NULL AND TRIM(mother_anten_corti) <> ''
        AND mother_anten_corti NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 130: maternal_arv_s ? shown when maternal_hiv = '1'; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_maternal_arv_s AS (
      SELECT id, hosp_id, date_today,
        'maternal_arv_s' AS variable,
        'No answer recorded for whether the mother received ARV/ART/HAART (mother was recorded as HIV positive)' AS issue,
        maternal_arv_s AS current_value
      FROM neonatal_core
      WHERE maternal_hiv = '1'
        AND (maternal_arv_s IS NULL OR TRIM(maternal_arv_s) = '')
    ),
    invalid_maternal_arv_s AS (
      SELECT id, hosp_id, date_today,
        'maternal_arv_s' AS variable,
        'Maternal ARV/ART/HAART field has an unrecognised value (' || maternal_arv_s || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        maternal_arv_s AS current_value
      FROM neonatal_core
      WHERE maternal_hiv = '1'
        AND maternal_arv_s IS NOT NULL AND TRIM(maternal_arv_s) <> ''
        AND maternal_arv_s NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 131: baby_given_arv_s ? shown when maternal_hiv = '1'; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_baby_given_arv_s AS (
      SELECT id, hosp_id, date_today,
        'baby_given_arv_s' AS variable,
        'No answer recorded for whether the baby received ARV/ART/HAART (mother was recorded as HIV positive)' AS issue,
        baby_given_arv_s AS current_value
      FROM neonatal_core
      WHERE maternal_hiv = '1'
        AND (baby_given_arv_s IS NULL OR TRIM(baby_given_arv_s) = '')
    ),
    invalid_baby_given_arv_s AS (
      SELECT id, hosp_id, date_today,
        'baby_given_arv_s' AS variable,
        'Baby ARV/ART/HAART field has an unrecognised value (' || baby_given_arv_s || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        baby_given_arv_s AS current_value
      FROM neonatal_core
      WHERE maternal_hiv = '1'
        AND baby_given_arv_s IS NOT NULL AND TRIM(baby_given_arv_s) <> ''
        AND baby_given_arv_s NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 132: maternal_vdrl ? shown when is_minimum = '0'; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_maternal_vdrl AS (
      SELECT id, hosp_id, date_today,
        'maternal_vdrl' AS variable,
        'Maternal VDRL result is missing (entry is required for non-minimum dataset records)' AS issue,
        maternal_vdrl AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (maternal_vdrl IS NULL OR TRIM(maternal_vdrl) = '')
    ),
    invalid_maternal_vdrl AS (
      SELECT id, hosp_id, date_today,
        'maternal_vdrl' AS variable,
        'Maternal VDRL field has an unrecognised value (' || maternal_vdrl || '); expected 1 (Positive), 2 (Negative), or -1 (Empty)' AS issue,
        maternal_vdrl AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND maternal_vdrl IS NOT NULL AND TRIM(maternal_vdrl) <> ''
        AND maternal_vdrl NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 133: last_menstrual_period ? shown when is_minimum = '0'; required
    --      placeholder 1914-01-01 is valid
    -- -------------------------------------------------------------------------
    missing_last_menstrual_period AS (
      SELECT id, hosp_id, date_today,
        'last_menstrual_period' AS variable,
        'Last menstrual period (LMP) date is missing (entry is required for non-minimum dataset records)' AS issue,
        last_menstrual_period AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (last_menstrual_period IS NULL OR TRIM(last_menstrual_period) = '')
    ),
    invalid_last_menstrual_period AS (
      SELECT id, hosp_id, date_today,
        'last_menstrual_period' AS variable,
        'Last menstrual period (LMP) date (' || last_menstrual_period || ') cannot be parsed as a valid date' AS issue,
        last_menstrual_period AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND last_menstrual_period IS NOT NULL AND TRIM(last_menstrual_period) <> ''
        AND last_menstrual_period <> '1914-01-01'
        AND TRY_CAST(last_menstrual_period AS DATE) IS NULL
    ),
    lmp_after_dob AS (
      SELECT id, hosp_id, date_today,
        'last_menstrual_period' AS variable,
        'Last menstrual period (' || last_menstrual_period || ') is on or after the baby''s date of birth (' || date_of_birth || ')' AS issue,
        last_menstrual_period AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND last_menstrual_period IS NOT NULL AND TRIM(last_menstrual_period) <> ''
        AND last_menstrual_period <> '1914-01-01'
        AND date_of_birth IS NOT NULL AND TRIM(date_of_birth) <> ''
        AND date_of_birth <> '1914-01-01'
        AND TRY_CAST(last_menstrual_period AS DATE) IS NOT NULL
        AND TRY_CAST(date_of_birth AS DATE) IS NOT NULL
        AND TRY_CAST(last_menstrual_period AS DATE) >= TRY_CAST(date_of_birth AS DATE)
    ),

    -- -------------------------------------------------------------------------
    -- 134: expected_date_of_delivery ? shown when is_minimum = '0'; required
    --      placeholder 1914-01-01 is valid
    -- -------------------------------------------------------------------------
    missing_expected_date_of_delivery AS (
      SELECT id, hosp_id, date_today,
        'expected_date_of_delivery' AS variable,
        'Expected date of delivery (EDD) is missing (entry is required for non-minimum dataset records)' AS issue,
        expected_date_of_delivery AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (expected_date_of_delivery IS NULL OR TRIM(expected_date_of_delivery) = '')
    ),
    invalid_expected_date_of_delivery AS (
      SELECT id, hosp_id, date_today,
        'expected_date_of_delivery' AS variable,
        'Expected date of delivery (EDD) (' || expected_date_of_delivery || ') cannot be parsed as a valid date' AS issue,
        expected_date_of_delivery AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND expected_date_of_delivery IS NOT NULL AND TRIM(expected_date_of_delivery) <> ''
        AND expected_date_of_delivery <> '1914-01-01'
        AND TRY_CAST(expected_date_of_delivery AS DATE) IS NULL
    ),
    edd_before_lmp AS (
      SELECT id, hosp_id, date_today,
        'expected_date_of_delivery' AS variable,
        'Expected date of delivery (' || expected_date_of_delivery || ') is on or before the last menstrual period (' || last_menstrual_period || ')' AS issue,
        expected_date_of_delivery AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND expected_date_of_delivery IS NOT NULL AND TRIM(expected_date_of_delivery) <> ''
        AND expected_date_of_delivery <> '1914-01-01'
        AND last_menstrual_period IS NOT NULL AND TRIM(last_menstrual_period) <> ''
        AND last_menstrual_period <> '1914-01-01'
        AND TRY_CAST(expected_date_of_delivery AS DATE) IS NOT NULL
        AND TRY_CAST(last_menstrual_period AS DATE) IS NOT NULL
        AND TRY_CAST(expected_date_of_delivery AS DATE) <= TRY_CAST(last_menstrual_period AS DATE)
    ),

    -- -------------------------------------------------------------------------
    -- 135: premature_rapture_of_membr ? show logic is is_minimum='0' AND
    --      is_minimum='1' which is always FALSE; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 136: rapture_of_membrane ? shown when is_minimum = '0'; required
    --      valid: 1 (< 18 hrs), 0 (> 18 hrs), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_rapture_of_membrane AS (
      SELECT id, hosp_id, date_today,
        'rapture_of_membrane' AS variable,
        'Rupture of membranes (ROM) status is missing (entry is required for non-minimum dataset records)' AS issue,
        rapture_of_membrane AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (rapture_of_membrane IS NULL OR TRIM(rapture_of_membrane) = '')
    ),
    invalid_rapture_of_membrane AS (
      SELECT id, hosp_id, date_today,
        'rapture_of_membrane' AS variable,
        'Rupture of membranes (ROM) field has an unrecognised value (' || rapture_of_membrane || '); expected 1 (< 18 hrs), 0 (> 18 hrs), or -1 (Empty)' AS issue,
        rapture_of_membrane AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND rapture_of_membrane IS NOT NULL AND TRIM(rapture_of_membrane) <> ''
        AND rapture_of_membrane NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 137?142: maternal condition fields ? shown when nar_used='1' OR transfer_form='1'
    --          all required; valid: 1 (Yes), 2 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_mother_fever AS (
      SELECT id, hosp_id, date_today,
        'mother_fever' AS variable,
        'No answer recorded for whether the mother had fever in labour (NAR or transfer form was used)' AS issue,
        mother_fever AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND (mother_fever IS NULL OR TRIM(mother_fever) = '')
    ),
    invalid_mother_fever AS (
      SELECT id, hosp_id, date_today,
        'mother_fever' AS variable,
        'Mother fever in labour field has an unrecognised value (' || mother_fever || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_fever AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND mother_fever IS NOT NULL AND TRIM(mother_fever) <> ''
        AND mother_fever NOT IN ('1','2','-1')
    ),
    missing_mother_tbtreat AS (
      SELECT id, hosp_id, date_today,
        'mother_tbtreat' AS variable,
        'No answer recorded for whether the mother is currently on TB treatment (NAR or transfer form was used)' AS issue,
        mother_tbtreat AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND (mother_tbtreat IS NULL OR TRIM(mother_tbtreat) = '')
    ),
    invalid_mother_tbtreat AS (
      SELECT id, hosp_id, date_today,
        'mother_tbtreat' AS variable,
        'Mother TB treatment field has an unrecognised value (' || mother_tbtreat || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_tbtreat AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND mother_tbtreat IS NOT NULL AND TRIM(mother_tbtreat) <> ''
        AND mother_tbtreat NOT IN ('1','2','-1')
    ),
    missing_mother_diabetes AS (
      SELECT id, hosp_id, date_today,
        'mother_diabetes' AS variable,
        'No answer recorded for whether the mother is diabetic (NAR or transfer form was used)' AS issue,
        mother_diabetes AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND (mother_diabetes IS NULL OR TRIM(mother_diabetes) = '')
    ),
    invalid_mother_diabetes AS (
      SELECT id, hosp_id, date_today,
        'mother_diabetes' AS variable,
        'Mother diabetes field has an unrecognised value (' || mother_diabetes || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_diabetes AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND mother_diabetes IS NOT NULL AND TRIM(mother_diabetes) <> ''
        AND mother_diabetes NOT IN ('1','2','-1')
    ),
    missing_mother_htn AS (
      SELECT id, hosp_id, date_today,
        'mother_htn' AS variable,
        'No answer recorded for hypertension in pregnancy (NAR or transfer form was used)' AS issue,
        mother_htn AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND (mother_htn IS NULL OR TRIM(mother_htn) = '')
    ),
    invalid_mother_htn AS (
      SELECT id, hosp_id, date_today,
        'mother_htn' AS variable,
        'Mother HTN in pregnancy field has an unrecognised value (' || mother_htn || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_htn AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND mother_htn IS NOT NULL AND TRIM(mother_htn) <> ''
        AND mother_htn NOT IN ('1','2','-1')
    ),
    missing_mother_preeclampsia AS (
      SELECT id, hosp_id, date_today,
        'mother_preeclampsia' AS variable,
        'No answer recorded for pre-eclampsia (NAR or transfer form was used)' AS issue,
        mother_preeclampsia AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND (mother_preeclampsia IS NULL OR TRIM(mother_preeclampsia) = '')
    ),
    invalid_mother_preeclampsia AS (
      SELECT id, hosp_id, date_today,
        'mother_preeclampsia' AS variable,
        'Pre-eclampsia field has an unrecognised value (' || mother_preeclampsia || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_preeclampsia AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND mother_preeclampsia IS NOT NULL AND TRIM(mother_preeclampsia) <> ''
        AND mother_preeclampsia NOT IN ('1','2','-1')
    ),
    missing_mother_eclampsia AS (
      SELECT id, hosp_id, date_today,
        'mother_eclampsia' AS variable,
        'No answer recorded for eclampsia (NAR or transfer form was used)' AS issue,
        mother_eclampsia AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND (mother_eclampsia IS NULL OR TRIM(mother_eclampsia) = '')
    ),
    invalid_mother_eclampsia AS (
      SELECT id, hosp_id, date_today,
        'mother_eclampsia' AS variable,
        'Eclampsia field has an unrecognised value (' || mother_eclampsia || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_eclampsia AS current_value
      FROM neonatal_core
      WHERE (nar_used = '1' OR transfer_form = '1')
        AND mother_eclampsia IS NOT NULL AND TRIM(mother_eclampsia) <> ''
        AND mother_eclampsia NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 143: is_other_maternal_cond ? always shown; valid: 1 (Yes), 2 (No)
    --      not marked Required in the form; flagged only when a non-valid value
    --      is present (not flagged as simply missing)
    -- -------------------------------------------------------------------------
    invalid_is_other_maternal_cond AS (
      SELECT id, hosp_id, date_today,
        'is_other_maternal_cond' AS variable,
        'Other maternal condition flag has an unrecognised value (' || is_other_maternal_cond || '); expected 1 (Yes) or 2 (No)' AS issue,
        is_other_maternal_cond AS current_value
      FROM neonatal_core
      WHERE is_other_maternal_cond IS NOT NULL AND TRIM(is_other_maternal_cond) <> ''
        AND is_other_maternal_cond NOT IN ('1','2')
    ),

    -- -------------------------------------------------------------------------
    -- 144: other_maternal_cond ? shown when is_other_maternal_cond = '1'
    --      orphan check: populated but gate not open; missing check when gate open
    -- -------------------------------------------------------------------------
    missing_other_maternal_cond AS (
      SELECT id, hosp_id, date_today,
        'other_maternal_cond' AS variable,
        'Other maternal conditions text is missing even though additional conditions were indicated' AS issue,
        other_maternal_cond AS current_value
      FROM neonatal_core
      WHERE is_other_maternal_cond = '1'
        AND (other_maternal_cond IS NULL OR TRIM(other_maternal_cond) = '')
    ),
    orphan_other_maternal_cond AS (
      SELECT id, hosp_id, date_today,
        'other_maternal_cond' AS variable,
        'Other maternal conditions text is populated ("' || other_maternal_cond || '") but no additional conditions were indicated' AS issue,
        other_maternal_cond AS current_value
      FROM neonatal_core
      WHERE (is_other_maternal_cond IS NULL OR is_other_maternal_cond <> '1')
        AND other_maternal_cond IS NOT NULL AND TRIM(other_maternal_cond) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- 145: mother_alive ? always shown; required; valid: 1 (Yes), 2 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_mother_alive AS (
      SELECT id, hosp_id, date_today,
        'mother_alive' AS variable,
        'No answer recorded for whether the mother is alive' AS issue,
        mother_alive AS current_value
      FROM neonatal_core
      WHERE mother_alive IS NULL OR TRIM(mother_alive) = ''
    ),
    invalid_mother_alive AS (
      SELECT id, hosp_id, date_today,
        'mother_alive' AS variable,
        'Mother alive field has an unrecognised value (' || mother_alive || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        mother_alive AS current_value
      FROM neonatal_core
      WHERE mother_alive IS NOT NULL AND TRIM(mother_alive) <> ''
        AND mother_alive NOT IN ('1','2','-1')
    ),

        -- =========================================================================
    -- BIRTH ASSESSMENT SECTION DQA (fields 147?175)
    -- =========================================================================

    -- -------------------------------------------------------------------------
    -- 147: gest ? always shown; required; range 24?46; -1 is valid placeholder
    -- -------------------------------------------------------------------------
    missing_gest AS (
      SELECT id, hosp_id, date_today,
        'gest' AS variable,
        'Gestation at birth (weeks) is missing' AS issue,
        gest AS current_value
      FROM neonatal_core
      WHERE gest IS NULL OR TRIM(gest) = ''
    ),
    implausible_gest AS (
      SELECT id, hosp_id, date_today,
        'gest' AS variable,
        'Gestation at birth (' || gest || ' weeks) is outside the plausible range of 24 to 46 weeks' AS issue,
        gest AS current_value
      FROM neonatal_core
      WHERE gest IS NOT NULL AND TRIM(gest) <> '' AND gest <> '-1'
        AND TRY_CAST(gest AS DOUBLE) IS NOT NULL
        AND (TRY_CAST(gest AS DOUBLE) < 24 OR TRY_CAST(gest AS DOUBLE) > 46)
    ),

    -- -------------------------------------------------------------------------
    -- 148: apg_doc ? always shown; required; valid: 1 (Yes), 0 (No)
    -- -------------------------------------------------------------------------
    missing_apg_doc AS (
      SELECT id, hosp_id, date_today,
        'apg_doc' AS variable,
        'No answer recorded for whether an Apgar score was documented' AS issue,
        apg_doc AS current_value
      FROM neonatal_core
      WHERE apg_doc IS NULL OR TRIM(apg_doc) = ''
    ),
    invalid_apg_doc AS (
      SELECT id, hosp_id, date_today,
        'apg_doc' AS variable,
        'Apgar score documentation flag has an unrecognised value (' || apg_doc || '); expected 1 (Yes) or 0 (No)' AS issue,
        apg_doc AS current_value
      FROM neonatal_core
      WHERE apg_doc IS NOT NULL AND TRIM(apg_doc) <> ''
        AND apg_doc NOT IN ('1','0')
    ),

    -- -------------------------------------------------------------------------
    -- 149: apgar_1min ? shown when apg_doc = '1'; valid: 0?10 and -1
    -- -------------------------------------------------------------------------
    missing_apgar_1min AS (
      SELECT id, hosp_id, date_today,
        'apgar_1min' AS variable,
        'Apgar score at 1 minute is missing (Apgar score was indicated as documented)' AS issue,
        apgar_1min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND (apgar_1min IS NULL OR TRIM(apgar_1min) = '')
    ),
    invalid_apgar_1min AS (
      SELECT id, hosp_id, date_today,
        'apgar_1min' AS variable,
        'Apgar score at 1 minute has an unrecognised value (' || apgar_1min || '); expected 0?10 or -1 (Empty)' AS issue,
        apgar_1min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND apgar_1min IS NOT NULL AND TRIM(apgar_1min) <> ''
        AND apgar_1min NOT IN ('0','1','2','3','4','5','6','7','8','9','10','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 150: apgar_5min ? shown when apg_doc = '1'; valid: 0?10 and -1
    -- -------------------------------------------------------------------------
    missing_apgar_5min AS (
      SELECT id, hosp_id, date_today,
        'apgar_5min' AS variable,
        'Apgar score at 5 minutes is missing (Apgar score was indicated as documented)' AS issue,
        apgar_5min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND (apgar_5min IS NULL OR TRIM(apgar_5min) = '')
    ),
    invalid_apgar_5min AS (
      SELECT id, hosp_id, date_today,
        'apgar_5min' AS variable,
        'Apgar score at 5 minutes has an unrecognised value (' || apgar_5min || '); expected 0?10 or -1 (Empty)' AS issue,
        apgar_5min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND apgar_5min IS NOT NULL AND TRIM(apgar_5min) <> ''
        AND apgar_5min NOT IN ('0','1','2','3','4','5','6','7','8','9','10','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 151: apgar_10min ? shown when apg_doc = '1'; valid: 0?10 and -1
    -- -------------------------------------------------------------------------
    missing_apgar_10min AS (
      SELECT id, hosp_id, date_today,
        'apgar_10min' AS variable,
        'Apgar score at 10 minutes is missing (Apgar score was indicated as documented)' AS issue,
        apgar_10min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND (apgar_10min IS NULL OR TRIM(apgar_10min) = '')
    ),
    invalid_apgar_10min AS (
      SELECT id, hosp_id, date_today,
        'apgar_10min' AS variable,
        'Apgar score at 10 minutes has an unrecognised value (' || apgar_10min || '); expected 0?10 or -1 (Empty)' AS issue,
        apgar_10min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND apgar_10min IS NOT NULL AND TRIM(apgar_10min) <> ''
        AND apgar_10min NOT IN ('0','1','2','3','4','5','6','7','8','9','10','-1')
    ),

    -- -------------------------------------------------------------------------
    -- Apgar temporal plausibility: 1-min score should be <= 5-min score
    --   in the large majority of cases; flag where 1-min > 5-min
    --   (both must be real values, not -1)
    -- -------------------------------------------------------------------------
    apgar_1min_gt_5min AS (
      SELECT id, hosp_id, date_today,
        'apgar_1min' AS variable,
        'Apgar score at 1 minute (' || apgar_1min || ') is greater than the 5-minute score (' || apgar_5min || '); review for data entry error' AS issue,
        apgar_1min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND apgar_1min NOT IN ('-1','') AND apgar_1min IS NOT NULL
        AND apgar_5min NOT IN ('-1','') AND apgar_5min IS NOT NULL
        AND TRY_CAST(apgar_1min AS INT) IS NOT NULL
        AND TRY_CAST(apgar_5min AS INT) IS NOT NULL
        AND TRY_CAST(apgar_1min AS INT) > TRY_CAST(apgar_5min AS INT)
    ),
    apgar_5min_gt_10min AS (
      SELECT id, hosp_id, date_today,
        'apgar_5min' AS variable,
        'Apgar score at 5 minutes (' || apgar_5min || ') is greater than the 10-minute score (' || apgar_10min || '); review for data entry error' AS issue,
        apgar_5min AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND apgar_5min NOT IN ('-1','') AND apgar_5min IS NOT NULL
        AND apgar_10min NOT IN ('-1','') AND apgar_10min IS NOT NULL
        AND TRY_CAST(apgar_5min AS INT) IS NOT NULL
        AND TRY_CAST(apgar_10min AS INT) IS NOT NULL
        AND TRY_CAST(apgar_5min AS INT) > TRY_CAST(apgar_10min AS INT)
    ),

    -- -------------------------------------------------------------------------
    -- 152: wt_now ? always shown; required; -1 is valid
    -- -------------------------------------------------------------------------
    missing_wt_now AS (
      SELECT id, hosp_id, date_today,
        'wt_now' AS variable,
        'Weight at admission is missing' AS issue,
        wt_now AS current_value
      FROM neonatal_core
      WHERE wt_now IS NULL OR TRIM(wt_now) = ''
    ),

    -- -------------------------------------------------------------------------
    -- 153: wt_now_units ? shown when wt_now > 0; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_wt_now_units AS (
      SELECT id, hosp_id, date_today,
        'wt_now_units' AS variable,
        'Weight at admission units are missing (a positive weight value was recorded)' AS issue,
        wt_now_units AS current_value
      FROM neonatal_core
      WHERE wt_now IS NOT NULL AND TRIM(wt_now) <> ''
        AND TRY_CAST(wt_now AS DOUBLE) IS NOT NULL
        AND TRY_CAST(wt_now AS DOUBLE) > 0
        AND (wt_now_units IS NULL OR TRIM(wt_now_units) = '')
    ),
    invalid_wt_now_units AS (
      SELECT id, hosp_id, date_today,
        'wt_now_units' AS variable,
        'Weight at admission units have an unrecognised value (' || wt_now_units || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        wt_now_units AS current_value
      FROM neonatal_core
      WHERE wt_now IS NOT NULL AND TRIM(wt_now) <> ''
        AND TRY_CAST(wt_now AS DOUBLE) IS NOT NULL
        AND TRY_CAST(wt_now AS DOUBLE) > 0
        AND wt_now_units IS NOT NULL AND TRIM(wt_now_units) <> ''
        AND wt_now_units NOT IN ('1','2','-1')
    ),
    -- Plausibility: grams window 200?8000; kilograms window 0.2?8.0
    implausible_wt_now AS (
      SELECT id, hosp_id, date_today,
        'wt_now' AS variable,
        'Weight at admission (' || wt_now || ' ' ||
          CASE wt_now_units WHEN '1' THEN 'g' WHEN '2' THEN 'kg' ELSE 'unknown units' END ||
          ') is outside the plausible neonatal range' AS issue,
        wt_now AS current_value
      FROM neonatal_core
      WHERE wt_now IS NOT NULL AND TRIM(wt_now) <> '' AND wt_now <> '-1'
        AND wt_now_units IN ('1','2')
        AND TRY_CAST(wt_now AS DOUBLE) IS NOT NULL
        AND (
          (wt_now_units = '1' AND (TRY_CAST(wt_now AS DOUBLE) < 200  OR TRY_CAST(wt_now AS DOUBLE) > 8000))
          OR
          (wt_now_units = '2' AND (TRY_CAST(wt_now AS DOUBLE) < 0.2  OR TRY_CAST(wt_now AS DOUBLE) > 8.0))
        )
    ),

    -- -------------------------------------------------------------------------
    -- 154: baby_resusc_at_birth ? always shown; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_baby_resusc_at_birth AS (
      SELECT id, hosp_id, date_today,
        'baby_resusc_at_birth' AS variable,
        'No answer recorded for whether the baby was resuscitated at birth (BVM resuscitation)' AS issue,
        baby_resusc_at_birth AS current_value
      FROM neonatal_core
      WHERE baby_resusc_at_birth IS NULL OR TRIM(baby_resusc_at_birth) = ''
    ),
    invalid_baby_resusc_at_birth AS (
      SELECT id, hosp_id, date_today,
        'baby_resusc_at_birth' AS variable,
        'Baby resuscitation at birth field has an unrecognised value (' || baby_resusc_at_birth || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        baby_resusc_at_birth AS current_value
      FROM neonatal_core
      WHERE baby_resusc_at_birth IS NOT NULL AND TRIM(baby_resusc_at_birth) <> ''
        AND baby_resusc_at_birth NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 155: length ? shown when age_days = '1' AND age_days <= 3
    --      NOTE: age_days = '1' is a fixed equality; age_days <= 3 is always
    --      satisfied when age_days = 1, so the effective condition is age_days = '1'.
    --      Range 32?56 cm; -1 valid.
    -- -------------------------------------------------------------------------
    missing_length AS (
      SELECT id, hosp_id, date_today,
        'length' AS variable,
        'Length (cm) is missing (entry is required for babies aged 1 day)' AS issue,
        length AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(age_days AS DOUBLE) = 1
        AND (length IS NULL OR TRIM(length) = '')
    ),
    implausible_length AS (
      SELECT id, hosp_id, date_today,
        'length' AS variable,
        'Length (' || length || ' cm) is outside the plausible neonatal range of 32 to 56 cm' AS issue,
        length AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(age_days AS DOUBLE) = 1
        AND length IS NOT NULL AND TRIM(length) <> '' AND length <> '-1'
        AND TRY_CAST(length AS DOUBLE) IS NOT NULL
        AND (TRY_CAST(length AS DOUBLE) < 32 OR TRY_CAST(length AS DOUBLE) > 56)
    ),

    -- -------------------------------------------------------------------------
    -- 156: head_circum ? same visibility as length; range 23?39 cm; -1 valid
    -- -------------------------------------------------------------------------
    missing_head_circum AS (
      SELECT id, hosp_id, date_today,
        'head_circum' AS variable,
        'Head circumference (cm) is missing (entry is required for babies aged 1 day)' AS issue,
        head_circum AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(age_days AS DOUBLE) = 1
        AND (head_circum IS NULL OR TRIM(head_circum) = '')
    ),
    implausible_head_circum AS (
      SELECT id, hosp_id, date_today,
        'head_circum' AS variable,
        'Head circumference (' || head_circum || ' cm) is outside the plausible neonatal range of 23 to 39 cm' AS issue,
        head_circum AS current_value
      FROM neonatal_core
      WHERE TRY_CAST(age_days AS DOUBLE) = 1
        AND head_circum IS NOT NULL AND TRIM(head_circum) <> '' AND head_circum <> '-1'
        AND TRY_CAST(head_circum AS DOUBLE) IS NOT NULL
        AND (TRY_CAST(head_circum AS DOUBLE) < 23 OR TRY_CAST(head_circum AS DOUBLE) > 39)
    ),

    -- -------------------------------------------------------------------------
    -- 157: bba ? always shown; required; valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_bba AS (
      SELECT id, hosp_id, date_today,
        'bba' AS variable,
        'No answer recorded for whether the baby was born outside this facility' AS issue,
        bba AS current_value
      FROM neonatal_core
      WHERE bba IS NULL OR TRIM(bba) = ''
    ),
    invalid_bba AS (
      SELECT id, hosp_id, date_today,
        'bba' AS variable,
        'Born-outside-facility field has an unrecognised value (' || bba || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        bba AS current_value
      FROM neonatal_core
      WHERE bba IS NOT NULL AND TRIM(bba) <> ''
        AND bba NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 158: born_where ? shown when bba = '1'; valid: 1, 2, 3, -1
    -- -------------------------------------------------------------------------
    missing_born_where AS (
      SELECT id, hosp_id, date_today,
        'born_where' AS variable,
        'No answer recorded for where the baby was born (baby was indicated as born outside this facility)' AS issue,
        born_where AS current_value
      FROM neonatal_core
      WHERE bba = '1'
        AND (born_where IS NULL OR TRIM(born_where) = '')
    ),
    invalid_born_where AS (
      SELECT id, hosp_id, date_today,
        'born_where' AS variable,
        'Born-where field has an unrecognised value (' || born_where || '); expected 1 (Home), 2 (Other health facility), 3 (Others), or -1 (Empty)' AS issue,
        born_where AS current_value
      FROM neonatal_core
      WHERE bba = '1'
        AND born_where IS NOT NULL AND TRIM(born_where) <> ''
        AND born_where NOT IN ('1','2','3','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 159: in_othfac_nam ? shown when born_where = '2' AND hosp_id IN KE set
    --      required; free text ? only missing check needed
    -- -------------------------------------------------------------------------
    missing_in_othfac_nam AS (
      SELECT id, hosp_id, date_today,
        'in_othfac_nam' AS variable,
        'Facility name is missing (baby was born at another health facility and this site requires facility name capture)' AS issue,
        in_othfac_nam AS current_value
      FROM neonatal_core
      WHERE born_where = '2'
        AND hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND (in_othfac_nam IS NULL OR TRIM(in_othfac_nam) = '')
    ),

    -- -------------------------------------------------------------------------
    -- 160: delivery ? always shown; required; valid: 0, 1, 2, 3, -1
    -- -------------------------------------------------------------------------
    missing_delivery AS (
      SELECT id, hosp_id, date_today,
        'delivery' AS variable,
        'Mode of delivery was not recorded' AS issue,
        delivery AS current_value
      FROM neonatal_core
      WHERE delivery IS NULL OR TRIM(delivery) = ''
    ),
    invalid_delivery AS (
      SELECT id, hosp_id, date_today,
        'delivery' AS variable,
        'Mode of delivery has an unrecognised value (' || delivery || '); expected 0 (SVD), 1 (Assisted vaginal), 2 (Breech), 3 (C/S), or -1 (Empty)' AS issue,
        delivery AS current_value
      FROM neonatal_core
      WHERE delivery IS NOT NULL AND TRIM(delivery) <> ''
        AND delivery NOT IN ('0','1','2','3','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 161: time_of_admission_document ? show logic is_minimum='0' AND
    --      is_minimum='1' ? always FALSE; no DQA check emitted.
    -- 162: time_baby_seen ? same impossible show condition; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 163: fever ? shown when is_minimum = '0'; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_fever AS (
      SELECT id, hosp_id, date_today,
        'fever' AS variable,
        'Fever status is missing (entry is required for non-minimum dataset records)' AS issue,
        fever AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (fever IS NULL OR TRIM(fever) = '')
    ),
    invalid_fever AS (
      SELECT id, hosp_id, date_today,
        'fever' AS variable,
        'Fever field has an unrecognised value (' || fever || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        fever AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND fever IS NOT NULL AND TRIM(fever) <> ''
        AND fever NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 164: fever_duration ? shown when fever = '1'; @HIDDEN; valid: 1, 2, -1
    --      @HIDDEN means it is suppressed in the UI but data may still be
    --      captured; we flag only invalid codes, not missingness.
    -- -------------------------------------------------------------------------
    invalid_fever_duration AS (
      SELECT id, hosp_id, date_today,
        'fever_duration' AS variable,
        'Fever duration (< 1 day?) field has an unrecognised value (' || fever_duration || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        fever_duration AS current_value
      FROM neonatal_core
      WHERE fever = '1'
        AND fever_duration IS NOT NULL AND TRIM(fever_duration) <> ''
        AND fever_duration NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 165: fever_duration_in_days ? shown when fever='1' AND fever_duration='0';
    --      NOTE: fever_duration valid codes are 1, 2, -1; code '0' is not valid,
    --      so this field's show condition can never be satisfied in clean data.
    --      Flag only if value is present when it should not be (orphan check).
    -- -------------------------------------------------------------------------
    orphan_fever_duration_in_days AS (
      SELECT id, hosp_id, date_today,
        'fever_duration_in_days' AS variable,
        'Fever duration in days is populated ("' || fever_duration_in_days || '") but the controlling show condition (fever_duration = 0) cannot be satisfied with valid data; review entry' AS issue,
        fever_duration_in_days AS current_value
      FROM neonatal_core
      WHERE fever_duration_in_days IS NOT NULL AND TRIM(fever_duration_in_days) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- 166: difficulty_breathing ? always shown; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_difficulty_breathing AS (
      SELECT id, hosp_id, date_today,
        'difficulty_breathing' AS variable,
        'No answer recorded for difficulty in breathing (DIB)' AS issue,
        difficulty_breathing AS current_value
      FROM neonatal_core
      WHERE difficulty_breathing IS NULL OR TRIM(difficulty_breathing) = ''
    ),
    invalid_difficulty_breathing AS (
      SELECT id, hosp_id, date_today,
        'difficulty_breathing' AS variable,
        'Difficulty breathing (DIB) field has an unrecognised value (' || difficulty_breathing || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        difficulty_breathing AS current_value
      FROM neonatal_core
      WHERE difficulty_breathing IS NOT NULL AND TRIM(difficulty_breathing) <> ''
        AND difficulty_breathing NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 167: diarrhoea ? show logic age_days >= 3 AND age_days < 3 ? always FALSE;
    --      @HIDDEN also applied; no DQA check emitted.
    -- 168: severe_vomiting ? is_minimum='0' AND is_minimum='1' ? always FALSE;
    --      @HIDDEN also applied; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 169: difficulty_feeding ? always shown; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_difficulty_feeding AS (
      SELECT id, hosp_id, date_today,
        'difficulty_feeding' AS variable,
        'No answer recorded for difficulty feeding or breastfeeding' AS issue,
        difficulty_feeding AS current_value
      FROM neonatal_core
      WHERE difficulty_feeding IS NULL OR TRIM(difficulty_feeding) = ''
    ),
    invalid_difficulty_feeding AS (
      SELECT id, hosp_id, date_today,
        'difficulty_feeding' AS variable,
        'Difficulty feeding/breastfeeding field has an unrecognised value (' || difficulty_feeding || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        difficulty_feeding AS current_value
      FROM neonatal_core
      WHERE difficulty_feeding IS NOT NULL AND TRIM(difficulty_feeding) <> ''
        AND difficulty_feeding NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 170: convulsions ? shown when is_minimum = '0'; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_convulsions AS (
      SELECT id, hosp_id, date_today,
        'convulsions' AS variable,
        'Convulsions status is missing (entry is required for non-minimum dataset records)' AS issue,
        convulsions AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (convulsions IS NULL OR TRIM(convulsions) = '')
    ),
    invalid_convulsions AS (
      SELECT id, hosp_id, date_today,
        'convulsions' AS variable,
        'Convulsions field has an unrecognised value (' || convulsions || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        convulsions AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND convulsions IS NOT NULL AND TRIM(convulsions) <> ''
        AND convulsions NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 171: partial_focal_fits ? is_minimum='0' AND is_minimum='1' ? always FALSE;
    --      @HIDDEN also applied; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 172: level_of_activity ? shown when apg_doc = '1'; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_level_of_activity AS (
      SELECT id, hosp_id, date_today,
        'level_of_activity' AS variable,
        'Reduced/absent movement status is missing (Apgar score was indicated as documented)' AS issue,
        level_of_activity AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND (level_of_activity IS NULL OR TRIM(level_of_activity) = '')
    ),
    invalid_level_of_activity AS (
      SELECT id, hosp_id, date_today,
        'level_of_activity' AS variable,
        'Reduced/absent movement field has an unrecognised value (' || level_of_activity || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        level_of_activity AS current_value
      FROM neonatal_core
      WHERE apg_doc = '1'
        AND level_of_activity IS NOT NULL AND TRIM(level_of_activity) <> ''
        AND level_of_activity NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 173: apnoea ? shown when is_minimum = '0'; required; valid: 1, 2, -1
    -- -------------------------------------------------------------------------
    missing_apnoea AS (
      SELECT id, hosp_id, date_today,
        'apnoea' AS variable,
        'Apnoea status is missing (entry is required for non-minimum dataset records)' AS issue,
        apnoea AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (apnoea IS NULL OR TRIM(apnoea) = '')
    ),
    invalid_apnoea AS (
      SELECT id, hosp_id, date_today,
        'apnoea' AS variable,
        'Apnoea field has an unrecognised value (' || apnoea || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        apnoea AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND apnoea IS NOT NULL AND TRIM(apnoea) <> ''
        AND apnoea NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 174: high_pitched_cry ? show logic is_minimum='0' AND apg_doc='1' AND
    --      apg_doc='0' ? apg_doc cannot simultaneously be '1' and '0';
    --      always FALSE; @HIDDEN also applied; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 175: infant_drugs ? show condition references itself ([infant_drugs]='1')
    --      which creates a self-referential loop that can never be satisfied on
    --      an empty/new record; treat as always visible in practice.
    --      Field is an autocomplete SQL lookup; validate only that it is not
    --      an empty string when a value is expected (no closed value set to
    --      validate against).
    -- -------------------------------------------------------------------------
    missing_infant_drugs AS (
      SELECT id, hosp_id, date_today,
        'infant_drugs' AS variable,
        'Infant drugs field is empty; if drugs were administered please record them, otherwise this field can be left blank' AS issue,
        infant_drugs AS current_value
      FROM neonatal_core
      WHERE infant_drugs IS NOT NULL AND TRIM(infant_drugs) = ''
    ),


        -- =========================================================================
    -- BABY'S EXAMINATION SECTION DQA (fields 177?202, instrument: examination)
    -- =========================================================================

    -- -------------------------------------------------------------------------
    -- 177: temperature_degrees_celciu ? always shown; required
    --      Form Min: -1 (placeholder), Max: 42
    --      Plausible clinical range: 34.0?42.0 �C; -1 is valid placeholder
    -- -------------------------------------------------------------------------
    missing_temperature AS (
      SELECT id, hosp_id, date_today,
        'temperature_degrees_celciu' AS variable,
        'Temperature (�C) is missing' AS issue,
        temperature_degrees_celciu AS current_value
      FROM neonatal_core
      WHERE temperature_degrees_celciu IS NULL OR TRIM(temperature_degrees_celciu) = ''
    ),
    implausible_temperature AS (
      SELECT id, hosp_id, date_today,
        'temperature_degrees_celciu' AS variable,
        'Temperature (' || temperature_degrees_celciu || ' �C) is outside the plausible neonatal clinical range of 34.0 to 42.0 �C' AS issue,
        temperature_degrees_celciu AS current_value
      FROM neonatal_core
      WHERE temperature_degrees_celciu IS NOT NULL
        AND TRIM(temperature_degrees_celciu) <> ''
        AND temperature_degrees_celciu <> '-1'
        AND TRY_CAST(temperature_degrees_celciu AS DOUBLE) IS NOT NULL
        AND (
          TRY_CAST(temperature_degrees_celciu AS DOUBLE) < 34.0
          OR TRY_CAST(temperature_degrees_celciu AS DOUBLE) > 42.0
        )
    ),

    -- -------------------------------------------------------------------------
    -- 178: respiratory_rate_rr_per_mi ? shown when is_minimum = '0'; required
    --      Form range: 20?110 breaths/min; -1 valid
    -- -------------------------------------------------------------------------
    missing_respiratory_rate AS (
      SELECT id, hosp_id, date_today,
        'respiratory_rate_rr_per_mi' AS variable,
        'Respiratory rate (breaths per minute) is missing (entry is required for non-minimum dataset records)' AS issue,
        respiratory_rate_rr_per_mi AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (respiratory_rate_rr_per_mi IS NULL OR TRIM(respiratory_rate_rr_per_mi) = '')
    ),
    implausible_respiratory_rate AS (
      SELECT id, hosp_id, date_today,
        'respiratory_rate_rr_per_mi' AS variable,
        'Respiratory rate (' || respiratory_rate_rr_per_mi || ' breaths/min) is outside the plausible neonatal range of 20 to 110 breaths per minute' AS issue,
        respiratory_rate_rr_per_mi AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND respiratory_rate_rr_per_mi IS NOT NULL
        AND TRIM(respiratory_rate_rr_per_mi) <> ''
        AND respiratory_rate_rr_per_mi <> '-1'
        AND TRY_CAST(respiratory_rate_rr_per_mi AS DOUBLE) IS NOT NULL
        AND (
          TRY_CAST(respiratory_rate_rr_per_mi AS DOUBLE) < 20
          OR TRY_CAST(respiratory_rate_rr_per_mi AS DOUBLE) > 110
        )
    ),

    -- -------------------------------------------------------------------------
    -- 179: heart_rate_hr_min ? shown when is_minimum = '0'; required
    --      Form range: 60?200 beats/min; -1 valid
    -- -------------------------------------------------------------------------
    missing_heart_rate AS (
      SELECT id, hosp_id, date_today,
        'heart_rate_hr_min' AS variable,
        'Heart rate / pulse (beats per minute) is missing (entry is required for non-minimum dataset records)' AS issue,
        heart_rate_hr_min AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (heart_rate_hr_min IS NULL OR TRIM(heart_rate_hr_min) = '')
    ),
    implausible_heart_rate AS (
      SELECT id, hosp_id, date_today,
        'heart_rate_hr_min' AS variable,
        'Heart rate (' || heart_rate_hr_min || ' beats/min) is outside the plausible neonatal range of 60 to 200 beats per minute' AS issue,
        heart_rate_hr_min AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND heart_rate_hr_min IS NOT NULL
        AND TRIM(heart_rate_hr_min) <> ''
        AND heart_rate_hr_min <> '-1'
        AND TRY_CAST(heart_rate_hr_min AS DOUBLE) IS NOT NULL
        AND (
          TRY_CAST(heart_rate_hr_min AS DOUBLE) < 60
          OR TRY_CAST(heart_rate_hr_min AS DOUBLE) > 200
        )
    ),

    -- -------------------------------------------------------------------------
    -- 180: oxygen_saturation_measured ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No)
    -- -------------------------------------------------------------------------
    missing_oxygen_saturation_measured AS (
      SELECT id, hosp_id, date_today,
        'oxygen_saturation_measured' AS variable,
        'No answer recorded for whether oxygen saturation was documented (entry is required for non-minimum dataset records)' AS issue,
        oxygen_saturation_measured AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (oxygen_saturation_measured IS NULL OR TRIM(oxygen_saturation_measured) = '')
    ),
    invalid_oxygen_saturation_measured AS (
      SELECT id, hosp_id, date_today,
        'oxygen_saturation_measured' AS variable,
        'Oxygen saturation documented field has an unrecognised value (' || oxygen_saturation_measured || '); expected 1 (Yes) or 0 (No)' AS issue,
        oxygen_saturation_measured AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND oxygen_saturation_measured IS NOT NULL
        AND TRIM(oxygen_saturation_measured) <> ''
        AND oxygen_saturation_measured NOT IN ('1','0')
    ),

    -- -------------------------------------------------------------------------
    -- 181: oxygen_saturation ? shown when oxygen_saturation_measured = '1'
    --      AND is_minimum = '0'; no hard required flag but must be present
    --      when gate is open; -1 valid; plausible range 50?100 %
    -- -------------------------------------------------------------------------
    missing_oxygen_saturation AS (
      SELECT id, hosp_id, date_today,
        'oxygen_saturation' AS variable,
        'Oxygen saturation (%) is missing (oxygen saturation was indicated as documented)' AS issue,
        oxygen_saturation AS current_value
      FROM neonatal_core
      WHERE oxygen_saturation_measured = '1'
        AND is_minimum = '0'
        AND (oxygen_saturation IS NULL OR TRIM(oxygen_saturation) = '')
    ),
    implausible_oxygen_saturation AS (
      SELECT id, hosp_id, date_today,
        'oxygen_saturation' AS variable,
        'Oxygen saturation (' || oxygen_saturation || '%) is outside the plausible range of 50 to 100 %' AS issue,
        oxygen_saturation AS current_value
      FROM neonatal_core
      WHERE oxygen_saturation_measured = '1'
        AND is_minimum = '0'
        AND oxygen_saturation IS NOT NULL
        AND TRIM(oxygen_saturation) <> ''
        AND oxygen_saturation <> '-1'
        AND TRY_CAST(oxygen_saturation AS DOUBLE) IS NOT NULL
        AND (
          TRY_CAST(oxygen_saturation AS DOUBLE) < 50
          OR TRY_CAST(oxygen_saturation AS DOUBLE) > 100
        )
    ),

    -- -------------------------------------------------------------------------
    -- 182: stirdor ? show logic is_minimum='0' AND is_minimum='1' ? always FALSE
    --      @HIDDEN also applied; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 183: cry ? shown when is_minimum = '0'; no required flag
    --      valid: 1 (Normal), 2 (Weak), 3 (Hoarse), 4 (High pitched), -1 (Empty)
    --      Validate only invalid codes when gate is open.
    -- -------------------------------------------------------------------------
    invalid_cry AS (
      SELECT id, hosp_id, date_today,
        'cry' AS variable,
        'Cry field has an unrecognised value (' || cry || '); expected 1 (Normal), 2 (Weak), 3 (Hoarse), 4 (High pitched), or -1 (Empty)' AS issue,
        cry AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND cry IS NOT NULL AND TRIM(cry) <> ''
        AND cry NOT IN ('1','2','3','4','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 184: central_cyanosis ? always shown; required
    --      valid: 1 (Yes), 2 (No), 3 (Not specified), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_central_cyanosis AS (
      SELECT id, hosp_id, date_today,
        'central_cyanosis' AS variable,
        'Central cyanosis status was not recorded' AS issue,
        central_cyanosis AS current_value
      FROM neonatal_core
      WHERE central_cyanosis IS NULL OR TRIM(central_cyanosis) = ''
    ),
    invalid_central_cyanosis AS (
      SELECT id, hosp_id, date_today,
        'central_cyanosis' AS variable,
        'Central cyanosis field has an unrecognised value (' || central_cyanosis || '); expected 1 (Yes), 2 (No), 3 (Not specified), or -1 (Empty)' AS issue,
        central_cyanosis AS current_value
      FROM neonatal_core
      WHERE central_cyanosis IS NOT NULL AND TRIM(central_cyanosis) <> ''
        AND central_cyanosis NOT IN ('1','2','3','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 185: indrawing ? always shown; required
    --      valid: 1 (none/mild), 2 (severe), 3 (sternum), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_indrawing AS (
      SELECT id, hosp_id, date_today,
        'indrawing' AS variable,
        'Chest indrawing status was not recorded' AS issue,
        indrawing AS current_value
      FROM neonatal_core
      WHERE indrawing IS NULL OR TRIM(indrawing) = ''
    ),
    invalid_indrawing AS (
      SELECT id, hosp_id, date_today,
        'indrawing' AS variable,
        'Indrawing field has an unrecognised value (' || indrawing || '); expected 1 (none/mild), 2 (severe), 3 (sternum), or -1 (Empty)' AS issue,
        indrawing AS current_value
      FROM neonatal_core
      WHERE indrawing IS NOT NULL AND TRIM(indrawing) <> ''
        AND indrawing NOT IN ('1','2','3','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 186: grunting ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_grunting AS (
      SELECT id, hosp_id, date_today,
        'grunting' AS variable,
        'Grunting status is missing (entry is required for non-minimum dataset records)' AS issue,
        grunting AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (grunting IS NULL OR TRIM(grunting) = '')
    ),
    invalid_grunting AS (
      SELECT id, hosp_id, date_today,
        'grunting' AS variable,
        'Grunting field has an unrecognised value (' || grunting || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        grunting AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND grunting IS NOT NULL AND TRIM(grunting) <> ''
        AND grunting NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 187: air_entry_bilateral ? shown when is_minimum = '0'; not required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    invalid_air_entry_bilateral AS (
      SELECT id, hosp_id, date_today,
        'air_entry_bilateral' AS variable,
        'Air entry bilateral field has an unrecognised value (' || air_entry_bilateral || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        air_entry_bilateral AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND air_entry_bilateral IS NOT NULL AND TRIM(air_entry_bilateral) <> ''
        AND air_entry_bilateral NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 188: crackles ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_crackles AS (
      SELECT id, hosp_id, date_today,
        'crackles' AS variable,
        'Crackles/crepitations status is missing (entry is required for non-minimum dataset records)' AS issue,
        crackles AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (crackles IS NULL OR TRIM(crackles) = '')
    ),
    invalid_crackles AS (
      SELECT id, hosp_id, date_today,
        'crackles' AS variable,
        'Crackles/crepitations field has an unrecognised value (' || crackles || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        crackles AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND crackles IS NOT NULL AND TRIM(crackles) <> ''
        AND crackles NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 189: cap_refill ? shown when is_minimum = '0'; required
    --      valid: 1 (X-indeterminate), 2 (2 sec), 3 (3 sec), 4 (>3 sec),
    --             5 (2-3 sec), 6 (1 sec), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_cap_refill AS (
      SELECT id, hosp_id, date_today,
        'cap_refill' AS variable,
        'Capillary refill time (CRT) is missing (entry is required for non-minimum dataset records)' AS issue,
        cap_refill AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (cap_refill IS NULL OR TRIM(cap_refill) = '')
    ),
    invalid_cap_refill AS (
      SELECT id, hosp_id, date_today,
        'cap_refill' AS variable,
        'Capillary refill time field has an unrecognised value (' || cap_refill || '); expected 1 (X-indeterminate), 6 (1 sec), 2 (2 sec), 5 (2-3 sec), 3 (3 sec), 4 (>3 sec), or -1 (Empty)' AS issue,
        cap_refill AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND cap_refill IS NOT NULL AND TRIM(cap_refill) <> ''
        AND cap_refill NOT IN ('1','2','3','4','5','6','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 190: pallor_anaemia ? shown when is_minimum = '0'; required
    --      valid: 1 (none), 2 (+(mild/moderate)), 3 (+++(Severe)),
    --             4 (Not classified), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_pallor_anaemia AS (
      SELECT id, hosp_id, date_today,
        'pallor_anaemia' AS variable,
        'Pallor/anaemia assessment is missing (entry is required for non-minimum dataset records)' AS issue,
        pallor_anaemia AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (pallor_anaemia IS NULL OR TRIM(pallor_anaemia) = '')
    ),
    invalid_pallor_anaemia AS (
      SELECT id, hosp_id, date_today,
        'pallor_anaemia' AS variable,
        'Pallor/anaemia field has an unrecognised value (' || pallor_anaemia || '); expected 1 (none), 2 (mild/moderate), 3 (severe), 4 (not classified), or -1 (Empty)' AS issue,
        pallor_anaemia AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND pallor_anaemia IS NOT NULL AND TRIM(pallor_anaemia) <> ''
        AND pallor_anaemia NOT IN ('1','2','3','4','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 191: suck_breastfeed ? always shown; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_suck_breastfeed AS (
      SELECT id, hosp_id, date_today,
        'suck_breastfeed' AS variable,
        'No answer recorded for whether the baby can suck or breastfeed' AS issue,
        suck_breastfeed AS current_value
      FROM neonatal_core
      WHERE suck_breastfeed IS NULL OR TRIM(suck_breastfeed) = ''
    ),
    invalid_suck_breastfeed AS (
      SELECT id, hosp_id, date_today,
        'suck_breastfeed' AS variable,
        'Can suck/breastfeed field has an unrecognised value (' || suck_breastfeed || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        suck_breastfeed AS current_value
      FROM neonatal_core
      WHERE suck_breastfeed IS NOT NULL AND TRIM(suck_breastfeed) <> ''
        AND suck_breastfeed NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 192: bulging_fontanelle ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 2 (No/flat), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_bulging_fontanelle AS (
      SELECT id, hosp_id, date_today,
        'bulging_fontanelle' AS variable,
        'Bulging fontanelle status is missing (entry is required for non-minimum dataset records)' AS issue,
        bulging_fontanelle AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (bulging_fontanelle IS NULL OR TRIM(bulging_fontanelle) = '')
    ),
    invalid_bulging_fontanelle AS (
      SELECT id, hosp_id, date_today,
        'bulging_fontanelle' AS variable,
        'Bulging fontanelle field has an unrecognised value (' || bulging_fontanelle || '); expected 1 (Yes), 2 (No/flat), or -1 (Empty)' AS issue,
        bulging_fontanelle AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND bulging_fontanelle IS NOT NULL AND TRIM(bulging_fontanelle) <> ''
        AND bulging_fontanelle NOT IN ('1','2','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 193: irritable ? shown when is_minimum = '0'; not required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    invalid_irritable AS (
      SELECT id, hosp_id, date_today,
        'irritable' AS variable,
        'Irritable field has an unrecognised value (' || irritable || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        irritable AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND irritable IS NOT NULL AND TRIM(irritable) <> ''
        AND irritable NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 194: eye_pus ? show logic is_minimum='0' AND is_minimum='1' ? always FALSE
    --      No DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 195: tone ? always shown; not required
    --      valid: 1 (Normal), 2 (Increased), 3 (Reduced), -1 (Empty)
    -- -------------------------------------------------------------------------
    invalid_tone AS (
      SELECT id, hosp_id, date_today,
        'tone' AS variable,
        'Tone field has an unrecognised value (' || tone || '); expected 1 (Normal), 2 (Increased), 3 (Reduced), or -1 (Empty)' AS issue,
        tone AS current_value
      FROM neonatal_core
      WHERE tone IS NOT NULL AND TRIM(tone) <> ''
        AND tone NOT IN ('1','2','3','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 196: redced_movement_floppy ? show logic is_minimum='0' AND is_minimum='1'
    --      Always FALSE; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 197: umbilicus ? shown when is_minimum = '0'; not required
    --      valid: 1 (Clean), 2 (Local pus), 3 (Pus+red skin), 4 (Other), -1 (Empty)
    -- -------------------------------------------------------------------------
    invalid_umbilicus AS (
      SELECT id, hosp_id, date_today,
        'umbilicus' AS variable,
        'Umbilicus field has an unrecognised value (' || umbilicus || '); expected 1 (Clean), 2 (Local pus), 3 (Pus+red skin), 4 (Other), or -1 (Empty)' AS issue,
        umbilicus AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND umbilicus IS NOT NULL AND TRIM(umbilicus) <> ''
        AND umbilicus NOT IN ('1','2','3','4','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 198: skin ? show logic is_minimum='0' AND is_minimum='1' ? always FALSE
    --      @HIDDEN also applied; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 199: jaundice ? shown when is_minimum = '0'; required
    --      valid: 1 (none), 2 (+(mild/moderate)), 3 (+++(severe)),
    --             4 (Not classified), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_jaundice AS (
      SELECT id, hosp_id, date_today,
        'jaundice' AS variable,
        'Jaundice assessment is missing (entry is required for non-minimum dataset records)' AS issue,
        jaundice AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (jaundice IS NULL OR TRIM(jaundice) = '')
    ),
    invalid_jaundice AS (
      SELECT id, hosp_id, date_today,
        'jaundice' AS variable,
        'Jaundice field has an unrecognised value (' || jaundice || '); expected 1 (none), 2 (mild/moderate), 3 (severe), 4 (not classified), or -1 (Empty)' AS issue,
        jaundice AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND jaundice IS NOT NULL AND TRIM(jaundice) <> ''
        AND jaundice NOT IN ('1','2','3','4','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 200: gest_size ? show logic is_minimum='0' AND is_minimum='1' ? always FALSE
    --      @HIDDEN also applied; no DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 202: abnormalities_1 ? shown when is_minimum = '0'; not required
    --      valid: 1 (Yes), 2 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    invalid_abnormalities_1 AS (
      SELECT id, hosp_id, date_today,
        'abnormalities_1' AS variable,
        'Abnormalities field has an unrecognised value (' || abnormalities_1 || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        abnormalities_1 AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND abnormalities_1 IS NOT NULL AND TRIM(abnormalities_1) <> ''
        AND abnormalities_1 NOT IN ('1','2','-1')
    ),

        -- =========================================================================
    -- INVESTIGATIONS SECTION DQA (fields 204?224, instrument: investigations)
    -- =========================================================================

    -- -------------------------------------------------------------------------
    -- 204: glucose ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_glucose AS (
      SELECT id, hosp_id, date_today,
        'glucose' AS variable,
        'No answer recorded for whether glucose (RBS) was ordered at admission (entry is required for non-minimum dataset records)' AS issue,
        glucose AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (glucose IS NULL OR TRIM(glucose) = '')
    ),
    invalid_glucose AS (
      SELECT id, hosp_id, date_today,
        'glucose' AS variable,
        'Glucose (RBS) ordered field has an unrecognised value (' || glucose || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        glucose AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND glucose IS NOT NULL AND TRIM(glucose) <> ''
        AND glucose NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 205: glucose_results ? shown when glucose = '1' AND is_minimum = '0'
    --      not required; -1 (not recorded), 40.0 (HI), 0.1 (LO) are valid
    --      Plausible clinical range: 0.1?40.0 (covers LO/HI sentinels)
    --      Units-gated check: when glucose_results is present and not -1,
    --      glucose_test_results_units (206) must also be present.
    -- -------------------------------------------------------------------------
    missing_glucose_results AS (
      SELECT id, hosp_id, date_today,
        'glucose_results' AS variable,
        'Glucose result value is missing (glucose was indicated as ordered)' AS issue,
        glucose_results AS current_value
      FROM neonatal_core
      WHERE glucose = '1'
        AND is_minimum = '0'
        AND (glucose_results IS NULL OR TRIM(glucose_results) = '')
    ),
    implausible_glucose_results AS (
      SELECT id, hosp_id, date_today,
        'glucose_results' AS variable,
        'Glucose result (' || glucose_results || ') is outside the plausible range of 0.1 (LO) to 40.0 (HI)' AS issue,
        glucose_results AS current_value
      FROM neonatal_core
      WHERE glucose = '1'
        AND is_minimum = '0'
        AND glucose_results IS NOT NULL AND TRIM(glucose_results) <> ''
        AND glucose_results <> '-1'
        AND TRY_CAST(glucose_results AS DOUBLE) IS NOT NULL
        AND (
          TRY_CAST(glucose_results AS DOUBLE) < 0.1
          OR TRY_CAST(glucose_results AS DOUBLE) > 40.0
        )
    ),

    -- -------------------------------------------------------------------------
    -- 206: glucose_test_results_units ? shown when glucose_results <> '-1'
    --      AND glucose_results <> ''
    --      valid: 1 (mg/dl), 2 (mmol/L), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_glucose_units AS (
      SELECT id, hosp_id, date_today,
        'glucose_test_results_units' AS variable,
        'Glucose result units are missing (a glucose result value has been entered)' AS issue,
        glucose_test_results_units AS current_value
      FROM neonatal_core
      WHERE glucose_results IS NOT NULL
        AND TRIM(glucose_results) <> ''
        AND glucose_results <> '-1'
        AND (glucose_test_results_units IS NULL OR TRIM(glucose_test_results_units) = '')
    ),
    invalid_glucose_units AS (
      SELECT id, hosp_id, date_today,
        'glucose_test_results_units' AS variable,
        'Glucose result units field has an unrecognised value (' || glucose_test_results_units || '); expected 1 (mg/dl), 2 (mmol/L), or -1 (Empty)' AS issue,
        glucose_test_results_units AS current_value
      FROM neonatal_core
      WHERE glucose_results IS NOT NULL
        AND TRIM(glucose_results) <> ''
        AND glucose_results <> '-1'
        AND glucose_test_results_units IS NOT NULL AND TRIM(glucose_test_results_units) <> ''
        AND glucose_test_results_units NOT IN ('1','2','-1')
    ),
    -- Orphan check: units present but no valid result to justify them
    orphan_glucose_units AS (
      SELECT id, hosp_id, date_today,
        'glucose_test_results_units' AS variable,
        'Glucose result units (' || glucose_test_results_units || ') are recorded but there is no corresponding glucose result value' AS issue,
        glucose_test_results_units AS current_value
      FROM neonatal_core
      WHERE (glucose_results IS NULL OR TRIM(glucose_results) = '' OR glucose_results = '-1')
        AND glucose_test_results_units IS NOT NULL
        AND TRIM(glucose_test_results_units) <> ''
        AND glucose_test_results_units NOT IN ('-1')
    ),

    -- -------------------------------------------------------------------------
    -- 207: hbadmission ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_hbadmission AS (
      SELECT id, hosp_id, date_today,
        'hbadmission' AS variable,
        'No answer recorded for whether a haemoglobin (Hb) test was ordered during hospitalisation (entry is required for non-minimum dataset records)' AS issue,
        hbadmission AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (hbadmission IS NULL OR TRIM(hbadmission) = '')
    ),
    invalid_hbadmission AS (
      SELECT id, hosp_id, date_today,
        'hbadmission' AS variable,
        'Hb test ordered field has an unrecognised value (' || hbadmission || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        hbadmission AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND hbadmission IS NOT NULL AND TRIM(hbadmission) <> ''
        AND hbadmission NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 208: hb_hct ? shown when hbadmission = '1' AND is_minimum = '0'
    --      not required; valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_hb_hct AS (
      SELECT id, hosp_id, date_today,
        'hb_hct' AS variable,
        'No answer recorded for whether Hb results are available (Hb test was indicated as ordered)' AS issue,
        hb_hct AS current_value
      FROM neonatal_core
      WHERE hbadmission = '1'
        AND is_minimum = '0'
        AND (hb_hct IS NULL OR TRIM(hb_hct) = '')
    ),
    invalid_hb_hct AS (
      SELECT id, hosp_id, date_today,
        'hb_hct' AS variable,
        'Hb results available field has an unrecognised value (' || hb_hct || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        hb_hct AS current_value
      FROM neonatal_core
      WHERE hbadmission = '1'
        AND is_minimum = '0'
        AND hb_hct IS NOT NULL AND TRIM(hb_hct) <> ''
        AND hb_hct NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 209: hb_results ? shown when hb_hct = '1' AND is_minimum = '0'
    --      not required; -1 means not recorded
    --      Plausible neonatal Hb range: 5.0?25.0 g/dL
    -- -------------------------------------------------------------------------
    missing_hb_results AS (
      SELECT id, hosp_id, date_today,
        'hb_results' AS variable,
        'Haemoglobin result value is missing (Hb results were indicated as available)' AS issue,
        hb_results AS current_value
      FROM neonatal_core
      WHERE hb_hct = '1'
        AND is_minimum = '0'
        AND (hb_results IS NULL OR TRIM(hb_results) = '')
    ),
    implausible_hb_results AS (
      SELECT id, hosp_id, date_today,
        'hb_results' AS variable,
        'Haemoglobin result (' || hb_results || ' g/dL) is outside the plausible neonatal range of 5.0 to 25.0 g/dL' AS issue,
        hb_results AS current_value
      FROM neonatal_core
      WHERE hb_hct = '1'
        AND is_minimum = '0'
        AND hb_results IS NOT NULL AND TRIM(hb_results) <> ''
        AND hb_results <> '-1'
        AND TRY_CAST(hb_results AS DOUBLE) IS NOT NULL
        AND (
          TRY_CAST(hb_results AS DOUBLE) < 5.0
          OR TRY_CAST(hb_results AS DOUBLE) > 25.0
        )
    ),

    -- -------------------------------------------------------------------------
    -- 210: bilirubin ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_bilirubin AS (
      SELECT id, hosp_id, date_today,
        'bilirubin' AS variable,
        'No answer recorded for whether a bilirubin test was ordered during hospitalisation (entry is required for non-minimum dataset records)' AS issue,
        bilirubin AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (bilirubin IS NULL OR TRIM(bilirubin) = '')
    ),
    invalid_bilirubin AS (
      SELECT id, hosp_id, date_today,
        'bilirubin' AS variable,
        'Bilirubin test ordered field has an unrecognised value (' || bilirubin || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        bilirubin AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND bilirubin IS NOT NULL AND TRIM(bilirubin) <> ''
        AND bilirubin NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- lp (field preceding 217): shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_lp AS (
      SELECT id, hosp_id, date_today,
        'lp' AS variable,
        'No answer recorded for whether a lumbar puncture (LP) test was ordered during hospitalisation (entry is required for non-minimum dataset records)' AS issue,
        lp AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (lp IS NULL OR TRIM(lp) = '')
    ),
    invalid_lp AS (
      SELECT id, hosp_id, date_today,
        'lp' AS variable,
        'Lumbar puncture ordered field has an unrecognised value (' || lp || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        lp AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND lp IS NOT NULL AND TRIM(lp) <> ''
        AND lp NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 217: lp_results ? shown when lp = '1' AND is_minimum = '0'; not required
    --      valid: 1 (dry tap), 2 (under pressure), 3 (turbid),
    --             4 (bloody), 5 (clear), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_lp_results AS (
      SELECT id, hosp_id, date_today,
        'lp_results' AS variable,
        'LP result is missing (lumbar puncture was indicated as ordered)' AS issue,
        lp_results AS current_value
      FROM neonatal_core
      WHERE lp = '1'
        AND is_minimum = '0'
        AND (lp_results IS NULL OR TRIM(lp_results) = '')
    ),
    invalid_lp_results AS (
      SELECT id, hosp_id, date_today,
        'lp_results' AS variable,
        'LP results field has an unrecognised value (' || lp_results || '); expected 1 (dry tap), 2 (under pressure), 3 (turbid), 4 (bloody), 5 (clear), or -1 (Empty)' AS issue,
        lp_results AS current_value
      FROM neonatal_core
      WHERE lp = '1'
        AND is_minimum = '0'
        AND lp_results IS NOT NULL AND TRIM(lp_results) <> ''
        AND lp_results NOT IN ('1','2','3','4','5','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 218: blood_culture_ordered ? shown when is_minimum = '0'; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_blood_culture_ordered AS (
      SELECT id, hosp_id, date_today,
        'blood_culture_ordered' AS variable,
        'No answer recorded for whether blood culture was ordered during hospitalisation (entry is required for non-minimum dataset records)' AS issue,
        blood_culture_ordered AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (blood_culture_ordered IS NULL OR TRIM(blood_culture_ordered) = '')
    ),
    invalid_blood_culture_ordered AS (
      SELECT id, hosp_id, date_today,
        'blood_culture_ordered' AS variable,
        'Blood culture ordered field has an unrecognised value (' || blood_culture_ordered || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        blood_culture_ordered AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND blood_culture_ordered IS NOT NULL AND TRIM(blood_culture_ordered) <> ''
        AND blood_culture_ordered NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 219: blood_culture_result ? shown when blood_culture_ordered = '1'
    --      (no is_minimum gate); not required
    --      valid: 1 (Positive), 0 (Negative), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_blood_culture_result AS (
      SELECT id, hosp_id, date_today,
        'blood_culture_result' AS variable,
        'Blood culture result is missing (blood culture was indicated as ordered)' AS issue,
        blood_culture_result AS current_value
      FROM neonatal_core
      WHERE blood_culture_ordered = '1'
        AND (blood_culture_result IS NULL OR TRIM(blood_culture_result) = '')
    ),
    invalid_blood_culture_result AS (
      SELECT id, hosp_id, date_today,
        'blood_culture_result' AS variable,
        'Blood culture result field has an unrecognised value (' || blood_culture_result || '); expected 1 (Positive), 0 (Negative), or -1 (Empty)' AS issue,
        blood_culture_result AS current_value
      FROM neonatal_core
      WHERE blood_culture_ordered = '1'
        AND blood_culture_result IS NOT NULL AND TRIM(blood_culture_result) <> ''
        AND blood_culture_result NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- crp_done ? shown when hosp_id = '70' only; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_crp_done AS (
      SELECT id, hosp_id, date_today,
        'crp_done' AS variable,
        'No answer recorded for whether CRP was done (entry is required for this facility)' AS issue,
        crp_done AS current_value
      FROM neonatal_core
      WHERE hosp_id = '70'
        AND (crp_done IS NULL OR TRIM(crp_done) = '')
    ),
    invalid_crp_done AS (
      SELECT id, hosp_id, date_today,
        'crp_done' AS variable,
        'CRP done field has an unrecognised value (' || crp_done || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        crp_done AS current_value
      FROM neonatal_core
      WHERE hosp_id = '70'
        AND crp_done IS NOT NULL AND TRIM(crp_done) <> ''
        AND crp_done NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 223: urine ? show logic is_minimum='0' AND is_minimum='1' ? always FALSE
    --      No DQA check emitted.
    -- -------------------------------------------------------------------------

    -- -------------------------------------------------------------------------
    -- 224: pus_swab ? @HIDDEN; no DQA check emitted (as instructed).
    -- -------------------------------------------------------------------------

        -- =========================================================================
    -- BABY'S ADMISSION DIAGNOSES SECTION DQA (fields 227?239,
    -- instrument: babys_admission_diagnoses)
    -- =========================================================================

    -- -------------------------------------------------------------------------
    -- 227: clear_pry_adm_diag ? always visible; required
    --      valid: 1 (Yes), 0 (No), -1 (Empty)
    -- -------------------------------------------------------------------------
    missing_clear_pry_adm_diag AS (
      SELECT id, hosp_id, date_today,
        'clear_pry_adm_diag' AS variable,
        'No answer recorded for whether there is a clear primary admission diagnosis (field is always required)' AS issue,
        clear_pry_adm_diag AS current_value
      FROM neonatal_core
      WHERE (clear_pry_adm_diag IS NULL OR TRIM(clear_pry_adm_diag) = '')
    ),
    invalid_clear_pry_adm_diag AS (
      SELECT id, hosp_id, date_today,
        'clear_pry_adm_diag' AS variable,
        'Clear primary admission diagnosis field has an unrecognised value (' || clear_pry_adm_diag || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        clear_pry_adm_diag AS current_value
      FROM neonatal_core
      WHERE clear_pry_adm_diag IS NOT NULL AND TRIM(clear_pry_adm_diag) <> ''
        AND clear_pry_adm_diag NOT IN ('1','0','-1')
    ),

    -- -------------------------------------------------------------------------
    -- 228: pry_adm_diag ? shown when clear_pry_adm_diag = '1'
    --      free-text; required when gate is open
    -- -------------------------------------------------------------------------
    missing_pry_adm_diag AS (
      SELECT id, hosp_id, date_today,
        'pry_adm_diag' AS variable,
        'Primary admission diagnosis text is missing (a clear primary admission diagnosis was indicated)' AS issue,
        pry_adm_diag AS current_value
      FROM neonatal_core
      WHERE clear_pry_adm_diag = '1'
        AND (pry_adm_diag IS NULL OR TRIM(pry_adm_diag) = '')
    ),
    -- Orphan: text entered but gate is closed
    orphan_pry_adm_diag AS (
      SELECT id, hosp_id, date_today,
        'pry_adm_diag' AS variable,
        'Primary admission diagnosis text (' || pry_adm_diag || ') is recorded but the clear primary diagnosis flag is not set to Yes' AS issue,
        pry_adm_diag AS current_value
      FROM neonatal_core
      WHERE (clear_pry_adm_diag IS NULL OR clear_pry_adm_diag <> '1')
        AND pry_adm_diag IS NOT NULL AND TRIM(pry_adm_diag) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- 229: adm_diag_1 ? shown when clear_pry_adm_diag = '0'
    --      free-text; at least adm_diag_1 required when gate is open
    -- -------------------------------------------------------------------------
    missing_adm_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'adm_diag_1' AS variable,
        'Admission diagnosis 1 is missing (no clear primary diagnosis was indicated; at least one diagnosis entry is required)' AS issue,
        adm_diag_1 AS current_value
      FROM neonatal_core
      WHERE clear_pry_adm_diag = '0'
        AND (adm_diag_1 IS NULL OR TRIM(adm_diag_1) = '')
    ),
    -- Orphan
    orphan_adm_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'adm_diag_1' AS variable,
        'Admission diagnosis 1 text (' || adm_diag_1 || ') is recorded but the clear primary diagnosis flag is not set to No' AS issue,
        adm_diag_1 AS current_value
      FROM neonatal_core
      WHERE (clear_pry_adm_diag IS NULL OR clear_pry_adm_diag <> '0')
        AND adm_diag_1 IS NOT NULL AND TRIM(adm_diag_1) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- 230: adm_diag_2 ? shown when clear_pry_adm_diag = '0'
    --      free-text; optional but orphan-checked
    -- -------------------------------------------------------------------------
    orphan_adm_diag_2 AS (
      SELECT id, hosp_id, date_today,
        'adm_diag_2' AS variable,
        'Admission diagnosis 2 text (' || adm_diag_2 || ') is recorded but the clear primary diagnosis flag is not set to No' AS issue,
        adm_diag_2 AS current_value
      FROM neonatal_core
      WHERE (clear_pry_adm_diag IS NULL OR clear_pry_adm_diag <> '0')
        AND adm_diag_2 IS NOT NULL AND TRIM(adm_diag_2) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- 231: adm_diag_3 ? shown when clear_pry_adm_diag = '0'
    --      free-text; optional but orphan-checked
    -- -------------------------------------------------------------------------
    orphan_adm_diag_3 AS (
      SELECT id, hosp_id, date_today,
        'adm_diag_3' AS variable,
        'Admission diagnosis 3 text (' || adm_diag_3 || ') is recorded but the clear primary diagnosis flag is not set to No' AS issue,
        adm_diag_3 AS current_value
      FROM neonatal_core
      WHERE (clear_pry_adm_diag IS NULL OR clear_pry_adm_diag <> '0')
        AND adm_diag_3 IS NOT NULL AND TRIM(adm_diag_3) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- Cross-check: adm_diag_2 / adm_diag_3 sequencing
    --   adm_diag_2 should not be populated without adm_diag_1
    --   adm_diag_3 should not be populated without adm_diag_2
    -- -------------------------------------------------------------------------
    seq_adm_diag_2_without_1 AS (
      SELECT id, hosp_id, date_today,
        'adm_diag_2' AS variable,
        'Admission diagnosis 2 is recorded (' || adm_diag_2 || ') but admission diagnosis 1 is empty; diagnoses should be entered sequentially' AS issue,
        adm_diag_2 AS current_value
      FROM neonatal_core
      WHERE clear_pry_adm_diag = '0'
        AND adm_diag_2 IS NOT NULL AND TRIM(adm_diag_2) <> ''
        AND (adm_diag_1 IS NULL OR TRIM(adm_diag_1) = '')
    ),
    seq_adm_diag_3_without_2 AS (
      SELECT id, hosp_id, date_today,
        'adm_diag_3' AS variable,
        'Admission diagnosis 3 is recorded (' || adm_diag_3 || ') but admission diagnosis 2 is empty; diagnoses should be entered sequentially' AS issue,
        adm_diag_3 AS current_value
      FROM neonatal_core
      WHERE clear_pry_adm_diag = '0'
        AND adm_diag_3 IS NOT NULL AND TRIM(adm_diag_3) <> ''
        AND (adm_diag_2 IS NULL OR TRIM(adm_diag_2) = '')
    ),

    -- -------------------------------------------------------------------------
    -- 232: other_admission_diag ? always visible; yesno; not marked required
    --      valid: 1 (Yes), 0 (No)
    -- -------------------------------------------------------------------------
    missing_other_admission_diag AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag' AS variable,
        'No answer recorded for whether there are other admission diagnoses' AS issue,
        other_admission_diag AS current_value
      FROM neonatal_core
      WHERE (other_admission_diag IS NULL OR TRIM(other_admission_diag) = '')
    ),
    invalid_other_admission_diag AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag' AS variable,
        'Other admission diagnoses field has an unrecognised value (' || other_admission_diag || '); expected 1 (Yes) or 0 (No)' AS issue,
        other_admission_diag AS current_value
      FROM neonatal_core
      WHERE other_admission_diag IS NOT NULL AND TRIM(other_admission_diag) <> ''
        AND other_admission_diag NOT IN ('1','0')
    ),

    -- -------------------------------------------------------------------------
    -- 233?237: other_admission_diag_1 through _5
    --   shown when other_admission_diag = '1'
    --   free-text; at least other_admission_diag_1 required when gate is open
    --   sequential population enforced (_2 requires _1, _3 requires _2, etc.)
    --   orphan-checked when gate is closed
    -- -------------------------------------------------------------------------
    missing_other_admission_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_1' AS variable,
        'Other admission diagnosis 1 is missing (other admission diagnoses were indicated as present)' AS issue,
        other_admission_diag_1 AS current_value
      FROM neonatal_core
      WHERE other_admission_diag = '1'
        AND (other_admission_diag_1 IS NULL OR TRIM(other_admission_diag_1) = '')
    ),
    orphan_other_admission_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_1' AS variable,
        'Other admission diagnosis 1 text (' || other_admission_diag_1 || ') is recorded but other admission diagnoses flag is not set to Yes' AS issue,
        other_admission_diag_1 AS current_value
      FROM neonatal_core
      WHERE (other_admission_diag IS NULL OR other_admission_diag <> '1')
        AND other_admission_diag_1 IS NOT NULL AND TRIM(other_admission_diag_1) <> ''
    ),
    -- _2
    seq_other_diag_2_without_1 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_2' AS variable,
        'Other admission diagnosis 2 is recorded (' || other_admission_diag_2 || ') but other admission diagnosis 1 is empty; diagnoses should be entered sequentially' AS issue,
        other_admission_diag_2 AS current_value
      FROM neonatal_core
      WHERE other_admission_diag = '1'
        AND other_admission_diag_2 IS NOT NULL AND TRIM(other_admission_diag_2) <> ''
        AND (other_admission_diag_1 IS NULL OR TRIM(other_admission_diag_1) = '')
    ),
    orphan_other_admission_diag_2 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_2' AS variable,
        'Other admission diagnosis 2 text (' || other_admission_diag_2 || ') is recorded but other admission diagnoses flag is not set to Yes' AS issue,
        other_admission_diag_2 AS current_value
      FROM neonatal_core
      WHERE (other_admission_diag IS NULL OR other_admission_diag <> '1')
        AND other_admission_diag_2 IS NOT NULL AND TRIM(other_admission_diag_2) <> ''
    ),
    -- _3
    seq_other_diag_3_without_2 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_3' AS variable,
        'Other admission diagnosis 3 is recorded (' || other_admission_diag_3 || ') but other admission diagnosis 2 is empty; diagnoses should be entered sequentially' AS issue,
        other_admission_diag_3 AS current_value
      FROM neonatal_core
      WHERE other_admission_diag = '1'
        AND other_admission_diag_3 IS NOT NULL AND TRIM(other_admission_diag_3) <> ''
        AND (other_admission_diag_2 IS NULL OR TRIM(other_admission_diag_2) = '')
    ),
    orphan_other_admission_diag_3 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_3' AS variable,
        'Other admission diagnosis 3 text (' || other_admission_diag_3 || ') is recorded but other admission diagnoses flag is not set to Yes' AS issue,
        other_admission_diag_3 AS current_value
      FROM neonatal_core
      WHERE (other_admission_diag IS NULL OR other_admission_diag <> '1')
        AND other_admission_diag_3 IS NOT NULL AND TRIM(other_admission_diag_3) <> ''
    ),
    -- _4
    seq_other_diag_4_without_3 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_4' AS variable,
        'Other admission diagnosis 4 is recorded (' || other_admission_diag_4 || ') but other admission diagnosis 3 is empty; diagnoses should be entered sequentially' AS issue,
        other_admission_diag_4 AS current_value
      FROM neonatal_core
      WHERE other_admission_diag = '1'
        AND other_admission_diag_4 IS NOT NULL AND TRIM(other_admission_diag_4) <> ''
        AND (other_admission_diag_3 IS NULL OR TRIM(other_admission_diag_3) = '')
    ),
    orphan_other_admission_diag_4 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_4' AS variable,
        'Other admission diagnosis 4 text (' || other_admission_diag_4 || ') is recorded but other admission diagnoses flag is not set to Yes' AS issue,
        other_admission_diag_4 AS current_value
      FROM neonatal_core
      WHERE (other_admission_diag IS NULL OR other_admission_diag <> '1')
        AND other_admission_diag_4 IS NOT NULL AND TRIM(other_admission_diag_4) <> ''
    ),
    -- _5
    seq_other_diag_5_without_4 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_5' AS variable,
        'Other admission diagnosis 5 is recorded (' || other_admission_diag_5 || ') but other admission diagnosis 4 is empty; diagnoses should be entered sequentially' AS issue,
        other_admission_diag_5 AS current_value
      FROM neonatal_core
      WHERE other_admission_diag = '1'
        AND other_admission_diag_5 IS NOT NULL AND TRIM(other_admission_diag_5) <> ''
        AND (other_admission_diag_4 IS NULL OR TRIM(other_admission_diag_4) = '')
    ),
    orphan_other_admission_diag_5 AS (
      SELECT id, hosp_id, date_today,
        'other_admission_diag_5' AS variable,
        'Other admission diagnosis 5 text (' || other_admission_diag_5 || ') is recorded but other admission diagnoses flag is not set to Yes' AS issue,
        other_admission_diag_5 AS current_value
      FROM neonatal_core
      WHERE (other_admission_diag IS NULL OR other_admission_diag <> '1')
        AND other_admission_diag_5 IS NOT NULL AND TRIM(other_admission_diag_5) <> ''
    ),

    -- -------------------------------------------------------------------------
    -- 238: other_adm_diag_not_listed ? always visible; yesno; not required
    --      valid: 1 (Yes), 0 (No)
    -- -------------------------------------------------------------------------
    missing_other_adm_diag_not_listed AS (
      SELECT id, hosp_id, date_today,
        'other_adm_diag_not_listed' AS variable,
        'No answer recorded for whether there are admission diagnoses not listed in the standard options' AS issue,
        other_adm_diag_not_listed AS current_value
      FROM neonatal_core
      WHERE (other_adm_diag_not_listed IS NULL OR TRIM(other_adm_diag_not_listed) = '')
    ),
    invalid_other_adm_diag_not_listed AS (
      SELECT id, hosp_id, date_today,
        'other_adm_diag_not_listed' AS variable,
        'Other admission diagnosis not listed field has an unrecognised value (' || other_adm_diag_not_listed || '); expected 1 (Yes) or 0 (No)' AS issue,
        other_adm_diag_not_listed AS current_value
      FROM neonatal_core
      WHERE other_adm_diag_not_listed IS NOT NULL AND TRIM(other_adm_diag_not_listed) <> ''
        AND other_adm_diag_not_listed NOT IN ('1','0')
    ),

    -- -------------------------------------------------------------------------
    -- 239: admisn_diag_not_listed ? shown when other_adm_diag_not_listed = '1'
    --      free-text (comma-separated); required when gate is open
    -- -------------------------------------------------------------------------
    missing_admisn_diag_not_listed AS (
      SELECT id, hosp_id, date_today,
        'admisn_diag_not_listed' AS variable,
        'Admission diagnoses not listed text is missing (unlisted diagnoses were indicated as present)' AS issue,
        admisn_diag_not_listed AS current_value
      FROM neonatal_core
      WHERE other_adm_diag_not_listed = '1'
        AND (admisn_diag_not_listed IS NULL OR TRIM(admisn_diag_not_listed) = '')
    ),
    orphan_admisn_diag_not_listed AS (
      SELECT id, hosp_id, date_today,
        'admisn_diag_not_listed' AS variable,
        'Admission diagnoses not listed text (' || admisn_diag_not_listed || ') is recorded but the unlisted diagnoses flag is not set to Yes' AS issue,
        admisn_diag_not_listed AS current_value
      FROM neonatal_core
      WHERE (other_adm_diag_not_listed IS NULL OR other_adm_diag_not_listed <> '1')
        AND admisn_diag_not_listed IS NOT NULL AND TRIM(admisn_diag_not_listed) <> ''
    ),

        -- =========================================================================
    -- DRUG TREATMENT SECTION DQA (fields 241?345,
    -- instrument: drug_treatment)
    -- =========================================================================

    -- =========================================================================
    -- HELPER: a macro-style note on gates used throughout this section
    --   PRIMARY gate  : t_sheet = '1'  (treatment sheet present)
    --   SECONDARY gate: specific drug = '1' AND is_minimum = '0'
    --   AMIKACIN/CEFTA: specific drug = '1' only (no is_minimum guard)
    --   SECTION 8.2   : other_treatment = '1'
    --   SECTION 8.3   : drugs = '1'
    --   SECTION 8.3b  : is_minimum = '0' AND t_sheet = '1'
    --   Placeholder dates (1914-01-01) treated as valid / not flagged missing
    -- =========================================================================

    -- =========================================================================
    -- 241: t_sheet ? always visible, Required; yesno
    -- =========================================================================
    missing_t_sheet AS (
      SELECT id, hosp_id, date_today,
        't_sheet' AS variable,
        'No answer recorded for whether a treatment sheet is present in the file (field is always required)' AS issue,
        t_sheet AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR TRIM(t_sheet) = '')
    ),
    invalid_t_sheet AS (
      SELECT id, hosp_id, date_today,
        't_sheet' AS variable,
        'Treatment sheet field has an unrecognised value (' || t_sheet || '); expected 1 (Yes) or 0 (No)' AS issue,
        t_sheet AS current_value
      FROM neonatal_core
      WHERE t_sheet IS NOT NULL AND TRIM(t_sheet) <> ''
        AND t_sheet NOT IN ('1','0')
    ),

    -- =========================================================================
    -- SECTION 8.1 ANTIBIOTICS
    -- Pattern per antibiotic (pen, genta, amp, ceftr):
    --   ? drug flag : gated by t_sheet='1'; Required; yesno
    --   ? detail fields: gated by drug='1' AND is_minimum='0'
    --     - date_prescribed  : placeholder 1914-01-01 valid; text date
    --     - route            : coded radio
    --     - dose             : numeric; plausibility range per drug
    --     - units/freq/dur   : coded; -1 = empty/unrecorded
    --     - date_stopped     : placeholder 1914-01-01 valid; must be >= date_prescribed
    -- Amikacin (272) and Ceftazidime (279): no is_minimum guard
    -- =========================================================================

    -- -------------------------------------------------------------------------
    -- 242: pen ? gated by t_sheet='1'; Required; yesno
    -- -------------------------------------------------------------------------
    missing_pen AS (
      SELECT id, hosp_id, date_today,
        'pen' AS variable,
        'No answer recorded for whether Benzyl/Crystalline Penicillin was prescribed (treatment sheet is present)' AS issue,
        pen AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (pen IS NULL OR TRIM(pen) = '')
    ),
    invalid_pen AS (
      SELECT id, hosp_id, date_today,
        'pen' AS variable,
        'Benzyl Penicillin prescribed field has an unrecognised value (' || pen || '); expected 1 (Yes) or 0 (No)' AS issue,
        pen AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND pen IS NOT NULL AND TRIM(pen) <> ''
        AND pen NOT IN ('1','0')
    ),
    orphan_pen AS (
      SELECT id, hosp_id, date_today,
        'pen' AS variable,
        'Benzyl Penicillin prescribed flag (' || pen || ') is recorded but no treatment sheet is indicated as present' AS issue,
        pen AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND pen IS NOT NULL AND TRIM(pen) <> ''
    ),

    -- 243: date_prescribed (pen)
    missing_pen_date_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_prescribed' AS variable,
        'Date prescribed for Benzyl Penicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_prescribed AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (date_prescribed IS NULL OR TRIM(date_prescribed) = '')
    ),
    orphan_pen_date_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_prescribed' AS variable,
        'Date prescribed for Benzyl Penicillin (' || date_prescribed || ') is recorded but Penicillin is not marked as prescribed or dataset is minimum' AS issue,
        date_prescribed AS current_value
      FROM neonatal_core
      WHERE (pen IS NULL OR pen <> '1' OR is_minimum <> '0')
        AND date_prescribed IS NOT NULL AND TRIM(date_prescribed) <> ''
    ),

    -- 244: pen_route
    missing_pen_route AS (
      SELECT id, hosp_id, date_today,
        'pen_route' AS variable,
        'Route of administration for Benzyl Penicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        pen_route AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (pen_route IS NULL OR TRIM(pen_route) = '')
    ),
    invalid_pen_route AS (
      SELECT id, hosp_id, date_today,
        'pen_route' AS variable,
        'Route for Benzyl Penicillin has an unrecognised value (' || pen_route || '); expected 1 (I.M), 2 (I.V), or -1 (Empty)' AS issue,
        pen_route AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND pen_route IS NOT NULL AND TRIM(pen_route) <> ''
        AND pen_route NOT IN ('1','2','-1')
    ),

    -- 245: pen_dose_mg (range 25000?250000; -1 = not recorded)
    missing_pen_dose_mg AS (
      SELECT id, hosp_id, date_today,
        'pen_dose_mg' AS variable,
        'Dose for Benzyl Penicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        pen_dose_mg AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (pen_dose_mg IS NULL OR TRIM(pen_dose_mg) = '')
    ),
    implausible_pen_dose_mg AS (
      SELECT id, hosp_id, date_today,
        'pen_dose_mg' AS variable,
        'Dose for Benzyl Penicillin (' || pen_dose_mg || ') is outside the plausible range (25,000?250,000 IU/mg); review the recorded value' AS issue,
        pen_dose_mg AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND pen_dose_mg IS NOT NULL AND TRIM(pen_dose_mg) <> ''
        AND pen_dose_mg <> '-1'
        AND TRY_CAST(pen_dose_mg AS FLOAT) IS NOT NULL
        AND (TRY_CAST(pen_dose_mg AS FLOAT) < 25000
          OR TRY_CAST(pen_dose_mg AS FLOAT) > 250000)
    ),

    -- 246: pen_dose_unit
    missing_pen_dose_unit AS (
      SELECT id, hosp_id, date_today,
        'pen_dose_unit' AS variable,
        'Dose units for Benzyl Penicillin are missing (drug prescribed and non-minimum dataset)' AS issue,
        pen_dose_unit AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (pen_dose_unit IS NULL OR TRIM(pen_dose_unit) = '')
    ),
    invalid_pen_dose_unit AS (
      SELECT id, hosp_id, date_today,
        'pen_dose_unit' AS variable,
        'Dose units for Benzyl Penicillin have an unrecognised value (' || pen_dose_unit || '); expected 1 (IU), 2 (mg), 3 (MU), or -1 (Empty)' AS issue,
        pen_dose_unit AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND pen_dose_unit IS NOT NULL AND TRIM(pen_dose_unit) <> ''
        AND pen_dose_unit NOT IN ('1','2','3','-1')
    ),

    -- 247: pen_freq
    missing_pen_freq AS (
      SELECT id, hosp_id, date_today,
        'pen_freq' AS variable,
        'Frequency for Benzyl Penicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        pen_freq AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (pen_freq IS NULL OR TRIM(pen_freq) = '')
    ),
    invalid_pen_freq AS (
      SELECT id, hosp_id, date_today,
        'pen_freq' AS variable,
        'Frequency for Benzyl Penicillin has an unrecognised value (' || pen_freq || '); expected 1?5 or -1 (Empty)' AS issue,
        pen_freq AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND pen_freq IS NOT NULL AND TRIM(pen_freq) <> ''
        AND pen_freq NOT IN ('1','2','3','4','5','-1')
    ),

    -- 248: pen_dur (numeric; -1 = not recorded)
    missing_pen_dur AS (
      SELECT id, hosp_id, date_today,
        'pen_dur' AS variable,
        'Duration for Benzyl Penicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        pen_dur AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (pen_dur IS NULL OR TRIM(pen_dur) = '')
    ),
    implausible_pen_dur AS (
      SELECT id, hosp_id, date_today,
        'pen_dur' AS variable,
        'Duration for Benzyl Penicillin (' || pen_dur || ' days) is outside a plausible range (1?90 days); review the recorded value' AS issue,
        pen_dur AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND pen_dur IS NOT NULL AND TRIM(pen_dur) <> ''
        AND pen_dur <> '-1'
        AND TRY_CAST(pen_dur AS FLOAT) IS NOT NULL
        AND (TRY_CAST(pen_dur AS FLOAT) < 1
          OR TRY_CAST(pen_dur AS FLOAT) > 90)
    ),

    -- 249: date_stopped (pen)
    missing_pen_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_stopped' AS variable,
        'Date stopped for Benzyl Penicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_stopped AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND (date_stopped IS NULL OR TRIM(date_stopped) = '')
    ),
    temporal_pen_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_stopped' AS variable,
        'Date stopped for Benzyl Penicillin (' || date_stopped || ') is before the date prescribed (' || date_prescribed || '); a drug cannot be stopped before it was started' AS issue,
        date_stopped AS current_value
      FROM neonatal_core
      WHERE pen = '1' AND is_minimum = '0'
        AND date_stopped IS NOT NULL AND TRIM(date_stopped) <> ''
        AND date_stopped <> '1914-01-01'
        AND date_prescribed IS NOT NULL AND TRIM(date_prescribed) <> ''
        AND date_prescribed <> '1914-01-01'
        AND TRY_CAST(date_stopped AS DATE) < TRY_CAST(date_prescribed AS DATE)
    ),

    -- =========================================================================
    -- 250?256: GENTAMICIN (genta)
    -- Dose range: 1.5?25 mg (per dose); -1 = not recorded
    -- =========================================================================
    missing_genta AS (
      SELECT id, hosp_id, date_today,
        'genta' AS variable,
        'No answer recorded for whether Gentamicin was prescribed (treatment sheet is present)' AS issue,
        genta AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (genta IS NULL OR TRIM(genta) = '')
    ),
    invalid_genta AS (
      SELECT id, hosp_id, date_today,
        'genta' AS variable,
        'Gentamicin prescribed field has an unrecognised value (' || genta || '); expected 1 (Yes) or 0 (No)' AS issue,
        genta AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND genta IS NOT NULL AND TRIM(genta) <> ''
        AND genta NOT IN ('1','0')
    ),
    orphan_genta AS (
      SELECT id, hosp_id, date_today,
        'genta' AS variable,
        'Gentamicin prescribed flag (' || genta || ') is recorded but no treatment sheet is indicated as present' AS issue,
        genta AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND genta IS NOT NULL AND TRIM(genta) <> ''
    ),
    -- 251
    missing_genta_date_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_gentamycin_prescribed' AS variable,
        'Date prescribed for Gentamicin is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_gentamycin_prescribed AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND (date_gentamycin_prescribed IS NULL OR TRIM(date_gentamycin_prescribed) = '')
    ),
    -- 252
    missing_genta_route AS (
      SELECT id, hosp_id, date_today,
        'genta_route' AS variable,
        'Route of administration for Gentamicin is missing (drug prescribed and non-minimum dataset)' AS issue,
        genta_route AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND (genta_route IS NULL OR TRIM(genta_route) = '')
    ),
    invalid_genta_route AS (
      SELECT id, hosp_id, date_today,
        'genta_route' AS variable,
        'Route for Gentamicin has an unrecognised value (' || genta_route || '); expected 1 (I.M), 2 (I.V), or -1 (Empty)' AS issue,
        genta_route AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND genta_route IS NOT NULL AND TRIM(genta_route) <> ''
        AND genta_route NOT IN ('1','2','-1')
    ),
    -- 253: genta_dose (1.5?25 mg)
    missing_genta_dose AS (
      SELECT id, hosp_id, date_today,
        'genta_dose' AS variable,
        'Dose for Gentamicin is missing (drug prescribed and non-minimum dataset)' AS issue,
        genta_dose AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND (genta_dose IS NULL OR TRIM(genta_dose) = '')
    ),
    implausible_genta_dose AS (
      SELECT id, hosp_id, date_today,
        'genta_dose' AS variable,
        'Dose for Gentamicin (' || genta_dose || ' mg) is outside the plausible range (1.5?25 mg); review the recorded value' AS issue,
        genta_dose AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND genta_dose IS NOT NULL AND TRIM(genta_dose) <> ''
        AND genta_dose <> '-1'
        AND TRY_CAST(genta_dose AS FLOAT) IS NOT NULL
        AND (TRY_CAST(genta_dose AS FLOAT) < 1.5
          OR TRY_CAST(genta_dose AS FLOAT) > 25)
    ),
    -- 254: genta_freq
    missing_genta_freq AS (
      SELECT id, hosp_id, date_today,
        'genta_freq' AS variable,
        'Frequency for Gentamicin is missing (drug prescribed and non-minimum dataset)' AS issue,
        genta_freq AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND (genta_freq IS NULL OR TRIM(genta_freq) = '')
    ),
    invalid_genta_freq AS (
      SELECT id, hosp_id, date_today,
        'genta_freq' AS variable,
        'Frequency for Gentamicin has an unrecognised value (' || genta_freq || '); expected 1?4 or -1 (Empty)' AS issue,
        genta_freq AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND genta_freq IS NOT NULL AND TRIM(genta_freq) <> ''
        AND genta_freq NOT IN ('1','2','3','4','-1')
    ),
    -- 255: genta_dur
    missing_genta_dur AS (
      SELECT id, hosp_id, date_today,
        'genta_dur' AS variable,
        'Duration for Gentamicin is missing (drug prescribed and non-minimum dataset)' AS issue,
        genta_dur AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND (genta_dur IS NULL OR TRIM(genta_dur) = '')
    ),
    implausible_genta_dur AS (
      SELECT id, hosp_id, date_today,
        'genta_dur' AS variable,
        'Duration for Gentamicin (' || genta_dur || ' days) is outside a plausible range (1?90 days); review the recorded value' AS issue,
        genta_dur AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND genta_dur IS NOT NULL AND TRIM(genta_dur) <> ''
        AND genta_dur <> '-1'
        AND TRY_CAST(genta_dur AS FLOAT) IS NOT NULL
        AND (TRY_CAST(genta_dur AS FLOAT) < 1
          OR TRY_CAST(genta_dur AS FLOAT) > 90)
    ),
    -- 256: date_gent_stopped
    missing_genta_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_gent_stopped' AS variable,
        'Date stopped for Gentamicin is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_gent_stopped AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND (date_gent_stopped IS NULL OR TRIM(date_gent_stopped) = '')
    ),
    temporal_genta_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_gent_stopped' AS variable,
        'Date stopped for Gentamicin (' || date_gent_stopped || ') is before the date prescribed (' || date_gentamycin_prescribed || '); a drug cannot be stopped before it was started' AS issue,
        date_gent_stopped AS current_value
      FROM neonatal_core
      WHERE genta = '1' AND is_minimum = '0'
        AND date_gent_stopped IS NOT NULL AND TRIM(date_gent_stopped) <> ''
        AND date_gent_stopped <> '1914-01-01'
        AND date_gentamycin_prescribed IS NOT NULL AND TRIM(date_gentamycin_prescribed) <> ''
        AND date_gentamycin_prescribed <> '1914-01-01'
        AND TRY_CAST(date_gent_stopped AS DATE) < TRY_CAST(date_gentamycin_prescribed AS DATE)
    ),

    -- =========================================================================
    -- 257?264: AMPICILLIN (amp)
    -- Note: amp_route codes 0=I.M, 1=I.V (non-standard; preserved as defined)
    -- amp_freq is marked Required on the form
    -- =========================================================================
    missing_amp AS (
      SELECT id, hosp_id, date_today,
        'amp' AS variable,
        'No answer recorded for whether Ampicillin was prescribed (treatment sheet is present)' AS issue,
        amp AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (amp IS NULL OR TRIM(amp) = '')
    ),
    invalid_amp AS (
      SELECT id, hosp_id, date_today,
        'amp' AS variable,
        'Ampicillin prescribed field has an unrecognised value (' || amp || '); expected 1 (Yes) or 0 (No)' AS issue,
        amp AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND amp IS NOT NULL AND TRIM(amp) <> ''
        AND amp NOT IN ('1','0')
    ),
    orphan_amp AS (
      SELECT id, hosp_id, date_today,
        'amp' AS variable,
        'Ampicillin prescribed flag (' || amp || ') is recorded but no treatment sheet is indicated as present' AS issue,
        amp AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND amp IS NOT NULL AND TRIM(amp) <> ''
    ),
    -- 258
    missing_amp_date_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_ampicillin_prescribed' AS variable,
        'Date prescribed for Ampicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_ampicillin_prescribed AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (date_ampicillin_prescribed IS NULL OR TRIM(date_ampicillin_prescribed) = '')
    ),
    -- 259: amp_route (0=I.M, 1=I.V)
    missing_amp_route AS (
      SELECT id, hosp_id, date_today,
        'amp_route' AS variable,
        'Route of administration for Ampicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        amp_route AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (amp_route IS NULL OR TRIM(amp_route) = '')
    ),
    invalid_amp_route AS (
      SELECT id, hosp_id, date_today,
        'amp_route' AS variable,
        'Route for Ampicillin has an unrecognised value (' || amp_route || '); expected 0 (I.M), 1 (I.V), or -1 (Empty)' AS issue,
        amp_route AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND amp_route IS NOT NULL AND TRIM(amp_route) <> ''
        AND amp_route NOT IN ('0','1','-1')
    ),
    -- 260: amp_dose (numeric; -1=not recorded)
    missing_amp_dose AS (
      SELECT id, hosp_id, date_today,
        'amp_dose' AS variable,
        'Dose for Ampicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        amp_dose AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (amp_dose IS NULL OR TRIM(amp_dose) = '')
    ),
    -- 261: ampicilin_units (4=mg, 3=Empty, 1=iv, 2=im)
    missing_amp_units AS (
      SELECT id, hosp_id, date_today,
        'ampicilin_units' AS variable,
        'Units for Ampicillin are missing (drug prescribed and non-minimum dataset)' AS issue,
        ampicilin_units AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (ampicilin_units IS NULL OR TRIM(ampicilin_units) = '')
    ),
    invalid_amp_units AS (
      SELECT id, hosp_id, date_today,
        'ampicilin_units' AS variable,
        'Units for Ampicillin have an unrecognised value (' || ampicilin_units || '); expected 1 (iv), 2 (im), 3 (Empty), or 4 (mg)' AS issue,
        ampicilin_units AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND ampicilin_units IS NOT NULL AND TRIM(ampicilin_units) <> ''
        AND ampicilin_units NOT IN ('1','2','3','4')
    ),
    -- 262: amp_freq (Required on form)
    missing_amp_freq AS (
      SELECT id, hosp_id, date_today,
        'amp_freq' AS variable,
        'Frequency for Ampicillin is missing (drug prescribed and non-minimum dataset; field is marked required)' AS issue,
        amp_freq AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (amp_freq IS NULL OR TRIM(amp_freq) = '')
    ),
    invalid_amp_freq AS (
      SELECT id, hosp_id, date_today,
        'amp_freq' AS variable,
        'Frequency for Ampicillin has an unrecognised value (' || amp_freq || '); expected 1?4 or -1 (Empty)' AS issue,
        amp_freq AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND amp_freq IS NOT NULL AND TRIM(amp_freq) <> ''
        AND amp_freq NOT IN ('1','2','3','4','-1')
    ),
    -- 263: amp_dur
    missing_amp_dur AS (
      SELECT id, hosp_id, date_today,
        'amp_dur' AS variable,
        'Duration for Ampicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        amp_dur AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (amp_dur IS NULL OR TRIM(amp_dur) = '')
    ),
    implausible_amp_dur AS (
      SELECT id, hosp_id, date_today,
        'amp_dur' AS variable,
        'Duration for Ampicillin (' || amp_dur || ' days) is outside a plausible range (1?90 days); review the recorded value' AS issue,
        amp_dur AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND amp_dur IS NOT NULL AND TRIM(amp_dur) <> ''
        AND amp_dur <> '-1'
        AND TRY_CAST(amp_dur AS FLOAT) IS NOT NULL
        AND (TRY_CAST(amp_dur AS FLOAT) < 1
          OR TRY_CAST(amp_dur AS FLOAT) > 90)
    ),
    -- 264: date_amp_stopped
    missing_amp_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_amp_stopped' AS variable,
        'Date stopped for Ampicillin is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_amp_stopped AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND (date_amp_stopped IS NULL OR TRIM(date_amp_stopped) = '')
    ),
    temporal_amp_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_amp_stopped' AS variable,
        'Date stopped for Ampicillin (' || date_amp_stopped || ') is before the date prescribed (' || date_ampicillin_prescribed || '); a drug cannot be stopped before it was started' AS issue,
        date_amp_stopped AS current_value
      FROM neonatal_core
      WHERE amp = '1' AND is_minimum = '0'
        AND date_amp_stopped IS NOT NULL AND TRIM(date_amp_stopped) <> ''
        AND date_amp_stopped <> '1914-01-01'
        AND date_ampicillin_prescribed IS NOT NULL AND TRIM(date_ampicillin_prescribed) <> ''
        AND date_ampicillin_prescribed <> '1914-01-01'
        AND TRY_CAST(date_amp_stopped AS DATE) < TRY_CAST(date_ampicillin_prescribed AS DATE)
    ),

    -- =========================================================================
    -- 265?271: CEFTRIAXONE (ceftr)
    -- =========================================================================
    missing_ceftr AS (
      SELECT id, hosp_id, date_today,
        'ceftr' AS variable,
        'No answer recorded for whether Ceftriaxone was prescribed (treatment sheet is present)' AS issue,
        ceftr AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (ceftr IS NULL OR TRIM(ceftr) = '')
    ),
    invalid_ceftr AS (
      SELECT id, hosp_id, date_today,
        'ceftr' AS variable,
        'Ceftriaxone prescribed field has an unrecognised value (' || ceftr || '); expected 1 (Yes) or 0 (No)' AS issue,
        ceftr AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND ceftr IS NOT NULL AND TRIM(ceftr) <> ''
        AND ceftr NOT IN ('1','0')
    ),
    orphan_ceftr AS (
      SELECT id, hosp_id, date_today,
        'ceftr' AS variable,
        'Ceftriaxone prescribed flag (' || ceftr || ') is recorded but no treatment sheet is indicated as present' AS issue,
        ceftr AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND ceftr IS NOT NULL AND TRIM(ceftr) <> ''
    ),
    -- 266
    missing_ceftr_date_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_ceftriaxone_prescribe' AS variable,
        'Date prescribed for Ceftriaxone is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_ceftriaxone_prescribe AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND (date_ceftriaxone_prescribe IS NULL OR TRIM(date_ceftriaxone_prescribe) = '')
    ),
    -- 267
    missing_ceftr_route AS (
      SELECT id, hosp_id, date_today,
        'ceftr_route' AS variable,
        'Route of administration for Ceftriaxone is missing (drug prescribed and non-minimum dataset)' AS issue,
        ceftr_route AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND (ceftr_route IS NULL OR TRIM(ceftr_route) = '')
    ),
    invalid_ceftr_route AS (
      SELECT id, hosp_id, date_today,
        'ceftr_route' AS variable,
        'Route for Ceftriaxone has an unrecognised value (' || ceftr_route || '); expected 1 (I.M), 2 (I.V), or -1 (Empty)' AS issue,
        ceftr_route AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND ceftr_route IS NOT NULL AND TRIM(ceftr_route) <> ''
        AND ceftr_route NOT IN ('1','2','-1')
    ),
    -- 268
    missing_ceftr_dose AS (
      SELECT id, hosp_id, date_today,
        'ceftr_dose' AS variable,
        'Dose for Ceftriaxone is missing (drug prescribed and non-minimum dataset)' AS issue,
        ceftr_dose AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND (ceftr_dose IS NULL OR TRIM(ceftr_dose) = '')
    ),
    -- 269
    missing_ceftr_freq AS (
      SELECT id, hosp_id, date_today,
        'ceftr_freq' AS variable,
        'Frequency for Ceftriaxone is missing (drug prescribed and non-minimum dataset)' AS issue,
        ceftr_freq AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND (ceftr_freq IS NULL OR TRIM(ceftr_freq) = '')
    ),
    invalid_ceftr_freq AS (
      SELECT id, hosp_id, date_today,
        'ceftr_freq' AS variable,
        'Frequency for Ceftriaxone has an unrecognised value (' || ceftr_freq || '); expected 1?5 or -1 (Empty)' AS issue,
        ceftr_freq AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND ceftr_freq IS NOT NULL AND TRIM(ceftr_freq) <> ''
        AND ceftr_freq NOT IN ('1','2','3','4','5','-1')
    ),
    -- 270
    missing_ceftr_dur AS (
      SELECT id, hosp_id, date_today,
        'ceftr_dur' AS variable,
        'Duration for Ceftriaxone is missing (drug prescribed and non-minimum dataset)' AS issue,
        ceftr_dur AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND (ceftr_dur IS NULL OR TRIM(ceftr_dur) = '')
    ),
    implausible_ceftr_dur AS (
      SELECT id, hosp_id, date_today,
        'ceftr_dur' AS variable,
        'Duration for Ceftriaxone (' || ceftr_dur || ' days) is outside a plausible range (1?90 days); review the recorded value' AS issue,
        ceftr_dur AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND ceftr_dur IS NOT NULL AND TRIM(ceftr_dur) <> ''
        AND ceftr_dur <> '-1'
        AND TRY_CAST(ceftr_dur AS FLOAT) IS NOT NULL
        AND (TRY_CAST(ceftr_dur AS FLOAT) < 1
          OR TRY_CAST(ceftr_dur AS FLOAT) > 90)
    ),
    -- 271
    missing_ceftr_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_ceftri_stopped' AS variable,
        'Date stopped for Ceftriaxone is missing (drug prescribed and non-minimum dataset)' AS issue,
        date_ceftri_stopped AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND (date_ceftri_stopped IS NULL OR TRIM(date_ceftri_stopped) = '')
    ),
    temporal_ceftr_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_ceftri_stopped' AS variable,
        'Date stopped for Ceftriaxone (' || date_ceftri_stopped || ') is before the date prescribed (' || date_ceftriaxone_prescribe || '); a drug cannot be stopped before it was started' AS issue,
        date_ceftri_stopped AS current_value
      FROM neonatal_core
      WHERE ceftr = '1' AND is_minimum = '0'
        AND date_ceftri_stopped IS NOT NULL AND TRIM(date_ceftri_stopped) <> ''
        AND date_ceftri_stopped <> '1914-01-01'
        AND date_ceftriaxone_prescribe IS NOT NULL AND TRIM(date_ceftriaxone_prescribe) <> ''
        AND date_ceftriaxone_prescribe <> '1914-01-01'
        AND TRY_CAST(date_ceftri_stopped AS DATE) < TRY_CAST(date_ceftriaxone_prescribe AS DATE)
    ),

    -- =========================================================================
    -- 272?278: AMIKACIN (amikacin)
    -- Gate: t_sheet='1' for flag; amikacin='1' only for detail (no is_minimum)
    -- =========================================================================
    missing_amikacin AS (
      SELECT id, hosp_id, date_today,
        'amikacin' AS variable,
        'No answer recorded for whether Amikacin was prescribed (treatment sheet is present)' AS issue,
        amikacin AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (amikacin IS NULL OR TRIM(amikacin) = '')
    ),
    invalid_amikacin AS (
      SELECT id, hosp_id, date_today,
        'amikacin' AS variable,
        'Amikacin prescribed field has an unrecognised value (' || amikacin || '); expected 1 (Yes) or 0 (No)' AS issue,
        amikacin AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND amikacin IS NOT NULL AND TRIM(amikacin) <> ''
        AND amikacin NOT IN ('1','0')
    ),
    orphan_amikacin AS (
      SELECT id, hosp_id, date_today,
        'amikacin' AS variable,
        'Amikacin prescribed flag (' || amikacin || ') is recorded but no treatment sheet is indicated as present' AS issue,
        amikacin AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND amikacin IS NOT NULL AND TRIM(amikacin) <> ''
    ),
    -- 273
    missing_amikacin_date AS (
      SELECT id, hosp_id, date_today,
        'amikacin_date' AS variable,
        'Date prescribed for Amikacin is missing (drug is marked as prescribed)' AS issue,
        amikacin_date AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND (amikacin_date IS NULL OR TRIM(amikacin_date) = '')
    ),
    -- 274
    missing_amikacin_route AS (
      SELECT id, hosp_id, date_today,
        'amikacin_route' AS variable,
        'Route of administration for Amikacin is missing (drug is marked as prescribed)' AS issue,
        amikacin_route AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND (amikacin_route IS NULL OR TRIM(amikacin_route) = '')
    ),
    invalid_amikacin_route AS (
      SELECT id, hosp_id, date_today,
        'amikacin_route' AS variable,
        'Route for Amikacin has an unrecognised value (' || amikacin_route || '); expected 1 (I.M), 2 (I.V), or -1 (Empty)' AS issue,
        amikacin_route AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND amikacin_route IS NOT NULL AND TRIM(amikacin_route) <> ''
        AND amikacin_route NOT IN ('1','2','-1')
    ),
    -- 275
    missing_amikacin_dose AS (
      SELECT id, hosp_id, date_today,
        'amikacin_dose' AS variable,
        'Dose for Amikacin is missing (drug is marked as prescribed)' AS issue,
        amikacin_dose AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND (amikacin_dose IS NULL OR TRIM(amikacin_dose) = '')
    ),
    -- 276: frequency (amikacin)
    missing_amikacin_freq AS (
      SELECT id, hosp_id, date_today,
        'frequency' AS variable,
        'Frequency for Amikacin is missing (drug is marked as prescribed)' AS issue,
        frequency AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND (frequency IS NULL OR TRIM(frequency) = '')
    ),
    invalid_amikacin_freq AS (
      SELECT id, hosp_id, date_today,
        'frequency' AS variable,
        'Frequency for Amikacin has an unrecognised value (' || frequency || '); expected 1?5 or -1 (Empty)' AS issue,
        frequency AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND frequency IS NOT NULL AND TRIM(frequency) <> ''
        AND frequency NOT IN ('1','2','3','4','5','-1')
    ),
    -- 277
    missing_amikacin_dur AS (
      SELECT id, hosp_id, date_today,
        'duration_amikacin' AS variable,
        'Duration for Amikacin is missing (drug is marked as prescribed)' AS issue,
        duration_amikacin AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND (duration_amikacin IS NULL OR TRIM(duration_amikacin) = '')
    ),
    -- 278
    missing_amikacin_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_amikacin_stopped' AS variable,
        'Date stopped for Amikacin is missing (drug is marked as prescribed)' AS issue,
        date_amikacin_stopped AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND (date_amikacin_stopped IS NULL OR TRIM(date_amikacin_stopped) = '')
    ),
    temporal_amikacin_stopped AS (
      SELECT id, hosp_id, date_today,
        'date_amikacin_stopped' AS variable,
        'Date stopped for Amikacin (' || date_amikacin_stopped || ') is before the date prescribed (' || amikacin_date || '); a drug cannot be stopped before it was started' AS issue,
        date_amikacin_stopped AS current_value
      FROM neonatal_core
      WHERE amikacin = '1'
        AND date_amikacin_stopped IS NOT NULL AND TRIM(date_amikacin_stopped) <> ''
        AND date_amikacin_stopped <> '1914-01-01'
        AND amikacin_date IS NOT NULL AND TRIM(amikacin_date) <> ''
        AND amikacin_date <> '1914-01-01'
        AND TRY_CAST(date_amikacin_stopped AS DATE) < TRY_CAST(amikacin_date AS DATE)
    ),

    -- =========================================================================
    -- 279?286: CEFTAZIDIME (cefta)
    -- Gate: t_sheet='1' for flag; cefta='1' only for detail (no is_minimum)
    -- =========================================================================
    missing_cefta AS (
      SELECT id, hosp_id, date_today,
        'cefta' AS variable,
        'No answer recorded for whether Ceftazidime was prescribed (treatment sheet is present)' AS issue,
        cefta AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (cefta IS NULL OR TRIM(cefta) = '')
    ),
    invalid_cefta AS (
      SELECT id, hosp_id, date_today,
        'cefta' AS variable,
        'Ceftazidime prescribed field has an unrecognised value (' || cefta || '); expected 1 (Yes) or 0 (No)' AS issue,
        cefta AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND cefta IS NOT NULL AND TRIM(cefta) <> ''
        AND cefta NOT IN ('1','0')
    ),
    orphan_cefta AS (
      SELECT id, hosp_id, date_today,
        'cefta' AS variable,
        'Ceftazidime prescribed flag (' || cefta || ') is recorded but no treatment sheet is indicated as present' AS issue,
        cefta AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND cefta IS NOT NULL AND TRIM(cefta) <> ''
    ),
    -- 280
    missing_cefta_date AS (
      SELECT id, hosp_id, date_today,
        'cefta_date' AS variable,
        'Date prescribed for Ceftazidime is missing (drug is marked as prescribed)' AS issue,
        cefta_date AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_date IS NULL OR TRIM(cefta_date) = '')
    ),
    -- 281
    missing_cefta_route AS (
      SELECT id, hosp_id, date_today,
        'cefta_route' AS variable,
        'Route of administration for Ceftazidime is missing (drug is marked as prescribed)' AS issue,
        cefta_route AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_route IS NULL OR TRIM(cefta_route) = '')
    ),
    invalid_cefta_route AS (
      SELECT id, hosp_id, date_today,
        'cefta_route' AS variable,
        'Route for Ceftazidime has an unrecognised value (' || cefta_route || '); expected 1 (I.M), 2 (I.V), or -1 (Empty)' AS issue,
        cefta_route AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND cefta_route IS NOT NULL AND TRIM(cefta_route) <> ''
        AND cefta_route NOT IN ('1','2','-1')
    ),
    -- 282
    missing_cefta_dose AS (
      SELECT id, hosp_id, date_today,
        'cefta_dose' AS variable,
        'Dose for Ceftazidime is missing (drug is marked as prescribed)' AS issue,
        cefta_dose AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_dose IS NULL OR TRIM(cefta_dose) = '')
    ),
    -- 283: cefta_units (1=mg, -1=Empty)
    missing_cefta_units AS (
      SELECT id, hosp_id, date_today,
        'cefta_units' AS variable,
        'Units for Ceftazidime are missing (drug is marked as prescribed)' AS issue,
        cefta_units AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_units IS NULL OR TRIM(cefta_units) = '')
    ),
    invalid_cefta_units AS (
      SELECT id, hosp_id, date_today,
        'cefta_units' AS variable,
        'Units for Ceftazidime have an unrecognised value (' || cefta_units || '); expected 1 (mg) or -1 (Empty)' AS issue,
        cefta_units AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND cefta_units IS NOT NULL AND TRIM(cefta_units) <> ''
        AND cefta_units NOT IN ('1','-1')
    ),
    -- 284
    missing_cefta_freq AS (
      SELECT id, hosp_id, date_today,
        'cefta_freq' AS variable,
        'Frequency for Ceftazidime is missing (drug is marked as prescribed)' AS issue,
        cefta_freq AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_freq IS NULL OR TRIM(cefta_freq) = '')
    ),
    invalid_cefta_freq AS (
      SELECT id, hosp_id, date_today,
        'cefta_freq' AS variable,
        'Frequency for Ceftazidime has an unrecognised value (' || cefta_freq || '); expected 1?5 or -1 (Empty)' AS issue,
        cefta_freq AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND cefta_freq IS NOT NULL AND TRIM(cefta_freq) <> ''
        AND cefta_freq NOT IN ('1','2','3','4','5','-1')
    ),
    -- 285
    missing_cefta_dur AS (
      SELECT id, hosp_id, date_today,
        'cefta_dur' AS variable,
        'Duration for Ceftazidime is missing (drug is marked as prescribed)' AS issue,
        cefta_dur AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_dur IS NULL OR TRIM(cefta_dur) = '')
    ),
    -- 286
    missing_cefta_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'cefta_date_stopped' AS variable,
        'Date stopped for Ceftazidime is missing (drug is marked as prescribed)' AS issue,
        cefta_date_stopped AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND (cefta_date_stopped IS NULL OR TRIM(cefta_date_stopped) = '')
    ),
    temporal_cefta_date_stopped AS (
      SELECT id, hosp_id, date_today,
        'cefta_date_stopped' AS variable,
        'Date stopped for Ceftazidime (' || cefta_date_stopped || ') is before the date prescribed (' || cefta_date || '); a drug cannot be stopped before it was started' AS issue,
        cefta_date_stopped AS current_value
      FROM neonatal_core
      WHERE cefta = '1'
        AND cefta_date_stopped IS NOT NULL AND TRIM(cefta_date_stopped) <> ''
        AND cefta_date_stopped <> '1914-01-01'
        AND cefta_date IS NOT NULL AND TRIM(cefta_date) <> ''
        AND cefta_date <> '1914-01-01'
        AND TRY_CAST(cefta_date_stopped AS DATE) < TRY_CAST(cefta_date AS DATE)
    ),

    -- =========================================================================
    -- SECTION 8.2: phenobarb, aminophylline, caffeine_citrate
    -- Flags gated by t_sheet='1'; Required
    -- Start/stop dates gated by other_treatment='1'
    -- NOTE: 288/289, 291/292, 294/295 show if other_treatment='1' ? this is
    --       the same gate used for other_drugs_1?5, suggesting the form intends
    --       these dates to be captured alongside the "other drugs" block.
    --       We apply missingness and temporal checks when gate is open.
    -- =========================================================================
    -- 287: phenobarb
    missing_phenobarb AS (
      SELECT id, hosp_id, date_today,
        'phenobarb' AS variable,
        'No answer recorded for whether Phenobarbitone was prescribed (treatment sheet is present)' AS issue,
        phenobarb AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (phenobarb IS NULL OR TRIM(phenobarb) = '')
    ),
    invalid_phenobarb AS (
      SELECT id, hosp_id, date_today,
        'phenobarb' AS variable,
        'Phenobarbitone prescribed field has an unrecognised value (' || phenobarb || '); expected 1 (Yes) or 0 (No)' AS issue,
        phenobarb AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND phenobarb IS NOT NULL AND TRIM(phenobarb) <> ''
        AND phenobarb NOT IN ('1','0')
    ),
    orphan_phenobarb AS (
      SELECT id, hosp_id, date_today,
        'phenobarb' AS variable,
        'Phenobarbitone prescribed flag (' || phenobarb || ') is recorded but no treatment sheet is indicated as present' AS issue,
        phenobarb AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND phenobarb IS NOT NULL AND TRIM(phenobarb) <> ''
    ),
    -- 288?289: phenobarb_start / phenobarb_stop
    missing_phenobarb_start AS (
      SELECT id, hosp_id, date_today,
        'phenobarb_start' AS variable,
        'Start date for Phenobarbitone is missing (other drugs section is open)' AS issue,
        phenobarb_start AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND phenobarb = '1'
        AND (phenobarb_start IS NULL OR TRIM(phenobarb_start) = '')
    ),
    missing_phenobarb_stop AS (
      SELECT id, hosp_id, date_today,
        'phenobarb_stop' AS variable,
        'Stop date for Phenobarbitone is missing (other drugs section is open)' AS issue,
        phenobarb_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND phenobarb = '1'
        AND (phenobarb_stop IS NULL OR TRIM(phenobarb_stop) = '')
    ),
    temporal_phenobarb AS (
      SELECT id, hosp_id, date_today,
        'phenobarb_stop' AS variable,
        'Stop date for Phenobarbitone (' || phenobarb_stop || ') is before the start date (' || phenobarb_start || '); a drug cannot be stopped before it was started' AS issue,
        phenobarb_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND phenobarb = '1'
        AND phenobarb_stop IS NOT NULL AND TRIM(phenobarb_stop) <> ''
        AND phenobarb_stop <> '1914-01-01'
        AND phenobarb_start IS NOT NULL AND TRIM(phenobarb_start) <> ''
        AND phenobarb_start <> '1914-01-01'
        AND TRY_CAST(phenobarb_stop AS DATE) < TRY_CAST(phenobarb_start AS DATE)
    ),

    -- 290: aminophylline
    missing_aminophylline AS (
      SELECT id, hosp_id, date_today,
        'aminophylline' AS variable,
        'No answer recorded for whether Aminophylline was prescribed (treatment sheet is present)' AS issue,
        aminophylline AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (aminophylline IS NULL OR TRIM(aminophylline) = '')
    ),
    invalid_aminophylline AS (
      SELECT id, hosp_id, date_today,
        'aminophylline' AS variable,
        'Aminophylline prescribed field has an unrecognised value (' || aminophylline || '); expected 1 (Yes) or 0 (No)' AS issue,
        aminophylline AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND aminophylline IS NOT NULL AND TRIM(aminophylline) <> ''
        AND aminophylline NOT IN ('1','0')
    ),
    orphan_aminophylline AS (
      SELECT id, hosp_id, date_today,
        'aminophylline' AS variable,
        'Aminophylline prescribed flag (' || aminophylline || ') is recorded but no treatment sheet is indicated as present' AS issue,
        aminophylline AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND aminophylline IS NOT NULL AND TRIM(aminophylline) <> ''
    ),
    -- 291?292
    missing_aminophylline_start AS (
      SELECT id, hosp_id, date_today,
        'aminophylline_start' AS variable,
        'Start date for Aminophylline is missing (other drugs section is open)' AS issue,
        aminophylline_start AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND aminophylline = '1'
        AND (aminophylline_start IS NULL OR TRIM(aminophylline_start) = '')
    ),
    missing_aminophylline_stop AS (
      SELECT id, hosp_id, date_today,
        'aminophylline_stop' AS variable,
        'Stop date for Aminophylline is missing (other drugs section is open)' AS issue,
        aminophylline_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND aminophylline = '1'
        AND (aminophylline_stop IS NULL OR TRIM(aminophylline_stop) = '')
    ),
    temporal_aminophylline AS (
      SELECT id, hosp_id, date_today,
        'aminophylline_stop' AS variable,
        'Stop date for Aminophylline (' || aminophylline_stop || ') is before the start date (' || aminophylline_start || '); a drug cannot be stopped before it was started' AS issue,
        aminophylline_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND aminophylline = '1'
        AND aminophylline_stop IS NOT NULL AND TRIM(aminophylline_stop) <> ''
        AND aminophylline_stop <> '1914-01-01'
        AND aminophylline_start IS NOT NULL AND TRIM(aminophylline_start) <> ''
        AND aminophylline_start <> '1914-01-01'
        AND TRY_CAST(aminophylline_stop AS DATE) < TRY_CAST(aminophylline_start AS DATE)
    ),

    -- 293: caffeine_citrate
    missing_caffeine_citrate AS (
      SELECT id, hosp_id, date_today,
        'caffeine_citrate' AS variable,
        'No answer recorded for whether Caffeine Citrate was prescribed (treatment sheet is present)' AS issue,
        caffeine_citrate AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (caffeine_citrate IS NULL OR TRIM(caffeine_citrate) = '')
    ),
    invalid_caffeine_citrate AS (
      SELECT id, hosp_id, date_today,
        'caffeine_citrate' AS variable,
        'Caffeine Citrate prescribed field has an unrecognised value (' || caffeine_citrate || '); expected 1 (Yes) or 0 (No)' AS issue,
        caffeine_citrate AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND caffeine_citrate IS NOT NULL AND TRIM(caffeine_citrate) <> ''
        AND caffeine_citrate NOT IN ('1','0')
    ),
    orphan_caffeine_citrate AS (
      SELECT id, hosp_id, date_today,
        'caffeine_citrate' AS variable,
        'Caffeine Citrate prescribed flag (' || caffeine_citrate || ') is recorded but no treatment sheet is indicated as present' AS issue,
        caffeine_citrate AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND caffeine_citrate IS NOT NULL AND TRIM(caffeine_citrate) <> ''
    ),
    -- 294?295
    missing_caffeine_start AS (
      SELECT id, hosp_id, date_today,
        'caffeine_start' AS variable,
        'Start date for Caffeine Citrate is missing (other drugs section is open)' AS issue,
        caffeine_start AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND caffeine_citrate = '1'
        AND (caffeine_start IS NULL OR TRIM(caffeine_start) = '')
    ),
    missing_caffeine_stop AS (
      SELECT id, hosp_id, date_today,
        'caffeine_stop' AS variable,
        'Stop date for Caffeine Citrate is missing (other drugs section is open)' AS issue,
        caffeine_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND caffeine_citrate = '1'
        AND (caffeine_stop IS NULL OR TRIM(caffeine_stop) = '')
    ),
    temporal_caffeine AS (
      SELECT id, hosp_id, date_today,
        'caffeine_stop' AS variable,
        'Stop date for Caffeine Citrate (' || caffeine_stop || ') is before the start date (' || caffeine_start || '); a drug cannot be stopped before it was started' AS issue,
        caffeine_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1' AND caffeine_citrate = '1'
        AND caffeine_stop IS NOT NULL AND TRIM(caffeine_stop) <> ''
        AND caffeine_stop <> '1914-01-01'
        AND caffeine_start IS NOT NULL AND TRIM(caffeine_start) <> ''
        AND caffeine_start <> '1914-01-01'
        AND TRY_CAST(caffeine_stop AS DATE) < TRY_CAST(caffeine_start AS DATE)
    ),

    -- =========================================================================
    -- 296: other_treatment ? gated by t_sheet='1'; Required; radio
    --      1=Yes, 2=No, -1=Empty
    -- =========================================================================
    missing_other_treatment AS (
      SELECT id, hosp_id, date_today,
        'other_treatment' AS variable,
        'No answer recorded for whether other drugs were prescribed on the day of admission (treatment sheet is present)' AS issue,
        other_treatment AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (other_treatment IS NULL OR TRIM(other_treatment) = '')
    ),
    invalid_other_treatment AS (
      SELECT id, hosp_id, date_today,
        'other_treatment' AS variable,
        'Other drugs on admission field has an unrecognised value (' || other_treatment || '); expected 1 (Yes), 2 (No), or -1 (Empty)' AS issue,
        other_treatment AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND other_treatment IS NOT NULL AND TRIM(other_treatment) <> ''
        AND other_treatment NOT IN ('1','2','-1')
    ),

    -- =========================================================================
    -- 297?311: other_drugs_1 through other_drugs_5 with start/stop dates
    -- Gate: other_treatment='1'
    -- drug_N text: at least other_drugs_1 required; sequential population
    -- start/stop: required per drug_N populated; stop >= start
    -- =========================================================================
    missing_other_drugs_1 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_1' AS variable,
        'Other drug 1 name is missing (other drugs on admission were indicated as present)' AS issue,
        other_drugs_1 AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND (other_drugs_1 IS NULL OR TRIM(other_drugs_1) = '')
    ),
    orphan_other_drugs_1 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_1' AS variable,
        'Other drug 1 name (' || other_drugs_1 || ') is recorded but the other drugs on admission flag is not set to Yes' AS issue,
        other_drugs_1 AS current_value
      FROM neonatal_core
      WHERE (other_treatment IS NULL OR other_treatment <> '1')
        AND other_drugs_1 IS NOT NULL AND TRIM(other_drugs_1) <> ''
    ),
    temporal_other_drugs_1 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_1_stop' AS variable,
        'Stop date for other drug 1 (' || other_drugs_1_stop || ') is before the start date (' || other_drugs_1_start || ')' AS issue,
        other_drugs_1_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_1_stop IS NOT NULL AND TRIM(other_drugs_1_stop) <> ''
        AND other_drugs_1_stop <> '1914-01-01'
        AND other_drugs_1_start IS NOT NULL AND TRIM(other_drugs_1_start) <> ''
        AND other_drugs_1_start <> '1914-01-01'
        AND TRY_CAST(other_drugs_1_stop AS DATE) < TRY_CAST(other_drugs_1_start AS DATE)
    ),
    -- _2
    seq_other_drugs_2 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_2' AS variable,
        'Other drug 2 (' || other_drugs_2 || ') is recorded but other drug 1 is empty; drugs should be entered sequentially' AS issue,
        other_drugs_2 AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_2 IS NOT NULL AND TRIM(other_drugs_2) <> ''
        AND (other_drugs_1 IS NULL OR TRIM(other_drugs_1) = '')
    ),
    orphan_other_drugs_2 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_2' AS variable,
        'Other drug 2 name (' || other_drugs_2 || ') is recorded but the other drugs on admission flag is not set to Yes' AS issue,
        other_drugs_2 AS current_value
      FROM neonatal_core
      WHERE (other_treatment IS NULL OR other_treatment <> '1')
        AND other_drugs_2 IS NOT NULL AND TRIM(other_drugs_2) <> ''
    ),
    temporal_other_drugs_2 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_2_stop' AS variable,
        'Stop date for other drug 2 (' || other_drugs_2_stop || ') is before the start date (' || other_drugs_2_start || ')' AS issue,
        other_drugs_2_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_2_stop IS NOT NULL AND TRIM(other_drugs_2_stop) <> ''
        AND other_drugs_2_stop <> '1914-01-01'
        AND other_drugs_2_start IS NOT NULL AND TRIM(other_drugs_2_start) <> ''
        AND other_drugs_2_start <> '1914-01-01'
        AND TRY_CAST(other_drugs_2_stop AS DATE) < TRY_CAST(other_drugs_2_start AS DATE)
    ),
    -- _3
    seq_other_drugs_3 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_3' AS variable,
        'Other drug 3 (' || other_drugs_3 || ') is recorded but other drug 2 is empty; drugs should be entered sequentially' AS issue,
        other_drugs_3 AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_3 IS NOT NULL AND TRIM(other_drugs_3) <> ''
        AND (other_drugs_2 IS NULL OR TRIM(other_drugs_2) = '')
    ),
    orphan_other_drugs_3 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_3' AS variable,
        'Other drug 3 name (' || other_drugs_3 || ') is recorded but the other drugs on admission flag is not set to Yes' AS issue,
        other_drugs_3 AS current_value
      FROM neonatal_core
      WHERE (other_treatment IS NULL OR other_treatment <> '1')
        AND other_drugs_3 IS NOT NULL AND TRIM(other_drugs_3) <> ''
    ),
    temporal_other_drugs_3 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_3_stop' AS variable,
        'Stop date for other drug 3 (' || other_drugs_3_stop || ') is before the start date (' || other_drugs_3_start || ')' AS issue,
        other_drugs_3_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_3_stop IS NOT NULL AND TRIM(other_drugs_3_stop) <> ''
        AND other_drugs_3_stop <> '1914-01-01'
        AND other_drugs_3_start IS NOT NULL AND TRIM(other_drugs_3_start) <> ''
        AND other_drugs_3_start <> '1914-01-01'
        AND TRY_CAST(other_drugs_3_stop AS DATE) < TRY_CAST(other_drugs_3_start AS DATE)
    ),
    -- _4
    seq_other_drugs_4 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_4' AS variable,
        'Other drug 4 (' || other_drugs_4 || ') is recorded but other drug 3 is empty; drugs should be entered sequentially' AS issue,
        other_drugs_4 AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_4 IS NOT NULL AND TRIM(other_drugs_4) <> ''
        AND (other_drugs_3 IS NULL OR TRIM(other_drugs_3) = '')
    ),
    orphan_other_drugs_4 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_4' AS variable,
        'Other drug 4 name (' || other_drugs_4 || ') is recorded but the other drugs on admission flag is not set to Yes' AS issue,
        other_drugs_4 AS current_value
      FROM neonatal_core
      WHERE (other_treatment IS NULL OR other_treatment <> '1')
        AND other_drugs_4 IS NOT NULL AND TRIM(other_drugs_4) <> ''
    ),
    temporal_other_drugs_4 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_4_stop' AS variable,
        'Stop date for other drug 4 (' || other_drugs_4_stop || ') is before the start date (' || other_drugs_4_start || ')' AS issue,
        other_drugs_4_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_4_stop IS NOT NULL AND TRIM(other_drugs_4_stop) <> ''
        AND other_drugs_4_stop <> '1914-01-01'
        AND other_drugs_4_start IS NOT NULL AND TRIM(other_drugs_4_start) <> ''
        AND other_drugs_4_start <> '1914-01-01'
        AND TRY_CAST(other_drugs_4_stop AS DATE) < TRY_CAST(other_drugs_4_start AS DATE)
    ),
    -- _5
    seq_other_drugs_5 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_5' AS variable,
        'Other drug 5 (' || other_drugs_5 || ') is recorded but other drug 4 is empty; drugs should be entered sequentially' AS issue,
        other_drugs_5 AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_5 IS NOT NULL AND TRIM(other_drugs_5) <> ''
        AND (other_drugs_4 IS NULL OR TRIM(other_drugs_4) = '')
    ),
    orphan_other_drugs_5 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_5' AS variable,
        'Other drug 5 name (' || other_drugs_5 || ') is recorded but the other drugs on admission flag is not set to Yes' AS issue,
        other_drugs_5 AS current_value
      FROM neonatal_core
      WHERE (other_treatment IS NULL OR other_treatment <> '1')
        AND other_drugs_5 IS NOT NULL AND TRIM(other_drugs_5) <> ''
    ),
    temporal_other_drugs_5 AS (
      SELECT id, hosp_id, date_today,
        'other_drugs_5_stop' AS variable,
        'Stop date for other drug 5 (' || other_drugs_5_stop || ') is before the start date (' || other_drugs_5_start || ')' AS issue,
        other_drugs_5_stop AS current_value
      FROM neonatal_core
      WHERE other_treatment = '1'
        AND other_drugs_5_stop IS NOT NULL AND TRIM(other_drugs_5_stop) <> ''
        AND other_drugs_5_stop <> '1914-01-01'
        AND other_drugs_5_start IS NOT NULL AND TRIM(other_drugs_5_start) <> ''
        AND other_drugs_5_start <> '1914-01-01'
        AND TRY_CAST(other_drugs_5_stop AS DATE) < TRY_CAST(other_drugs_5_start AS DATE)
    ),

    -- =========================================================================
    -- 312: other_treatment_2 ? gate: is_minimum='0' AND t_sheet='1'; Required
    --      yesno: 1=Yes, 0=No
    -- =========================================================================
    missing_other_treatment_2 AS (
      SELECT id, hosp_id, date_today,
        'other_treatment_2' AS variable,
        'No answer recorded for whether there are drugs not in the lookup list (non-minimum dataset with treatment sheet present)' AS issue,
        other_treatment_2 AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND t_sheet = '1'
        AND (other_treatment_2 IS NULL OR TRIM(other_treatment_2) = '')
    ),
    invalid_other_treatment_2 AS (
      SELECT id, hosp_id, date_today,
        'other_treatment_2' AS variable,
        'Drugs not in lookup list field has an unrecognised value (' || other_treatment_2 || '); expected 1 (Yes) or 0 (No)' AS issue,
        other_treatment_2 AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND t_sheet = '1'
        AND other_treatment_2 IS NOT NULL AND TRIM(other_treatment_2) <> ''
        AND other_treatment_2 NOT IN ('1','0')
    ),

    -- 313: admisn_dx_not_listed ? gated by other_treatment_2='1'; Required
    missing_admisn_dx_not_listed AS (
      SELECT id, hosp_id, date_today,
        'admisn_dx_not_listed' AS variable,
        'List of drugs not in the lookup list is missing (field is marked required when unlisted drugs are indicated)' AS issue,
        admisn_dx_not_listed AS current_value
      FROM neonatal_core
      WHERE other_treatment_2 = '1'
        AND (admisn_dx_not_listed IS NULL OR TRIM(admisn_dx_not_listed) = '')
    ),
    orphan_admisn_dx_not_listed AS (
      SELECT id, hosp_id, date_today,
        'admisn_dx_not_listed' AS variable,
        'List of drugs not in lookup list (' || admisn_dx_not_listed || ') is recorded but the unlisted drugs flag is not set to Yes' AS issue,
        admisn_dx_not_listed AS current_value
      FROM neonatal_core
      WHERE (other_treatment_2 IS NULL OR other_treatment_2 <> '1')
        AND admisn_dx_not_listed IS NOT NULL AND TRIM(admisn_dx_not_listed) <> ''
    ),

    -- =========================================================================
    -- SECTION 8.3: drugs prescribed after the day of admission
    -- 314: drugs ? gated by t_sheet='1'; Required; yesno
    -- 315?344: drugs_1 through drugs_10 with start/stop dates
    --          gated by drugs='1'; sequential population enforced
    -- 345: other_post_admission_drugs ? gated by drugs='1'; notes (free text)
    -- =========================================================================
    missing_drugs AS (
      SELECT id, hosp_id, date_today,
        'drugs' AS variable,
        'No answer recorded for whether drugs were prescribed after the day of admission (treatment sheet is present)' AS issue,
        drugs AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND (drugs IS NULL OR TRIM(drugs) = '')
    ),
    invalid_drugs AS (
      SELECT id, hosp_id, date_today,
        'drugs' AS variable,
        'Drugs after admission field has an unrecognised value (' || drugs || '); expected 1 (Yes) or 0 (No)' AS issue,
        drugs AS current_value
      FROM neonatal_core
      WHERE t_sheet = '1'
        AND drugs IS NOT NULL AND TRIM(drugs) <> ''
        AND drugs NOT IN ('1','0')
    ),
    orphan_drugs AS (
      SELECT id, hosp_id, date_today,
        'drugs' AS variable,
        'Post-admission drugs flag (' || drugs || ') is recorded but no treatment sheet is indicated as present' AS issue,
        drugs AS current_value
      FROM neonatal_core
      WHERE (t_sheet IS NULL OR t_sheet <> '1')
        AND drugs IS NOT NULL AND TRIM(drugs) <> ''
    ),

    -- drugs_1 (required when gate open)
    missing_drugs_1 AS (
      SELECT id, hosp_id, date_today,
        'drugs_1' AS variable,
        'Post-admission drug 1 name is missing (drugs after admission were indicated as present)' AS issue,
        drugs_1 AS current_value
      FROM neonatal_core
      WHERE drugs = '1'
        AND (drugs_1 IS NULL OR TRIM(drugs_1) = '')
    ),
    orphan_drugs_1 AS (
      SELECT id, hosp_id, date_today,
        'drugs_1' AS variable,
        'Post-admission drug 1 name (' || drugs_1 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_1 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1')
        AND drugs_1 IS NOT NULL AND TRIM(drugs_1) <> ''
    ),
    temporal_drugs_1 AS (
      SELECT id, hosp_id, date_today,
        'drugs_1_stop' AS variable,
        'Stop date for post-admission drug 1 (' || drugs_1_stop || ') is before the start date (' || drugs_1_start || ')' AS issue,
        drugs_1_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1'
        AND drugs_1_stop IS NOT NULL AND TRIM(drugs_1_stop) <> ''
        AND drugs_1_stop <> '1914-01-01'
        AND drugs_1_start IS NOT NULL AND TRIM(drugs_1_start) <> ''
        AND drugs_1_start <> '1914-01-01'
        AND TRY_CAST(drugs_1_stop AS DATE) < TRY_CAST(drugs_1_start AS DATE)
    ),

    -- drugs_2?drugs_10 (sequential, orphan, temporal) --
    -- _2
    seq_drugs_2 AS (
      SELECT id, hosp_id, date_today, 'drugs_2' AS variable,
        'Post-admission drug 2 (' || drugs_2 || ') is recorded but drug 1 is empty; drugs should be entered sequentially' AS issue,
        drugs_2 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_2 IS NOT NULL AND TRIM(drugs_2) <> ''
        AND (drugs_1 IS NULL OR TRIM(drugs_1) = '')
    ),
    orphan_drugs_2 AS (
      SELECT id, hosp_id, date_today, 'drugs_2' AS variable,
        'Post-admission drug 2 (' || drugs_2 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_2 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_2 IS NOT NULL AND TRIM(drugs_2) <> ''
    ),
    temporal_drugs_2 AS (
      SELECT id, hosp_id, date_today, 'drugs_2_stop' AS variable,
        'Stop date for post-admission drug 2 (' || drugs_2_stop || ') is before the start date (' || drugs_2_start || ')' AS issue,
        drugs_2_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_2_stop IS NOT NULL AND TRIM(drugs_2_stop) <> ''
        AND drugs_2_stop <> '1914-01-01' AND drugs_2_start IS NOT NULL AND TRIM(drugs_2_start) <> ''
        AND drugs_2_start <> '1914-01-01'
        AND TRY_CAST(drugs_2_stop AS DATE) < TRY_CAST(drugs_2_start AS DATE)
    ),
    -- _3
    seq_drugs_3 AS (
      SELECT id, hosp_id, date_today, 'drugs_3' AS variable,
        'Post-admission drug 3 (' || drugs_3 || ') is recorded but drug 2 is empty; drugs should be entered sequentially' AS issue,
        drugs_3 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_3 IS NOT NULL AND TRIM(drugs_3) <> ''
        AND (drugs_2 IS NULL OR TRIM(drugs_2) = '')
    ),
    orphan_drugs_3 AS (
      SELECT id, hosp_id, date_today, 'drugs_3' AS variable,
        'Post-admission drug 3 (' || drugs_3 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_3 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_3 IS NOT NULL AND TRIM(drugs_3) <> ''
    ),
    temporal_drugs_3 AS (
      SELECT id, hosp_id, date_today, 'drugs_3_stop' AS variable,
        'Stop date for post-admission drug 3 (' || drugs_3_stop || ') is before the start date (' || drugs_3_start || ')' AS issue,
        drugs_3_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_3_stop IS NOT NULL AND TRIM(drugs_3_stop) <> ''
        AND drugs_3_stop <> '1914-01-01' AND drugs_3_start IS NOT NULL AND TRIM(drugs_3_start) <> ''
        AND drugs_3_start <> '1914-01-01'
        AND TRY_CAST(drugs_3_stop AS DATE) < TRY_CAST(drugs_3_start AS DATE)
    ),
    -- _4
    seq_drugs_4 AS (
      SELECT id, hosp_id, date_today, 'drugs_4' AS variable,
        'Post-admission drug 4 (' || drugs_4 || ') is recorded but drug 3 is empty; drugs should be entered sequentially' AS issue,
        drugs_4 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_4 IS NOT NULL AND TRIM(drugs_4) <> ''
        AND (drugs_3 IS NULL OR TRIM(drugs_3) = '')
    ),
    orphan_drugs_4 AS (
      SELECT id, hosp_id, date_today, 'drugs_4' AS variable,
        'Post-admission drug 4 (' || drugs_4 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_4 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_4 IS NOT NULL AND TRIM(drugs_4) <> ''
    ),
    temporal_drugs_4 AS (
      SELECT id, hosp_id, date_today, 'drugs_4_stop' AS variable,
        'Stop date for post-admission drug 4 (' || drugs_4_stop || ') is before the start date (' || drugs_4_start || ')' AS issue,
        drugs_4_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_4_stop IS NOT NULL AND TRIM(drugs_4_stop) <> ''
        AND drugs_4_stop <> '1914-01-01' AND drugs_4_start IS NOT NULL AND TRIM(drugs_4_start) <> ''
        AND drugs_4_start <> '1914-01-01'
        AND TRY_CAST(drugs_4_stop AS DATE) < TRY_CAST(drugs_4_start AS DATE)
    ),
    -- _5
    seq_drugs_5 AS (
      SELECT id, hosp_id, date_today, 'drugs_5' AS variable,
        'Post-admission drug 5 (' || drugs_5 || ') is recorded but drug 4 is empty; drugs should be entered sequentially' AS issue,
        drugs_5 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_5 IS NOT NULL AND TRIM(drugs_5) <> ''
        AND (drugs_4 IS NULL OR TRIM(drugs_4) = '')
    ),
    orphan_drugs_5 AS (
      SELECT id, hosp_id, date_today, 'drugs_5' AS variable,
        'Post-admission drug 5 (' || drugs_5 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_5 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_5 IS NOT NULL AND TRIM(drugs_5) <> ''
    ),
    temporal_drugs_5 AS (
      SELECT id, hosp_id, date_today, 'drugs_5_stop' AS variable,
        'Stop date for post-admission drug 5 (' || drugs_5_stop || ') is before the start date (' || drugs_5_start || ')' AS issue,
        drugs_5_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_5_stop IS NOT NULL AND TRIM(drugs_5_stop) <> ''
        AND drugs_5_stop <> '1914-01-01' AND drugs_5_start IS NOT NULL AND TRIM(drugs_5_start) <> ''
        AND drugs_5_start <> '1914-01-01'
        AND TRY_CAST(drugs_5_stop AS DATE) < TRY_CAST(drugs_5_start AS DATE)
    ),
    -- _6
    seq_drugs_6 AS (
      SELECT id, hosp_id, date_today, 'drugs_6' AS variable,
        'Post-admission drug 6 (' || drugs_6 || ') is recorded but drug 5 is empty; drugs should be entered sequentially' AS issue,
        drugs_6 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_6 IS NOT NULL AND TRIM(drugs_6) <> ''
        AND (drugs_5 IS NULL OR TRIM(drugs_5) = '')
    ),
    orphan_drugs_6 AS (
      SELECT id, hosp_id, date_today, 'drugs_6' AS variable,
        'Post-admission drug 6 (' || drugs_6 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_6 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_6 IS NOT NULL AND TRIM(drugs_6) <> ''
    ),
    temporal_drugs_6 AS (
      SELECT id, hosp_id, date_today, 'drugs_6_stop' AS variable,
        'Stop date for post-admission drug 6 (' || drugs_6_stop || ') is before the start date (' || drugs_6_start || ')' AS issue,
        drugs_6_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_6_stop IS NOT NULL AND TRIM(drugs_6_stop) <> ''
        AND drugs_6_stop <> '1914-01-01' AND drugs_6_start IS NOT NULL AND TRIM(drugs_6_start) <> ''
        AND drugs_6_start <> '1914-01-01'
        AND TRY_CAST(drugs_6_stop AS DATE) < TRY_CAST(drugs_6_start AS DATE)
    ),
    -- _7
    seq_drugs_7 AS (
      SELECT id, hosp_id, date_today, 'drugs_7' AS variable,
        'Post-admission drug 7 (' || drugs_7 || ') is recorded but drug 6 is empty; drugs should be entered sequentially' AS issue,
        drugs_7 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_7 IS NOT NULL AND TRIM(drugs_7) <> ''
        AND (drugs_6 IS NULL OR TRIM(drugs_6) = '')
    ),
    orphan_drugs_7 AS (
      SELECT id, hosp_id, date_today, 'drugs_7' AS variable,
        'Post-admission drug 7 (' || drugs_7 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_7 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_7 IS NOT NULL AND TRIM(drugs_7) <> ''
    ),
    temporal_drugs_7 AS (
      SELECT id, hosp_id, date_today, 'drugs_7_stop' AS variable,
        'Stop date for post-admission drug 7 (' || drugs_7_stop || ') is before the start date (' || drugs_7_start || ')' AS issue,
        drugs_7_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_7_stop IS NOT NULL AND TRIM(drugs_7_stop) <> ''
        AND drugs_7_stop <> '1914-01-01' AND drugs_7_start IS NOT NULL AND TRIM(drugs_7_start) <> ''
        AND drugs_7_start <> '1914-01-01'
        AND TRY_CAST(drugs_7_stop AS DATE) < TRY_CAST(drugs_7_start AS DATE)
    ),
    -- _8
    seq_drugs_8 AS (
      SELECT id, hosp_id, date_today, 'drugs_8' AS variable,
        'Post-admission drug 8 (' || drugs_8 || ') is recorded but drug 7 is empty; drugs should be entered sequentially' AS issue,
        drugs_8 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_8 IS NOT NULL AND TRIM(drugs_8) <> ''
        AND (drugs_7 IS NULL OR TRIM(drugs_7) = '')
    ),
    orphan_drugs_8 AS (
      SELECT id, hosp_id, date_today, 'drugs_8' AS variable,
        'Post-admission drug 8 (' || drugs_8 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_8 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_8 IS NOT NULL AND TRIM(drugs_8) <> ''
    ),
    temporal_drugs_8 AS (
      SELECT id, hosp_id, date_today, 'drugs_8_stop' AS variable,
        'Stop date for post-admission drug 8 (' || drugs_8_stop || ') is before the start date (' || drugs_8_start || ')' AS issue,
        drugs_8_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_8_stop IS NOT NULL AND TRIM(drugs_8_stop) <> ''
        AND drugs_8_stop <> '1914-01-01' AND drugs_8_start IS NOT NULL AND TRIM(drugs_8_start) <> ''
        AND drugs_8_start <> '1914-01-01'
        AND TRY_CAST(drugs_8_stop AS DATE) < TRY_CAST(drugs_8_start AS DATE)
    ),
    -- _9
    seq_drugs_9 AS (
      SELECT id, hosp_id, date_today, 'drugs_9' AS variable,
        'Post-admission drug 9 (' || drugs_9 || ') is recorded but drug 8 is empty; drugs should be entered sequentially' AS issue,
        drugs_9 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_9 IS NOT NULL AND TRIM(drugs_9) <> ''
        AND (drugs_8 IS NULL OR TRIM(drugs_8) = '')
    ),
    orphan_drugs_9 AS (
      SELECT id, hosp_id, date_today, 'drugs_9' AS variable,
        'Post-admission drug 9 (' || drugs_9 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_9 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_9 IS NOT NULL AND TRIM(drugs_9) <> ''
    ),
    temporal_drugs_9 AS (
      SELECT id, hosp_id, date_today, 'drugs_9_stop' AS variable,
        'Stop date for post-admission drug 9 (' || drugs_9_stop || ') is before the start date (' || drugs_9_start || ')' AS issue,
        drugs_9_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_9_stop IS NOT NULL AND TRIM(drugs_9_stop) <> ''
        AND drugs_9_stop <> '1914-01-01' AND drugs_9_start IS NOT NULL AND TRIM(drugs_9_start) <> ''
        AND drugs_9_start <> '1914-01-01'
        AND TRY_CAST(drugs_9_stop AS DATE) < TRY_CAST(drugs_9_start AS DATE)
    ),
    -- _10
    seq_drugs_10 AS (
      SELECT id, hosp_id, date_today, 'drugs_10' AS variable,
        'Post-admission drug 10 (' || drugs_10 || ') is recorded but drug 9 is empty; drugs should be entered sequentially' AS issue,
        drugs_10 AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_10 IS NOT NULL AND TRIM(drugs_10) <> ''
        AND (drugs_9 IS NULL OR TRIM(drugs_9) = '')
    ),
    orphan_drugs_10 AS (
      SELECT id, hosp_id, date_today, 'drugs_10' AS variable,
        'Post-admission drug 10 (' || drugs_10 || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        drugs_10 AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1') AND drugs_10 IS NOT NULL AND TRIM(drugs_10) <> ''
    ),
    temporal_drugs_10 AS (
      SELECT id, hosp_id, date_today, 'drugs_10_stop' AS variable,
        'Stop date for post-admission drug 10 (' || drugs_10_stop || ') is before the start date (' || drugs_10_start || ')' AS issue,
        drugs_10_stop AS current_value
      FROM neonatal_core
      WHERE drugs = '1' AND drugs_10_stop IS NOT NULL AND TRIM(drugs_10_stop) <> ''
        AND drugs_10_stop <> '1914-01-01' AND drugs_10_start IS NOT NULL AND TRIM(drugs_10_start) <> ''
        AND drugs_10_start <> '1914-01-01'
        AND TRY_CAST(drugs_10_stop AS DATE) < TRY_CAST(drugs_10_start AS DATE)
    ),

    -- 345: other_post_admission_drugs ? gated by drugs='1'; free-text notes
    --      optional but orphan-checked
    orphan_other_post_admission_drugs AS (
      SELECT id, hosp_id, date_today,
        'other_post_admission_drugs' AS variable,
        'Other post-admission drugs text (' || other_post_admission_drugs || ') is recorded but the post-admission drugs flag is not set to Yes' AS issue,
        other_post_admission_drugs AS current_value
      FROM neonatal_core
      WHERE (drugs IS NULL OR drugs <> '1')
        AND other_post_admission_drugs IS NOT NULL AND TRIM(other_post_admission_drugs) <> ''
    ),


        -- =========================================================================
    -- SUPPORTIVE CARE SECTION DQA (fields 347?398,
    -- instrument: supportive_care)
    -- =========================================================================

    -- =========================================================================
    -- GATE SUMMARY
    --   347  oxygen_ordered   : always visible; Required
    --   348  cpap             : always visible; Required
    --   349?356              : cpap='1'  (+ sub-conditions for time fields)
    --   357  mechanical_ventilation : cpap='1' AND cpap='0' ? CONTRADICTORY; EXCLUDED
    --   358  blood_transfusion_prescrib: is_minimum='0'; Required
    --   359  blood_transf_pres_date    : blood_transfusion_prescrib='1'
    --   360  blood_transfussion_given  : blood_transfusion_prescrib='1' AND is_minimum='0'
    --   361  exchange_transfusion      : blood_transfusion_prescrib='1'
    --   362  fluid_feed_monitoring_chart: date_of_birth >= date_adm; Required
    --   363?366: fluid_feed_monitoring_chart='1' AND is_minimum='0'; @HIDDEN
    --   367  other_fluid      : is_minimum='0' AND fluid_feed_monitoring_chart='1'; Required; @HIDDEN
    --   368?370: other_fluid='1' AND is_minimum='0'; @HIDDEN
    --   371  other_fluid_2    : is_minimum='0' AND other_fluid='1'; @HIDDEN
    --   372?374: other_fluid_2='1'; @HIDDEN
    --   375  fluids_presc_next_day : is_minimum='0'; @HIDDEN
    --   376  total_fluids_next_day : is_minimum='0' AND fluids_presc_next_day='1'; @HIDDEN
    --   377  child_prescribed_with_feed: always visible; Required; @HIDDEN
    --   378?379,382?384: child_prescribed_with_feed='1' AND is_minimum='0'; @HIDDEN
    --   380  other_feeds      : type_of_feeds='5' AND child_prescribed_with_feed='1' AND is_minimum='0'; @HIDDEN
    --   381  time_to_start_feeds: is_minimum='0' AND is_minimum='1' ? CONTRADICTORY; EXCLUDED
    --   385  date_feeds_only_presc: (child_prescribed_with_feed='1' OR fluid_feed_monitoring_chart='1')
    --                               AND is_minimum='0'; @HIDDEN
    --   386  feeds_presc_next_day: child_prescribed_with_feed='1' OR ='0' (always visible); @HIDDEN
    --   387  date_feeds_first_presc: child_prescribed_with_feed='0' AND feeds_presc_next_day='0';
    --                                Required; @HIDDEN
    --   388?389,391: feeds_presc_next_day='1'; @HIDDEN
    --   390  freq_of_administration_2: feeds_presc_next_day='1' AND is_minimum='0'
    --                                  AND hosp_id IN ('17','53','54','72'); @HIDDEN
    --   392  total_input      : complex OR gate; @HIDDEN
    --   393  baby_breastfeeding: always visible; Required; @HIDDEN
    --   394  phototherapy     : always visible; Required
    --   395  photo_therapy_on_any_other: phototherapy='2'; Required
    --   396  start_date_phototherapy: photo_therapy_on_any_other='1'; Required
    --   397  stop_date_phototherapy : photo_therapy_on_any_other='1' OR phototherapy='1'; Required
    --   398  k_mother_care    : always visible; Required
    --
    -- EXCLUDED (contradictory visibility logic):
    --   357  mechanical_ventilation (cpap='1' AND cpap='0')
    --   381  time_to_start_feeds (is_minimum='0' AND is_minimum='1')
    -- =========================================================================

    -- =========================================================================
    -- 347: oxygen_ordered ? always visible; Required; yesno
    -- =========================================================================
    missing_oxygen_ordered AS (
      SELECT id, hosp_id, date_today,
        'oxygen_ordered' AS variable,
        'No answer recorded for whether oxygen was prescribed on the admission day (field is always required)' AS issue,
        oxygen_ordered AS current_value
      FROM neonatal_core
      WHERE (oxygen_ordered IS NULL OR TRIM(oxygen_ordered) = '')
    ),
    invalid_oxygen_ordered AS (
      SELECT id, hosp_id, date_today,
        'oxygen_ordered' AS variable,
        'Oxygen prescribed on admission day has an unrecognised value (' || oxygen_ordered || '); expected 1 (Yes) or 0 (No)' AS issue,
        oxygen_ordered AS current_value
      FROM neonatal_core
      WHERE oxygen_ordered IS NOT NULL AND TRIM(oxygen_ordered) <> ''
        AND oxygen_ordered NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 348: cpap ? always visible; Required; radio 1/0/-1
    -- =========================================================================
    missing_cpap AS (
      SELECT id, hosp_id, date_today,
        'cpap' AS variable,
        'No answer recorded for whether CPAP was done (field is always required)' AS issue,
        cpap AS current_value
      FROM neonatal_core
      WHERE (cpap IS NULL OR TRIM(cpap) = '')
    ),
    invalid_cpap AS (
      SELECT id, hosp_id, date_today,
        'cpap' AS variable,
        'CPAP field has an unrecognised value (' || cpap || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        cpap AS current_value
      FROM neonatal_core
      WHERE cpap IS NOT NULL AND TRIM(cpap) <> ''
        AND cpap NOT IN ('1','0','-1')
    ),

    -- =========================================================================
    -- 349: cpap_start ? gate: cpap='1'; Required; date text
    --      placeholder 1914-01-01 is valid
    -- =========================================================================
    missing_cpap_start AS (
      SELECT id, hosp_id, date_today,
        'cpap_start' AS variable,
        'CPAP start date is missing (CPAP is marked as done; field is required)' AS issue,
        cpap_start AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND (cpap_start IS NULL OR TRIM(cpap_start) = '')
    ),
    orphan_cpap_start AS (
      SELECT id, hosp_id, date_today,
        'cpap_start' AS variable,
        'CPAP start date (' || cpap_start || ') is recorded but CPAP is not marked as done' AS issue,
        cpap_start AS current_value
      FROM neonatal_core
      WHERE (cpap IS NULL OR cpap <> '1')
        AND cpap_start IS NOT NULL AND TRIM(cpap_start) <> ''
    ),

    -- =========================================================================
    -- 350: cpap_start_time ? gate: cpap='1'; @HIDDEN; Required
    --      Field is @HIDDEN (suppressed in UI); treat as excluded from DQA
    --      to avoid spurious missingness flags on a hidden field.
    --      Orphan check only for data integrity.
    -- =========================================================================
    orphan_cpap_start_time AS (
      SELECT id, hosp_id, date_today,
        'cpap_start_time' AS variable,
        'CPAP start time (legacy hidden field) (' || cpap_start_time || ') is recorded but CPAP is not marked as done' AS issue,
        cpap_start_time AS current_value
      FROM neonatal_core
      WHERE (cpap IS NULL OR cpap <> '1')
        AND cpap_start_time IS NOT NULL AND TRIM(cpap_start_time) <> ''
    ),

    -- =========================================================================
    -- 351: is_cpap_start_t_doc ? gate: cpap='1'; Required; yesno
    -- =========================================================================
    missing_is_cpap_start_t_doc AS (
      SELECT id, hosp_id, date_today,
        'is_cpap_start_t_doc' AS variable,
        'No answer recorded for whether CPAP start time is documented (CPAP is marked as done)' AS issue,
        is_cpap_start_t_doc AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND (is_cpap_start_t_doc IS NULL OR TRIM(is_cpap_start_t_doc) = '')
    ),
    invalid_is_cpap_start_t_doc AS (
      SELECT id, hosp_id, date_today,
        'is_cpap_start_t_doc' AS variable,
        'CPAP start time documented field has an unrecognised value (' || is_cpap_start_t_doc || '); expected 1 (Yes) or 0 (No)' AS issue,
        is_cpap_start_t_doc AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND is_cpap_start_t_doc IS NOT NULL AND TRIM(is_cpap_start_t_doc) <> ''
        AND is_cpap_start_t_doc NOT IN ('1','0')
    ),
    orphan_is_cpap_start_t_doc AS (
      SELECT id, hosp_id, date_today,
        'is_cpap_start_t_doc' AS variable,
        'CPAP start time documented flag (' || is_cpap_start_t_doc || ') is recorded but CPAP is not marked as done' AS issue,
        is_cpap_start_t_doc AS current_value
      FROM neonatal_core
      WHERE (cpap IS NULL OR cpap <> '1')
        AND is_cpap_start_t_doc IS NOT NULL AND TRIM(is_cpap_start_t_doc) <> ''
    ),

    -- =========================================================================
    -- 352: cpap_start_time_new
    --      gate: cpap='1' AND cpap_start != '1914-01-01' AND is_cpap_start_t_doc='1'
    --      Required; @HIDEBUTTON; -1 if empty
    -- =========================================================================
    missing_cpap_start_time_new AS (
      SELECT id, hosp_id, date_today,
        'cpap_start_time_new' AS variable,
        'CPAP start time is missing (CPAP done, start date is not a placeholder, and start time is documented as recorded)' AS issue,
        cpap_start_time_new AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND cpap_start IS NOT NULL AND TRIM(cpap_start) <> ''
        AND cpap_start <> '1914-01-01'
        AND is_cpap_start_t_doc = '1'
        AND (cpap_start_time_new IS NULL OR TRIM(cpap_start_time_new) = '')
    ),
    orphan_cpap_start_time_new AS (
      SELECT id, hosp_id, date_today,
        'cpap_start_time_new' AS variable,
        'CPAP start time (' || cpap_start_time_new || ') is recorded but the required gate conditions are not met (CPAP not done, placeholder start date, or start time not documented)' AS issue,
        cpap_start_time_new AS current_value
      FROM neonatal_core
      WHERE NOT (cpap = '1'
          AND cpap_start IS NOT NULL AND TRIM(cpap_start) <> ''
          AND cpap_start <> '1914-01-01'
          AND is_cpap_start_t_doc = '1')
        AND cpap_start_time_new IS NOT NULL AND TRIM(cpap_start_time_new) <> ''
    ),

    -- =========================================================================
    -- 353: cpap_stop ? gate: cpap='1'; Required; date text
    --      placeholder 1914-01-01 valid
    -- =========================================================================
    missing_cpap_stop AS (
      SELECT id, hosp_id, date_today,
        'cpap_stop' AS variable,
        'CPAP end date is missing (CPAP is marked as done; field is required)' AS issue,
        cpap_stop AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND (cpap_stop IS NULL OR TRIM(cpap_stop) = '')
    ),
    temporal_cpap_stop AS (
      SELECT id, hosp_id, date_today,
        'cpap_stop' AS variable,
        'CPAP end date (' || cpap_stop || ') is before the CPAP start date (' || cpap_start || '); CPAP cannot end before it begins' AS issue,
        cpap_stop AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND cpap_stop IS NOT NULL AND TRIM(cpap_stop) <> ''
        AND cpap_stop <> '1914-01-01'
        AND cpap_start IS NOT NULL AND TRIM(cpap_start) <> ''
        AND cpap_start <> '1914-01-01'
        AND TRY_CAST(cpap_stop AS DATE) < TRY_CAST(cpap_start AS DATE)
    ),
    orphan_cpap_stop AS (
      SELECT id, hosp_id, date_today,
        'cpap_stop' AS variable,
        'CPAP end date (' || cpap_stop || ') is recorded but CPAP is not marked as done' AS issue,
        cpap_stop AS current_value
      FROM neonatal_core
      WHERE (cpap IS NULL OR cpap <> '1')
        AND cpap_stop IS NOT NULL AND TRIM(cpap_stop) <> ''
    ),

    -- =========================================================================
    -- 354: cpap_end_time ? gate: cpap='1' AND cpap_stop != '1914-01-01'; @HIDDEN; Required
    --      Hidden field; orphan check only
    -- =========================================================================
    orphan_cpap_end_time AS (
      SELECT id, hosp_id, date_today,
        'cpap_end_time' AS variable,
        'CPAP end time (legacy hidden field) (' || cpap_end_time || ') is recorded but the gate conditions are not met' AS issue,
        cpap_end_time AS current_value
      FROM neonatal_core
      WHERE NOT (cpap = '1'
          AND cpap_stop IS NOT NULL AND TRIM(cpap_stop) <> ''
          AND cpap_stop <> '1914-01-01')
        AND cpap_end_time IS NOT NULL AND TRIM(cpap_end_time) <> ''
    ),

    -- =========================================================================
    -- 355: is_cpap_end_t_doc ? gate: cpap='1'; Required; yesno
    -- =========================================================================
    missing_is_cpap_end_t_doc AS (
      SELECT id, hosp_id, date_today,
        'is_cpap_end_t_doc' AS variable,
        'No answer recorded for whether CPAP end time is documented (CPAP is marked as done)' AS issue,
        is_cpap_end_t_doc AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND (is_cpap_end_t_doc IS NULL OR TRIM(is_cpap_end_t_doc) = '')
    ),
    invalid_is_cpap_end_t_doc AS (
      SELECT id, hosp_id, date_today,
        'is_cpap_end_t_doc' AS variable,
        'CPAP end time documented field has an unrecognised value (' || is_cpap_end_t_doc || '); expected 1 (Yes) or 0 (No)' AS issue,
        is_cpap_end_t_doc AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND is_cpap_end_t_doc IS NOT NULL AND TRIM(is_cpap_end_t_doc) <> ''
        AND is_cpap_end_t_doc NOT IN ('1','0')
    ),
    orphan_is_cpap_end_t_doc AS (
      SELECT id, hosp_id, date_today,
        'is_cpap_end_t_doc' AS variable,
        'CPAP end time documented flag (' || is_cpap_end_t_doc || ') is recorded but CPAP is not marked as done' AS issue,
        is_cpap_end_t_doc AS current_value
      FROM neonatal_core
      WHERE (cpap IS NULL OR cpap <> '1')
        AND is_cpap_end_t_doc IS NOT NULL AND TRIM(is_cpap_end_t_doc) <> ''
    ),

    -- =========================================================================
    -- 356: cpap_end_time_new
    --      gate: cpap='1' AND cpap_stop != '1914-01-01' AND is_cpap_end_t_doc='1'
    --      Required; @HIDEBUTTON; -1 if empty
    -- =========================================================================
    missing_cpap_end_time_new AS (
      SELECT id, hosp_id, date_today,
        'cpap_end_time_new' AS variable,
        'CPAP end time is missing (CPAP done, end date is not a placeholder, and end time is documented as recorded)' AS issue,
        cpap_end_time_new AS current_value
      FROM neonatal_core
      WHERE cpap = '1'
        AND cpap_stop IS NOT NULL AND TRIM(cpap_stop) <> ''
        AND cpap_stop <> '1914-01-01'
        AND is_cpap_end_t_doc = '1'
        AND (cpap_end_time_new IS NULL OR TRIM(cpap_end_time_new) = '')
    ),
    orphan_cpap_end_time_new AS (
      SELECT id, hosp_id, date_today,
        'cpap_end_time_new' AS variable,
        'CPAP end time (' || cpap_end_time_new || ') is recorded but the required gate conditions are not met (CPAP not done, placeholder end date, or end time not documented)' AS issue,
        cpap_end_time_new AS current_value
      FROM neonatal_core
      WHERE NOT (cpap = '1'
          AND cpap_stop IS NOT NULL AND TRIM(cpap_stop) <> ''
          AND cpap_stop <> '1914-01-01'
          AND is_cpap_end_t_doc = '1')
        AND cpap_end_time_new IS NOT NULL AND TRIM(cpap_end_time_new) <> ''
    ),

    -- =========================================================================
    -- 357: mechanical_ventilation ? EXCLUDED (cpap='1' AND cpap='0' is a
    --      logical contradiction; field can never be shown)
    -- =========================================================================

    -- =========================================================================
    -- 358: blood_transfusion_prescrib ? gate: is_minimum='0'; Required; radio
    --      1=Yes, 2=No
    -- =========================================================================
    missing_blood_transfusion_prescrib AS (
      SELECT id, hosp_id, date_today,
        'blood_transfusion_prescrib' AS variable,
        'No answer recorded for whether a blood transfusion was prescribed (non-minimum dataset; field is required)' AS issue,
        blood_transfusion_prescrib AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (blood_transfusion_prescrib IS NULL OR TRIM(blood_transfusion_prescrib) = '')
    ),
    invalid_blood_transfusion_prescrib AS (
      SELECT id, hosp_id, date_today,
        'blood_transfusion_prescrib' AS variable,
        'Blood transfusion prescribed field has an unrecognised value (' || blood_transfusion_prescrib || '); expected 1 (Yes) or 2 (No)' AS issue,
        blood_transfusion_prescrib AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND blood_transfusion_prescrib IS NOT NULL AND TRIM(blood_transfusion_prescrib) <> ''
        AND blood_transfusion_prescrib NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 359: blood_transf_pres_date ? gate: blood_transfusion_prescrib='1'; text date
    --      Not marked Required; check missingness and orphan only
    -- =========================================================================
    missing_blood_transf_pres_date AS (
      SELECT id, hosp_id, date_today,
        'blood_transf_pres_date' AS variable,
        'Date when blood transfusion was prescribed is missing (transfusion was prescribed)' AS issue,
        blood_transf_pres_date AS current_value
      FROM neonatal_core
      WHERE blood_transfusion_prescrib = '1'
        AND (blood_transf_pres_date IS NULL OR TRIM(blood_transf_pres_date) = '')
    ),
    orphan_blood_transf_pres_date AS (
      SELECT id, hosp_id, date_today,
        'blood_transf_pres_date' AS variable,
        'Blood transfusion prescription date (' || blood_transf_pres_date || ') is recorded but transfusion is not marked as prescribed' AS issue,
        blood_transf_pres_date AS current_value
      FROM neonatal_core
      WHERE (blood_transfusion_prescrib IS NULL OR blood_transfusion_prescrib <> '1')
        AND blood_transf_pres_date IS NOT NULL AND TRIM(blood_transf_pres_date) <> ''
    ),

    -- =========================================================================
    -- 360: blood_transfussion_given
    --      gate: blood_transfusion_prescrib='1' AND is_minimum='0'; radio 1/2
    -- =========================================================================
    missing_blood_transfussion_given AS (
      SELECT id, hosp_id, date_today,
        'blood_transfussion_given' AS variable,
        'No answer recorded for whether the blood transfusion was given (transfusion prescribed and non-minimum dataset)' AS issue,
        blood_transfussion_given AS current_value
      FROM neonatal_core
      WHERE blood_transfusion_prescrib = '1' AND is_minimum = '0'
        AND (blood_transfussion_given IS NULL OR TRIM(blood_transfussion_given) = '')
    ),
    invalid_blood_transfussion_given AS (
      SELECT id, hosp_id, date_today,
        'blood_transfussion_given' AS variable,
        'Blood transfusion given field has an unrecognised value (' || blood_transfussion_given || '); expected 1 (Yes) or 2 (No)' AS issue,
        blood_transfussion_given AS current_value
      FROM neonatal_core
      WHERE blood_transfusion_prescrib = '1' AND is_minimum = '0'
        AND blood_transfussion_given IS NOT NULL AND TRIM(blood_transfussion_given) <> ''
        AND blood_transfussion_given NOT IN ('1','2')
    ),
    orphan_blood_transfussion_given AS (
      SELECT id, hosp_id, date_today,
        'blood_transfussion_given' AS variable,
        'Blood transfusion given (' || blood_transfussion_given || ') is recorded but the gate conditions are not met (transfusion not prescribed or minimum dataset)' AS issue,
        blood_transfussion_given AS current_value
      FROM neonatal_core
      WHERE NOT (blood_transfusion_prescrib = '1' AND is_minimum = '0')
        AND blood_transfussion_given IS NOT NULL AND TRIM(blood_transfussion_given) <> ''
    ),

    -- =========================================================================
    -- 361: exchange_transfusion ? gate: blood_transfusion_prescrib='1'; radio 1/2
    -- =========================================================================
    missing_exchange_transfusion AS (
      SELECT id, hosp_id, date_today,
        'exchange_transfusion' AS variable,
        'No answer recorded for whether an exchange transfusion was performed (blood transfusion was prescribed)' AS issue,
        exchange_transfusion AS current_value
      FROM neonatal_core
      WHERE blood_transfusion_prescrib = '1'
        AND (exchange_transfusion IS NULL OR TRIM(exchange_transfusion) = '')
    ),
    invalid_exchange_transfusion AS (
      SELECT id, hosp_id, date_today,
        'exchange_transfusion' AS variable,
        'Exchange transfusion field has an unrecognised value (' || exchange_transfusion || '); expected 1 (Yes) or 2 (No)' AS issue,
        exchange_transfusion AS current_value
      FROM neonatal_core
      WHERE blood_transfusion_prescrib = '1'
        AND exchange_transfusion IS NOT NULL AND TRIM(exchange_transfusion) <> ''
        AND exchange_transfusion NOT IN ('1','2')
    ),
    orphan_exchange_transfusion AS (
      SELECT id, hosp_id, date_today,
        'exchange_transfusion' AS variable,
        'Exchange transfusion (' || exchange_transfusion || ') is recorded but blood transfusion is not marked as prescribed' AS issue,
        exchange_transfusion AS current_value
      FROM neonatal_core
      WHERE (blood_transfusion_prescrib IS NULL OR blood_transfusion_prescrib <> '1')
        AND exchange_transfusion IS NOT NULL AND TRIM(exchange_transfusion) <> ''
    ),

    -- =========================================================================
    -- 362: fluid_feed_monitoring_chart
    --      gate: date_of_birth >= date_adm (birth ? admission ? born in facility)
    --      Required; radio 1=Yes, 2=No
    --      NOTE: The condition is unusual (DOB >= date_adm rather than <=);
    --      we apply it exactly as specified. We check missingness when DOB is
    --      on or after admission date, excluding 1914-01-01 placeholders.
    -- =========================================================================
    missing_fluid_feed_monitoring_chart AS (
      SELECT id, hosp_id, date_today,
        'fluid_feed_monitoring_chart' AS variable,
        'No answer recorded for whether IV fluids were prescribed at admission (born on or after admission date; field is required)' AS issue,
        fluid_feed_monitoring_chart AS current_value
      FROM neonatal_core
      WHERE date_of_birth IS NOT NULL AND TRIM(date_of_birth) <> ''
        AND date_of_birth <> '1914-01-01'
        AND date_adm IS NOT NULL AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(date_of_birth AS DATE) >= TRY_CAST(date_adm AS DATE)
        AND (fluid_feed_monitoring_chart IS NULL OR TRIM(fluid_feed_monitoring_chart) = '')
    ),
    invalid_fluid_feed_monitoring_chart AS (
      SELECT id, hosp_id, date_today,
        'fluid_feed_monitoring_chart' AS variable,
        'IV fluids at admission field has an unrecognised value (' || fluid_feed_monitoring_chart || '); expected 1 (Yes) or 2 (No)' AS issue,
        fluid_feed_monitoring_chart AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart IS NOT NULL AND TRIM(fluid_feed_monitoring_chart) <> ''
        AND fluid_feed_monitoring_chart NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 363?366: IV fluid detail fields
    --   gate: fluid_feed_monitoring_chart='1' AND is_minimum='0'; all @HIDDEN
    --   363: date_fluid_presc      ? text date
    --   364: intravenous_fluids_presc ? dropdown 1?7
    --   365: total_volume_of_iv_fluids ? numeric
    --   366: duration_of_iv_fluid_presc ? text (hours)
    -- =========================================================================
    missing_date_fluid_presc AS (
      SELECT id, hosp_id, date_today,
        'date_fluid_presc' AS variable,
        'Date IV fluid was prescribed is missing (IV fluids prescribed at admission and non-minimum dataset)' AS issue,
        date_fluid_presc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND (date_fluid_presc IS NULL OR TRIM(date_fluid_presc) = '')
    ),
    orphan_date_fluid_presc AS (
      SELECT id, hosp_id, date_today,
        'date_fluid_presc' AS variable,
        'IV fluid prescription date (' || date_fluid_presc || ') is recorded but the gate conditions are not met' AS issue,
        date_fluid_presc AS current_value
      FROM neonatal_core
      WHERE NOT (fluid_feed_monitoring_chart = '1' AND is_minimum = '0')
        AND date_fluid_presc IS NOT NULL AND TRIM(date_fluid_presc) <> ''
    ),
    missing_intravenous_fluids_presc AS (
      SELECT id, hosp_id, date_today,
        'intravenous_fluids_presc' AS variable,
        'IV fluid type is missing (IV fluids prescribed at admission and non-minimum dataset)' AS issue,
        intravenous_fluids_presc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND (intravenous_fluids_presc IS NULL OR TRIM(intravenous_fluids_presc) = '')
    ),
    invalid_intravenous_fluids_presc AS (
      SELECT id, hosp_id, date_today,
        'intravenous_fluids_presc' AS variable,
        'IV fluid type has an unrecognised value (' || intravenous_fluids_presc || '); expected 1?7' AS issue,
        intravenous_fluids_presc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND intravenous_fluids_presc IS NOT NULL AND TRIM(intravenous_fluids_presc) <> ''
        AND intravenous_fluids_presc NOT IN ('1','2','3','4','5','6','7')
    ),
    missing_total_volume_of_iv_fluids AS (
      SELECT id, hosp_id, date_today,
        'total_volume_of_iv_fluids' AS variable,
        'Total volume of IV fluids is missing (IV fluids prescribed at admission and non-minimum dataset)' AS issue,
        total_volume_of_iv_fluids AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND (total_volume_of_iv_fluids IS NULL OR TRIM(total_volume_of_iv_fluids) = '')
    ),
    implausible_total_volume_of_iv_fluids AS (
      SELECT id, hosp_id, date_today,
        'total_volume_of_iv_fluids' AS variable,
        'Total volume of IV fluids (' || total_volume_of_iv_fluids || ' mL) is outside a plausible range (1?1000 mL); review the recorded value' AS issue,
        total_volume_of_iv_fluids AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND total_volume_of_iv_fluids IS NOT NULL AND TRIM(total_volume_of_iv_fluids) <> ''
        AND total_volume_of_iv_fluids <> '-1'
        AND TRY_CAST(total_volume_of_iv_fluids AS FLOAT) IS NOT NULL
        AND (TRY_CAST(total_volume_of_iv_fluids AS FLOAT) < 1
          OR TRY_CAST(total_volume_of_iv_fluids AS FLOAT) > 1000)
    ),
    missing_duration_of_iv_fluid_presc AS (
      SELECT id, hosp_id, date_today,
        'duration_of_iv_fluid_presc' AS variable,
        'Duration of IV fluid prescription is missing (IV fluids prescribed at admission and non-minimum dataset)' AS issue,
        duration_of_iv_fluid_presc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND (duration_of_iv_fluid_presc IS NULL OR TRIM(duration_of_iv_fluid_presc) = '')
    ),
    implausible_duration_of_iv_fluid_presc AS (
      SELECT id, hosp_id, date_today,
        'duration_of_iv_fluid_presc' AS variable,
        'Duration of IV fluid prescription (' || duration_of_iv_fluid_presc || ' hours) is outside a plausible range (1?168 hours); review the recorded value' AS issue,
        duration_of_iv_fluid_presc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1' AND is_minimum = '0'
        AND duration_of_iv_fluid_presc IS NOT NULL AND TRIM(duration_of_iv_fluid_presc) <> ''
        AND duration_of_iv_fluid_presc <> '-1'
        AND TRY_CAST(duration_of_iv_fluid_presc AS FLOAT) IS NOT NULL
        AND (TRY_CAST(duration_of_iv_fluid_presc AS FLOAT) < 1
          OR TRY_CAST(duration_of_iv_fluid_presc AS FLOAT) > 168)
    ),

    -- =========================================================================
    -- 367: other_fluid
    --      gate: is_minimum='0' AND fluid_feed_monitoring_chart='1'; Required; radio 1/2
    -- =========================================================================
    missing_other_fluid AS (
      SELECT id, hosp_id, date_today,
        'other_fluid' AS variable,
        'No answer recorded for whether a second IV fluid was prescribed (IV fluids at admission and non-minimum dataset; field is required)' AS issue,
        other_fluid AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND fluid_feed_monitoring_chart = '1'
        AND (other_fluid IS NULL OR TRIM(other_fluid) = '')
    ),
    invalid_other_fluid AS (
      SELECT id, hosp_id, date_today,
        'other_fluid' AS variable,
        'Other fluid field has an unrecognised value (' || other_fluid || '); expected 1 (Yes) or 2 (No)' AS issue,
        other_fluid AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND fluid_feed_monitoring_chart = '1'
        AND other_fluid IS NOT NULL AND TRIM(other_fluid) <> ''
        AND other_fluid NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 368?370: other_fluid detail
    --   gate: other_fluid='1' AND is_minimum='0'
    -- =========================================================================
    missing_other_fluid_prescribed AS (
      SELECT id, hosp_id, date_today,
        'other_fluid_prescribed' AS variable,
        'Type of second IV fluid is missing (other fluid indicated as prescribed and non-minimum dataset)' AS issue,
        other_fluid_prescribed AS current_value
      FROM neonatal_core
      WHERE other_fluid = '1' AND is_minimum = '0'
        AND (other_fluid_prescribed IS NULL OR TRIM(other_fluid_prescribed) = '')
    ),
    invalid_other_fluid_prescribed AS (
      SELECT id, hosp_id, date_today,
        'other_fluid_prescribed' AS variable,
        'Second IV fluid type has an unrecognised value (' || other_fluid_prescribed || '); expected 1?7' AS issue,
        other_fluid_prescribed AS current_value
      FROM neonatal_core
      WHERE other_fluid = '1' AND is_minimum = '0'
        AND other_fluid_prescribed IS NOT NULL AND TRIM(other_fluid_prescribed) <> ''
        AND other_fluid_prescribed NOT IN ('1','2','3','4','5','6','7')
    ),
    missing_total_vol_of_other_fluid AS (
      SELECT id, hosp_id, date_today,
        'total_vol_of_other_fluid' AS variable,
        'Total volume of second IV fluid is missing (other fluid indicated as prescribed and non-minimum dataset)' AS issue,
        total_vol_of_other_fluid AS current_value
      FROM neonatal_core
      WHERE other_fluid = '1' AND is_minimum = '0'
        AND (total_vol_of_other_fluid IS NULL OR TRIM(total_vol_of_other_fluid) = '')
    ),
    implausible_total_vol_of_other_fluid AS (
      SELECT id, hosp_id, date_today,
        'total_vol_of_other_fluid' AS variable,
        'Total volume of second IV fluid (' || total_vol_of_other_fluid || ' mL) is outside a plausible range (1?1000 mL); review the recorded value' AS issue,
        total_vol_of_other_fluid AS current_value
      FROM neonatal_core
      WHERE other_fluid = '1' AND is_minimum = '0'
        AND total_vol_of_other_fluid IS NOT NULL AND TRIM(total_vol_of_other_fluid) <> ''
        AND total_vol_of_other_fluid <> '-1'
        AND TRY_CAST(total_vol_of_other_fluid AS FLOAT) IS NOT NULL
        AND (TRY_CAST(total_vol_of_other_fluid AS FLOAT) < 1
          OR TRY_CAST(total_vol_of_other_fluid AS FLOAT) > 1000)
    ),
    missing_duration_prescribed AS (
      SELECT id, hosp_id, date_today,
        'duration_prescribed' AS variable,
        'Duration of flow for second IV fluid is missing (other fluid indicated as prescribed and non-minimum dataset)' AS issue,
        duration_prescribed AS current_value
      FROM neonatal_core
      WHERE other_fluid = '1' AND is_minimum = '0'
        AND (duration_prescribed IS NULL OR TRIM(duration_prescribed) = '')
    ),
    implausible_duration_prescribed AS (
      SELECT id, hosp_id, date_today,
        'duration_prescribed' AS variable,
        'Duration of flow for second IV fluid (' || duration_prescribed || ' hours) is outside a plausible range (1?168 hours); review the recorded value' AS issue,
        duration_prescribed AS current_value
      FROM neonatal_core
      WHERE other_fluid = '1' AND is_minimum = '0'
        AND duration_prescribed IS NOT NULL AND TRIM(duration_prescribed) <> ''
        AND duration_prescribed <> '-1'
        AND TRY_CAST(duration_prescribed AS FLOAT) IS NOT NULL
        AND (TRY_CAST(duration_prescribed AS FLOAT) < 1
          OR TRY_CAST(duration_prescribed AS FLOAT) > 168)
    ),

    -- =========================================================================
    -- 371: other_fluid_2 ? gate: is_minimum='0' AND other_fluid='1'; yesno 1/0
    -- =========================================================================
    missing_other_fluid_2 AS (
      SELECT id, hosp_id, date_today,
        'other_fluid_2' AS variable,
        'No answer recorded for whether a third IV fluid was prescribed (second IV fluid present and non-minimum dataset)' AS issue,
        other_fluid_2 AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND other_fluid = '1'
        AND (other_fluid_2 IS NULL OR TRIM(other_fluid_2) = '')
    ),
    invalid_other_fluid_2 AS (
      SELECT id, hosp_id, date_today,
        'other_fluid_2' AS variable,
        'Third IV fluid field has an unrecognised value (' || other_fluid_2 || '); expected 1 (Yes) or 0 (No)' AS issue,
        other_fluid_2 AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND other_fluid = '1'
        AND other_fluid_2 IS NOT NULL AND TRIM(other_fluid_2) <> ''
        AND other_fluid_2 NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 372?374: other_fluid_2 detail ? gate: other_fluid_2='1'
    -- =========================================================================
    missing_specify_other_fluid_2_pres AS (
      SELECT id, hosp_id, date_today,
        'specify_other_fluid_2_pres' AS variable,
        'Type of third IV fluid is missing (third fluid indicated as prescribed)' AS issue,
        specify_other_fluid_2_pres AS current_value
      FROM neonatal_core
      WHERE other_fluid_2 = '1'
        AND (specify_other_fluid_2_pres IS NULL OR TRIM(specify_other_fluid_2_pres) = '')
    ),
    invalid_specify_other_fluid_2_pres AS (
      SELECT id, hosp_id, date_today,
        'specify_other_fluid_2_pres' AS variable,
        'Third IV fluid type has an unrecognised value (' || specify_other_fluid_2_pres || '); expected 1?7' AS issue,
        specify_other_fluid_2_pres AS current_value
      FROM neonatal_core
      WHERE other_fluid_2 = '1'
        AND specify_other_fluid_2_pres IS NOT NULL AND TRIM(specify_other_fluid_2_pres) <> ''
        AND specify_other_fluid_2_pres NOT IN ('1','2','3','4','5','6','7')
    ),
    orphan_specify_other_fluid_2_pres AS (
      SELECT id, hosp_id, date_today,
        'specify_other_fluid_2_pres' AS variable,
        'Third IV fluid type (' || specify_other_fluid_2_pres || ') is recorded but third fluid is not marked as prescribed' AS issue,
        specify_other_fluid_2_pres AS current_value
      FROM neonatal_core
      WHERE (other_fluid_2 IS NULL OR other_fluid_2 <> '1')
        AND specify_other_fluid_2_pres IS NOT NULL AND TRIM(specify_other_fluid_2_pres) <> ''
    ),
    missing_total_volume_of_fluid_2 AS (
      SELECT id, hosp_id, date_today,
        'total_volume_of_fluid_2' AS variable,
        'Total volume of third IV fluid is missing (third fluid indicated as prescribed)' AS issue,
        total_volume_of_fluid_2 AS current_value
      FROM neonatal_core
      WHERE other_fluid_2 = '1'
        AND (total_volume_of_fluid_2 IS NULL OR TRIM(total_volume_of_fluid_2) = '')
    ),
    implausible_total_volume_of_fluid_2 AS (
      SELECT id, hosp_id, date_today,
        'total_volume_of_fluid_2' AS variable,
        'Total volume of third IV fluid (' || total_volume_of_fluid_2 || ' mL) is outside a plausible range (1?1000 mL); review the recorded value' AS issue,
        total_volume_of_fluid_2 AS current_value
      FROM neonatal_core
      WHERE other_fluid_2 = '1'
        AND total_volume_of_fluid_2 IS NOT NULL AND TRIM(total_volume_of_fluid_2) <> ''
        AND total_volume_of_fluid_2 <> '-1'
        AND TRY_CAST(total_volume_of_fluid_2 AS FLOAT) IS NOT NULL
        AND (TRY_CAST(total_volume_of_fluid_2 AS FLOAT) < 1
          OR TRY_CAST(total_volume_of_fluid_2 AS FLOAT) > 1000)
    ),
    missing_duration_of_flow_2 AS (
      SELECT id, hosp_id, date_today,
        'duration_of_flow_2' AS variable,
        'Duration of flow for third IV fluid is missing (third fluid indicated as prescribed)' AS issue,
        duration_of_flow_2 AS current_value
      FROM neonatal_core
      WHERE other_fluid_2 = '1'
        AND (duration_of_flow_2 IS NULL OR TRIM(duration_of_flow_2) = '')
    ),
    implausible_duration_of_flow_2 AS (
      SELECT id, hosp_id, date_today,
        'duration_of_flow_2' AS variable,
        'Duration of flow for third IV fluid (' || duration_of_flow_2 || ' hours) is outside a plausible range (1?168 hours); review the recorded value' AS issue,
        duration_of_flow_2 AS current_value
      FROM neonatal_core
      WHERE other_fluid_2 = '1'
        AND duration_of_flow_2 IS NOT NULL AND TRIM(duration_of_flow_2) <> ''
        AND duration_of_flow_2 <> '-1'
        AND TRY_CAST(duration_of_flow_2 AS FLOAT) IS NOT NULL
        AND (TRY_CAST(duration_of_flow_2 AS FLOAT) < 1
          OR TRY_CAST(duration_of_flow_2 AS FLOAT) > 168)
    ),

    -- =========================================================================
    -- 375: fluids_presc_next_day ? gate: is_minimum='0'; @HIDDEN; radio 1/2
    -- =========================================================================
    missing_fluids_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'fluids_presc_next_day' AS variable,
        'No answer recorded for whether fluids were prescribed the day after admission (non-minimum dataset)' AS issue,
        fluids_presc_next_day AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (fluids_presc_next_day IS NULL OR TRIM(fluids_presc_next_day) = '')
    ),
    invalid_fluids_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'fluids_presc_next_day' AS variable,
        'Fluids next day field has an unrecognised value (' || fluids_presc_next_day || '); expected 1 (Yes) or 2 (No)' AS issue,
        fluids_presc_next_day AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND fluids_presc_next_day IS NOT NULL AND TRIM(fluids_presc_next_day) <> ''
        AND fluids_presc_next_day NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 376: total_fluids_next_day
    --      gate: is_minimum='0' AND fluids_presc_next_day='1'; @HIDDEN; numeric
    -- =========================================================================
    missing_total_fluids_next_day AS (
      SELECT id, hosp_id, date_today,
        'total_fluids_next_day' AS variable,
        'Total volume of IV fluids prescribed the day after admission is missing (next-day fluids indicated and non-minimum dataset)' AS issue,
        total_fluids_next_day AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND fluids_presc_next_day = '1'
        AND (total_fluids_next_day IS NULL OR TRIM(total_fluids_next_day) = '')
    ),
    implausible_total_fluids_next_day AS (
      SELECT id, hosp_id, date_today,
        'total_fluids_next_day' AS variable,
        'Total volume of next-day IV fluids (' || total_fluids_next_day || ' mL) is outside a plausible range (1?1000 mL); review the recorded value' AS issue,
        total_fluids_next_day AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0' AND fluids_presc_next_day = '1'
        AND total_fluids_next_day IS NOT NULL AND TRIM(total_fluids_next_day) <> ''
        AND total_fluids_next_day <> '-1'
        AND TRY_CAST(total_fluids_next_day AS FLOAT) IS NOT NULL
        AND (TRY_CAST(total_fluids_next_day AS FLOAT) < 1
          OR TRY_CAST(total_fluids_next_day AS FLOAT) > 1000)
    ),
    orphan_total_fluids_next_day AS (
      SELECT id, hosp_id, date_today,
        'total_fluids_next_day' AS variable,
        'Total next-day IV fluid volume (' || total_fluids_next_day || ') is recorded but the gate conditions are not met' AS issue,
        total_fluids_next_day AS current_value
      FROM neonatal_core
      WHERE NOT (is_minimum = '0' AND fluids_presc_next_day = '1')
        AND total_fluids_next_day IS NOT NULL AND TRIM(total_fluids_next_day) <> ''
    ),

    -- =========================================================================
    -- 377: child_prescribed_with_feed ? always visible; Required; yesno 1/0
    -- =========================================================================
    missing_child_prescribed_with_feed AS (
      SELECT id, hosp_id, date_today,
        'child_prescribed_with_feed' AS variable,
        'No answer recorded for whether the child was prescribed feeds at admission (field is always required)' AS issue,
        child_prescribed_with_feed AS current_value
      FROM neonatal_core
      WHERE (child_prescribed_with_feed IS NULL OR TRIM(child_prescribed_with_feed) = '')
    ),
    invalid_child_prescribed_with_feed AS (
      SELECT id, hosp_id, date_today,
        'child_prescribed_with_feed' AS variable,
        'Child prescribed feeds at admission field has an unrecognised value (' || child_prescribed_with_feed || '); expected 1 (Yes) or 0 (No)' AS issue,
        child_prescribed_with_feed AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed IS NOT NULL AND TRIM(child_prescribed_with_feed) <> ''
        AND child_prescribed_with_feed NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 378: date_feeds_prescribed
    --      gate: child_prescribed_with_feed='1' AND is_minimum='0'; text date
    -- =========================================================================
    missing_date_feeds_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_feeds_prescribed' AS variable,
        'Date feeds were prescribed is missing (feeds prescribed at admission and non-minimum dataset)' AS issue,
        date_feeds_prescribed AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND (date_feeds_prescribed IS NULL OR TRIM(date_feeds_prescribed) = '')
    ),
    orphan_date_feeds_prescribed AS (
      SELECT id, hosp_id, date_today,
        'date_feeds_prescribed' AS variable,
        'Feeds prescription date (' || date_feeds_prescribed || ') is recorded but the gate conditions are not met' AS issue,
        date_feeds_prescribed AS current_value
      FROM neonatal_core
      WHERE NOT (child_prescribed_with_feed = '1' AND is_minimum = '0')
        AND date_feeds_prescribed IS NOT NULL AND TRIM(date_feeds_prescribed) <> ''
    ),

    -- =========================================================================
    -- 379: type_of_feeds
    --      gate: child_prescribed_with_feed='1' AND is_minimum='0'; dropdown 0?5
    -- =========================================================================
    missing_type_of_feeds AS (
      SELECT id, hosp_id, date_today,
        'type_of_feeds' AS variable,
        'Type of feeds prescribed is missing (feeds prescribed at admission and non-minimum dataset)' AS issue,
        type_of_feeds AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND (type_of_feeds IS NULL OR TRIM(type_of_feeds) = '')
    ),
    invalid_type_of_feeds AS (
      SELECT id, hosp_id, date_today,
        'type_of_feeds' AS variable,
        'Type of feeds has an unrecognised value (' || type_of_feeds || '); expected 0?5' AS issue,
        type_of_feeds AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND type_of_feeds IS NOT NULL AND TRIM(type_of_feeds) <> ''
        AND type_of_feeds NOT IN ('0','1','2','3','4','5')
    ),

    -- =========================================================================
    -- 380: other_feeds
    --      gate: type_of_feeds='5' AND child_prescribed_with_feed='1' AND is_minimum='0'; notes
    -- =========================================================================
    missing_other_feeds AS (
      SELECT id, hosp_id, date_today,
        'other_feeds' AS variable,
        'Other feed type description is missing (feed type is Other, feeds prescribed at admission, and non-minimum dataset)' AS issue,
        other_feeds AS current_value
      FROM neonatal_core
      WHERE type_of_feeds = '5'
        AND child_prescribed_with_feed = '1'
        AND is_minimum = '0'
        AND (other_feeds IS NULL OR TRIM(other_feeds) = '')
    ),
    orphan_other_feeds AS (
      SELECT id, hosp_id, date_today,
        'other_feeds' AS variable,
        'Other feed description (' || other_feeds || ') is recorded but the gate conditions are not met (feed type is not Other, feeds not prescribed, or minimum dataset)' AS issue,
        other_feeds AS current_value
      FROM neonatal_core
      WHERE NOT (type_of_feeds = '5' AND child_prescribed_with_feed = '1' AND is_minimum = '0')
        AND other_feeds IS NOT NULL AND TRIM(other_feeds) <> ''
    ),

    -- =========================================================================
    -- 381: time_to_start_feeds ? EXCLUDED (is_minimum='0' AND is_minimum='1'
    --      is a logical contradiction; field can never be shown)
    -- =========================================================================

    -- =========================================================================
    -- 382: feeding_route_prescribed
    --      gate: child_prescribed_with_feed='1' AND is_minimum='0'; dropdown 1?3/-1
    -- =========================================================================
    missing_feeding_route_prescribed AS (
      SELECT id, hosp_id, date_today,
        'feeding_route_prescribed' AS variable,
        'Feeding route prescribed is missing (feeds prescribed at admission and non-minimum dataset)' AS issue,
        feeding_route_prescribed AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND (feeding_route_prescribed IS NULL OR TRIM(feeding_route_prescribed) = '')
    ),
    invalid_feeding_route_prescribed AS (
      SELECT id, hosp_id, date_today,
        'feeding_route_prescribed' AS variable,
        'Feeding route prescribed has an unrecognised value (' || feeding_route_prescribed || '); expected 1 (NG Tube), 2 (Cup and spoon), 3 (Cup), or -1 (Empty)' AS issue,
        feeding_route_prescribed AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND feeding_route_prescribed IS NOT NULL AND TRIM(feeding_route_prescribed) <> ''
        AND feeding_route_prescribed NOT IN ('1','2','3','-1')
    ),

    -- =========================================================================
    -- 383: feed_volume
    --      gate: child_prescribed_with_feed='1' AND is_minimum='0'; numeric mL/feed
    -- =========================================================================
    missing_feed_volume AS (
      SELECT id, hosp_id, date_today,
        'feed_volume' AS variable,
        'Feed volume per feed is missing (feeds prescribed at admission and non-minimum dataset)' AS issue,
        feed_volume AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND (feed_volume IS NULL OR TRIM(feed_volume) = '')
    ),
    implausible_feed_volume AS (
      SELECT id, hosp_id, date_today,
        'feed_volume' AS variable,
        'Feed volume per feed (' || feed_volume || ' mL) is outside a plausible range (1?300 mL); review the recorded value' AS issue,
        feed_volume AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND feed_volume IS NOT NULL AND TRIM(feed_volume) <> ''
        AND feed_volume <> '-1'
        AND TRY_CAST(feed_volume AS FLOAT) IS NOT NULL
        AND (TRY_CAST(feed_volume AS FLOAT) < 1
          OR TRY_CAST(feed_volume AS FLOAT) > 300)
    ),

    -- =========================================================================
    -- 384: freq_of_administration
    --      gate: child_prescribed_with_feed='1' AND is_minimum='0'; dropdown 1?7/-1
    -- =========================================================================
    missing_freq_of_administration AS (
      SELECT id, hosp_id, date_today,
        'freq_of_administration' AS variable,
        'Frequency of feed administration is missing (feeds prescribed at admission and non-minimum dataset)' AS issue,
        freq_of_administration AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND (freq_of_administration IS NULL OR TRIM(freq_of_administration) = '')
    ),
    invalid_freq_of_administration AS (
      SELECT id, hosp_id, date_today,
        'freq_of_administration' AS variable,
        'Frequency of feed administration has an unrecognised value (' || freq_of_administration || '); expected 1?7 or -1 (Empty)' AS issue,
        freq_of_administration AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND freq_of_administration IS NOT NULL AND TRIM(freq_of_administration) <> ''
        AND freq_of_administration NOT IN ('1','2','3','4','5','6','7','-1')
    ),

    -- =========================================================================
    -- 385: date_feeds_only_presc
    --      gate: (child_prescribed_with_feed='1' OR fluid_feed_monitoring_chart='1')
    --            AND is_minimum='0'; @HIDDEN; text date
    --      placeholder 1914-01-01 valid
    -- =========================================================================
    missing_date_feeds_only_presc AS (
      SELECT id, hosp_id, date_today,
        'date_feeds_only_presc' AS variable,
        'Date feeds only were prescribed is missing (feeds or fluids prescribed and non-minimum dataset)' AS issue,
        date_feeds_only_presc AS current_value
      FROM neonatal_core
      WHERE (child_prescribed_with_feed = '1' OR fluid_feed_monitoring_chart = '1')
        AND is_minimum = '0'
        AND (date_feeds_only_presc IS NULL OR TRIM(date_feeds_only_presc) = '')
    ),
    orphan_date_feeds_only_presc AS (
      SELECT id, hosp_id, date_today,
        'date_feeds_only_presc' AS variable,
        'Date feeds only prescribed (' || date_feeds_only_presc || ') is recorded but the gate conditions are not met' AS issue,
        date_feeds_only_presc AS current_value
      FROM neonatal_core
      WHERE NOT ((child_prescribed_with_feed = '1' OR fluid_feed_monitoring_chart = '1')
          AND is_minimum = '0')
        AND date_feeds_only_presc IS NOT NULL AND TRIM(date_feeds_only_presc) <> ''
    ),

    -- =========================================================================
    -- 386: feeds_presc_next_day
    --      gate: child_prescribed_with_feed='1' OR ='0' (i.e., always, since
    --            the field is either Yes or No); yesno 1/0; @HIDDEN
    --      Treated as always visible since the gate resolves to always true
    --      for any valid value of child_prescribed_with_feed.
    -- =========================================================================
    missing_feeds_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'feeds_presc_next_day' AS variable,
        'No answer recorded for whether feeds were prescribed the day after admission (field is always required when child''s feed status is known)' AS issue,
        feeds_presc_next_day AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed IS NOT NULL AND TRIM(child_prescribed_with_feed) <> ''
        AND child_prescribed_with_feed IN ('1','0')
        AND (feeds_presc_next_day IS NULL OR TRIM(feeds_presc_next_day) = '')
    ),
    invalid_feeds_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'feeds_presc_next_day' AS variable,
        'Feeds next day field has an unrecognised value (' || feeds_presc_next_day || '); expected 1 (Yes) or 0 (No)' AS issue,
        feeds_presc_next_day AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day IS NOT NULL AND TRIM(feeds_presc_next_day) <> ''
        AND feeds_presc_next_day NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 387: date_feeds_first_presc
    --      gate: child_prescribed_with_feed='0' AND feeds_presc_next_day='0'
    --      Required; @HIDDEN; text date; placeholder 1914-01-01 valid
    -- =========================================================================
    missing_date_feeds_first_presc AS (
      SELECT id, hosp_id, date_today,
        'date_feeds_first_presc' AS variable,
        'Date when feeds were first prescribed is missing (feeds not prescribed at admission or next day; field is required)' AS issue,
        date_feeds_first_presc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '0' AND feeds_presc_next_day = '0'
        AND (date_feeds_first_presc IS NULL OR TRIM(date_feeds_first_presc) = '')
    ),
    orphan_date_feeds_first_presc AS (
      SELECT id, hosp_id, date_today,
        'date_feeds_first_presc' AS variable,
        'Date when feeds first prescribed (' || date_feeds_first_presc || ') is recorded but the gate conditions are not met (feeds were prescribed at admission or next day)' AS issue,
        date_feeds_first_presc AS current_value
      FROM neonatal_core
      WHERE NOT (child_prescribed_with_feed = '0' AND feeds_presc_next_day = '0')
        AND date_feeds_first_presc IS NOT NULL AND TRIM(date_feeds_first_presc) <> ''
    ),

    -- =========================================================================
    -- 388: type_feed_presc_next_day ? gate: feeds_presc_next_day='1'; dropdown 0?5
    -- =========================================================================
    missing_type_feed_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'type_feed_presc_next_day' AS variable,
        'Type of feed prescribed the day after admission is missing (next-day feeds indicated)' AS issue,
        type_feed_presc_next_day AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND (type_feed_presc_next_day IS NULL OR TRIM(type_feed_presc_next_day) = '')
    ),
    invalid_type_feed_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'type_feed_presc_next_day' AS variable,
        'Type of next-day feed has an unrecognised value (' || type_feed_presc_next_day || '); expected 0?5' AS issue,
        type_feed_presc_next_day AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND type_feed_presc_next_day IS NOT NULL AND TRIM(type_feed_presc_next_day) <> ''
        AND type_feed_presc_next_day NOT IN ('0','1','2','3','4','5')
    ),
    orphan_type_feed_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'type_feed_presc_next_day' AS variable,
        'Type of next-day feed (' || type_feed_presc_next_day || ') is recorded but next-day feeds are not indicated' AS issue,
        type_feed_presc_next_day AS current_value
      FROM neonatal_core
      WHERE (feeds_presc_next_day IS NULL OR feeds_presc_next_day <> '1')
        AND type_feed_presc_next_day IS NOT NULL AND TRIM(type_feed_presc_next_day) <> ''
    ),

    -- =========================================================================
    -- 389: nxtday_feed_rt_presc ? gate: feeds_presc_next_day='1'; dropdown 1?3/-1
    -- =========================================================================
    missing_nxtday_feed_rt_presc AS (
      SELECT id, hosp_id, date_today,
        'nxtday_feed_rt_presc' AS variable,
        'Feeding route prescribed the day after admission is missing (next-day feeds indicated)' AS issue,
        nxtday_feed_rt_presc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND (nxtday_feed_rt_presc IS NULL OR TRIM(nxtday_feed_rt_presc) = '')
    ),
    invalid_nxtday_feed_rt_presc AS (
      SELECT id, hosp_id, date_today,
        'nxtday_feed_rt_presc' AS variable,
        'Next-day feeding route has an unrecognised value (' || nxtday_feed_rt_presc || '); expected 1 (NG Tube), 2 (Cup and spoon), 3 (Cup), or -1 (Empty)' AS issue,
        nxtday_feed_rt_presc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND nxtday_feed_rt_presc IS NOT NULL AND TRIM(nxtday_feed_rt_presc) <> ''
        AND nxtday_feed_rt_presc NOT IN ('1','2','3','-1')
    ),
    orphan_nxtday_feed_rt_presc AS (
      SELECT id, hosp_id, date_today,
        'nxtday_feed_rt_presc' AS variable,
        'Next-day feeding route (' || nxtday_feed_rt_presc || ') is recorded but next-day feeds are not indicated' AS issue,
        nxtday_feed_rt_presc AS current_value
      FROM neonatal_core
      WHERE (feeds_presc_next_day IS NULL OR feeds_presc_next_day <> '1')
        AND nxtday_feed_rt_presc IS NOT NULL AND TRIM(nxtday_feed_rt_presc) <> ''
    ),

    -- =========================================================================
    -- 390: freq_of_administration_2
    --      gate: feeds_presc_next_day='1' AND is_minimum='0'
    --            AND hosp_id IN ('17','53','54','72')
    --      dropdown 1?7/-1; @HIDDEN
    -- =========================================================================
    missing_freq_of_administration_2 AS (
      SELECT id, hosp_id, date_today,
        'freq_of_administration_2' AS variable,
        'Frequency of next-day feed administration is missing (next-day feeds indicated, non-minimum dataset, and site requires this field)' AS issue,
        freq_of_administration_2 AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND is_minimum = '0'
        AND hosp_id IN ('17','53','54','72')
        AND (freq_of_administration_2 IS NULL OR TRIM(freq_of_administration_2) = '')
    ),
    invalid_freq_of_administration_2 AS (
      SELECT id, hosp_id, date_today,
        'freq_of_administration_2' AS variable,
        'Frequency of next-day feed administration has an unrecognised value (' || freq_of_administration_2 || '); expected 1?7 or -1 (Empty)' AS issue,
        freq_of_administration_2 AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND is_minimum = '0'
        AND hosp_id IN ('17','53','54','72')
        AND freq_of_administration_2 IS NOT NULL AND TRIM(freq_of_administration_2) <> ''
        AND freq_of_administration_2 NOT IN ('1','2','3','4','5','6','7','-1')
    ),
    orphan_freq_of_administration_2 AS (
      SELECT id, hosp_id, date_today,
        'freq_of_administration_2' AS variable,
        'Frequency of next-day feeds (' || freq_of_administration_2 || ') is recorded but the gate conditions are not met (next-day feeds not indicated, minimum dataset, or site not in scope)' AS issue,
        freq_of_administration_2 AS current_value
      FROM neonatal_core
      WHERE NOT (feeds_presc_next_day = '1' AND is_minimum = '0'
          AND hosp_id IN ('17','53','54','72'))
        AND freq_of_administration_2 IS NOT NULL AND TRIM(freq_of_administration_2) <> ''
    ),

    -- =========================================================================
    -- 391: total_feeds_presc_next_day ? gate: feeds_presc_next_day='1'; numeric
    -- =========================================================================
    missing_total_feeds_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'total_feeds_presc_next_day' AS variable,
        'Total volume of feeds prescribed the day after admission is missing (next-day feeds indicated)' AS issue,
        total_feeds_presc_next_day AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND (total_feeds_presc_next_day IS NULL OR TRIM(total_feeds_presc_next_day) = '')
    ),
    implausible_total_feeds_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'total_feeds_presc_next_day' AS variable,
        'Total volume of next-day feeds (' || total_feeds_presc_next_day || ' mL) is outside a plausible range (1?1000 mL); review the recorded value' AS issue,
        total_feeds_presc_next_day AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND total_feeds_presc_next_day IS NOT NULL AND TRIM(total_feeds_presc_next_day) <> ''
        AND total_feeds_presc_next_day <> '-1'
        AND TRY_CAST(total_feeds_presc_next_day AS FLOAT) IS NOT NULL
        AND (TRY_CAST(total_feeds_presc_next_day AS FLOAT) < 1
          OR TRY_CAST(total_feeds_presc_next_day AS FLOAT) > 1000)
    ),
    orphan_total_feeds_presc_next_day AS (
      SELECT id, hosp_id, date_today,
        'total_feeds_presc_next_day' AS variable,
        'Total next-day feed volume (' || total_feeds_presc_next_day || ') is recorded but next-day feeds are not indicated' AS issue,
        total_feeds_presc_next_day AS current_value
      FROM neonatal_core
      WHERE (feeds_presc_next_day IS NULL OR feeds_presc_next_day <> '1')
        AND total_feeds_presc_next_day IS NOT NULL AND TRIM(total_feeds_presc_next_day) <> ''
    ),

    -- =========================================================================
    -- 392: total_input ? complex OR gate; @HIDDEN; numeric
    --      gate: fluid_feed_monitoring_chart='1' OR fluids_presc_next_day='1'
    --            OR child_prescribed_with_feed='1' OR feeds_presc_next_day='1'
    --      Optional field; orphan check only
    -- =========================================================================
    orphan_total_input AS (
      SELECT id, hosp_id, date_today,
        'total_input' AS variable,
        'Total input (feeds + fluids) (' || total_input || ') is recorded but none of the gate conditions are met (no IV fluids, next-day fluids, feeds at admission, or next-day feeds)' AS issue,
        total_input AS current_value
      FROM neonatal_core
      WHERE NOT (
          fluid_feed_monitoring_chart = '1'
          OR fluids_presc_next_day = '1'
          OR child_prescribed_with_feed = '1'
          OR feeds_presc_next_day = '1'
        )
        AND total_input IS NOT NULL AND TRIM(total_input) <> ''
    ),

    -- =========================================================================
    -- 393: baby_breastfeeding ? always visible; Required; yesno 1/0; @HIDDEN
    -- =========================================================================
    missing_baby_breastfeeding AS (
      SELECT id, hosp_id, date_today,
        'baby_breastfeeding' AS variable,
        'No answer recorded for whether the baby is breastfeeding (field is always required)' AS issue,
        baby_breastfeeding AS current_value
      FROM neonatal_core
      WHERE (baby_breastfeeding IS NULL OR TRIM(baby_breastfeeding) = '')
    ),
    invalid_baby_breastfeeding AS (
      SELECT id, hosp_id, date_today,
        'baby_breastfeeding' AS variable,
        'Baby breastfeeding field has an unrecognised value (' || baby_breastfeeding || '); expected 1 (Yes) or 0 (No)' AS issue,
        baby_breastfeeding AS current_value
      FROM neonatal_core
      WHERE baby_breastfeeding IS NOT NULL AND TRIM(baby_breastfeeding) <> ''
        AND baby_breastfeeding NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 394: phototherapy ? always visible; Required; radio 1=Yes, 2=No
    -- =========================================================================
    missing_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'phototherapy' AS variable,
        'No answer recorded for whether phototherapy was ordered or given on the admission day (field is always required)' AS issue,
        phototherapy AS current_value
      FROM neonatal_core
      WHERE (phototherapy IS NULL OR TRIM(phototherapy) = '')
    ),
    invalid_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'phototherapy' AS variable,
        'Phototherapy field has an unrecognised value (' || phototherapy || '); expected 1 (Yes) or 2 (No)' AS issue,
        phototherapy AS current_value
      FROM neonatal_core
      WHERE phototherapy IS NOT NULL AND TRIM(phototherapy) <> ''
        AND phototherapy NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 395: photo_therapy_on_any_other ? gate: phototherapy='2'; Required; radio 1/2
    -- =========================================================================
    missing_photo_therapy_on_any_other AS (
      SELECT id, hosp_id, date_today,
        'photo_therapy_on_any_other' AS variable,
        'No answer recorded for whether phototherapy was given on any other day during hospitalisation (phototherapy not given on admission day; field is required)' AS issue,
        photo_therapy_on_any_other AS current_value
      FROM neonatal_core
      WHERE phototherapy = '2'
        AND (photo_therapy_on_any_other IS NULL OR TRIM(photo_therapy_on_any_other) = '')
    ),
    invalid_photo_therapy_on_any_other AS (
      SELECT id, hosp_id, date_today,
        'photo_therapy_on_any_other' AS variable,
        'Phototherapy on any other day field has an unrecognised value (' || photo_therapy_on_any_other || '); expected 1 (Yes) or 2 (No)' AS issue,
        photo_therapy_on_any_other AS current_value
      FROM neonatal_core
      WHERE phototherapy = '2'
        AND photo_therapy_on_any_other IS NOT NULL AND TRIM(photo_therapy_on_any_other) <> ''
        AND photo_therapy_on_any_other NOT IN ('1','2')
    ),
    orphan_photo_therapy_on_any_other AS (
      SELECT id, hosp_id, date_today,
        'photo_therapy_on_any_other' AS variable,
        'Phototherapy on any other day (' || photo_therapy_on_any_other || ') is recorded but phototherapy was not marked as absent on the admission day' AS issue,
        photo_therapy_on_any_other AS current_value
      FROM neonatal_core
      WHERE (phototherapy IS NULL OR phototherapy <> '2')
        AND photo_therapy_on_any_other IS NOT NULL AND TRIM(photo_therapy_on_any_other) <> ''
    ),

    -- =========================================================================
    -- 396: start_date_phototherapy
    --      gate: photo_therapy_on_any_other='1'; Required; text date
    --      placeholder 1914-01-01 valid
    -- =========================================================================
    missing_start_date_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'start_date_phototherapy' AS variable,
        'Start date of phototherapy is missing (phototherapy given on another day; field is required)' AS issue,
        start_date_phototherapy AS current_value
      FROM neonatal_core
      WHERE photo_therapy_on_any_other = '1'
        AND (start_date_phototherapy IS NULL OR TRIM(start_date_phototherapy) = '')
    ),
    orphan_start_date_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'start_date_phototherapy' AS variable,
        'Phototherapy start date (' || start_date_phototherapy || ') is recorded but phototherapy on another day is not indicated' AS issue,
        start_date_phototherapy AS current_value
      FROM neonatal_core
      WHERE (photo_therapy_on_any_other IS NULL OR photo_therapy_on_any_other <> '1')
        AND start_date_phototherapy IS NOT NULL AND TRIM(start_date_phototherapy) <> ''
    ),

    -- =========================================================================
    -- 397: stop_date_phototherapy
    --      gate: photo_therapy_on_any_other='1' OR phototherapy='1'; Required; text date
    --      placeholder 1914-01-01 valid; temporal: stop >= start (if start known)
    -- =========================================================================
    missing_stop_date_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'stop_date_phototherapy' AS variable,
        'Stop date of phototherapy is missing (phototherapy was given; field is required)' AS issue,
        stop_date_phototherapy AS current_value
      FROM neonatal_core
      WHERE (photo_therapy_on_any_other = '1' OR phototherapy = '1')
        AND (stop_date_phototherapy IS NULL OR TRIM(stop_date_phototherapy) = '')
    ),
    orphan_stop_date_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'stop_date_phototherapy' AS variable,
        'Phototherapy stop date (' || stop_date_phototherapy || ') is recorded but neither phototherapy on admission nor on any other day is indicated' AS issue,
        stop_date_phototherapy AS current_value
      FROM neonatal_core
      WHERE NOT (photo_therapy_on_any_other = '1' OR phototherapy = '1')
        AND stop_date_phototherapy IS NOT NULL AND TRIM(stop_date_phototherapy) <> ''
    ),
    temporal_stop_date_phototherapy AS (
      SELECT id, hosp_id, date_today,
        'stop_date_phototherapy' AS variable,
        'Phototherapy stop date (' || stop_date_phototherapy || ') is before the start date (' || start_date_phototherapy || '); phototherapy cannot end before it begins' AS issue,
        stop_date_phototherapy AS current_value
      FROM neonatal_core
      WHERE (photo_therapy_on_any_other = '1' OR phototherapy = '1')
        AND stop_date_phototherapy IS NOT NULL AND TRIM(stop_date_phototherapy) <> ''
        AND stop_date_phototherapy <> '1914-01-01'
        AND start_date_phototherapy IS NOT NULL AND TRIM(start_date_phototherapy) <> ''
        AND start_date_phototherapy <> '1914-01-01'
        AND TRY_CAST(stop_date_phototherapy AS DATE) < TRY_CAST(start_date_phototherapy AS DATE)
    ),

    -- =========================================================================
    -- 398: k_mother_care ? always visible; Required; yesno 1/0
    -- =========================================================================
    missing_k_mother_care AS (
      SELECT id, hosp_id, date_today,
        'k_mother_care' AS variable,
        'No answer recorded for whether Kangaroo Mother Care (KMC) was given (field is always required)' AS issue,
        k_mother_care AS current_value
      FROM neonatal_core
      WHERE (k_mother_care IS NULL OR TRIM(k_mother_care) = '')
    ),
    invalid_k_mother_care AS (
      SELECT id, hosp_id, date_today,
        'k_mother_care' AS variable,
        'Kangaroo Mother Care field has an unrecognised value (' || k_mother_care || '); expected 1 (Yes) or 0 (No)' AS issue,
        k_mother_care AS current_value
      FROM neonatal_core
      WHERE k_mother_care IS NOT NULL AND TRIM(k_mother_care) <> ''
        AND k_mother_care NOT IN ('1','0')
    ),

        -- =========================================================================
    -- FOLLOW-UP MONITORING SECTION DQA (fields 400?430,
    -- instrument: follow_up_monitoring)
    -- =========================================================================

    -- =========================================================================
    -- GATE SUMMARY
    --   400  vitals_signs_chart_present   : is_minimum='0'; Required; yesno
    --   401  neo_std_monit_chart_pre      : is_minimum='0' AND is_minimum='1'
    --                                       ? CONTRADICTORY; EXCLUDED
    --   [vital_signs_monitored_in_t]      : vitals_signs_chart_present='1'
    --                                       AND is_minimum='0'; Required; radio
    --        NOTE: Field name inferred from gate references; no field number
    --        assigned in the spec (appears between 401 and 404). Treated as
    --        field 403 for ordering purposes.
    --   404  no_of_times_temp_monitored   : vital_signs_monitored_in_t='1'
    --                                       AND is_minimum='0'; dropdown 1?11/-1
    --   405  lowest_temperature           : always visible; Required; numeric -1?42
    --   406  no_of_times_resp_monitored   : vital_signs_monitored_in_t='1'
    --                                       AND is_minimum='0'; dropdown 1?11/-1
    --   407  no_of_times_puls_monitored   : vital_signs_monitored_in_t='1'
    --                                       AND is_minimum='0'; dropdown 1?11/-1
    --   408  oxygen_sat_monitored         : vital_signs_monitored_in_t='1'
    --                                       AND is_minimum='0'; radio 1/2
    --   409  no_of_times_oxy_monitored    : vital_signs_monitored_in_t='1'
    --                                       AND is_minimum='0'
    --                                       AND oxygen_sat_monitored='1';
    --                                       dropdown 1?11/-1
    --   410  lowest_oxygen_saturation     : always visible; Required; numeric -1?100
    --   411  cyanosis_assessed            : vital_signs_monitored_in_t='1'
    --                                       AND is_minimum='0'
    --                                       AND oxygen_sat_monitored='2'; radio 1/2
    --   412  no_times_cyanosis_assessed   : cyanosis_assessed='1'; dropdown 1?11/-1
    --   413  neo_intnsv_monit_chart_pre   : is_minimum='0'; Required; dropdown 1/2
    --   414  oxygen_admin                 : always visible; yesno 1/0 (not Required)
    --   415  fluid_monitoring_chart       : is_minimum='0'; Required; yesno
    --   416  ivf_type_day0_doc            : fluid_feed_monitoring_chart='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   417  ivf_vol_day0_doc             : fluid_feed_monitoring_chart='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   418  ivf_summ_tot_day0_doc        : fluid_feed_monitoring_chart='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   419  ivf_type_day1_doc            : fluids_presc_next_day='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   420  ivf_vol_day1_doc             : fluids_presc_next_day='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   421  ivf_summ_tot_day1_doc        : fluids_presc_next_day='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   422  feed_fluid_monitorng_chart   : is_minimum='0'; Required; radio 1/2
    --   423  date_the_feeds_initiated     : child_prescribed_with_feed='1'
    --                                       AND is_minimum='0'; Required; date text
    --   424  time_feeds_started           : child_prescribed_with_feed='1'
    --                                       AND date_the_feeds_initiated!='1914-01-01';
    --                                       @HIDDEN; Required; text (-1 if empty)
    --   425  feed_type_day0_doc           : child_prescribed_with_feed='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   426  feed_vol_day0_doc            : child_prescribed_with_feed='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   427  feed_summ_tot_day0_doc       : child_prescribed_with_feed='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   428  feed_type_day1_doc           : feeds_presc_next_day='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   429  feed_vol_day1_doc            : feeds_presc_next_day='1';
    --                                       @HIDDEN; Required; radio 1/2
    --   430  feed_summ_tot_day1_doc       : feeds_presc_next_day='1';
    --                                       @HIDDEN; Required; radio 1/2
    --
    -- CROSS-INSTRUMENT REFERENCES (from supportive_care / earlier sections):
    --   fluid_feed_monitoring_chart  (field 362)
    --   fluids_presc_next_day        (field 375)
    --   child_prescribed_with_feed   (field 377)
    --   feeds_presc_next_day         (field 386)
    --
    -- EXCLUDED (contradictory visibility logic):
    --   401  neo_std_monit_chart_pre (is_minimum='0' AND is_minimum='1')
    -- =========================================================================

    -- =========================================================================
    -- 400: vitals_signs_chart_present
    --      gate: is_minimum='0'; Required; yesno 1/0
    -- =========================================================================
    missing_vitals_signs_chart_present AS (
      SELECT id, hosp_id, date_today,
        'vitals_signs_chart_present' AS variable,
        'No answer recorded for whether the vitals signs chart is present (non-minimum dataset; field is required)' AS issue,
        vitals_signs_chart_present AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (vitals_signs_chart_present IS NULL OR TRIM(vitals_signs_chart_present) = '')
    ),
    invalid_vitals_signs_chart_present AS (
      SELECT id, hosp_id, date_today,
        'vitals_signs_chart_present' AS variable,
        'Vitals signs chart present field has an unrecognised value (' || vitals_signs_chart_present || '); expected 1 (Yes) or 0 (No)' AS issue,
        vitals_signs_chart_present AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND vitals_signs_chart_present IS NOT NULL
        AND TRIM(vitals_signs_chart_present) <> ''
        AND vitals_signs_chart_present NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 401: neo_std_monit_chart_pre ? EXCLUDED
    --      (is_minimum='0' AND is_minimum='1' is a logical contradiction)
    -- =========================================================================

    -- =========================================================================
    -- 403: vital_signs_monitored_in_t   [field number inferred]
    --      gate: vitals_signs_chart_present='1' AND is_minimum='0'
    --      Required; radio 1=Yes, 2=No
    -- =========================================================================
    missing_vital_signs_monitored_in_t AS (
      SELECT id, hosp_id, date_today,
        'vital_signs_monitored_in_t' AS variable,
        'No answer recorded for whether vital signs were monitored in the first 48 hours (vitals chart present and non-minimum dataset; field is required)' AS issue,
        vital_signs_monitored_in_t AS current_value
      FROM neonatal_core
      WHERE vitals_signs_chart_present = '1' AND is_minimum = '0'
        AND (vital_signs_monitored_in_t IS NULL OR TRIM(vital_signs_monitored_in_t) = '')
    ),
    invalid_vital_signs_monitored_in_t AS (
      SELECT id, hosp_id, date_today,
        'vital_signs_monitored_in_t' AS variable,
        'Vital signs monitored in first 48 hrs field has an unrecognised value (' || vital_signs_monitored_in_t || '); expected 1 (Yes) or 2 (No)' AS issue,
        vital_signs_monitored_in_t AS current_value
      FROM neonatal_core
      WHERE vitals_signs_chart_present = '1' AND is_minimum = '0'
        AND vital_signs_monitored_in_t IS NOT NULL
        AND TRIM(vital_signs_monitored_in_t) <> ''
        AND vital_signs_monitored_in_t NOT IN ('1','2')
    ),
    orphan_vital_signs_monitored_in_t AS (
      SELECT id, hosp_id, date_today,
        'vital_signs_monitored_in_t' AS variable,
        'Vital signs monitored in first 48 hrs (' || vital_signs_monitored_in_t || ') is recorded but the gate conditions are not met (vitals chart not marked present or minimum dataset)' AS issue,
        vital_signs_monitored_in_t AS current_value
      FROM neonatal_core
      WHERE NOT (vitals_signs_chart_present = '1' AND is_minimum = '0')
        AND vital_signs_monitored_in_t IS NOT NULL
        AND TRIM(vital_signs_monitored_in_t) <> ''
    ),

    -- =========================================================================
    -- 404: no_of_times_temp_monitored
    --      gate: vital_signs_monitored_in_t='1' AND is_minimum='0'
    --      dropdown 1?11/-1; not marked Required
    -- =========================================================================
    missing_no_of_times_temp_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_temp_monitored' AS variable,
        'Number of times temperature was monitored in 48 hours is missing (vital signs monitored and non-minimum dataset)' AS issue,
        no_of_times_temp_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND (no_of_times_temp_monitored IS NULL OR TRIM(no_of_times_temp_monitored) = '')
    ),
    invalid_no_of_times_temp_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_temp_monitored' AS variable,
        'Number of times temperature monitored has an unrecognised value (' || no_of_times_temp_monitored || '); expected 1?11 or -1 (Empty)' AS issue,
        no_of_times_temp_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND no_of_times_temp_monitored IS NOT NULL
        AND TRIM(no_of_times_temp_monitored) <> ''
        AND no_of_times_temp_monitored NOT IN ('1','2','3','4','5','6','7','8','9','10','11','-1')
    ),
    orphan_no_of_times_temp_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_temp_monitored' AS variable,
        'Number of times temperature monitored (' || no_of_times_temp_monitored || ') is recorded but the gate conditions are not met' AS issue,
        no_of_times_temp_monitored AS current_value
      FROM neonatal_core
      WHERE NOT (vital_signs_monitored_in_t = '1' AND is_minimum = '0')
        AND no_of_times_temp_monitored IS NOT NULL
        AND TRIM(no_of_times_temp_monitored) <> ''
    ),

    -- =========================================================================
    -- 405: lowest_temperature ? always visible; Required; numeric -1?42
    --      -1 is the valid sentinel for empty; plausible clinical range 34?42�C
    -- =========================================================================
    missing_lowest_temperature AS (
      SELECT id, hosp_id, date_today,
        'lowest_temperature' AS variable,
        'Lowest temperature measured is missing (field is always required; enter -1 if not recorded)' AS issue,
        lowest_temperature AS current_value
      FROM neonatal_core
      WHERE (lowest_temperature IS NULL OR TRIM(lowest_temperature) = '')
    ),
    implausible_lowest_temperature AS (
      SELECT id, hosp_id, date_today,
        'lowest_temperature' AS variable,
        'Lowest temperature (' || lowest_temperature || '�C) is outside the plausible clinical range (34.0?42.0�C); review the recorded value' AS issue,
        lowest_temperature AS current_value
      FROM neonatal_core
      WHERE lowest_temperature IS NOT NULL
        AND TRIM(lowest_temperature) <> ''
        AND lowest_temperature <> '-1'
        AND TRY_CAST(lowest_temperature AS FLOAT) IS NOT NULL
        AND (TRY_CAST(lowest_temperature AS FLOAT) < 34.0
          OR TRY_CAST(lowest_temperature AS FLOAT) > 42.0)
    ),

    -- =========================================================================
    -- 406: no_of_times_resp_monitored
    --      gate: vital_signs_monitored_in_t='1' AND is_minimum='0'
    --      dropdown 1?11/-1
    -- =========================================================================
    missing_no_of_times_resp_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_resp_monitored' AS variable,
        'Number of times respiratory rate was monitored in 48 hours is missing (vital signs monitored and non-minimum dataset)' AS issue,
        no_of_times_resp_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND (no_of_times_resp_monitored IS NULL OR TRIM(no_of_times_resp_monitored) = '')
    ),
    invalid_no_of_times_resp_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_resp_monitored' AS variable,
        'Number of times respiratory rate monitored has an unrecognised value (' || no_of_times_resp_monitored || '); expected 1?11 or -1 (Empty)' AS issue,
        no_of_times_resp_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND no_of_times_resp_monitored IS NOT NULL
        AND TRIM(no_of_times_resp_monitored) <> ''
        AND no_of_times_resp_monitored NOT IN ('1','2','3','4','5','6','7','8','9','10','11','-1')
    ),
    orphan_no_of_times_resp_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_resp_monitored' AS variable,
        'Number of times respiratory rate monitored (' || no_of_times_resp_monitored || ') is recorded but the gate conditions are not met' AS issue,
        no_of_times_resp_monitored AS current_value
      FROM neonatal_core
      WHERE NOT (vital_signs_monitored_in_t = '1' AND is_minimum = '0')
        AND no_of_times_resp_monitored IS NOT NULL
        AND TRIM(no_of_times_resp_monitored) <> ''
    ),

    -- =========================================================================
    -- 407: no_of_times_puls_monitored
    --      gate: vital_signs_monitored_in_t='1' AND is_minimum='0'
    --      dropdown 1?11/-1
    -- =========================================================================
    missing_no_of_times_puls_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_puls_monitored' AS variable,
        'Number of times pulse rate was monitored in 48 hours is missing (vital signs monitored and non-minimum dataset)' AS issue,
        no_of_times_puls_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND (no_of_times_puls_monitored IS NULL OR TRIM(no_of_times_puls_monitored) = '')
    ),
    invalid_no_of_times_puls_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_puls_monitored' AS variable,
        'Number of times pulse rate monitored has an unrecognised value (' || no_of_times_puls_monitored || '); expected 1?11 or -1 (Empty)' AS issue,
        no_of_times_puls_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND no_of_times_puls_monitored IS NOT NULL
        AND TRIM(no_of_times_puls_monitored) <> ''
        AND no_of_times_puls_monitored NOT IN ('1','2','3','4','5','6','7','8','9','10','11','-1')
    ),
    orphan_no_of_times_puls_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_puls_monitored' AS variable,
        'Number of times pulse rate monitored (' || no_of_times_puls_monitored || ') is recorded but the gate conditions are not met' AS issue,
        no_of_times_puls_monitored AS current_value
      FROM neonatal_core
      WHERE NOT (vital_signs_monitored_in_t = '1' AND is_minimum = '0')
        AND no_of_times_puls_monitored IS NOT NULL
        AND TRIM(no_of_times_puls_monitored) <> ''
    ),

    -- =========================================================================
    -- 408: oxygen_sat_monitored
    --      gate: vital_signs_monitored_in_t='1' AND is_minimum='0'
    --      radio 1=Yes, 2=No; not marked Required
    -- =========================================================================
    missing_oxygen_sat_monitored AS (
      SELECT id, hosp_id, date_today,
        'oxygen_sat_monitored' AS variable,
        'No answer recorded for whether oxygen saturation was monitored (vital signs monitored and non-minimum dataset)' AS issue,
        oxygen_sat_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND (oxygen_sat_monitored IS NULL OR TRIM(oxygen_sat_monitored) = '')
    ),
    invalid_oxygen_sat_monitored AS (
      SELECT id, hosp_id, date_today,
        'oxygen_sat_monitored' AS variable,
        'Oxygen saturation monitored field has an unrecognised value (' || oxygen_sat_monitored || '); expected 1 (Yes) or 2 (No)' AS issue,
        oxygen_sat_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1' AND is_minimum = '0'
        AND oxygen_sat_monitored IS NOT NULL
        AND TRIM(oxygen_sat_monitored) <> ''
        AND oxygen_sat_monitored NOT IN ('1','2')
    ),
    orphan_oxygen_sat_monitored AS (
      SELECT id, hosp_id, date_today,
        'oxygen_sat_monitored' AS variable,
        'Oxygen saturation monitored (' || oxygen_sat_monitored || ') is recorded but the gate conditions are not met' AS issue,
        oxygen_sat_monitored AS current_value
      FROM neonatal_core
      WHERE NOT (vital_signs_monitored_in_t = '1' AND is_minimum = '0')
        AND oxygen_sat_monitored IS NOT NULL
        AND TRIM(oxygen_sat_monitored) <> ''
    ),

    -- =========================================================================
    -- 409: no_of_times_oxy_monitored
    --      gate: vital_signs_monitored_in_t='1' AND is_minimum='0'
    --            AND oxygen_sat_monitored='1'
    --      dropdown 1?11/-1
    -- =========================================================================
    missing_no_of_times_oxy_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_oxy_monitored' AS variable,
        'Number of times oxygen saturation was monitored in 48 hours is missing (oxygen saturation monitored, vital signs active, and non-minimum dataset)' AS issue,
        no_of_times_oxy_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1'
        AND is_minimum = '0'
        AND oxygen_sat_monitored = '1'
        AND (no_of_times_oxy_monitored IS NULL OR TRIM(no_of_times_oxy_monitored) = '')
    ),
    invalid_no_of_times_oxy_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_oxy_monitored' AS variable,
        'Number of times oxygen saturation monitored has an unrecognised value (' || no_of_times_oxy_monitored || '); expected 1?11 or -1 (Empty)' AS issue,
        no_of_times_oxy_monitored AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1'
        AND is_minimum = '0'
        AND oxygen_sat_monitored = '1'
        AND no_of_times_oxy_monitored IS NOT NULL
        AND TRIM(no_of_times_oxy_monitored) <> ''
        AND no_of_times_oxy_monitored NOT IN ('1','2','3','4','5','6','7','8','9','10','11','-1')
    ),
    orphan_no_of_times_oxy_monitored AS (
      SELECT id, hosp_id, date_today,
        'no_of_times_oxy_monitored' AS variable,
        'Number of times oxygen saturation monitored (' || no_of_times_oxy_monitored || ') is recorded but the gate conditions are not met (oxygen saturation not monitored, vital signs not active, or minimum dataset)' AS issue,
        no_of_times_oxy_monitored AS current_value
      FROM neonatal_core
      WHERE NOT (vital_signs_monitored_in_t = '1'
          AND is_minimum = '0'
          AND oxygen_sat_monitored = '1')
        AND no_of_times_oxy_monitored IS NOT NULL
        AND TRIM(no_of_times_oxy_monitored) <> ''
    ),

    -- =========================================================================
    -- 410: lowest_oxygen_saturation ? always visible; Required; numeric -1?100
    --      -1 is the valid sentinel for empty; plausible clinical range 50?100%
    -- =========================================================================
    missing_lowest_oxygen_saturation AS (
      SELECT id, hosp_id, date_today,
        'lowest_oxygen_saturation' AS variable,
        'Lowest oxygen saturation measured is missing (field is always required; enter -1 if not recorded)' AS issue,
        lowest_oxygen_saturation AS current_value
      FROM neonatal_core
      WHERE (lowest_oxygen_saturation IS NULL OR TRIM(lowest_oxygen_saturation) = '')
    ),
    implausible_lowest_oxygen_saturation AS (
      SELECT id, hosp_id, date_today,
        'lowest_oxygen_saturation' AS variable,
        'Lowest oxygen saturation (' || lowest_oxygen_saturation || '%) is outside the plausible clinical range (50?100%); review the recorded value' AS issue,
        lowest_oxygen_saturation AS current_value
      FROM neonatal_core
      WHERE lowest_oxygen_saturation IS NOT NULL
        AND TRIM(lowest_oxygen_saturation) <> ''
        AND lowest_oxygen_saturation <> '-1'
        AND TRY_CAST(lowest_oxygen_saturation AS FLOAT) IS NOT NULL
        AND (TRY_CAST(lowest_oxygen_saturation AS FLOAT) < 50
          OR TRY_CAST(lowest_oxygen_saturation AS FLOAT) > 100)
    ),

    -- =========================================================================
    -- 411: cyanosis_assessed
    --      gate: vital_signs_monitored_in_t='1' AND is_minimum='0'
    --            AND oxygen_sat_monitored='2'
    --      radio 1=Yes, 2=No; not marked Required
    -- =========================================================================
    missing_cyanosis_assessed AS (
      SELECT id, hosp_id, date_today,
        'cyanosis_assessed' AS variable,
        'No answer recorded for whether cyanosis assessment was done (oxygen saturation not monitored, vital signs active, and non-minimum dataset)' AS issue,
        cyanosis_assessed AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1'
        AND is_minimum = '0'
        AND oxygen_sat_monitored = '2'
        AND (cyanosis_assessed IS NULL OR TRIM(cyanosis_assessed) = '')
    ),
    invalid_cyanosis_assessed AS (
      SELECT id, hosp_id, date_today,
        'cyanosis_assessed' AS variable,
        'Cyanosis assessment done field has an unrecognised value (' || cyanosis_assessed || '); expected 1 (Yes) or 2 (No)' AS issue,
        cyanosis_assessed AS current_value
      FROM neonatal_core
      WHERE vital_signs_monitored_in_t = '1'
        AND is_minimum = '0'
        AND oxygen_sat_monitored = '2'
        AND cyanosis_assessed IS NOT NULL
        AND TRIM(cyanosis_assessed) <> ''
        AND cyanosis_assessed NOT IN ('1','2')
    ),
    orphan_cyanosis_assessed AS (
      SELECT id, hosp_id, date_today,
        'cyanosis_assessed' AS variable,
        'Cyanosis assessment done (' || cyanosis_assessed || ') is recorded but the gate conditions are not met (vital signs not monitored, minimum dataset, or oxygen saturation was monitored)' AS issue,
        cyanosis_assessed AS current_value
      FROM neonatal_core
      WHERE NOT (vital_signs_monitored_in_t = '1'
          AND is_minimum = '0'
          AND oxygen_sat_monitored = '2')
        AND cyanosis_assessed IS NOT NULL
        AND TRIM(cyanosis_assessed) <> ''
    ),

    -- =========================================================================
    -- 412: no_times_cyanosis_assessed
    --      gate: cyanosis_assessed='1'; dropdown 1?11/-1
    -- =========================================================================
    missing_no_times_cyanosis_assessed AS (
      SELECT id, hosp_id, date_today,
        'no_times_cyanosis_assessed' AS variable,
        'Number of times cyanosis was assessed in 48 hours is missing (cyanosis assessment done)' AS issue,
        no_times_cyanosis_assessed AS current_value
      FROM neonatal_core
      WHERE cyanosis_assessed = '1'
        AND (no_times_cyanosis_assessed IS NULL OR TRIM(no_times_cyanosis_assessed) = '')
    ),
    invalid_no_times_cyanosis_assessed AS (
      SELECT id, hosp_id, date_today,
        'no_times_cyanosis_assessed' AS variable,
        'Number of times cyanosis assessed has an unrecognised value (' || no_times_cyanosis_assessed || '); expected 1?11 or -1 (Empty)' AS issue,
        no_times_cyanosis_assessed AS current_value
      FROM neonatal_core
      WHERE cyanosis_assessed = '1'
        AND no_times_cyanosis_assessed IS NOT NULL
        AND TRIM(no_times_cyanosis_assessed) <> ''
        AND no_times_cyanosis_assessed NOT IN ('1','2','3','4','5','6','7','8','9','10','11','-1')
    ),
    orphan_no_times_cyanosis_assessed AS (
      SELECT id, hosp_id, date_today,
        'no_times_cyanosis_assessed' AS variable,
        'Number of times cyanosis assessed (' || no_times_cyanosis_assessed || ') is recorded but cyanosis assessment is not marked as done' AS issue,
        no_times_cyanosis_assessed AS current_value
      FROM neonatal_core
      WHERE (cyanosis_assessed IS NULL OR cyanosis_assessed <> '1')
        AND no_times_cyanosis_assessed IS NOT NULL
        AND TRIM(no_times_cyanosis_assessed) <> ''
    ),

    -- =========================================================================
    -- 413: neo_intnsv_monit_chart_pre
    --      gate: is_minimum='0'; Required; dropdown 1=Yes, 2=No
    -- =========================================================================
    missing_neo_intnsv_monit_chart_pre AS (
      SELECT id, hosp_id, date_today,
        'neo_intnsv_monit_chart_pre' AS variable,
        'No answer recorded for whether the comprehensive newborn monitoring chart is present (non-minimum dataset; field is required)' AS issue,
        neo_intnsv_monit_chart_pre AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (neo_intnsv_monit_chart_pre IS NULL OR TRIM(neo_intnsv_monit_chart_pre) = '')
    ),
    invalid_neo_intnsv_monit_chart_pre AS (
      SELECT id, hosp_id, date_today,
        'neo_intnsv_monit_chart_pre' AS variable,
        'Comprehensive newborn monitoring chart present field has an unrecognised value (' || neo_intnsv_monit_chart_pre || '); expected 1 (Yes) or 2 (No)' AS issue,
        neo_intnsv_monit_chart_pre AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND neo_intnsv_monit_chart_pre IS NOT NULL
        AND TRIM(neo_intnsv_monit_chart_pre) <> ''
        AND neo_intnsv_monit_chart_pre NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 414: oxygen_admin ? always visible; not marked Required; yesno 1/0
    --      No missingness flag since not Required; invalid code check only
    -- =========================================================================
    invalid_oxygen_admin AS (
      SELECT id, hosp_id, date_today,
        'oxygen_admin' AS variable,
        'Oxygen therapy administered field has an unrecognised value (' || oxygen_admin || '); expected 1 (Yes) or 0 (No)' AS issue,
        oxygen_admin AS current_value
      FROM neonatal_core
      WHERE oxygen_admin IS NOT NULL
        AND TRIM(oxygen_admin) <> ''
        AND oxygen_admin NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 415: fluid_monitoring_chart
    --      gate: is_minimum='0'; Required; yesno 1/0
    -- =========================================================================
    missing_fluid_monitoring_chart AS (
      SELECT id, hosp_id, date_today,
        'fluid_monitoring_chart' AS variable,
        'No answer recorded for whether a fluid monitoring chart is present (non-minimum dataset; field is required)' AS issue,
        fluid_monitoring_chart AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (fluid_monitoring_chart IS NULL OR TRIM(fluid_monitoring_chart) = '')
    ),
    invalid_fluid_monitoring_chart AS (
      SELECT id, hosp_id, date_today,
        'fluid_monitoring_chart' AS variable,
        'Fluid monitoring chart field has an unrecognised value (' || fluid_monitoring_chart || '); expected 1 (Yes) or 0 (No)' AS issue,
        fluid_monitoring_chart AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND fluid_monitoring_chart IS NOT NULL
        AND TRIM(fluid_monitoring_chart) <> ''
        AND fluid_monitoring_chart NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 416: ivf_type_day0_doc
    --      gate: fluid_feed_monitoring_chart='1' (cross-instrument, field 362)
    --      @HIDDEN; Required; radio 1=Yes, 2=No
    -- =========================================================================
    missing_ivf_type_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_type_day0_doc' AS variable,
        'No answer recorded for whether the IVF type was documented in the first 24 hours of admission (IV fluids were prescribed at admission; field is required)' AS issue,
        ivf_type_day0_doc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1'
        AND (ivf_type_day0_doc IS NULL OR TRIM(ivf_type_day0_doc) = '')
    ),
    invalid_ivf_type_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_type_day0_doc' AS variable,
        'IVF type documented (day 0) field has an unrecognised value (' || ivf_type_day0_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        ivf_type_day0_doc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1'
        AND ivf_type_day0_doc IS NOT NULL
        AND TRIM(ivf_type_day0_doc) <> ''
        AND ivf_type_day0_doc NOT IN ('1','2')
    ),
    orphan_ivf_type_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_type_day0_doc' AS variable,
        'IVF type documented (day 0) (' || ivf_type_day0_doc || ') is recorded but IV fluids were not marked as prescribed at admission' AS issue,
        ivf_type_day0_doc AS current_value
      FROM neonatal_core
      WHERE (fluid_feed_monitoring_chart IS NULL OR fluid_feed_monitoring_chart <> '1')
        AND ivf_type_day0_doc IS NOT NULL
        AND TRIM(ivf_type_day0_doc) <> ''
    ),

    -- =========================================================================
    -- 417: ivf_vol_day0_doc
    --      gate: fluid_feed_monitoring_chart='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_ivf_vol_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_vol_day0_doc' AS variable,
        'No answer recorded for whether the IVF fluid volume was documented in the first 24 hours of admission (IV fluids were prescribed at admission; field is required)' AS issue,
        ivf_vol_day0_doc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1'
        AND (ivf_vol_day0_doc IS NULL OR TRIM(ivf_vol_day0_doc) = '')
    ),
    invalid_ivf_vol_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_vol_day0_doc' AS variable,
        'IVF volume documented (day 0) field has an unrecognised value (' || ivf_vol_day0_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        ivf_vol_day0_doc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1'
        AND ivf_vol_day0_doc IS NOT NULL
        AND TRIM(ivf_vol_day0_doc) <> ''
        AND ivf_vol_day0_doc NOT IN ('1','2')
    ),
    orphan_ivf_vol_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_vol_day0_doc' AS variable,
        'IVF volume documented (day 0) (' || ivf_vol_day0_doc || ') is recorded but IV fluids were not marked as prescribed at admission' AS issue,
        ivf_vol_day0_doc AS current_value
      FROM neonatal_core
      WHERE (fluid_feed_monitoring_chart IS NULL OR fluid_feed_monitoring_chart <> '1')
        AND ivf_vol_day0_doc IS NOT NULL
        AND TRIM(ivf_vol_day0_doc) <> ''
    ),

    -- =========================================================================
    -- 418: ivf_summ_tot_day0_doc
    --      gate: fluid_feed_monitoring_chart='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_ivf_summ_tot_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_summ_tot_day0_doc' AS variable,
        'No answer recorded for whether the IVF summary total was documented in the first 24 hours of admission (IV fluids were prescribed at admission; field is required)' AS issue,
        ivf_summ_tot_day0_doc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1'
        AND (ivf_summ_tot_day0_doc IS NULL OR TRIM(ivf_summ_tot_day0_doc) = '')
    ),
    invalid_ivf_summ_tot_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_summ_tot_day0_doc' AS variable,
        'IVF summary total documented (day 0) field has an unrecognised value (' || ivf_summ_tot_day0_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        ivf_summ_tot_day0_doc AS current_value
      FROM neonatal_core
      WHERE fluid_feed_monitoring_chart = '1'
        AND ivf_summ_tot_day0_doc IS NOT NULL
        AND TRIM(ivf_summ_tot_day0_doc) <> ''
        AND ivf_summ_tot_day0_doc NOT IN ('1','2')
    ),
    orphan_ivf_summ_tot_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_summ_tot_day0_doc' AS variable,
        'IVF summary total documented (day 0) (' || ivf_summ_tot_day0_doc || ') is recorded but IV fluids were not marked as prescribed at admission' AS issue,
        ivf_summ_tot_day0_doc AS current_value
      FROM neonatal_core
      WHERE (fluid_feed_monitoring_chart IS NULL OR fluid_feed_monitoring_chart <> '1')
        AND ivf_summ_tot_day0_doc IS NOT NULL
        AND TRIM(ivf_summ_tot_day0_doc) <> ''
    ),

    -- =========================================================================
    -- 419: ivf_type_day1_doc
    --      gate: fluids_presc_next_day='1' (cross-instrument, field 375)
    --      @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_ivf_type_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_type_day1_doc' AS variable,
        'No answer recorded for whether the IVF type was documented in the next 24 hours (fluids prescribed the day after admission; field is required)' AS issue,
        ivf_type_day1_doc AS current_value
      FROM neonatal_core
      WHERE fluids_presc_next_day = '1'
        AND (ivf_type_day1_doc IS NULL OR TRIM(ivf_type_day1_doc) = '')
    ),
    invalid_ivf_type_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_type_day1_doc' AS variable,
        'IVF type documented (day 1) field has an unrecognised value (' || ivf_type_day1_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        ivf_type_day1_doc AS current_value
      FROM neonatal_core
      WHERE fluids_presc_next_day = '1'
        AND ivf_type_day1_doc IS NOT NULL
        AND TRIM(ivf_type_day1_doc) <> ''
        AND ivf_type_day1_doc NOT IN ('1','2')
    ),
    orphan_ivf_type_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_type_day1_doc' AS variable,
        'IVF type documented (day 1) (' || ivf_type_day1_doc || ') is recorded but fluids were not marked as prescribed on the next day' AS issue,
        ivf_type_day1_doc AS current_value
      FROM neonatal_core
      WHERE (fluids_presc_next_day IS NULL OR fluids_presc_next_day <> '1')
        AND ivf_type_day1_doc IS NOT NULL
        AND TRIM(ivf_type_day1_doc) <> ''
    ),

    -- =========================================================================
    -- 420: ivf_vol_day1_doc
    --      gate: fluids_presc_next_day='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_ivf_vol_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_vol_day1_doc' AS variable,
        'No answer recorded for whether the IVF fluid volume was documented in the next 24 hours (fluids prescribed the day after admission; field is required)' AS issue,
        ivf_vol_day1_doc AS current_value
      FROM neonatal_core
      WHERE fluids_presc_next_day = '1'
        AND (ivf_vol_day1_doc IS NULL OR TRIM(ivf_vol_day1_doc) = '')
    ),
    invalid_ivf_vol_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_vol_day1_doc' AS variable,
        'IVF volume documented (day 1) field has an unrecognised value (' || ivf_vol_day1_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        ivf_vol_day1_doc AS current_value
      FROM neonatal_core
      WHERE fluids_presc_next_day = '1'
        AND ivf_vol_day1_doc IS NOT NULL
        AND TRIM(ivf_vol_day1_doc) <> ''
        AND ivf_vol_day1_doc NOT IN ('1','2')
    ),
    orphan_ivf_vol_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_vol_day1_doc' AS variable,
        'IVF volume documented (day 1) (' || ivf_vol_day1_doc || ') is recorded but fluids were not marked as prescribed on the next day' AS issue,
        ivf_vol_day1_doc AS current_value
      FROM neonatal_core
      WHERE (fluids_presc_next_day IS NULL OR fluids_presc_next_day <> '1')
        AND ivf_vol_day1_doc IS NOT NULL
        AND TRIM(ivf_vol_day1_doc) <> ''
    ),

    -- =========================================================================
    -- 421: ivf_summ_tot_day1_doc
    --      gate: fluids_presc_next_day='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_ivf_summ_tot_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_summ_tot_day1_doc' AS variable,
        'No answer recorded for whether the IVF summary total was documented in the next 24 hours (fluids prescribed the day after admission; field is required)' AS issue,
        ivf_summ_tot_day1_doc AS current_value
      FROM neonatal_core
      WHERE fluids_presc_next_day = '1'
        AND (ivf_summ_tot_day1_doc IS NULL OR TRIM(ivf_summ_tot_day1_doc) = '')
    ),
    invalid_ivf_summ_tot_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_summ_tot_day1_doc' AS variable,
        'IVF summary total documented (day 1) field has an unrecognised value (' || ivf_summ_tot_day1_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        ivf_summ_tot_day1_doc AS current_value
      FROM neonatal_core
      WHERE fluids_presc_next_day = '1'
        AND ivf_summ_tot_day1_doc IS NOT NULL
        AND TRIM(ivf_summ_tot_day1_doc) <> ''
        AND ivf_summ_tot_day1_doc NOT IN ('1','2')
    ),
    orphan_ivf_summ_tot_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'ivf_summ_tot_day1_doc' AS variable,
        'IVF summary total documented (day 1) (' || ivf_summ_tot_day1_doc || ') is recorded but fluids were not marked as prescribed on the next day' AS issue,
        ivf_summ_tot_day1_doc AS current_value
      FROM neonatal_core
      WHERE (fluids_presc_next_day IS NULL OR fluids_presc_next_day <> '1')
        AND ivf_summ_tot_day1_doc IS NOT NULL
        AND TRIM(ivf_summ_tot_day1_doc) <> ''
    ),

    -- =========================================================================
    -- 422: feed_fluid_monitorng_chart
    --      gate: is_minimum='0'; Required; radio 1=Yes, 2=No
    -- =========================================================================
    missing_feed_fluid_monitorng_chart AS (
      SELECT id, hosp_id, date_today,
        'feed_fluid_monitorng_chart' AS variable,
        'No answer recorded for whether a feed monitoring chart is available (non-minimum dataset; field is required)' AS issue,
        feed_fluid_monitorng_chart AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND (feed_fluid_monitorng_chart IS NULL OR TRIM(feed_fluid_monitorng_chart) = '')
    ),
    invalid_feed_fluid_monitorng_chart AS (
      SELECT id, hosp_id, date_today,
        'feed_fluid_monitorng_chart' AS variable,
        'Feed monitoring chart field has an unrecognised value (' || feed_fluid_monitorng_chart || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_fluid_monitorng_chart AS current_value
      FROM neonatal_core
      WHERE is_minimum = '0'
        AND feed_fluid_monitorng_chart IS NOT NULL
        AND TRIM(feed_fluid_monitorng_chart) <> ''
        AND feed_fluid_monitorng_chart NOT IN ('1','2')
    ),

    -- =========================================================================
    -- 423: date_the_feeds_initiated
    --      gate: child_prescribed_with_feed='1' AND is_minimum='0'
    --      Required; text date; placeholder 1914-01-01 valid
    -- =========================================================================
    missing_date_the_feeds_initiated AS (
      SELECT id, hosp_id, date_today,
        'date_the_feeds_initiated' AS variable,
        'Date the feeds were initiated is missing (feeds prescribed at admission and non-minimum dataset; field is required)' AS issue,
        date_the_feeds_initiated AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1' AND is_minimum = '0'
        AND (date_the_feeds_initiated IS NULL OR TRIM(date_the_feeds_initiated) = '')
    ),
    orphan_date_the_feeds_initiated AS (
      SELECT id, hosp_id, date_today,
        'date_the_feeds_initiated' AS variable,
        'Date feeds initiated (' || date_the_feeds_initiated || ') is recorded but the gate conditions are not met (feeds not prescribed at admission or minimum dataset)' AS issue,
        date_the_feeds_initiated AS current_value
      FROM neonatal_core
      WHERE NOT (child_prescribed_with_feed = '1' AND is_minimum = '0')
        AND date_the_feeds_initiated IS NOT NULL
        AND TRIM(date_the_feeds_initiated) <> ''
    ),

    -- =========================================================================
    -- 424: time_feeds_started
    --      gate: child_prescribed_with_feed='1'
    --            AND date_the_feeds_initiated != '1914-01-01'
    --      @HIDDEN; Required; text (-1 if empty)
    --      Hidden field; missingness check applied since gate is meaningful
    -- =========================================================================
    missing_time_feeds_started AS (
      SELECT id, hosp_id, date_today,
        'time_feeds_started' AS variable,
        'Time feeds started is missing (feeds prescribed at admission and a real feeds initiation date is recorded; enter -1 if not recorded)' AS issue,
        time_feeds_started AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND date_the_feeds_initiated IS NOT NULL
        AND TRIM(date_the_feeds_initiated) <> ''
        AND date_the_feeds_initiated <> '1914-01-01'
        AND (time_feeds_started IS NULL OR TRIM(time_feeds_started) = '')
    ),
    orphan_time_feeds_started AS (
      SELECT id, hosp_id, date_today,
        'time_feeds_started' AS variable,
        'Time feeds started (' || time_feeds_started || ') is recorded but the gate conditions are not met (feeds not prescribed at admission or feeds initiation date is a placeholder)' AS issue,
        time_feeds_started AS current_value
      FROM neonatal_core
      WHERE NOT (child_prescribed_with_feed = '1'
          AND date_the_feeds_initiated IS NOT NULL
          AND TRIM(date_the_feeds_initiated) <> ''
          AND date_the_feeds_initiated <> '1914-01-01')
        AND time_feeds_started IS NOT NULL
        AND TRIM(time_feeds_started) <> ''
    ),

    -- =========================================================================
    -- 425: feed_type_day0_doc
    --      gate: child_prescribed_with_feed='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_feed_type_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_type_day0_doc' AS variable,
        'No answer recorded for whether the feed type was documented in the first 24 hours of admission (feeds prescribed at admission; field is required)' AS issue,
        feed_type_day0_doc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND (feed_type_day0_doc IS NULL OR TRIM(feed_type_day0_doc) = '')
    ),
    invalid_feed_type_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_type_day0_doc' AS variable,
        'Feed type documented (day 0) field has an unrecognised value (' || feed_type_day0_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_type_day0_doc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND feed_type_day0_doc IS NOT NULL
        AND TRIM(feed_type_day0_doc) <> ''
        AND feed_type_day0_doc NOT IN ('1','2')
    ),
    orphan_feed_type_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_type_day0_doc' AS variable,
        'Feed type documented (day 0) (' || feed_type_day0_doc || ') is recorded but feeds were not marked as prescribed at admission' AS issue,
        feed_type_day0_doc AS current_value
      FROM neonatal_core
      WHERE (child_prescribed_with_feed IS NULL OR child_prescribed_with_feed <> '1')
        AND feed_type_day0_doc IS NOT NULL
        AND TRIM(feed_type_day0_doc) <> ''
    ),

    -- =========================================================================
    -- 426: feed_vol_day0_doc
    --      gate: child_prescribed_with_feed='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_feed_vol_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_vol_day0_doc' AS variable,
        'No answer recorded for whether the feed volume was documented in the first 24 hours of admission (feeds prescribed at admission; field is required)' AS issue,
        feed_vol_day0_doc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND (feed_vol_day0_doc IS NULL OR TRIM(feed_vol_day0_doc) = '')
    ),
    invalid_feed_vol_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_vol_day0_doc' AS variable,
        'Feed volume documented (day 0) field has an unrecognised value (' || feed_vol_day0_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_vol_day0_doc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND feed_vol_day0_doc IS NOT NULL
        AND TRIM(feed_vol_day0_doc) <> ''
        AND feed_vol_day0_doc NOT IN ('1','2')
    ),
    orphan_feed_vol_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_vol_day0_doc' AS variable,
        'Feed volume documented (day 0) (' || feed_vol_day0_doc || ') is recorded but feeds were not marked as prescribed at admission' AS issue,
        feed_vol_day0_doc AS current_value
      FROM neonatal_core
      WHERE (child_prescribed_with_feed IS NULL OR child_prescribed_with_feed <> '1')
        AND feed_vol_day0_doc IS NOT NULL
        AND TRIM(feed_vol_day0_doc) <> ''
    ),

    -- =========================================================================
    -- 427: feed_summ_tot_day0_doc
    --      gate: child_prescribed_with_feed='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_feed_summ_tot_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_summ_tot_day0_doc' AS variable,
        'No answer recorded for whether the feed summary total was documented in the first 24 hours of admission (feeds prescribed at admission; field is required)' AS issue,
        feed_summ_tot_day0_doc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND (feed_summ_tot_day0_doc IS NULL OR TRIM(feed_summ_tot_day0_doc) = '')
    ),
    invalid_feed_summ_tot_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_summ_tot_day0_doc' AS variable,
        'Feed summary total documented (day 0) field has an unrecognised value (' || feed_summ_tot_day0_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_summ_tot_day0_doc AS current_value
      FROM neonatal_core
      WHERE child_prescribed_with_feed = '1'
        AND feed_summ_tot_day0_doc IS NOT NULL
        AND TRIM(feed_summ_tot_day0_doc) <> ''
        AND feed_summ_tot_day0_doc NOT IN ('1','2')
    ),
    orphan_feed_summ_tot_day0_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_summ_tot_day0_doc' AS variable,
        'Feed summary total documented (day 0) (' || feed_summ_tot_day0_doc || ') is recorded but feeds were not marked as prescribed at admission' AS issue,
        feed_summ_tot_day0_doc AS current_value
      FROM neonatal_core
      WHERE (child_prescribed_with_feed IS NULL OR child_prescribed_with_feed <> '1')
        AND feed_summ_tot_day0_doc IS NOT NULL
        AND TRIM(feed_summ_tot_day0_doc) <> ''
    ),

    -- =========================================================================
    -- 428: feed_type_day1_doc
    --      gate: feeds_presc_next_day='1' (cross-instrument, field 386)
    --      @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_feed_type_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_type_day1_doc' AS variable,
        'No answer recorded for whether the feed type was documented in the next 24 hours (feeds prescribed the day after admission; field is required)' AS issue,
        feed_type_day1_doc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND (feed_type_day1_doc IS NULL OR TRIM(feed_type_day1_doc) = '')
    ),
    invalid_feed_type_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_type_day1_doc' AS variable,
        'Feed type documented (day 1) field has an unrecognised value (' || feed_type_day1_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_type_day1_doc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND feed_type_day1_doc IS NOT NULL
        AND TRIM(feed_type_day1_doc) <> ''
        AND feed_type_day1_doc NOT IN ('1','2')
    ),
    orphan_feed_type_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_type_day1_doc' AS variable,
        'Feed type documented (day 1) (' || feed_type_day1_doc || ') is recorded but feeds were not marked as prescribed on the next day' AS issue,
        feed_type_day1_doc AS current_value
      FROM neonatal_core
      WHERE (feeds_presc_next_day IS NULL OR feeds_presc_next_day <> '1')
        AND feed_type_day1_doc IS NOT NULL
        AND TRIM(feed_type_day1_doc) <> ''
    ),

    -- =========================================================================
    -- 429: feed_vol_day1_doc
    --      gate: feeds_presc_next_day='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_feed_vol_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_vol_day1_doc' AS variable,
        'No answer recorded for whether the feed volume was documented in the next 24 hours (feeds prescribed the day after admission; field is required)' AS issue,
        feed_vol_day1_doc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND (feed_vol_day1_doc IS NULL OR TRIM(feed_vol_day1_doc) = '')
    ),
    invalid_feed_vol_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_vol_day1_doc' AS variable,
        'Feed volume documented (day 1) field has an unrecognised value (' || feed_vol_day1_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_vol_day1_doc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND feed_vol_day1_doc IS NOT NULL
        AND TRIM(feed_vol_day1_doc) <> ''
        AND feed_vol_day1_doc NOT IN ('1','2')
    ),
    orphan_feed_vol_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_vol_day1_doc' AS variable,
        'Feed volume documented (day 1) (' || feed_vol_day1_doc || ') is recorded but feeds were not marked as prescribed on the next day' AS issue,
        feed_vol_day1_doc AS current_value
      FROM neonatal_core
      WHERE (feeds_presc_next_day IS NULL OR feeds_presc_next_day <> '1')
        AND feed_vol_day1_doc IS NOT NULL
        AND TRIM(feed_vol_day1_doc) <> ''
    ),

    -- =========================================================================
    -- 430: feed_summ_tot_day1_doc
    --      gate: feeds_presc_next_day='1'; @HIDDEN; Required; radio 1/2
    -- =========================================================================
    missing_feed_summ_tot_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_summ_tot_day1_doc' AS variable,
        'No answer recorded for whether the feed summary total was documented in the next 24 hours (feeds prescribed the day after admission; field is required)' AS issue,
        feed_summ_tot_day1_doc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND (feed_summ_tot_day1_doc IS NULL OR TRIM(feed_summ_tot_day1_doc) = '')
    ),
    invalid_feed_summ_tot_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_summ_tot_day1_doc' AS variable,
        'Feed summary total documented (day 1) field has an unrecognised value (' || feed_summ_tot_day1_doc || '); expected 1 (Yes) or 2 (No)' AS issue,
        feed_summ_tot_day1_doc AS current_value
      FROM neonatal_core
      WHERE feeds_presc_next_day = '1'
        AND feed_summ_tot_day1_doc IS NOT NULL
        AND TRIM(feed_summ_tot_day1_doc) <> ''
        AND feed_summ_tot_day1_doc NOT IN ('1','2')
    ),
    orphan_feed_summ_tot_day1_doc AS (
      SELECT id, hosp_id, date_today,
        'feed_summ_tot_day1_doc' AS variable,
        'Feed summary total documented (day 1) (' || feed_summ_tot_day1_doc || ') is recorded but feeds were not marked as prescribed on the next day' AS issue,
        feed_summ_tot_day1_doc AS current_value
      FROM neonatal_core
      WHERE (feeds_presc_next_day IS NULL OR feeds_presc_next_day <> '1')
        AND feed_summ_tot_day1_doc IS NOT NULL
        AND TRIM(feed_summ_tot_day1_doc) <> ''
    ),

        -- =========================================================================
    -- DISCHARGE INFORMATION SECTION DQA (fields 432?465,
    -- instrument: discharge_information)
    -- =========================================================================

    -- =========================================================================
    -- GATE SUMMARY
    --   432  outcome                       : always visible; Required; dropdown 1?5/-1
    --   433  disch_death_summ              : always visible; Required; radio 1/0/-1
    --   434  d1_present                    : outcome='2'; text (not Required)
    --   435  referred_to                   : outcome='3'; text (not Required)
    --   436  referred_to_othr              : outcome='3'; text (not Required)
    --   437  referral_reason               : outcome='3'; text (not Required)
    --   438  referred_where                : outcome='3'; @HIDDEN; text (not Required)
    --   439  discharge_weight              : always visible; Required; numeric (-1 sentinel)
    --   440  discharge_wt_units            : discharge_weight > 0; radio -1/1/2
    --   441  dsc_condition                 : outcome='1' OR outcome='3'; dropdown 1?3/-1
    --   443  dsc_dx1_primary               : always visible; Required; radio 1/0/-1
    --   444  primary_disch_diagnosis       : dsc_dx1_primary='1'; text (not Required)
    --   445  disch_diag_1                  : dsc_dx1_primary='0'; text (not Required)
    --   446  disch_diag_2                  : dsc_dx1_primary='0'; text (not Required)
    --   447  disch_diag_3                  : dsc_dx1_primary='0'; text (not Required)
    --   448  disch_diag_4                  : dsc_dx1_primary='0'; text (not Required)
    --   449  disch_diag_5                  : dsc_dx1_primary='0'; text (not Required)
    --   450  other_discharge_diag          : always visible; Required; yesno 1/0
    --   451  other_discharge_diag_1        : other_discharge_diag='1'; text
    --   452  other_discharge_diag_2        : other_discharge_diag='1'; text
    --   453  other_discharge_diag_3        : other_discharge_diag='1'; text
    --   454  other_discharge_diag_4        : other_discharge_diag='1'; text
    --   455  other_discharge_diag_5        : other_discharge_diag='1'; text
    --   456  any_other_disch_diag          : always visible; not Required; yesno 1/0
    --   457  other_disch_diag_old          : any_other_disch_diag='1'
    --                                        AND any_other_disch_diag='0'
    --                                        ? CONTRADICTORY; EXCLUDED
    --   458  other_discharge_diag_unlisted : any_other_disch_diag='1'; text
    --   459  in_chloro                     : GIS Kenya hospitals; Required; yesno 1/0
    --   460  in_vitk                       : GIS Kenya hospitals; Required; yesno 1/0
    --   461  in_bil_hi                     : (bilirubin_type(2)='1' OR
    --                                         bilirubin_type(1)='1' OR
    --                                         phototherapy='1' OR
    --                                         photo_therapy_on_any_other='1')
    --                                        AND GIS Kenya hospitals;
    --                                        Required; numeric (-1 sentinel)
    --   462  bilirubin_hi_unit             : in_bil_hi > 0; Required; radio 1/2/-1
    --   463  opv                           : is_minimum='0' AND is_minimum='1'
    --                                        ? CONTRADICTORY; EXCLUDED
    --   464  bcg                           : is_minimum='0' AND is_minimum='1'
    --                                        ? CONTRADICTORY; EXCLUDED
    --   465  baby_feeding_disch            : outcome='1'; dropdown 1?5
    --
    -- EXCLUDED (contradictory visibility logic):
    --   457  other_disch_diag_old  (any_other_disch_diag='1' AND ='0')
    --   463  opv                   (is_minimum='0' AND is_minimum='1')
    --   464  bcg                   (is_minimum='0' AND is_minimum='1')
    --
    -- SEQUENTIAL POPULATION RULES:
    --   disch_diag_2 requires disch_diag_1; disch_diag_3 requires disch_diag_2;
    --   disch_diag_4 requires disch_diag_3; disch_diag_5 requires disch_diag_4
    --   (all when dsc_dx1_primary='0')
    --   other_discharge_diag_2 requires other_discharge_diag_1, etc.
    --   (all when other_discharge_diag='1')
    --
    -- CROSS-INSTRUMENT REFERENCES (from supportive_care / investigations):
    --   phototherapy              (field 394, supportive_care)
    --   photo_therapy_on_any_other(field 395, supportive_care)
    --   bilirubin_type            (field 211/212 checkbox, investigations)
    --
    -- GIS KENYA HOSPITAL IDs: 53, 58, 41, 51, 45, 40, 71, 55, 52, 63, 76
    -- =========================================================================

    -- =========================================================================
    -- 432: outcome ? always visible; Required; dropdown 1?5/-1
    -- =========================================================================
    missing_outcome AS (
      SELECT id, hosp_id, date_today,
        'outcome' AS variable,
        'Outcome at discharge is missing (field is always required)' AS issue,
        outcome AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR TRIM(outcome) = '')
    ),
    invalid_outcome AS (
      SELECT id, hosp_id, date_today,
        'outcome' AS variable,
        'Outcome at discharge has an unrecognised value (' || outcome || '); expected 1 (Alive), 2 (Dead), 3 (Referred), 4 (Absconded), 5 (Discharged Against Medical Advice), or -1 (Empty)' AS issue,
        outcome AS current_value
      FROM neonatal_core
      WHERE outcome IS NOT NULL
        AND TRIM(outcome) <> ''
        AND outcome NOT IN ('1','2','3','4','5','-1')
    ),

    -- =========================================================================
    -- 433: disch_death_summ ? always visible; Required; radio 1/0/-1
    -- =========================================================================
    missing_disch_death_summ AS (
      SELECT id, hosp_id, date_today,
        'disch_death_summ' AS variable,
        'Death/discharge summary present is missing (field is always required)' AS issue,
        disch_death_summ AS current_value
      FROM neonatal_core
      WHERE (disch_death_summ IS NULL OR TRIM(disch_death_summ) = '')
    ),
    invalid_disch_death_summ AS (
      SELECT id, hosp_id, date_today,
        'disch_death_summ' AS variable,
        'Death/discharge summary present field has an unrecognised value (' || disch_death_summ || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        disch_death_summ AS current_value
      FROM neonatal_core
      WHERE disch_death_summ IS NOT NULL
        AND TRIM(disch_death_summ) <> ''
        AND disch_death_summ NOT IN ('1','0','-1')
    ),

    -- =========================================================================
    -- 434: d1_present ? gate: outcome='2'; text; not Required
    --      Missing check applied when gate is open (death outcome)
    -- =========================================================================
    missing_d1_present AS (
      SELECT id, hosp_id, date_today,
        'd1_present' AS variable,
        'D1 form present/used is missing (outcome is recorded as Dead; documentation is expected)' AS issue,
        d1_present AS current_value
      FROM neonatal_core
      WHERE outcome = '2'
        AND (d1_present IS NULL OR TRIM(d1_present) = '')
    ),
    orphan_d1_present AS (
      SELECT id, hosp_id, date_today,
        'd1_present' AS variable,
        'D1 form present/used (' || d1_present || ') is recorded but outcome is not Dead' AS issue,
        d1_present AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '2')
        AND d1_present IS NOT NULL
        AND TRIM(d1_present) <> ''
    ),

    -- =========================================================================
    -- 435: referred_to ? gate: outcome='3'; text; not Required
    -- =========================================================================
    missing_referred_to AS (
      SELECT id, hosp_id, date_today,
        'referred_to' AS variable,
        'Referred To destination is missing (outcome is recorded as Referred; documentation is expected)' AS issue,
        referred_to AS current_value
      FROM neonatal_core
      WHERE outcome = '3'
        AND (referred_to IS NULL OR TRIM(referred_to) = '')
    ),
    orphan_referred_to AS (
      SELECT id, hosp_id, date_today,
        'referred_to' AS variable,
        'Referred To destination (' || referred_to || ') is recorded but outcome is not Referred' AS issue,
        referred_to AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '3')
        AND referred_to IS NOT NULL
        AND TRIM(referred_to) <> ''
    ),

    -- =========================================================================
    -- 436: referred_to_othr ? gate: outcome='3'; text; not Required
    --      Orphan check only; free text alternative when facility not on list
    -- =========================================================================
    orphan_referred_to_othr AS (
      SELECT id, hosp_id, date_today,
        'referred_to_othr' AS variable,
        'Referred To (Other) (' || referred_to_othr || ') is recorded but outcome is not Referred' AS issue,
        referred_to_othr AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '3')
        AND referred_to_othr IS NOT NULL
        AND TRIM(referred_to_othr) <> ''
    ),

    -- =========================================================================
    -- 437: referral_reason ? gate: outcome='3'; text; not Required
    -- =========================================================================
    missing_referral_reason AS (
      SELECT id, hosp_id, date_today,
        'referral_reason' AS variable,
        'Reason for referral is missing (outcome is recorded as Referred; documentation is expected)' AS issue,
        referral_reason AS current_value
      FROM neonatal_core
      WHERE outcome = '3'
        AND (referral_reason IS NULL OR TRIM(referral_reason) = '')
    ),
    orphan_referral_reason AS (
      SELECT id, hosp_id, date_today,
        'referral_reason' AS variable,
        'Reason for referral (' || referral_reason || ') is recorded but outcome is not Referred' AS issue,
        referral_reason AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '3')
        AND referral_reason IS NOT NULL
        AND TRIM(referral_reason) <> ''
    ),

    -- =========================================================================
    -- 438: referred_where ? gate: outcome='3'; @HIDDEN; text; not Required
    --      Orphan check applied; no missingness flag (not Required and hidden)
    -- =========================================================================
    orphan_referred_where AS (
      SELECT id, hosp_id, date_today,
        'referred_where' AS variable,
        'Referred from Where (' || referred_where || ') is recorded but outcome is not Referred' AS issue,
        referred_where AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '3')
        AND referred_where IS NOT NULL
        AND TRIM(referred_where) <> ''
    ),

    -- =========================================================================
    -- 439: discharge_weight ? always visible; Required; numeric; -1 sentinel
    --      Plausible range: 200?8000 g equivalent; -1 excluded from check
    -- =========================================================================
    missing_discharge_weight AS (
      SELECT id, hosp_id, date_today,
        'discharge_weight' AS variable,
        'Discharge weight is missing (field is always required; enter -1 if unrecorded)' AS issue,
        discharge_weight AS current_value
      FROM neonatal_core
      WHERE (discharge_weight IS NULL OR TRIM(discharge_weight) = '')
    ),

    -- =========================================================================
    -- 440: discharge_wt_units ? gate: discharge_weight > 0; radio -1/1/2
    --      Required if a real weight is recorded
    -- =========================================================================
    missing_discharge_wt_units AS (
      SELECT id, hosp_id, date_today,
        'discharge_wt_units' AS variable,
        'Discharge weight units are missing (a positive discharge weight is recorded; units are required)' AS issue,
        discharge_wt_units AS current_value
      FROM neonatal_core
      WHERE discharge_weight IS NOT NULL
        AND TRIM(discharge_weight) <> ''
        AND TRY_CAST(discharge_weight AS FLOAT) IS NOT NULL
        AND TRY_CAST(discharge_weight AS FLOAT) > 0
        AND (discharge_wt_units IS NULL OR TRIM(discharge_wt_units) = '')
    ),
    invalid_discharge_wt_units AS (
      SELECT id, hosp_id, date_today,
        'discharge_wt_units' AS variable,
        'Discharge weight units field has an unrecognised value (' || discharge_wt_units || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        discharge_wt_units AS current_value
      FROM neonatal_core
      WHERE discharge_weight IS NOT NULL
        AND TRIM(discharge_weight) <> ''
        AND TRY_CAST(discharge_weight AS FLOAT) IS NOT NULL
        AND TRY_CAST(discharge_weight AS FLOAT) > 0
        AND discharge_wt_units IS NOT NULL
        AND TRIM(discharge_wt_units) <> ''
        AND discharge_wt_units NOT IN ('1','2','-1')
    ),
    orphan_discharge_wt_units AS (
      SELECT id, hosp_id, date_today,
        'discharge_wt_units' AS variable,
        'Discharge weight units (' || discharge_wt_units || ') is recorded but discharge weight is not a positive value' AS issue,
        discharge_wt_units AS current_value
      FROM neonatal_core
      WHERE NOT (
          discharge_weight IS NOT NULL
          AND TRIM(discharge_weight) <> ''
          AND TRY_CAST(discharge_weight AS FLOAT) IS NOT NULL
          AND TRY_CAST(discharge_weight AS FLOAT) > 0
        )
        AND discharge_wt_units IS NOT NULL
        AND TRIM(discharge_wt_units) <> ''
    ),
    -- Plausibility: grams 200?8000; kilograms 0.2?8.0
    implausible_discharge_weight AS (
      SELECT id, hosp_id, date_today,
        'discharge_weight' AS variable,
        'Discharge weight (' || discharge_weight || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(discharge_wt_units,'unknown') || '); verify the value and units' AS issue,
        discharge_weight AS current_value
      FROM neonatal_core
      WHERE discharge_weight IS NOT NULL
        AND TRIM(discharge_weight) <> ''
        AND discharge_weight <> '-1'
        AND TRY_CAST(discharge_weight AS FLOAT) IS NOT NULL
        AND TRY_CAST(discharge_weight AS FLOAT) > 0
        AND (
          (discharge_wt_units = '1'
            AND (TRY_CAST(discharge_weight AS FLOAT) < 200
              OR TRY_CAST(discharge_weight AS FLOAT) > 8000))
          OR
          (discharge_wt_units = '2'
            AND (TRY_CAST(discharge_weight AS FLOAT) < 0.2
              OR TRY_CAST(discharge_weight AS FLOAT) > 8.0))
        )
    ),

    -- =========================================================================
    -- 441: dsc_condition ? gate: outcome='1' OR outcome='3'; dropdown 1?3/-1
    --      Not Required; missing check applied when gate is open
    -- =========================================================================
    missing_dsc_condition AS (
      SELECT id, hosp_id, date_today,
        'dsc_condition' AS variable,
        'Condition on discharge is missing (outcome is Alive or Referred; documentation is expected)' AS issue,
        dsc_condition AS current_value
      FROM neonatal_core
      WHERE outcome IN ('1','3')
        AND (dsc_condition IS NULL OR TRIM(dsc_condition) = '')
    ),
    invalid_dsc_condition AS (
      SELECT id, hosp_id, date_today,
        'dsc_condition' AS variable,
        'Condition on discharge has an unrecognised value (' || dsc_condition || '); expected 1 (Normal), 2 (Neuro sequelae/disability), 3 (Other), or -1 (Empty)' AS issue,
        dsc_condition AS current_value
      FROM neonatal_core
      WHERE outcome IN ('1','3')
        AND dsc_condition IS NOT NULL
        AND TRIM(dsc_condition) <> ''
        AND dsc_condition NOT IN ('1','2','3','-1')
    ),
    orphan_dsc_condition AS (
      SELECT id, hosp_id, date_today,
        'dsc_condition' AS variable,
        'Condition on discharge (' || dsc_condition || ') is recorded but outcome is not Alive or Referred' AS issue,
        dsc_condition AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome NOT IN ('1','3'))
        AND dsc_condition IS NOT NULL
        AND TRIM(dsc_condition) <> ''
    ),

    -- =========================================================================
    -- 443: dsc_dx1_primary ? always visible; Required; radio 1/0/-1
    -- =========================================================================
    missing_dsc_dx1_primary AS (
      SELECT id, hosp_id, date_today,
        'dsc_dx1_primary' AS variable,
        'Clear primary discharge diagnosis field is missing (field is always required)' AS issue,
        dsc_dx1_primary AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR TRIM(dsc_dx1_primary) = '')
    ),
    invalid_dsc_dx1_primary AS (
      SELECT id, hosp_id, date_today,
        'dsc_dx1_primary' AS variable,
        'Clear primary discharge diagnosis field has an unrecognised value (' || dsc_dx1_primary || '); expected 1 (Yes), 0 (No), or -1 (Empty)' AS issue,
        dsc_dx1_primary AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary IS NOT NULL
        AND TRIM(dsc_dx1_primary) <> ''
        AND dsc_dx1_primary NOT IN ('1','0','-1')
    ),

    -- =========================================================================
    -- 444: primary_disch_diagnosis ? gate: dsc_dx1_primary='1'; text
    --      Required when gate is open
    -- =========================================================================
    missing_primary_disch_diagnosis AS (
      SELECT id, hosp_id, date_today,
        'primary_disch_diagnosis' AS variable,
        'Primary discharge diagnosis is missing (a clear primary diagnosis was indicated; documentation is required)' AS issue,
        primary_disch_diagnosis AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary = '1'
        AND (primary_disch_diagnosis IS NULL OR TRIM(primary_disch_diagnosis) = '')
    ),
    orphan_primary_disch_diagnosis AS (
      SELECT id, hosp_id, date_today,
        'primary_disch_diagnosis' AS variable,
        'Primary discharge diagnosis (' || primary_disch_diagnosis || ') is recorded but the primary diagnosis flag is not set to Yes' AS issue,
        primary_disch_diagnosis AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR dsc_dx1_primary <> '1')
        AND primary_disch_diagnosis IS NOT NULL
        AND TRIM(primary_disch_diagnosis) <> ''
    ),

    -- =========================================================================
    -- 445?449: disch_diag_1 through disch_diag_5
    --      gate: dsc_dx1_primary='0'; text
    --      disch_diag_1 required when gate is open;
    --      disch_diag_N+1 requires disch_diag_N (sequential population)
    -- =========================================================================
    missing_disch_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_1' AS variable,
        'Discharge diagnosis 1 is missing (no clear primary diagnosis; at least one diagnosis entry is required)' AS issue,
        disch_diag_1 AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary = '0'
        AND (disch_diag_1 IS NULL OR TRIM(disch_diag_1) = '')
    ),
    orphan_disch_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_1' AS variable,
        'Discharge diagnosis 1 (' || disch_diag_1 || ') is recorded but the primary diagnosis flag is not set to No' AS issue,
        disch_diag_1 AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR dsc_dx1_primary <> '0')
        AND disch_diag_1 IS NOT NULL
        AND TRIM(disch_diag_1) <> ''
    ),
    -- disch_diag_2 requires disch_diag_1
    gap_disch_diag_2 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_2' AS variable,
        'Discharge diagnosis 2 (' || disch_diag_2 || ') is recorded but discharge diagnosis 1 is empty; diagnoses must be entered sequentially' AS issue,
        disch_diag_2 AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary = '0'
        AND disch_diag_2 IS NOT NULL AND TRIM(disch_diag_2) <> ''
        AND (disch_diag_1 IS NULL OR TRIM(disch_diag_1) = '')
    ),
    orphan_disch_diag_2 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_2' AS variable,
        'Discharge diagnosis 2 (' || disch_diag_2 || ') is recorded but the primary diagnosis flag is not set to No' AS issue,
        disch_diag_2 AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR dsc_dx1_primary <> '0')
        AND disch_diag_2 IS NOT NULL AND TRIM(disch_diag_2) <> ''
    ),
    -- disch_diag_3 requires disch_diag_2
    gap_disch_diag_3 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_3' AS variable,
        'Discharge diagnosis 3 (' || disch_diag_3 || ') is recorded but discharge diagnosis 2 is empty; diagnoses must be entered sequentially' AS issue,
        disch_diag_3 AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary = '0'
        AND disch_diag_3 IS NOT NULL AND TRIM(disch_diag_3) <> ''
        AND (disch_diag_2 IS NULL OR TRIM(disch_diag_2) = '')
    ),
    orphan_disch_diag_3 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_3' AS variable,
        'Discharge diagnosis 3 (' || disch_diag_3 || ') is recorded but the primary diagnosis flag is not set to No' AS issue,
        disch_diag_3 AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR dsc_dx1_primary <> '0')
        AND disch_diag_3 IS NOT NULL AND TRIM(disch_diag_3) <> ''
    ),
    -- disch_diag_4 requires disch_diag_3
    gap_disch_diag_4 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_4' AS variable,
        'Discharge diagnosis 4 (' || disch_diag_4 || ') is recorded but discharge diagnosis 3 is empty; diagnoses must be entered sequentially' AS issue,
        disch_diag_4 AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary = '0'
        AND disch_diag_4 IS NOT NULL AND TRIM(disch_diag_4) <> ''
        AND (disch_diag_3 IS NULL OR TRIM(disch_diag_3) = '')
    ),
    orphan_disch_diag_4 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_4' AS variable,
        'Discharge diagnosis 4 (' || disch_diag_4 || ') is recorded but the primary diagnosis flag is not set to No' AS issue,
        disch_diag_4 AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR dsc_dx1_primary <> '0')
        AND disch_diag_4 IS NOT NULL AND TRIM(disch_diag_4) <> ''
    ),
    -- disch_diag_5 requires disch_diag_4
    gap_disch_diag_5 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_5' AS variable,
        'Discharge diagnosis 5 (' || disch_diag_5 || ') is recorded but discharge diagnosis 4 is empty; diagnoses must be entered sequentially' AS issue,
        disch_diag_5 AS current_value
      FROM neonatal_core
      WHERE dsc_dx1_primary = '0'
        AND disch_diag_5 IS NOT NULL AND TRIM(disch_diag_5) <> ''
        AND (disch_diag_4 IS NULL OR TRIM(disch_diag_4) = '')
    ),
    orphan_disch_diag_5 AS (
      SELECT id, hosp_id, date_today,
        'disch_diag_5' AS variable,
        'Discharge diagnosis 5 (' || disch_diag_5 || ') is recorded but the primary diagnosis flag is not set to No' AS issue,
        disch_diag_5 AS current_value
      FROM neonatal_core
      WHERE (dsc_dx1_primary IS NULL OR dsc_dx1_primary <> '0')
        AND disch_diag_5 IS NOT NULL AND TRIM(disch_diag_5) <> ''
    ),

    -- =========================================================================
    -- 450: other_discharge_diag ? always visible; Required; yesno 1/0
    -- =========================================================================
    missing_other_discharge_diag AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag' AS variable,
        'Other discharge diagnosis flag is missing (field is always required)' AS issue,
        other_discharge_diag AS current_value
      FROM neonatal_core
      WHERE (other_discharge_diag IS NULL OR TRIM(other_discharge_diag) = '')
    ),
    invalid_other_discharge_diag AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag' AS variable,
        'Other discharge diagnosis flag has an unrecognised value (' || other_discharge_diag || '); expected 1 (Yes) or 0 (No)' AS issue,
        other_discharge_diag AS current_value
      FROM neonatal_core
      WHERE other_discharge_diag IS NOT NULL
        AND TRIM(other_discharge_diag) <> ''
        AND other_discharge_diag NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 451?455: other_discharge_diag_1 through other_discharge_diag_5
    --      gate: other_discharge_diag='1'; text
    --      other_discharge_diag_1 required when gate is open;
    --      sequential population enforced for 2?5
    -- =========================================================================
    missing_other_discharge_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_1' AS variable,
        'Other discharge diagnosis 1 is missing (other discharge diagnoses were indicated; at least one entry is required)' AS issue,
        other_discharge_diag_1 AS current_value
      FROM neonatal_core
      WHERE other_discharge_diag = '1'
        AND (other_discharge_diag_1 IS NULL OR TRIM(other_discharge_diag_1) = '')
    ),
    orphan_other_discharge_diag_1 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_1' AS variable,
        'Other discharge diagnosis 1 (' || other_discharge_diag_1 || ') is recorded but other discharge diagnoses flag is not set to Yes' AS issue,
        other_discharge_diag_1 AS current_value
      FROM neonatal_core
      WHERE (other_discharge_diag IS NULL OR other_discharge_diag <> '1')
        AND other_discharge_diag_1 IS NOT NULL AND TRIM(other_discharge_diag_1) <> ''
    ),
    gap_other_discharge_diag_2 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_2' AS variable,
        'Other discharge diagnosis 2 (' || other_discharge_diag_2 || ') is recorded but other discharge diagnosis 1 is empty; diagnoses must be entered sequentially' AS issue,
        other_discharge_diag_2 AS current_value
      FROM neonatal_core
      WHERE other_discharge_diag = '1'
        AND other_discharge_diag_2 IS NOT NULL AND TRIM(other_discharge_diag_2) <> ''
        AND (other_discharge_diag_1 IS NULL OR TRIM(other_discharge_diag_1) = '')
    ),
    orphan_other_discharge_diag_2 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_2' AS variable,
        'Other discharge diagnosis 2 (' || other_discharge_diag_2 || ') is recorded but other discharge diagnoses flag is not set to Yes' AS issue,
        other_discharge_diag_2 AS current_value
      FROM neonatal_core
      WHERE (other_discharge_diag IS NULL OR other_discharge_diag <> '1')
        AND other_discharge_diag_2 IS NOT NULL AND TRIM(other_discharge_diag_2) <> ''
    ),
    gap_other_discharge_diag_3 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_3' AS variable,
        'Other discharge diagnosis 3 (' || other_discharge_diag_3 || ') is recorded but other discharge diagnosis 2 is empty; diagnoses must be entered sequentially' AS issue,
        other_discharge_diag_3 AS current_value
      FROM neonatal_core
      WHERE other_discharge_diag = '1'
        AND other_discharge_diag_3 IS NOT NULL AND TRIM(other_discharge_diag_3) <> ''
        AND (other_discharge_diag_2 IS NULL OR TRIM(other_discharge_diag_2) = '')
    ),
    orphan_other_discharge_diag_3 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_3' AS variable,
        'Other discharge diagnosis 3 (' || other_discharge_diag_3 || ') is recorded but other discharge diagnoses flag is not set to Yes' AS issue,
        other_discharge_diag_3 AS current_value
      FROM neonatal_core
      WHERE (other_discharge_diag IS NULL OR other_discharge_diag <> '1')
        AND other_discharge_diag_3 IS NOT NULL AND TRIM(other_discharge_diag_3) <> ''
    ),
    gap_other_discharge_diag_4 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_4' AS variable,
        'Other discharge diagnosis 4 (' || other_discharge_diag_4 || ') is recorded but other discharge diagnosis 3 is empty; diagnoses must be entered sequentially' AS issue,
        other_discharge_diag_4 AS current_value
      FROM neonatal_core
      WHERE other_discharge_diag = '1'
        AND other_discharge_diag_4 IS NOT NULL AND TRIM(other_discharge_diag_4) <> ''
        AND (other_discharge_diag_3 IS NULL OR TRIM(other_discharge_diag_3) = '')
    ),
    orphan_other_discharge_diag_4 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_4' AS variable,
        'Other discharge diagnosis 4 (' || other_discharge_diag_4 || ') is recorded but other discharge diagnoses flag is not set to Yes' AS issue,
        other_discharge_diag_4 AS current_value
      FROM neonatal_core
      WHERE (other_discharge_diag IS NULL OR other_discharge_diag <> '1')
        AND other_discharge_diag_4 IS NOT NULL AND TRIM(other_discharge_diag_4) <> ''
    ),
    gap_other_discharge_diag_5 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_5' AS variable,
        'Other discharge diagnosis 5 (' || other_discharge_diag_5 || ') is recorded but other discharge diagnosis 4 is empty; diagnoses must be entered sequentially' AS issue,
        other_discharge_diag_5 AS current_value
      FROM neonatal_core
      WHERE other_discharge_diag = '1'
        AND other_discharge_diag_5 IS NOT NULL AND TRIM(other_discharge_diag_5) <> ''
        AND (other_discharge_diag_4 IS NULL OR TRIM(other_discharge_diag_4) = '')
    ),
    orphan_other_discharge_diag_5 AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_5' AS variable,
        'Other discharge diagnosis 5 (' || other_discharge_diag_5 || ') is recorded but other discharge diagnoses flag is not set to Yes' AS issue,
        other_discharge_diag_5 AS current_value
      FROM neonatal_core
      WHERE (other_discharge_diag IS NULL OR other_discharge_diag <> '1')
        AND other_discharge_diag_5 IS NOT NULL AND TRIM(other_discharge_diag_5) <> ''
    ),

    -- =========================================================================
    -- 456: any_other_disch_diag ? always visible; not Required; yesno 1/0
    --      Invalid code check only
    -- =========================================================================
    invalid_any_other_disch_diag AS (
      SELECT id, hosp_id, date_today,
        'any_other_disch_diag' AS variable,
        'Any other discharge diagnosis not in the lookup list field has an unrecognised value (' || any_other_disch_diag || '); expected 1 (Yes) or 0 (No)' AS issue,
        any_other_disch_diag AS current_value
      FROM neonatal_core
      WHERE any_other_disch_diag IS NOT NULL
        AND TRIM(any_other_disch_diag) <> ''
        AND any_other_disch_diag NOT IN ('1','0')
    ),

    -- =========================================================================
    -- 457: other_disch_diag_old ? EXCLUDED
    --      (any_other_disch_diag='1' AND any_other_disch_diag='0' contradiction)
    -- =========================================================================

    -- =========================================================================
    -- 458: other_discharge_diag_unlisted
    --      gate: any_other_disch_diag='1'; text
    --      Required when gate is open; orphan check when gate is closed
    -- =========================================================================
    missing_other_discharge_diag_unlisted AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_unlisted' AS variable,
        'List of discharge diagnoses not in the lookup list is missing (unlisted diagnoses were indicated; free text entry is required)' AS issue,
        other_discharge_diag_unlisted AS current_value
      FROM neonatal_core
      WHERE any_other_disch_diag = '1'
        AND (other_discharge_diag_unlisted IS NULL OR TRIM(other_discharge_diag_unlisted) = '')
    ),
    orphan_other_discharge_diag_unlisted AS (
      SELECT id, hosp_id, date_today,
        'other_discharge_diag_unlisted' AS variable,
        'Unlisted discharge diagnoses (' || other_discharge_diag_unlisted || ') is recorded but the unlisted diagnoses flag is not set to Yes' AS issue,
        other_discharge_diag_unlisted AS current_value
      FROM neonatal_core
      WHERE (any_other_disch_diag IS NULL OR any_other_disch_diag <> '1')
        AND other_discharge_diag_unlisted IS NOT NULL
        AND TRIM(other_discharge_diag_unlisted) <> ''
    ),

    -- =========================================================================
    -- 459: in_chloro ? gate: GIS Kenya hospital IDs; Required; yesno 1/0
    -- =========================================================================
    missing_in_chloro AS (
      SELECT id, hosp_id, date_today,
        'in_chloro' AS variable,
        'Cord chlorhexidine administered is missing (Kenya GIS hospital; field is required)' AS issue,
        in_chloro AS current_value
      FROM neonatal_core
      WHERE hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND (in_chloro IS NULL OR TRIM(in_chloro) = '')
    ),
    invalid_in_chloro AS (
      SELECT id, hosp_id, date_today,
        'in_chloro' AS variable,
        'Cord chlorhexidine administered field has an unrecognised value (' || in_chloro || '); expected 1 (Yes) or 0 (No)' AS issue,
        in_chloro AS current_value
      FROM neonatal_core
      WHERE hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND in_chloro IS NOT NULL
        AND TRIM(in_chloro) <> ''
        AND in_chloro NOT IN ('1','0')
    ),
    orphan_in_chloro AS (
      SELECT id, hosp_id, date_today,
        'in_chloro' AS variable,
        'Cord chlorhexidine administered (' || in_chloro || ') is recorded but this hospital (' || hosp_id || ') is not in the GIS Kenya hospital list' AS issue,
        in_chloro AS current_value
      FROM neonatal_core
      WHERE hosp_id NOT IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND in_chloro IS NOT NULL
        AND TRIM(in_chloro) <> ''
    ),

    -- =========================================================================
    -- 460: in_vitk ? gate: GIS Kenya hospital IDs; Required; yesno 1/0
    -- =========================================================================
    missing_in_vitk AS (
      SELECT id, hosp_id, date_today,
        'in_vitk' AS variable,
        'Vitamin K administered is missing (Kenya GIS hospital; field is required)' AS issue,
        in_vitk AS current_value
      FROM neonatal_core
      WHERE hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND (in_vitk IS NULL OR TRIM(in_vitk) = '')
    ),
    invalid_in_vitk AS (
      SELECT id, hosp_id, date_today,
        'in_vitk' AS variable,
        'Vitamin K administered field has an unrecognised value (' || in_vitk || '); expected 1 (Yes) or 0 (No)' AS issue,
        in_vitk AS current_value
      FROM neonatal_core
      WHERE hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND in_vitk IS NOT NULL
        AND TRIM(in_vitk) <> ''
        AND in_vitk NOT IN ('1','0')
    ),
    orphan_in_vitk AS (
      SELECT id, hosp_id, date_today,
        'in_vitk' AS variable,
        'Vitamin K administered (' || in_vitk || ') is recorded but this hospital (' || hosp_id || ') is not in the GIS Kenya hospital list' AS issue,
        in_vitk AS current_value
      FROM neonatal_core
      WHERE hosp_id NOT IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND in_vitk IS NOT NULL
        AND TRIM(in_vitk) <> ''
    ),

    -- =========================================================================
    -- 461: in_bil_hi
    --      gate: (bilirubin_type___2='1' OR bilirubin_type___1='1'
    --             OR phototherapy='1' OR photo_therapy_on_any_other='1')
    --            AND GIS Kenya hospital IDs
    --      Required; numeric (-1 sentinel)
    --      Plausible range: >0 (validated through gate: entered when bilirubin
    --      or phototherapy is active); -1 is valid empty sentinel
    -- =========================================================================
    missing_in_bil_hi AS (
      SELECT id, hosp_id, date_today,
        'in_bil_hi' AS variable,
        'Highest bilirubin value is missing (bilirubin or phototherapy documented and Kenya GIS hospital; field is required; enter -1 if unrecorded)' AS issue,
        in_bil_hi AS current_value
      FROM neonatal_core
      WHERE hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
        AND (
          bilirubin_type___2 = '1'
          OR bilirubin_type___1 = '1'
          OR phototherapy = '1'
          OR photo_therapy_on_any_other = '1'
        )
        AND (in_bil_hi IS NULL OR TRIM(in_bil_hi) = '')
    ),
    orphan_in_bil_hi AS (
      SELECT id, hosp_id, date_today,
        'in_bil_hi' AS variable,
        'Highest bilirubin (' || in_bil_hi || ') is recorded but the gate conditions are not met (no bilirubin/phototherapy documentation or non-GIS hospital)' AS issue,
        in_bil_hi AS current_value
      FROM neonatal_core
      WHERE NOT (
          hosp_id IN ('53','58','41','51','45','40','71','55','52','63','76')
          AND (
            bilirubin_type___2 = '1'
            OR bilirubin_type___1 = '1'
            OR phototherapy = '1'
            OR photo_therapy_on_any_other = '1'
          )
        )
        AND in_bil_hi IS NOT NULL
        AND TRIM(in_bil_hi) <> ''
    ),

    -- =========================================================================
    -- 462: bilirubin_hi_unit
    --      gate: in_bil_hi > 0; Required; radio 1/2/-1
    -- =========================================================================
    missing_bilirubin_hi_unit AS (
      SELECT id, hosp_id, date_today,
        'bilirubin_hi_unit' AS variable,
        'Highest bilirubin units are missing (a positive highest bilirubin value is recorded; units are required)' AS issue,
        bilirubin_hi_unit AS current_value
      FROM neonatal_core
      WHERE in_bil_hi IS NOT NULL
        AND TRIM(in_bil_hi) <> ''
        AND TRY_CAST(in_bil_hi AS FLOAT) IS NOT NULL
        AND TRY_CAST(in_bil_hi AS FLOAT) > 0
        AND (bilirubin_hi_unit IS NULL OR TRIM(bilirubin_hi_unit) = '')
    ),
    invalid_bilirubin_hi_unit AS (
      SELECT id, hosp_id, date_today,
        'bilirubin_hi_unit' AS variable,
        'Highest bilirubin units field has an unrecognised value (' || bilirubin_hi_unit || '); expected 1 (micromol/L), 2 (mg/dL), or -1 (Empty)' AS issue,
        bilirubin_hi_unit AS current_value
      FROM neonatal_core
      WHERE in_bil_hi IS NOT NULL
        AND TRIM(in_bil_hi) <> ''
        AND TRY_CAST(in_bil_hi AS FLOAT) IS NOT NULL
        AND TRY_CAST(in_bil_hi AS FLOAT) > 0
        AND bilirubin_hi_unit IS NOT NULL
        AND TRIM(bilirubin_hi_unit) <> ''
        AND bilirubin_hi_unit NOT IN ('1','2','-1')
    ),
    orphan_bilirubin_hi_unit AS (
      SELECT id, hosp_id, date_today,
        'bilirubin_hi_unit' AS variable,
        'Highest bilirubin units (' || bilirubin_hi_unit || ') is recorded but the highest bilirubin value is not a positive number' AS issue,
        bilirubin_hi_unit AS current_value
      FROM neonatal_core
      WHERE NOT (
          in_bil_hi IS NOT NULL
          AND TRIM(in_bil_hi) <> ''
          AND TRY_CAST(in_bil_hi AS FLOAT) IS NOT NULL
          AND TRY_CAST(in_bil_hi AS FLOAT) > 0
        )
        AND bilirubin_hi_unit IS NOT NULL
        AND TRIM(bilirubin_hi_unit) <> ''
    ),

    -- =========================================================================
    -- 463: opv ? EXCLUDED (is_minimum='0' AND is_minimum='1' contradiction)
    -- 464: bcg ? EXCLUDED (is_minimum='0' AND is_minimum='1' contradiction)
    -- =========================================================================

    -- =========================================================================
    -- 465: baby_feeding_disch ? gate: outcome='1'; dropdown 1?5
    --      Not Required; missing check applied when gate is open
    -- =========================================================================
    missing_baby_feeding_disch AS (
      SELECT id, hosp_id, date_today,
        'baby_feeding_disch' AS variable,
        'Baby feeding at discharge is missing (outcome is Alive; documentation is expected)' AS issue,
        baby_feeding_disch AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND (baby_feeding_disch IS NULL OR TRIM(baby_feeding_disch) = '')
    ),
    invalid_baby_feeding_disch AS (
      SELECT id, hosp_id, date_today,
        'baby_feeding_disch' AS variable,
        'Baby feeding at discharge has an unrecognised value (' || baby_feeding_disch || '); expected 1 (Breast milk only), 2 (Formula only), 3 (Formula & Breast milk), 4 (Fortified Breast milk), or 5 (Empty)' AS issue,
        baby_feeding_disch AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND baby_feeding_disch IS NOT NULL
        AND TRIM(baby_feeding_disch) <> ''
        AND baby_feeding_disch NOT IN ('1','2','3','4','5')
    ),
    orphan_baby_feeding_disch AS (
      SELECT id, hosp_id, date_today,
        'baby_feeding_disch' AS variable,
        'Baby feeding at discharge (' || baby_feeding_disch || ') is recorded but outcome is not Alive' AS issue,
        baby_feeding_disch AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND baby_feeding_disch IS NOT NULL
        AND TRIM(baby_feeding_disch) <> ''
    ),

        -- =========================================================================
    -- POST DISCHARGE WEIGHT MONITORING SECTION DQA (fields 467?485)
    -- instrument: post_discharge_weights
    -- =========================================================================

    -- =========================================================================
    -- GATE SUMMARY
    --
    --   post_discharge_weight_other (470) is a CALC field hardcoded to 1.
    --   Therefore:
    --     - outcome='1' AND post_discharge_weight_other='1'
    --       simplifies to outcome='1' for ALL visit 2?6 fields.
    --   All 19 fields in this section are gated exclusively by outcome='1'.
    --
    --   Visit 1  (467?469): gate = outcome='1'
    --   Visits 2?6 (471?485): gate = outcome='1' AND calc=1 ? outcome='1'
    --
    -- FIELD LAYOUT PER VISIT:
    --   post_weight_dateN   : text (date); not Required; visit date
    --   post_weight_unitN   : radio -1/1/2; not Required; weight units
    --   postdischarge_weight_N : text (number); not Required; weight value
    --
    -- SEQUENTIAL POPULATION RULE:
    --   Visit N+1 fields should not be populated if Visit N date and weight
    --   are both absent (date-and-weight pair treated as the unit of presence).
    --   Weight N+1 requires weight N to have been recorded.
    --
    -- PLAUSIBILITY:
    --   Grams   : 200?8000 g  (consistent with neonatal weight plausibility
    --             in the rest of the script)
    --   Kilograms: 0.2?8.0 kg
    --
    -- TEMPORAL CONSISTENCY:
    --   Each visit date must be >= date_adm (discharge date is the minimum
    --   sensible lower bound for a post-discharge visit).
    --   Visit N+1 date must be >= Visit N date (visits must be chronological).
    --   1914-01-01 placeholder excluded from temporal arithmetic.
    --
    -- NOTE ON LABEL MISMATCH:
    --   The form labels Visit 3 date as field 477 and Visit 4 date as field 474.
    --   The DQA follows the FIELD NAME (post_weight_date3, post_weight_date4)
    --   and variable order (3 before 4) regardless of the display label error.
    --
    -- EXCLUDED: none in this section.
    -- =========================================================================

    -- =========================================================================
    -- HELPER: flag a visit as "present" when either the date or the weight
    -- value has been entered (a partially completed visit is still a visit).
    -- =========================================================================

    -- =========================================================================
    -- VISIT 1  (467?469) gate: outcome='1'
    -- =========================================================================

    -- 467: post_weight_date1 ? orphan when gate closed
    orphan_post_weight_date1 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date1' AS variable,
        'Post-discharge visit 1 date (' || post_weight_date1 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_date1 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_date1 IS NOT NULL
        AND TRIM(post_weight_date1) <> ''
        AND post_weight_date1 <> '1914-01-01'
    ),
    -- date must be >= discharge/admission date
    temporal_post_weight_date1 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date1' AS variable,
        'Post-discharge visit 1 date (' || post_weight_date1 || ') precedes the admission date (' || date_adm || '); a post-discharge visit cannot occur before admission' AS issue,
        post_weight_date1 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date1 IS NOT NULL
        AND TRIM(post_weight_date1) <> ''
        AND post_weight_date1 <> '1914-01-01'
        AND date_adm IS NOT NULL
        AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(post_weight_date1 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date1 AS DATE) < TRY_CAST(date_adm AS DATE)
    ),

    -- 468: post_weight_unit1
    missing_post_weight_unit1 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit1' AS variable,
        'Post-discharge visit 1 weight units are missing (a weight value is recorded for visit 1; units are required)' AS issue,
        post_weight_unit1 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_1 IS NOT NULL
        AND TRIM(postdischarge_weight_1) <> ''
        AND TRY_CAST(postdischarge_weight_1 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_1 AS FLOAT) > 0
        AND (post_weight_unit1 IS NULL OR TRIM(post_weight_unit1) = '')
    ),
    invalid_post_weight_unit1 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit1' AS variable,
        'Post-discharge visit 1 weight units field has an unrecognised value (' || post_weight_unit1 || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        post_weight_unit1 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_unit1 IS NOT NULL
        AND TRIM(post_weight_unit1) <> ''
        AND post_weight_unit1 NOT IN ('1','2','-1')
    ),
    orphan_post_weight_unit1 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit1' AS variable,
        'Post-discharge visit 1 weight units (' || post_weight_unit1 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_unit1 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_unit1 IS NOT NULL
        AND TRIM(post_weight_unit1) <> ''
    ),

    -- 469: postdischarge_weight_1 ? plausibility
    implausible_postdischarge_weight_1 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_1' AS variable,
        'Post-discharge visit 1 weight (' || postdischarge_weight_1 || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(post_weight_unit1,'unknown') || '); verify the value and units' AS issue,
        postdischarge_weight_1 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_1 IS NOT NULL
        AND TRIM(postdischarge_weight_1) <> ''
        AND TRY_CAST(postdischarge_weight_1 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_1 AS FLOAT) > 0
        AND (
          (post_weight_unit1 = '1'
            AND (TRY_CAST(postdischarge_weight_1 AS FLOAT) < 200
              OR TRY_CAST(postdischarge_weight_1 AS FLOAT) > 8000))
          OR
          (post_weight_unit1 = '2'
            AND (TRY_CAST(postdischarge_weight_1 AS FLOAT) < 0.2
              OR TRY_CAST(postdischarge_weight_1 AS FLOAT) > 8.0))
        )
    ),
    orphan_postdischarge_weight_1 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_1' AS variable,
        'Post-discharge visit 1 weight (' || postdischarge_weight_1 || ') is recorded but outcome is not Alive' AS issue,
        postdischarge_weight_1 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND postdischarge_weight_1 IS NOT NULL
        AND TRIM(postdischarge_weight_1) <> ''
    ),

    -- =========================================================================
    -- VISITS 2?6  gate: outcome='1' (calc field = 1 is always true)
    -- Macro-like pattern repeated for each visit:
    --   (a) orphan check on date when outcome <> '1'
    --   (b) temporal check: visit date >= date_adm
    --   (c) temporal check: visit N date >= visit N-1 date
    --   (d) missing units when weight > 0
    --   (e) invalid units code
    --   (f) orphan units when outcome <> '1'
    --   (g) implausible weight
    --   (h) orphan weight when outcome <> '1'
    --   (i) sequential gap: visit N weight requires visit N-1 weight
    -- =========================================================================

    -- =========================================================================
    -- VISIT 2  (471?473)
    -- =========================================================================
    orphan_post_weight_date2 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date2' AS variable,
        'Post-discharge visit 2 date (' || post_weight_date2 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_date2 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_date2 IS NOT NULL
        AND TRIM(post_weight_date2) <> ''
        AND post_weight_date2 <> '1914-01-01'
    ),
    temporal_post_weight_date2_adm AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date2' AS variable,
        'Post-discharge visit 2 date (' || post_weight_date2 || ') precedes the admission date (' || date_adm || '); a post-discharge visit cannot occur before admission' AS issue,
        post_weight_date2 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date2 IS NOT NULL AND TRIM(post_weight_date2) <> ''
        AND post_weight_date2 <> '1914-01-01'
        AND date_adm IS NOT NULL AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(post_weight_date2 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date2 AS DATE) < TRY_CAST(date_adm AS DATE)
    ),
    temporal_post_weight_date2_seq AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date2' AS variable,
        'Post-discharge visit 2 date (' || post_weight_date2 || ') is earlier than visit 1 date (' || post_weight_date1 || '); visit dates must be in chronological order' AS issue,
        post_weight_date2 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date2 IS NOT NULL AND TRIM(post_weight_date2) <> ''
        AND post_weight_date2 <> '1914-01-01'
        AND post_weight_date1 IS NOT NULL AND TRIM(post_weight_date1) <> ''
        AND post_weight_date1 <> '1914-01-01'
        AND TRY_CAST(post_weight_date2 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date1 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date2 AS DATE) < TRY_CAST(post_weight_date1 AS DATE)
    ),
    missing_post_weight_unit2 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit2' AS variable,
        'Post-discharge visit 2 weight units are missing (a weight value is recorded for visit 2; units are required)' AS issue,
        post_weight_unit2 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_2 IS NOT NULL AND TRIM(postdischarge_weight_2) <> ''
        AND TRY_CAST(postdischarge_weight_2 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_2 AS FLOAT) > 0
        AND (post_weight_unit2 IS NULL OR TRIM(post_weight_unit2) = '')
    ),
    invalid_post_weight_unit2 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit2' AS variable,
        'Post-discharge visit 2 weight units field has an unrecognised value (' || post_weight_unit2 || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        post_weight_unit2 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_unit2 IS NOT NULL AND TRIM(post_weight_unit2) <> ''
        AND post_weight_unit2 NOT IN ('1','2','-1')
    ),
    orphan_post_weight_unit2 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit2' AS variable,
        'Post-discharge visit 2 weight units (' || post_weight_unit2 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_unit2 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_unit2 IS NOT NULL AND TRIM(post_weight_unit2) <> ''
    ),
    implausible_postdischarge_weight_2 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_2' AS variable,
        'Post-discharge visit 2 weight (' || postdischarge_weight_2 || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(post_weight_unit2,'unknown') || '); verify the value and units' AS issue,
        postdischarge_weight_2 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_2 IS NOT NULL AND TRIM(postdischarge_weight_2) <> ''
        AND TRY_CAST(postdischarge_weight_2 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_2 AS FLOAT) > 0
        AND (
          (post_weight_unit2 = '1'
            AND (TRY_CAST(postdischarge_weight_2 AS FLOAT) < 200
              OR TRY_CAST(postdischarge_weight_2 AS FLOAT) > 8000))
          OR
          (post_weight_unit2 = '2'
            AND (TRY_CAST(postdischarge_weight_2 AS FLOAT) < 0.2
              OR TRY_CAST(postdischarge_weight_2 AS FLOAT) > 8.0))
        )
    ),
    orphan_postdischarge_weight_2 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_2' AS variable,
        'Post-discharge visit 2 weight (' || postdischarge_weight_2 || ') is recorded but outcome is not Alive' AS issue,
        postdischarge_weight_2 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND postdischarge_weight_2 IS NOT NULL AND TRIM(postdischarge_weight_2) <> ''
    ),
    gap_postdischarge_weight_2 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_2' AS variable,
        'Post-discharge visit 2 weight (' || postdischarge_weight_2 || ') is recorded but visit 1 weight is absent; weights must be entered sequentially' AS issue,
        postdischarge_weight_2 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_2 IS NOT NULL AND TRIM(postdischarge_weight_2) <> ''
        AND (postdischarge_weight_1 IS NULL OR TRIM(postdischarge_weight_1) = '')
    ),

    -- =========================================================================
    -- VISIT 3  (474?476)
    -- =========================================================================
    orphan_post_weight_date3 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date3' AS variable,
        'Post-discharge visit 3 date (' || post_weight_date3 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_date3 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_date3 IS NOT NULL AND TRIM(post_weight_date3) <> ''
        AND post_weight_date3 <> '1914-01-01'
    ),
    temporal_post_weight_date3_adm AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date3' AS variable,
        'Post-discharge visit 3 date (' || post_weight_date3 || ') precedes the admission date (' || date_adm || '); a post-discharge visit cannot occur before admission' AS issue,
        post_weight_date3 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date3 IS NOT NULL AND TRIM(post_weight_date3) <> ''
        AND post_weight_date3 <> '1914-01-01'
        AND date_adm IS NOT NULL AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(post_weight_date3 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date3 AS DATE) < TRY_CAST(date_adm AS DATE)
    ),
    temporal_post_weight_date3_seq AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date3' AS variable,
        'Post-discharge visit 3 date (' || post_weight_date3 || ') is earlier than visit 2 date (' || post_weight_date2 || '); visit dates must be in chronological order' AS issue,
        post_weight_date3 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date3 IS NOT NULL AND TRIM(post_weight_date3) <> ''
        AND post_weight_date3 <> '1914-01-01'
        AND post_weight_date2 IS NOT NULL AND TRIM(post_weight_date2) <> ''
        AND post_weight_date2 <> '1914-01-01'
        AND TRY_CAST(post_weight_date3 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date2 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date3 AS DATE) < TRY_CAST(post_weight_date2 AS DATE)
    ),
    missing_post_weight_unit3 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit3' AS variable,
        'Post-discharge visit 3 weight units are missing (a weight value is recorded for visit 3; units are required)' AS issue,
        post_weight_unit3 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_3 IS NOT NULL AND TRIM(postdischarge_weight_3) <> ''
        AND TRY_CAST(postdischarge_weight_3 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_3 AS FLOAT) > 0
        AND (post_weight_unit3 IS NULL OR TRIM(post_weight_unit3) = '')
    ),
    invalid_post_weight_unit3 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit3' AS variable,
        'Post-discharge visit 3 weight units field has an unrecognised value (' || post_weight_unit3 || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        post_weight_unit3 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_unit3 IS NOT NULL AND TRIM(post_weight_unit3) <> ''
        AND post_weight_unit3 NOT IN ('1','2','-1')
    ),
    orphan_post_weight_unit3 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit3' AS variable,
        'Post-discharge visit 3 weight units (' || post_weight_unit3 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_unit3 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_unit3 IS NOT NULL AND TRIM(post_weight_unit3) <> ''
    ),
    implausible_postdischarge_weight_3 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_3' AS variable,
        'Post-discharge visit 3 weight (' || postdischarge_weight_3 || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(post_weight_unit3,'unknown') || '); verify the value and units' AS issue,
        postdischarge_weight_3 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_3 IS NOT NULL AND TRIM(postdischarge_weight_3) <> ''
        AND TRY_CAST(postdischarge_weight_3 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_3 AS FLOAT) > 0
        AND (
          (post_weight_unit3 = '1'
            AND (TRY_CAST(postdischarge_weight_3 AS FLOAT) < 200
              OR TRY_CAST(postdischarge_weight_3 AS FLOAT) > 8000))
          OR
          (post_weight_unit3 = '2'
            AND (TRY_CAST(postdischarge_weight_3 AS FLOAT) < 0.2
              OR TRY_CAST(postdischarge_weight_3 AS FLOAT) > 8.0))
        )
    ),
    orphan_postdischarge_weight_3 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_3' AS variable,
        'Post-discharge visit 3 weight (' || postdischarge_weight_3 || ') is recorded but outcome is not Alive' AS issue,
        postdischarge_weight_3 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND postdischarge_weight_3 IS NOT NULL AND TRIM(postdischarge_weight_3) <> ''
    ),
    gap_postdischarge_weight_3 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_3' AS variable,
        'Post-discharge visit 3 weight (' || postdischarge_weight_3 || ') is recorded but visit 2 weight is absent; weights must be entered sequentially' AS issue,
        postdischarge_weight_3 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_3 IS NOT NULL AND TRIM(postdischarge_weight_3) <> ''
        AND (postdischarge_weight_2 IS NULL OR TRIM(postdischarge_weight_2) = '')
    ),

    -- =========================================================================
    -- VISIT 4  (477?479)
    -- =========================================================================
    orphan_post_weight_date4 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date4' AS variable,
        'Post-discharge visit 4 date (' || post_weight_date4 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_date4 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_date4 IS NOT NULL AND TRIM(post_weight_date4) <> ''
        AND post_weight_date4 <> '1914-01-01'
    ),
    temporal_post_weight_date4_adm AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date4' AS variable,
        'Post-discharge visit 4 date (' || post_weight_date4 || ') precedes the admission date (' || date_adm || '); a post-discharge visit cannot occur before admission' AS issue,
        post_weight_date4 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date4 IS NOT NULL AND TRIM(post_weight_date4) <> ''
        AND post_weight_date4 <> '1914-01-01'
        AND date_adm IS NOT NULL AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(post_weight_date4 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date4 AS DATE) < TRY_CAST(date_adm AS DATE)
    ),
    temporal_post_weight_date4_seq AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date4' AS variable,
        'Post-discharge visit 4 date (' || post_weight_date4 || ') is earlier than visit 3 date (' || post_weight_date3 || '); visit dates must be in chronological order' AS issue,
        post_weight_date4 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date4 IS NOT NULL AND TRIM(post_weight_date4) <> ''
        AND post_weight_date4 <> '1914-01-01'
        AND post_weight_date3 IS NOT NULL AND TRIM(post_weight_date3) <> ''
        AND post_weight_date3 <> '1914-01-01'
        AND TRY_CAST(post_weight_date4 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date3 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date4 AS DATE) < TRY_CAST(post_weight_date3 AS DATE)
    ),
    missing_post_weight_unit4 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit4' AS variable,
        'Post-discharge visit 4 weight units are missing (a weight value is recorded for visit 4; units are required)' AS issue,
        post_weight_unit4 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_4 IS NOT NULL AND TRIM(postdischarge_weight_4) <> ''
        AND TRY_CAST(postdischarge_weight_4 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_4 AS FLOAT) > 0
        AND (post_weight_unit4 IS NULL OR TRIM(post_weight_unit4) = '')
    ),
    invalid_post_weight_unit4 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit4' AS variable,
        'Post-discharge visit 4 weight units field has an unrecognised value (' || post_weight_unit4 || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        post_weight_unit4 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_unit4 IS NOT NULL AND TRIM(post_weight_unit4) <> ''
        AND post_weight_unit4 NOT IN ('1','2','-1')
    ),
    orphan_post_weight_unit4 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit4' AS variable,
        'Post-discharge visit 4 weight units (' || post_weight_unit4 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_unit4 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_unit4 IS NOT NULL AND TRIM(post_weight_unit4) <> ''
    ),
    implausible_postdischarge_weight_4 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_4' AS variable,
        'Post-discharge visit 4 weight (' || postdischarge_weight_4 || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(post_weight_unit4,'unknown') || '); verify the value and units' AS issue,
        postdischarge_weight_4 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_4 IS NOT NULL AND TRIM(postdischarge_weight_4) <> ''
        AND TRY_CAST(postdischarge_weight_4 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_4 AS FLOAT) > 0
        AND (
          (post_weight_unit4 = '1'
            AND (TRY_CAST(postdischarge_weight_4 AS FLOAT) < 200
              OR TRY_CAST(postdischarge_weight_4 AS FLOAT) > 8000))
          OR
          (post_weight_unit4 = '2'
            AND (TRY_CAST(postdischarge_weight_4 AS FLOAT) < 0.2
              OR TRY_CAST(postdischarge_weight_4 AS FLOAT) > 8.0))
        )
    ),
    orphan_postdischarge_weight_4 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_4' AS variable,
        'Post-discharge visit 4 weight (' || postdischarge_weight_4 || ') is recorded but outcome is not Alive' AS issue,
        postdischarge_weight_4 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND postdischarge_weight_4 IS NOT NULL AND TRIM(postdischarge_weight_4) <> ''
    ),
    gap_postdischarge_weight_4 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_4' AS variable,
        'Post-discharge visit 4 weight (' || postdischarge_weight_4 || ') is recorded but visit 3 weight is absent; weights must be entered sequentially' AS issue,
        postdischarge_weight_4 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_4 IS NOT NULL AND TRIM(postdischarge_weight_4) <> ''
        AND (postdischarge_weight_3 IS NULL OR TRIM(postdischarge_weight_3) = '')
    ),

    -- =========================================================================
    -- VISIT 5  (480?482)
    -- =========================================================================
    orphan_post_weight_date5 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date5' AS variable,
        'Post-discharge visit 5 date (' || post_weight_date5 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_date5 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_date5 IS NOT NULL AND TRIM(post_weight_date5) <> ''
        AND post_weight_date5 <> '1914-01-01'
    ),
    temporal_post_weight_date5_adm AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date5' AS variable,
        'Post-discharge visit 5 date (' || post_weight_date5 || ') precedes the admission date (' || date_adm || '); a post-discharge visit cannot occur before admission' AS issue,
        post_weight_date5 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date5 IS NOT NULL AND TRIM(post_weight_date5) <> ''
        AND post_weight_date5 <> '1914-01-01'
        AND date_adm IS NOT NULL AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(post_weight_date5 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date5 AS DATE) < TRY_CAST(date_adm AS DATE)
    ),
    temporal_post_weight_date5_seq AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date5' AS variable,
        'Post-discharge visit 5 date (' || post_weight_date5 || ') is earlier than visit 4 date (' || post_weight_date4 || '); visit dates must be in chronological order' AS issue,
        post_weight_date5 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date5 IS NOT NULL AND TRIM(post_weight_date5) <> ''
        AND post_weight_date5 <> '1914-01-01'
        AND post_weight_date4 IS NOT NULL AND TRIM(post_weight_date4) <> ''
        AND post_weight_date4 <> '1914-01-01'
        AND TRY_CAST(post_weight_date5 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date4 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date5 AS DATE) < TRY_CAST(post_weight_date4 AS DATE)
    ),
    missing_post_weight_unit5 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit5' AS variable,
        'Post-discharge visit 5 weight units are missing (a weight value is recorded for visit 5; units are required)' AS issue,
        post_weight_unit5 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_5 IS NOT NULL AND TRIM(postdischarge_weight_5) <> ''
        AND TRY_CAST(postdischarge_weight_5 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_5 AS FLOAT) > 0
        AND (post_weight_unit5 IS NULL OR TRIM(post_weight_unit5) = '')
    ),
    invalid_post_weight_unit5 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit5' AS variable,
        'Post-discharge visit 5 weight units field has an unrecognised value (' || post_weight_unit5 || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        post_weight_unit5 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_unit5 IS NOT NULL AND TRIM(post_weight_unit5) <> ''
        AND post_weight_unit5 NOT IN ('1','2','-1')
    ),
    orphan_post_weight_unit5 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit5' AS variable,
        'Post-discharge visit 5 weight units (' || post_weight_unit5 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_unit5 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_unit5 IS NOT NULL AND TRIM(post_weight_unit5) <> ''
    ),
    implausible_postdischarge_weight_5 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_5' AS variable,
        'Post-discharge visit 5 weight (' || postdischarge_weight_5 || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(post_weight_unit5,'unknown') || '); verify the value and units' AS issue,
        postdischarge_weight_5 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_5 IS NOT NULL AND TRIM(postdischarge_weight_5) <> ''
        AND TRY_CAST(postdischarge_weight_5 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_5 AS FLOAT) > 0
        AND (
          (post_weight_unit5 = '1'
            AND (TRY_CAST(postdischarge_weight_5 AS FLOAT) < 200
              OR TRY_CAST(postdischarge_weight_5 AS FLOAT) > 8000))
          OR
          (post_weight_unit5 = '2'
            AND (TRY_CAST(postdischarge_weight_5 AS FLOAT) < 0.2
              OR TRY_CAST(postdischarge_weight_5 AS FLOAT) > 8.0))
        )
    ),
    orphan_postdischarge_weight_5 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_5' AS variable,
        'Post-discharge visit 5 weight (' || postdischarge_weight_5 || ') is recorded but outcome is not Alive' AS issue,
        postdischarge_weight_5 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND postdischarge_weight_5 IS NOT NULL AND TRIM(postdischarge_weight_5) <> ''
    ),
    gap_postdischarge_weight_5 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_5' AS variable,
        'Post-discharge visit 5 weight (' || postdischarge_weight_5 || ') is recorded but visit 4 weight is absent; weights must be entered sequentially' AS issue,
        postdischarge_weight_5 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_5 IS NOT NULL AND TRIM(postdischarge_weight_5) <> ''
        AND (postdischarge_weight_4 IS NULL OR TRIM(postdischarge_weight_4) = '')
    ),

    -- =========================================================================
    -- VISIT 6  (483?485)
    -- =========================================================================
    orphan_post_weight_date6 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date6' AS variable,
        'Post-discharge visit 6 date (' || post_weight_date6 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_date6 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_date6 IS NOT NULL AND TRIM(post_weight_date6) <> ''
        AND post_weight_date6 <> '1914-01-01'
    ),
    temporal_post_weight_date6_adm AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date6' AS variable,
        'Post-discharge visit 6 date (' || post_weight_date6 || ') precedes the admission date (' || date_adm || '); a post-discharge visit cannot occur before admission' AS issue,
        post_weight_date6 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date6 IS NOT NULL AND TRIM(post_weight_date6) <> ''
        AND post_weight_date6 <> '1914-01-01'
        AND date_adm IS NOT NULL AND TRIM(date_adm) <> ''
        AND date_adm <> '1914-01-01'
        AND TRY_CAST(post_weight_date6 AS DATE) IS NOT NULL
        AND TRY_CAST(date_adm AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date6 AS DATE) < TRY_CAST(date_adm AS DATE)
    ),
    temporal_post_weight_date6_seq AS (
      SELECT id, hosp_id, date_today,
        'post_weight_date6' AS variable,
        'Post-discharge visit 6 date (' || post_weight_date6 || ') is earlier than visit 5 date (' || post_weight_date5 || '); visit dates must be in chronological order' AS issue,
        post_weight_date6 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_date6 IS NOT NULL AND TRIM(post_weight_date6) <> ''
        AND post_weight_date6 <> '1914-01-01'
        AND post_weight_date5 IS NOT NULL AND TRIM(post_weight_date5) <> ''
        AND post_weight_date5 <> '1914-01-01'
        AND TRY_CAST(post_weight_date6 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date5 AS DATE) IS NOT NULL
        AND TRY_CAST(post_weight_date6 AS DATE) < TRY_CAST(post_weight_date5 AS DATE)
    ),
    missing_post_weight_unit6 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit6' AS variable,
        'Post-discharge visit 6 weight units are missing (a weight value is recorded for visit 6; units are required)' AS issue,
        post_weight_unit6 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_6 IS NOT NULL AND TRIM(postdischarge_weight_6) <> ''
        AND TRY_CAST(postdischarge_weight_6 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_6 AS FLOAT) > 0
        AND (post_weight_unit6 IS NULL OR TRIM(post_weight_unit6) = '')
    ),
    invalid_post_weight_unit6 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit6' AS variable,
        'Post-discharge visit 6 weight units field has an unrecognised value (' || post_weight_unit6 || '); expected 1 (Grams), 2 (Kilograms), or -1 (Empty)' AS issue,
        post_weight_unit6 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND post_weight_unit6 IS NOT NULL AND TRIM(post_weight_unit6) <> ''
        AND post_weight_unit6 NOT IN ('1','2','-1')
    ),
    orphan_post_weight_unit6 AS (
      SELECT id, hosp_id, date_today,
        'post_weight_unit6' AS variable,
        'Post-discharge visit 6 weight units (' || post_weight_unit6 || ') is recorded but outcome is not Alive' AS issue,
        post_weight_unit6 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND post_weight_unit6 IS NOT NULL AND TRIM(post_weight_unit6) <> ''
    ),
    implausible_postdischarge_weight_6 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_6' AS variable,
        'Post-discharge visit 6 weight (' || postdischarge_weight_6 || ') is outside the plausible neonatal range for the recorded units (' || COALESCE(post_weight_unit6,'unknown') || '); verify the value and units' AS issue,
        postdischarge_weight_6 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_6 IS NOT NULL AND TRIM(postdischarge_weight_6) <> ''
        AND TRY_CAST(postdischarge_weight_6 AS FLOAT) IS NOT NULL
        AND TRY_CAST(postdischarge_weight_6 AS FLOAT) > 0
        AND (
          (post_weight_unit6 = '1'
            AND (TRY_CAST(postdischarge_weight_6 AS FLOAT) < 200
              OR TRY_CAST(postdischarge_weight_6 AS FLOAT) > 8000))
          OR
          (post_weight_unit6 = '2'
            AND (TRY_CAST(postdischarge_weight_6 AS FLOAT) < 0.2
              OR TRY_CAST(postdischarge_weight_6 AS FLOAT) > 8.0))
        )
    ),
    orphan_postdischarge_weight_6 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_6' AS variable,
        'Post-discharge visit 6 weight (' || postdischarge_weight_6 || ') is recorded but outcome is not Alive' AS issue,
        postdischarge_weight_6 AS current_value
      FROM neonatal_core
      WHERE (outcome IS NULL OR outcome <> '1')
        AND postdischarge_weight_6 IS NOT NULL AND TRIM(postdischarge_weight_6) <> ''
    ),
    gap_postdischarge_weight_6 AS (
      SELECT id, hosp_id, date_today,
        'postdischarge_weight_6' AS variable,
        'Post-discharge visit 6 weight (' || postdischarge_weight_6 || ') is recorded but visit 5 weight is absent; weights must be entered sequentially' AS issue,
        postdischarge_weight_6 AS current_value
      FROM neonatal_core
      WHERE outcome = '1'
        AND postdischarge_weight_6 IS NOT NULL AND TRIM(postdischarge_weight_6) <> ''
        AND (postdischarge_weight_5 IS NULL OR TRIM(postdischarge_weight_5) = '')
    ),












    -- =========================================================================
    -- combine all checks
    -- =========================================================================
    all_issues AS (
      SELECT * FROM missing_document_source
      UNION ALL
      SELECT * FROM missing_hosp_id
      UNION ALL
      SELECT * FROM missing_ipno
      UNION ALL
      SELECT * FROM missing_multiple_delivery
      UNION ALL
      SELECT * FROM missing_number_delivered
      UNION ALL
      SELECT * FROM missing_birth_wt
      UNION ALL
      SELECT * FROM implausible_birth_wt
      UNION ALL
      SELECT * FROM missing_birth_wt_units
      UNION ALL
      SELECT * FROM missing_date_of_birth
      UNION ALL
      SELECT * FROM missing_date_adm
      UNION ALL
      SELECT * FROM missing_date_discharge
      UNION ALL
      SELECT * FROM missing_t_seen
      UNION ALL
      SELECT * FROM dob_after_adm
      UNION ALL
      SELECT * FROM adm_after_discharge
      UNION ALL
      SELECT * FROM dob_after_discharge
      UNION ALL
      SELECT * FROM adm_after_today
      UNION ALL
      SELECT * FROM discharge_after_today
      UNION ALL
      SELECT * FROM dob_after_today
      UNION ALL
      SELECT * FROM age_at_adm_implausible
      UNION ALL
      SELECT * FROM missing_age_recorded
      UNION ALL
      SELECT * FROM missing_age_less_than_24hrs
      UNION ALL
      SELECT * FROM missing_age_days
      UNION ALL
      SELECT * FROM implausible_age_days
      UNION ALL
      SELECT * FROM age_days_vs_dates_inconsistent
      UNION ALL
      SELECT * FROM age_lt24hrs_contradicts_dates
      UNION ALL
      SELECT * FROM age_gte24hrs_contradicts_dates
      UNION ALL
      SELECT * FROM missing_child_sex
      UNION ALL
      SELECT * FROM invalid_child_sex
      UNION ALL
      SELECT * FROM missing_referred_to_hospital
      UNION ALL
      SELECT * FROM invalid_referred_to_hospital
      UNION ALL
      SELECT * FROM missing_referral_info_available
      UNION ALL
      SELECT * FROM orphaned_referral_info_available
      UNION ALL
      SELECT * FROM orphaned_referred_from_facility
      UNION ALL
      SELECT * FROM missing_in_gis_avail_ke
                     -- serial weight checks
      UNION ALL SELECT * FROM missing_weight_doc
      UNION ALL SELECT * FROM missing_weight_1_units
      UNION ALL SELECT * FROM missing_weight_1
      UNION ALL SELECT * FROM implausible_weight_1
      UNION ALL SELECT * FROM missing_date_1
      UNION ALL SELECT * FROM date_1_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_1
      UNION ALL SELECT * FROM missing_weight_2_units
      UNION ALL SELECT * FROM missing_weight_2
      UNION ALL SELECT * FROM implausible_weight_2
      UNION ALL SELECT * FROM missing_date_2
      UNION ALL SELECT * FROM date_2_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_2
      UNION ALL SELECT * FROM missing_weight_3_units
      UNION ALL SELECT * FROM missing_weight_3
      UNION ALL SELECT * FROM implausible_weight_3
      UNION ALL SELECT * FROM missing_date_3
      UNION ALL SELECT * FROM date_3_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_3
      UNION ALL SELECT * FROM missing_weight_4_units
      UNION ALL SELECT * FROM missing_weight_4
      UNION ALL SELECT * FROM implausible_weight_4
      UNION ALL SELECT * FROM missing_date_4
      UNION ALL SELECT * FROM date_4_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_4
      UNION ALL SELECT * FROM missing_weight_5_units
      UNION ALL SELECT * FROM missing_weight_5
      UNION ALL SELECT * FROM implausible_weight_5
      UNION ALL SELECT * FROM missing_date_5
      UNION ALL SELECT * FROM date_5_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_5
      UNION ALL SELECT * FROM missing_weight_6_units
      UNION ALL SELECT * FROM missing_weight_6
      UNION ALL SELECT * FROM implausible_weight_6
      UNION ALL SELECT * FROM missing_date_6
      UNION ALL SELECT * FROM date_6_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_6
      UNION ALL SELECT * FROM missing_weight_7_units
      UNION ALL SELECT * FROM missing_weight_7
      UNION ALL SELECT * FROM implausible_weight_7
      UNION ALL SELECT * FROM missing_date_7
      UNION ALL SELECT * FROM date_7_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_7
      UNION ALL SELECT * FROM missing_weight_8_units
      UNION ALL SELECT * FROM missing_weight_8
      UNION ALL SELECT * FROM implausible_weight_8
      UNION ALL SELECT * FROM missing_date_8
      UNION ALL SELECT * FROM date_8_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_8
      UNION ALL SELECT * FROM missing_weight_9_units
      UNION ALL SELECT * FROM missing_weight_9
      UNION ALL SELECT * FROM implausible_weight_9
      UNION ALL SELECT * FROM missing_date_9
      UNION ALL SELECT * FROM date_9_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_9
      UNION ALL SELECT * FROM missing_weight_10_units
      UNION ALL SELECT * FROM missing_weight_10
      UNION ALL SELECT * FROM implausible_weight_10
      UNION ALL SELECT * FROM missing_date_10
      UNION ALL SELECT * FROM date_10_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_10
      UNION ALL SELECT * FROM missing_weight_11_units
      UNION ALL SELECT * FROM missing_weight_11
      UNION ALL SELECT * FROM implausible_weight_11
      UNION ALL SELECT * FROM missing_date_11
      UNION ALL SELECT * FROM date_11_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_11
      UNION ALL SELECT * FROM missing_weight_12_units
      UNION ALL SELECT * FROM missing_weight_12
      UNION ALL SELECT * FROM implausible_weight_12
      UNION ALL SELECT * FROM missing_date_12
      UNION ALL SELECT * FROM date_12_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_12
      UNION ALL SELECT * FROM missing_weight_13_units
      UNION ALL SELECT * FROM missing_weight_13
      UNION ALL SELECT * FROM implausible_weight_13
      UNION ALL SELECT * FROM missing_date_13
      UNION ALL SELECT * FROM date_13_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_13
      UNION ALL SELECT * FROM missing_weight_14_units
      UNION ALL SELECT * FROM missing_weight_14
      UNION ALL SELECT * FROM implausible_weight_14
      UNION ALL SELECT * FROM missing_date_14
      UNION ALL SELECT * FROM date_14_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_14
      UNION ALL SELECT * FROM missing_weight_15_units
      UNION ALL SELECT * FROM missing_weight_15
      UNION ALL SELECT * FROM implausible_weight_15
      UNION ALL SELECT * FROM missing_date_15
      UNION ALL SELECT * FROM date_15_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_15
      UNION ALL SELECT * FROM missing_weight_16_units
      UNION ALL SELECT * FROM missing_weight_16
      UNION ALL SELECT * FROM implausible_weight_16
      UNION ALL SELECT * FROM missing_date_16
      UNION ALL SELECT * FROM date_16_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_16
      UNION ALL SELECT * FROM missing_weight_17_units
      UNION ALL SELECT * FROM missing_weight_17
      UNION ALL SELECT * FROM implausible_weight_17
      UNION ALL SELECT * FROM missing_date_17
      UNION ALL SELECT * FROM date_17_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_17
      UNION ALL SELECT * FROM missing_weight_18_units
      UNION ALL SELECT * FROM missing_weight_18
      UNION ALL SELECT * FROM implausible_weight_18
      UNION ALL SELECT * FROM missing_date_18
      UNION ALL SELECT * FROM date_18_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_18
      UNION ALL SELECT * FROM missing_weight_19_units
      UNION ALL SELECT * FROM missing_weight_19
      UNION ALL SELECT * FROM implausible_weight_19
      UNION ALL SELECT * FROM missing_date_19
      UNION ALL SELECT * FROM date_19_out_of_window
      UNION ALL SELECT * FROM missing_other_weight_19
      UNION ALL SELECT * FROM missing_weight_20_units
      UNION ALL SELECT * FROM missing_weight_20
      UNION ALL SELECT * FROM implausible_weight_20
      UNION ALL SELECT * FROM missing_date_20
      UNION ALL SELECT * FROM date_20_out_of_window

                               -- maternal / transfer section checks (fields 21, 122?145)
      UNION ALL SELECT * FROM missing_transfer_form
      UNION ALL SELECT * FROM missing_mothers_ipno
      UNION ALL SELECT * FROM missing_mar_redcap_id
      UNION ALL SELECT * FROM missing_mothers_age
      UNION ALL SELECT * FROM implausible_mothers_age
      -- gravity (125) skipped: show condition is always FALSE
      UNION ALL SELECT * FROM missing_parity_live_birth
      UNION ALL SELECT * FROM implausible_parity_live_birth
      UNION ALL SELECT * FROM missing_parity_abortion
      UNION ALL SELECT * FROM implausible_parity_abortion
      UNION ALL SELECT * FROM missing_maternal_hiv
      UNION ALL SELECT * FROM invalid_maternal_hiv
      UNION ALL SELECT * FROM missing_mother_anten_corti
      UNION ALL SELECT * FROM invalid_mother_anten_corti
      UNION ALL SELECT * FROM missing_maternal_arv_s
      UNION ALL SELECT * FROM invalid_maternal_arv_s
      UNION ALL SELECT * FROM missing_baby_given_arv_s
      UNION ALL SELECT * FROM invalid_baby_given_arv_s
      UNION ALL SELECT * FROM missing_maternal_vdrl
      UNION ALL SELECT * FROM invalid_maternal_vdrl
      UNION ALL SELECT * FROM missing_last_menstrual_period
      UNION ALL SELECT * FROM invalid_last_menstrual_period
      UNION ALL SELECT * FROM lmp_after_dob
      UNION ALL SELECT * FROM missing_expected_date_of_delivery
      UNION ALL SELECT * FROM invalid_expected_date_of_delivery
      UNION ALL SELECT * FROM edd_before_lmp
      -- premature_rapture_of_membr (135) skipped: show condition is always FALSE
      UNION ALL SELECT * FROM missing_rapture_of_membrane
      UNION ALL SELECT * FROM invalid_rapture_of_membrane
      UNION ALL SELECT * FROM missing_mother_fever
      UNION ALL SELECT * FROM invalid_mother_fever
      UNION ALL SELECT * FROM missing_mother_tbtreat
      UNION ALL SELECT * FROM invalid_mother_tbtreat
      UNION ALL SELECT * FROM missing_mother_diabetes
      UNION ALL SELECT * FROM invalid_mother_diabetes
      UNION ALL SELECT * FROM missing_mother_htn
      UNION ALL SELECT * FROM invalid_mother_htn
      UNION ALL SELECT * FROM missing_mother_preeclampsia
      UNION ALL SELECT * FROM invalid_mother_preeclampsia
      UNION ALL SELECT * FROM missing_mother_eclampsia
      UNION ALL SELECT * FROM invalid_mother_eclampsia
      UNION ALL SELECT * FROM invalid_is_other_maternal_cond
      UNION ALL SELECT * FROM missing_other_maternal_cond
      UNION ALL SELECT * FROM orphan_other_maternal_cond
      UNION ALL SELECT * FROM missing_mother_alive
      UNION ALL SELECT * FROM invalid_mother_alive

                               -- birth assessment section checks (fields 147?175)
      UNION ALL SELECT * FROM missing_gest
      UNION ALL SELECT * FROM implausible_gest
      UNION ALL SELECT * FROM missing_apg_doc
      UNION ALL SELECT * FROM invalid_apg_doc
      UNION ALL SELECT * FROM missing_apgar_1min
      UNION ALL SELECT * FROM invalid_apgar_1min
      UNION ALL SELECT * FROM missing_apgar_5min
      UNION ALL SELECT * FROM invalid_apgar_5min
      UNION ALL SELECT * FROM missing_apgar_10min
      UNION ALL SELECT * FROM invalid_apgar_10min
      UNION ALL SELECT * FROM apgar_1min_gt_5min
      UNION ALL SELECT * FROM apgar_5min_gt_10min
      UNION ALL SELECT * FROM missing_wt_now
      UNION ALL SELECT * FROM missing_wt_now_units
      UNION ALL SELECT * FROM invalid_wt_now_units
      UNION ALL SELECT * FROM implausible_wt_now
      UNION ALL SELECT * FROM missing_baby_resusc_at_birth
      UNION ALL SELECT * FROM invalid_baby_resusc_at_birth
      UNION ALL SELECT * FROM missing_length
      UNION ALL SELECT * FROM implausible_length
      UNION ALL SELECT * FROM missing_head_circum
      UNION ALL SELECT * FROM implausible_head_circum
      UNION ALL SELECT * FROM missing_bba
      UNION ALL SELECT * FROM invalid_bba
      UNION ALL SELECT * FROM missing_born_where
      UNION ALL SELECT * FROM invalid_born_where
      UNION ALL SELECT * FROM missing_in_othfac_nam
      UNION ALL SELECT * FROM missing_delivery
      UNION ALL SELECT * FROM invalid_delivery
      -- time_of_admission_document (161) skipped: show condition always FALSE
      -- time_baby_seen (162)           skipped: show condition always FALSE
      UNION ALL SELECT * FROM missing_fever
      UNION ALL SELECT * FROM invalid_fever
      UNION ALL SELECT * FROM invalid_fever_duration
      UNION ALL SELECT * FROM orphan_fever_duration_in_days
      -- diarrhoea (167)       skipped: show condition always FALSE
      -- severe_vomiting (168) skipped: show condition always FALSE
      UNION ALL SELECT * FROM missing_difficulty_breathing
      UNION ALL SELECT * FROM invalid_difficulty_breathing
      UNION ALL SELECT * FROM missing_difficulty_feeding
      UNION ALL SELECT * FROM invalid_difficulty_feeding
      UNION ALL SELECT * FROM missing_convulsions
      UNION ALL SELECT * FROM invalid_convulsions
      -- partial_focal_fits (171) skipped: show condition always FALSE
      UNION ALL SELECT * FROM missing_level_of_activity
      UNION ALL SELECT * FROM invalid_level_of_activity
      UNION ALL SELECT * FROM missing_apnoea
      UNION ALL SELECT * FROM invalid_apnoea
      -- high_pitched_cry (174) skipped: show condition always FALSE
      UNION ALL SELECT * FROM missing_infant_drugs

                               -- baby's examination section checks (fields 177?202)
      UNION ALL SELECT * FROM missing_temperature
      UNION ALL SELECT * FROM implausible_temperature
      UNION ALL SELECT * FROM missing_respiratory_rate
      UNION ALL SELECT * FROM implausible_respiratory_rate
      UNION ALL SELECT * FROM missing_heart_rate
      UNION ALL SELECT * FROM implausible_heart_rate
      UNION ALL SELECT * FROM missing_oxygen_saturation_measured
      UNION ALL SELECT * FROM invalid_oxygen_saturation_measured
      UNION ALL SELECT * FROM missing_oxygen_saturation
      UNION ALL SELECT * FROM implausible_oxygen_saturation
      -- stirdor (182)           skipped: show condition always FALSE + @HIDDEN
      UNION ALL SELECT * FROM invalid_cry
      UNION ALL SELECT * FROM missing_central_cyanosis
      UNION ALL SELECT * FROM invalid_central_cyanosis
      UNION ALL SELECT * FROM missing_indrawing
      UNION ALL SELECT * FROM invalid_indrawing
      UNION ALL SELECT * FROM missing_grunting
      UNION ALL SELECT * FROM invalid_grunting
      UNION ALL SELECT * FROM invalid_air_entry_bilateral
      UNION ALL SELECT * FROM missing_crackles
      UNION ALL SELECT * FROM invalid_crackles
      UNION ALL SELECT * FROM missing_cap_refill
      UNION ALL SELECT * FROM invalid_cap_refill
      UNION ALL SELECT * FROM missing_pallor_anaemia
      UNION ALL SELECT * FROM invalid_pallor_anaemia
      UNION ALL SELECT * FROM missing_suck_breastfeed
      UNION ALL SELECT * FROM invalid_suck_breastfeed
      UNION ALL SELECT * FROM missing_bulging_fontanelle
      UNION ALL SELECT * FROM invalid_bulging_fontanelle
      UNION ALL SELECT * FROM invalid_irritable
      -- eye_pus (194)           skipped: show condition always FALSE
      UNION ALL SELECT * FROM invalid_tone
      -- redced_movement_floppy (196) skipped: show condition always FALSE
      UNION ALL SELECT * FROM invalid_umbilicus
      -- skin (198)              skipped: show condition always FALSE + @HIDDEN
      UNION ALL SELECT * FROM missing_jaundice
      UNION ALL SELECT * FROM invalid_jaundice
      -- gest_size (200)         skipped: show condition always FALSE + @HIDDEN
      UNION ALL SELECT * FROM invalid_abnormalities_1

                               -- investigations section checks (fields 204?224)
      UNION ALL SELECT * FROM missing_glucose
      UNION ALL SELECT * FROM invalid_glucose
      UNION ALL SELECT * FROM missing_glucose_results
      UNION ALL SELECT * FROM implausible_glucose_results
      UNION ALL SELECT * FROM missing_glucose_units
      UNION ALL SELECT * FROM invalid_glucose_units
      UNION ALL SELECT * FROM orphan_glucose_units
      UNION ALL SELECT * FROM missing_hbadmission
      UNION ALL SELECT * FROM invalid_hbadmission
      UNION ALL SELECT * FROM missing_hb_hct
      UNION ALL SELECT * FROM invalid_hb_hct
      UNION ALL SELECT * FROM missing_hb_results
      UNION ALL SELECT * FROM implausible_hb_results
      UNION ALL SELECT * FROM missing_bilirubin
      UNION ALL SELECT * FROM invalid_bilirubin
      UNION ALL SELECT * FROM missing_lp
      UNION ALL SELECT * FROM invalid_lp
      UNION ALL SELECT * FROM missing_lp_results
      UNION ALL SELECT * FROM invalid_lp_results
      UNION ALL SELECT * FROM missing_blood_culture_ordered
      UNION ALL SELECT * FROM invalid_blood_culture_ordered
      UNION ALL SELECT * FROM missing_blood_culture_result
      UNION ALL SELECT * FROM invalid_blood_culture_result
      UNION ALL SELECT * FROM missing_crp_done
      UNION ALL SELECT * FROM invalid_crp_done
      -- urine (223)    skipped: show condition always FALSE
      -- pus_swab (224) skipped: @HIDDEN

          -- baby's admission diagnoses section checks (fields 227?239)
      UNION ALL SELECT * FROM missing_clear_pry_adm_diag
      UNION ALL SELECT * FROM invalid_clear_pry_adm_diag
      UNION ALL SELECT * FROM missing_pry_adm_diag
      UNION ALL SELECT * FROM orphan_pry_adm_diag
      UNION ALL SELECT * FROM missing_adm_diag_1
      UNION ALL SELECT * FROM orphan_adm_diag_1
      UNION ALL SELECT * FROM orphan_adm_diag_2
      UNION ALL SELECT * FROM orphan_adm_diag_3
      UNION ALL SELECT * FROM seq_adm_diag_2_without_1
      UNION ALL SELECT * FROM seq_adm_diag_3_without_2
      UNION ALL SELECT * FROM missing_other_admission_diag
      UNION ALL SELECT * FROM invalid_other_admission_diag
      UNION ALL SELECT * FROM missing_other_admission_diag_1
      UNION ALL SELECT * FROM orphan_other_admission_diag_1
      UNION ALL SELECT * FROM seq_other_diag_2_without_1
      UNION ALL SELECT * FROM orphan_other_admission_diag_2
      UNION ALL SELECT * FROM seq_other_diag_3_without_2
      UNION ALL SELECT * FROM orphan_other_admission_diag_3
      UNION ALL SELECT * FROM seq_other_diag_4_without_3
      UNION ALL SELECT * FROM orphan_other_admission_diag_4
      UNION ALL SELECT * FROM seq_other_diag_5_without_4
      UNION ALL SELECT * FROM orphan_other_admission_diag_5
      UNION ALL SELECT * FROM missing_other_adm_diag_not_listed
      UNION ALL SELECT * FROM invalid_other_adm_diag_not_listed
      UNION ALL SELECT * FROM missing_admisn_diag_not_listed
      UNION ALL SELECT * FROM orphan_admisn_diag_not_listed

                               -- drug treatment section checks (fields 241?345)
      UNION ALL SELECT * FROM missing_t_sheet
      UNION ALL SELECT * FROM invalid_t_sheet
      -- antibiotics: pen
      UNION ALL SELECT * FROM missing_pen
      UNION ALL SELECT * FROM invalid_pen
      UNION ALL SELECT * FROM orphan_pen
      UNION ALL SELECT * FROM missing_pen_date_prescribed
      UNION ALL SELECT * FROM orphan_pen_date_prescribed
      UNION ALL SELECT * FROM missing_pen_route
      UNION ALL SELECT * FROM invalid_pen_route
      UNION ALL SELECT * FROM missing_pen_dose_mg
      UNION ALL SELECT * FROM implausible_pen_dose_mg
      UNION ALL SELECT * FROM missing_pen_dose_unit
      UNION ALL SELECT * FROM invalid_pen_dose_unit
      UNION ALL SELECT * FROM missing_pen_freq
      UNION ALL SELECT * FROM invalid_pen_freq
      UNION ALL SELECT * FROM missing_pen_dur
      UNION ALL SELECT * FROM implausible_pen_dur
      UNION ALL SELECT * FROM missing_pen_date_stopped
      UNION ALL SELECT * FROM temporal_pen_date_stopped
      -- gentamicin
      UNION ALL SELECT * FROM missing_genta
      UNION ALL SELECT * FROM invalid_genta
      UNION ALL SELECT * FROM orphan_genta
      UNION ALL SELECT * FROM missing_genta_date_prescribed
      UNION ALL SELECT * FROM missing_genta_route
      UNION ALL SELECT * FROM invalid_genta_route
      UNION ALL SELECT * FROM missing_genta_dose
      UNION ALL SELECT * FROM implausible_genta_dose
      UNION ALL SELECT * FROM missing_genta_freq
      UNION ALL SELECT * FROM invalid_genta_freq
      UNION ALL SELECT * FROM missing_genta_dur
      UNION ALL SELECT * FROM implausible_genta_dur
      UNION ALL SELECT * FROM missing_genta_date_stopped
      UNION ALL SELECT * FROM temporal_genta_date_stopped
      -- ampicillin
      UNION ALL SELECT * FROM missing_amp
      UNION ALL SELECT * FROM invalid_amp
      UNION ALL SELECT * FROM orphan_amp
      UNION ALL SELECT * FROM missing_amp_date_prescribed
      UNION ALL SELECT * FROM missing_amp_route
      UNION ALL SELECT * FROM invalid_amp_route
      UNION ALL SELECT * FROM missing_amp_dose
      UNION ALL SELECT * FROM missing_amp_units
      UNION ALL SELECT * FROM invalid_amp_units
      UNION ALL SELECT * FROM missing_amp_freq
      UNION ALL SELECT * FROM invalid_amp_freq
      UNION ALL SELECT * FROM missing_amp_dur
      UNION ALL SELECT * FROM implausible_amp_dur
      UNION ALL SELECT * FROM missing_amp_date_stopped
      UNION ALL SELECT * FROM temporal_amp_date_stopped
      -- ceftriaxone
      UNION ALL SELECT * FROM missing_ceftr
      UNION ALL SELECT * FROM invalid_ceftr
      UNION ALL SELECT * FROM orphan_ceftr
      UNION ALL SELECT * FROM missing_ceftr_date_prescribed
      UNION ALL SELECT * FROM missing_ceftr_route
      UNION ALL SELECT * FROM invalid_ceftr_route
      UNION ALL SELECT * FROM missing_ceftr_dose
      UNION ALL SELECT * FROM missing_ceftr_freq
      UNION ALL SELECT * FROM invalid_ceftr_freq
      UNION ALL SELECT * FROM missing_ceftr_dur
      UNION ALL SELECT * FROM implausible_ceftr_dur
      UNION ALL SELECT * FROM missing_ceftr_date_stopped
      UNION ALL SELECT * FROM temporal_ceftr_date_stopped
      -- amikacin
      UNION ALL SELECT * FROM missing_amikacin
      UNION ALL SELECT * FROM invalid_amikacin
      UNION ALL SELECT * FROM orphan_amikacin
      UNION ALL SELECT * FROM missing_amikacin_date
      UNION ALL SELECT * FROM missing_amikacin_route
      UNION ALL SELECT * FROM invalid_amikacin_route
      UNION ALL SELECT * FROM missing_amikacin_dose
      UNION ALL SELECT * FROM missing_amikacin_freq
      UNION ALL SELECT * FROM invalid_amikacin_freq
      UNION ALL SELECT * FROM missing_amikacin_dur
      UNION ALL SELECT * FROM missing_amikacin_date_stopped
      UNION ALL SELECT * FROM temporal_amikacin_stopped
      -- ceftazidime
      UNION ALL SELECT * FROM missing_cefta
      UNION ALL SELECT * FROM invalid_cefta
      UNION ALL SELECT * FROM orphan_cefta
      UNION ALL SELECT * FROM missing_cefta_date
      UNION ALL SELECT * FROM missing_cefta_route
      UNION ALL SELECT * FROM invalid_cefta_route
      UNION ALL SELECT * FROM missing_cefta_dose
      UNION ALL SELECT * FROM missing_cefta_units
      UNION ALL SELECT * FROM invalid_cefta_units
      UNION ALL SELECT * FROM missing_cefta_freq
      UNION ALL SELECT * FROM invalid_cefta_freq
      UNION ALL SELECT * FROM missing_cefta_dur
      UNION ALL SELECT * FROM missing_cefta_date_stopped
      UNION ALL SELECT * FROM temporal_cefta_date_stopped
      -- section 8.2: phenobarb / aminophylline / caffeine
      UNION ALL SELECT * FROM missing_phenobarb
      UNION ALL SELECT * FROM invalid_phenobarb
      UNION ALL SELECT * FROM orphan_phenobarb
      UNION ALL SELECT * FROM missing_phenobarb_start
      UNION ALL SELECT * FROM missing_phenobarb_stop
      UNION ALL SELECT * FROM temporal_phenobarb
      UNION ALL SELECT * FROM missing_aminophylline
      UNION ALL SELECT * FROM invalid_aminophylline
      UNION ALL SELECT * FROM orphan_aminophylline
      UNION ALL SELECT * FROM missing_aminophylline_start
      UNION ALL SELECT * FROM missing_aminophylline_stop
      UNION ALL SELECT * FROM temporal_aminophylline
      UNION ALL SELECT * FROM missing_caffeine_citrate
      UNION ALL SELECT * FROM invalid_caffeine_citrate
      UNION ALL SELECT * FROM orphan_caffeine_citrate
      UNION ALL SELECT * FROM missing_caffeine_start
      UNION ALL SELECT * FROM missing_caffeine_stop
      UNION ALL SELECT * FROM temporal_caffeine
      -- other_treatment + other_drugs_1?5
      UNION ALL SELECT * FROM missing_other_treatment
      UNION ALL SELECT * FROM invalid_other_treatment
      UNION ALL SELECT * FROM missing_other_drugs_1
      UNION ALL SELECT * FROM orphan_other_drugs_1
      UNION ALL SELECT * FROM temporal_other_drugs_1
      UNION ALL SELECT * FROM seq_other_drugs_2
      UNION ALL SELECT * FROM orphan_other_drugs_2
      UNION ALL SELECT * FROM temporal_other_drugs_2
      UNION ALL SELECT * FROM seq_other_drugs_3
      UNION ALL SELECT * FROM orphan_other_drugs_3
      UNION ALL SELECT * FROM temporal_other_drugs_3
      UNION ALL SELECT * FROM seq_other_drugs_4
      UNION ALL SELECT * FROM orphan_other_drugs_4
      UNION ALL SELECT * FROM temporal_other_drugs_4
      UNION ALL SELECT * FROM seq_other_drugs_5
      UNION ALL SELECT * FROM orphan_other_drugs_5
      UNION ALL SELECT * FROM temporal_other_drugs_5
      -- other_treatment_2 + admisn_dx_not_listed
      UNION ALL SELECT * FROM missing_other_treatment_2
      UNION ALL SELECT * FROM invalid_other_treatment_2
      UNION ALL SELECT * FROM missing_admisn_dx_not_listed
      UNION ALL SELECT * FROM orphan_admisn_dx_not_listed
      -- section 8.3: post-admission drugs_1?10
      UNION ALL SELECT * FROM missing_drugs
      UNION ALL SELECT * FROM invalid_drugs
      UNION ALL SELECT * FROM orphan_drugs
      UNION ALL SELECT * FROM missing_drugs_1
      UNION ALL SELECT * FROM orphan_drugs_1
      UNION ALL SELECT * FROM temporal_drugs_1
      UNION ALL SELECT * FROM seq_drugs_2
      UNION ALL SELECT * FROM orphan_drugs_2
      UNION ALL SELECT * FROM temporal_drugs_2
      UNION ALL SELECT * FROM seq_drugs_3
      UNION ALL SELECT * FROM orphan_drugs_3
      UNION ALL SELECT * FROM temporal_drugs_3
      UNION ALL SELECT * FROM seq_drugs_4
      UNION ALL SELECT * FROM orphan_drugs_4
      UNION ALL SELECT * FROM temporal_drugs_4
      UNION ALL SELECT * FROM seq_drugs_5
      UNION ALL SELECT * FROM orphan_drugs_5
      UNION ALL SELECT * FROM temporal_drugs_5
      UNION ALL SELECT * FROM seq_drugs_6
      UNION ALL SELECT * FROM orphan_drugs_6
      UNION ALL SELECT * FROM temporal_drugs_6
      UNION ALL SELECT * FROM seq_drugs_7
      UNION ALL SELECT * FROM orphan_drugs_7
      UNION ALL SELECT * FROM temporal_drugs_7
      UNION ALL SELECT * FROM seq_drugs_8
      UNION ALL SELECT * FROM orphan_drugs_8
      UNION ALL SELECT * FROM temporal_drugs_8
      UNION ALL SELECT * FROM seq_drugs_9
      UNION ALL SELECT * FROM orphan_drugs_9
      UNION ALL SELECT * FROM temporal_drugs_9
      UNION ALL SELECT * FROM seq_drugs_10
      UNION ALL SELECT * FROM orphan_drugs_10
      UNION ALL SELECT * FROM temporal_drugs_10
      UNION ALL SELECT * FROM orphan_other_post_admission_drugs

                               -- supportive care section checks (fields 347?398)
      UNION ALL SELECT * FROM missing_oxygen_ordered
      UNION ALL SELECT * FROM invalid_oxygen_ordered
      -- cpap
      UNION ALL SELECT * FROM missing_cpap
      UNION ALL SELECT * FROM invalid_cpap
      UNION ALL SELECT * FROM missing_cpap_start
      UNION ALL SELECT * FROM orphan_cpap_start
      UNION ALL SELECT * FROM orphan_cpap_start_time
      UNION ALL SELECT * FROM missing_is_cpap_start_t_doc
      UNION ALL SELECT * FROM invalid_is_cpap_start_t_doc
      UNION ALL SELECT * FROM orphan_is_cpap_start_t_doc
      UNION ALL SELECT * FROM missing_cpap_start_time_new
      UNION ALL SELECT * FROM orphan_cpap_start_time_new
      UNION ALL SELECT * FROM missing_cpap_stop
      UNION ALL SELECT * FROM temporal_cpap_stop
      UNION ALL SELECT * FROM orphan_cpap_stop
      UNION ALL SELECT * FROM orphan_cpap_end_time
      UNION ALL SELECT * FROM missing_is_cpap_end_t_doc
      UNION ALL SELECT * FROM invalid_is_cpap_end_t_doc
      UNION ALL SELECT * FROM orphan_is_cpap_end_t_doc
      UNION ALL SELECT * FROM missing_cpap_end_time_new
      UNION ALL SELECT * FROM orphan_cpap_end_time_new
      -- blood transfusion
      UNION ALL SELECT * FROM missing_blood_transfusion_prescrib
      UNION ALL SELECT * FROM invalid_blood_transfusion_prescrib
      UNION ALL SELECT * FROM missing_blood_transf_pres_date
      UNION ALL SELECT * FROM orphan_blood_transf_pres_date
      UNION ALL SELECT * FROM missing_blood_transfussion_given
      UNION ALL SELECT * FROM invalid_blood_transfussion_given
      UNION ALL SELECT * FROM orphan_blood_transfussion_given
      UNION ALL SELECT * FROM missing_exchange_transfusion
      UNION ALL SELECT * FROM invalid_exchange_transfusion
      UNION ALL SELECT * FROM orphan_exchange_transfusion
      -- fluids
      UNION ALL SELECT * FROM missing_fluid_feed_monitoring_chart
      UNION ALL SELECT * FROM invalid_fluid_feed_monitoring_chart
      UNION ALL SELECT * FROM missing_date_fluid_presc
      UNION ALL SELECT * FROM orphan_date_fluid_presc
      UNION ALL SELECT * FROM missing_intravenous_fluids_presc
      UNION ALL SELECT * FROM invalid_intravenous_fluids_presc
      UNION ALL SELECT * FROM missing_total_volume_of_iv_fluids
      UNION ALL SELECT * FROM implausible_total_volume_of_iv_fluids
      UNION ALL SELECT * FROM missing_duration_of_iv_fluid_presc
      UNION ALL SELECT * FROM implausible_duration_of_iv_fluid_presc
      UNION ALL SELECT * FROM missing_other_fluid
      UNION ALL SELECT * FROM invalid_other_fluid
      UNION ALL SELECT * FROM missing_other_fluid_prescribed
      UNION ALL SELECT * FROM invalid_other_fluid_prescribed
      UNION ALL SELECT * FROM missing_total_vol_of_other_fluid
      UNION ALL SELECT * FROM implausible_total_vol_of_other_fluid
      UNION ALL SELECT * FROM missing_duration_prescribed
      UNION ALL SELECT * FROM implausible_duration_prescribed
      UNION ALL SELECT * FROM missing_other_fluid_2
      UNION ALL SELECT * FROM invalid_other_fluid_2
      UNION ALL SELECT * FROM missing_specify_other_fluid_2_pres
      UNION ALL SELECT * FROM invalid_specify_other_fluid_2_pres
      UNION ALL SELECT * FROM orphan_specify_other_fluid_2_pres
      UNION ALL SELECT * FROM missing_total_volume_of_fluid_2
      UNION ALL SELECT * FROM implausible_total_volume_of_fluid_2
      UNION ALL SELECT * FROM missing_duration_of_flow_2
      UNION ALL SELECT * FROM implausible_duration_of_flow_2
      UNION ALL SELECT * FROM missing_fluids_presc_next_day
      UNION ALL SELECT * FROM invalid_fluids_presc_next_day
      UNION ALL SELECT * FROM missing_total_fluids_next_day
      UNION ALL SELECT * FROM implausible_total_fluids_next_day
      UNION ALL SELECT * FROM orphan_total_fluids_next_day
      -- feeds
      UNION ALL SELECT * FROM missing_child_prescribed_with_feed
      UNION ALL SELECT * FROM invalid_child_prescribed_with_feed
      UNION ALL SELECT * FROM missing_date_feeds_prescribed
      UNION ALL SELECT * FROM orphan_date_feeds_prescribed
      UNION ALL SELECT * FROM missing_type_of_feeds
      UNION ALL SELECT * FROM invalid_type_of_feeds
      UNION ALL SELECT * FROM missing_other_feeds
      UNION ALL SELECT * FROM orphan_other_feeds
      UNION ALL SELECT * FROM missing_feeding_route_prescribed
      UNION ALL SELECT * FROM invalid_feeding_route_prescribed
      UNION ALL SELECT * FROM missing_feed_volume
      UNION ALL SELECT * FROM implausible_feed_volume
      UNION ALL SELECT * FROM missing_freq_of_administration
      UNION ALL SELECT * FROM invalid_freq_of_administration
      UNION ALL SELECT * FROM missing_date_feeds_only_presc
      UNION ALL SELECT * FROM orphan_date_feeds_only_presc
      UNION ALL SELECT * FROM missing_feeds_presc_next_day
      UNION ALL SELECT * FROM invalid_feeds_presc_next_day
      UNION ALL SELECT * FROM missing_date_feeds_first_presc
      UNION ALL SELECT * FROM orphan_date_feeds_first_presc
      UNION ALL SELECT * FROM missing_type_feed_presc_next_day
      UNION ALL SELECT * FROM invalid_type_feed_presc_next_day
      UNION ALL SELECT * FROM orphan_type_feed_presc_next_day
      UNION ALL SELECT * FROM missing_nxtday_feed_rt_presc
      UNION ALL SELECT * FROM invalid_nxtday_feed_rt_presc
      UNION ALL SELECT * FROM orphan_nxtday_feed_rt_presc
      UNION ALL SELECT * FROM missing_freq_of_administration_2
      UNION ALL SELECT * FROM invalid_freq_of_administration_2
      UNION ALL SELECT * FROM orphan_freq_of_administration_2
      UNION ALL SELECT * FROM missing_total_feeds_presc_next_day
      UNION ALL SELECT * FROM implausible_total_feeds_presc_next_day
      UNION ALL SELECT * FROM orphan_total_feeds_presc_next_day
      UNION ALL SELECT * FROM orphan_total_input
      -- breastfeeding
      UNION ALL SELECT * FROM missing_baby_breastfeeding
      UNION ALL SELECT * FROM invalid_baby_breastfeeding
      -- phototherapy
      UNION ALL SELECT * FROM missing_phototherapy
      UNION ALL SELECT * FROM invalid_phototherapy
      UNION ALL SELECT * FROM missing_photo_therapy_on_any_other
      UNION ALL SELECT * FROM invalid_photo_therapy_on_any_other
      UNION ALL SELECT * FROM orphan_photo_therapy_on_any_other
      UNION ALL SELECT * FROM missing_start_date_phototherapy
      UNION ALL SELECT * FROM orphan_start_date_phototherapy
      UNION ALL SELECT * FROM missing_stop_date_phototherapy
      UNION ALL SELECT * FROM orphan_stop_date_phototherapy
      UNION ALL SELECT * FROM temporal_stop_date_phototherapy
      -- KMC
      UNION ALL SELECT * FROM missing_k_mother_care
      UNION ALL SELECT * FROM invalid_k_mother_care

                               -- follow-up monitoring section checks (fields 400?430)
      UNION ALL SELECT * FROM missing_vitals_signs_chart_present
      UNION ALL SELECT * FROM invalid_vitals_signs_chart_present
      -- vital_signs_monitored_in_t (field 403)
      UNION ALL SELECT * FROM missing_vital_signs_monitored_in_t
      UNION ALL SELECT * FROM invalid_vital_signs_monitored_in_t
      UNION ALL SELECT * FROM orphan_vital_signs_monitored_in_t
      -- temperature monitoring
      UNION ALL SELECT * FROM missing_no_of_times_temp_monitored
      UNION ALL SELECT * FROM invalid_no_of_times_temp_monitored
      UNION ALL SELECT * FROM orphan_no_of_times_temp_monitored
      UNION ALL SELECT * FROM missing_lowest_temperature
      UNION ALL SELECT * FROM implausible_lowest_temperature
      -- respiratory monitoring
      UNION ALL SELECT * FROM missing_no_of_times_resp_monitored
      UNION ALL SELECT * FROM invalid_no_of_times_resp_monitored
      UNION ALL SELECT * FROM orphan_no_of_times_resp_monitored
      -- pulse monitoring
      UNION ALL SELECT * FROM missing_no_of_times_puls_monitored
      UNION ALL SELECT * FROM invalid_no_of_times_puls_monitored
      UNION ALL SELECT * FROM orphan_no_of_times_puls_monitored
      -- oxygen saturation monitoring
      UNION ALL SELECT * FROM missing_oxygen_sat_monitored
      UNION ALL SELECT * FROM invalid_oxygen_sat_monitored
      UNION ALL SELECT * FROM orphan_oxygen_sat_monitored
      UNION ALL SELECT * FROM missing_no_of_times_oxy_monitored
      UNION ALL SELECT * FROM invalid_no_of_times_oxy_monitored
      UNION ALL SELECT * FROM orphan_no_of_times_oxy_monitored
      UNION ALL SELECT * FROM missing_lowest_oxygen_saturation
      UNION ALL SELECT * FROM implausible_lowest_oxygen_saturation
      -- cyanosis
      UNION ALL SELECT * FROM missing_cyanosis_assessed
      UNION ALL SELECT * FROM invalid_cyanosis_assessed
      UNION ALL SELECT * FROM orphan_cyanosis_assessed
      UNION ALL SELECT * FROM missing_no_times_cyanosis_assessed
      UNION ALL SELECT * FROM invalid_no_times_cyanosis_assessed
      UNION ALL SELECT * FROM orphan_no_times_cyanosis_assessed
      -- monitoring charts
      UNION ALL SELECT * FROM missing_neo_intnsv_monit_chart_pre
      UNION ALL SELECT * FROM invalid_neo_intnsv_monit_chart_pre
      UNION ALL SELECT * FROM invalid_oxygen_admin
      UNION ALL SELECT * FROM missing_fluid_monitoring_chart
      UNION ALL SELECT * FROM invalid_fluid_monitoring_chart
      -- IVF documentation day 0
      UNION ALL SELECT * FROM missing_ivf_type_day0_doc
      UNION ALL SELECT * FROM invalid_ivf_type_day0_doc
      UNION ALL SELECT * FROM orphan_ivf_type_day0_doc
      UNION ALL SELECT * FROM missing_ivf_vol_day0_doc
      UNION ALL SELECT * FROM invalid_ivf_vol_day0_doc
      UNION ALL SELECT * FROM orphan_ivf_vol_day0_doc
      UNION ALL SELECT * FROM missing_ivf_summ_tot_day0_doc
      UNION ALL SELECT * FROM invalid_ivf_summ_tot_day0_doc
      UNION ALL SELECT * FROM orphan_ivf_summ_tot_day0_doc
      -- IVF documentation day 1
      UNION ALL SELECT * FROM missing_ivf_type_day1_doc
      UNION ALL SELECT * FROM invalid_ivf_type_day1_doc
      UNION ALL SELECT * FROM orphan_ivf_type_day1_doc
      UNION ALL SELECT * FROM missing_ivf_vol_day1_doc
      UNION ALL SELECT * FROM invalid_ivf_vol_day1_doc
      UNION ALL SELECT * FROM orphan_ivf_vol_day1_doc
      UNION ALL SELECT * FROM missing_ivf_summ_tot_day1_doc
      UNION ALL SELECT * FROM invalid_ivf_summ_tot_day1_doc
      UNION ALL SELECT * FROM orphan_ivf_summ_tot_day1_doc
      -- feed monitoring chart
      UNION ALL SELECT * FROM missing_feed_fluid_monitorng_chart
      UNION ALL SELECT * FROM invalid_feed_fluid_monitorng_chart
      -- feeds initiated
      UNION ALL SELECT * FROM missing_date_the_feeds_initiated
      UNION ALL SELECT * FROM orphan_date_the_feeds_initiated
      UNION ALL SELECT * FROM missing_time_feeds_started
      UNION ALL SELECT * FROM orphan_time_feeds_started
      -- feed documentation day 0
      UNION ALL SELECT * FROM missing_feed_type_day0_doc
      UNION ALL SELECT * FROM invalid_feed_type_day0_doc
      UNION ALL SELECT * FROM orphan_feed_type_day0_doc
      UNION ALL SELECT * FROM missing_feed_vol_day0_doc
      UNION ALL SELECT * FROM invalid_feed_vol_day0_doc
      UNION ALL SELECT * FROM orphan_feed_vol_day0_doc
      UNION ALL SELECT * FROM missing_feed_summ_tot_day0_doc
      UNION ALL SELECT * FROM invalid_feed_summ_tot_day0_doc
      UNION ALL SELECT * FROM orphan_feed_summ_tot_day0_doc
      -- feed documentation day 1
      UNION ALL SELECT * FROM missing_feed_type_day1_doc
      UNION ALL SELECT * FROM invalid_feed_type_day1_doc
      UNION ALL SELECT * FROM orphan_feed_type_day1_doc
      UNION ALL SELECT * FROM missing_feed_vol_day1_doc
      UNION ALL SELECT * FROM invalid_feed_vol_day1_doc
      UNION ALL SELECT * FROM orphan_feed_vol_day1_doc
      UNION ALL SELECT * FROM missing_feed_summ_tot_day1_doc
      UNION ALL SELECT * FROM invalid_feed_summ_tot_day1_doc
      UNION ALL SELECT * FROM orphan_feed_summ_tot_day1_doc

                               -- discharge information section checks (fields 432?465)
      UNION ALL SELECT * FROM missing_outcome
      UNION ALL SELECT * FROM invalid_outcome
      UNION ALL SELECT * FROM missing_disch_death_summ
      UNION ALL SELECT * FROM invalid_disch_death_summ
      -- d1 form (dead outcome)
      UNION ALL SELECT * FROM missing_d1_present
      UNION ALL SELECT * FROM orphan_d1_present
      -- referral fields
      UNION ALL SELECT * FROM missing_referred_to
      UNION ALL SELECT * FROM orphan_referred_to
      UNION ALL SELECT * FROM orphan_referred_to_othr
      UNION ALL SELECT * FROM missing_referral_reason
      UNION ALL SELECT * FROM orphan_referral_reason
      UNION ALL SELECT * FROM orphan_referred_where
      -- discharge weight
      UNION ALL SELECT * FROM missing_discharge_weight
      UNION ALL SELECT * FROM missing_discharge_wt_units
      UNION ALL SELECT * FROM invalid_discharge_wt_units
      UNION ALL SELECT * FROM orphan_discharge_wt_units
      UNION ALL SELECT * FROM implausible_discharge_weight
      -- condition on discharge
      UNION ALL SELECT * FROM missing_dsc_condition
      UNION ALL SELECT * FROM invalid_dsc_condition
      UNION ALL SELECT * FROM orphan_dsc_condition
      -- primary discharge diagnosis
      UNION ALL SELECT * FROM missing_dsc_dx1_primary
      UNION ALL SELECT * FROM invalid_dsc_dx1_primary
      UNION ALL SELECT * FROM missing_primary_disch_diagnosis
      UNION ALL SELECT * FROM orphan_primary_disch_diagnosis
      -- discharge diagnoses 1?5 (no clear primary)
      UNION ALL SELECT * FROM missing_disch_diag_1
      UNION ALL SELECT * FROM orphan_disch_diag_1
      UNION ALL SELECT * FROM gap_disch_diag_2
      UNION ALL SELECT * FROM orphan_disch_diag_2
      UNION ALL SELECT * FROM gap_disch_diag_3
      UNION ALL SELECT * FROM orphan_disch_diag_3
      UNION ALL SELECT * FROM gap_disch_diag_4
      UNION ALL SELECT * FROM orphan_disch_diag_4
      UNION ALL SELECT * FROM gap_disch_diag_5
      UNION ALL SELECT * FROM orphan_disch_diag_5
      -- other discharge diagnoses
      UNION ALL SELECT * FROM missing_other_discharge_diag
      UNION ALL SELECT * FROM invalid_other_discharge_diag
      UNION ALL SELECT * FROM missing_other_discharge_diag_1
      UNION ALL SELECT * FROM orphan_other_discharge_diag_1
      UNION ALL SELECT * FROM gap_other_discharge_diag_2
      UNION ALL SELECT * FROM orphan_other_discharge_diag_2
      UNION ALL SELECT * FROM gap_other_discharge_diag_3
      UNION ALL SELECT * FROM orphan_other_discharge_diag_3
      UNION ALL SELECT * FROM gap_other_discharge_diag_4
      UNION ALL SELECT * FROM orphan_other_discharge_diag_4
      UNION ALL SELECT * FROM gap_other_discharge_diag_5
      UNION ALL SELECT * FROM orphan_other_discharge_diag_5
      -- unlisted discharge diagnoses
      UNION ALL SELECT * FROM invalid_any_other_disch_diag
      UNION ALL SELECT * FROM missing_other_discharge_diag_unlisted
      UNION ALL SELECT * FROM orphan_other_discharge_diag_unlisted
      -- GIS Kenya fields
      UNION ALL SELECT * FROM missing_in_chloro
      UNION ALL SELECT * FROM invalid_in_chloro
      UNION ALL SELECT * FROM orphan_in_chloro
      UNION ALL SELECT * FROM missing_in_vitk
      UNION ALL SELECT * FROM invalid_in_vitk
      UNION ALL SELECT * FROM orphan_in_vitk
      -- bilirubin highest
      UNION ALL SELECT * FROM missing_in_bil_hi
      UNION ALL SELECT * FROM orphan_in_bil_hi
      UNION ALL SELECT * FROM missing_bilirubin_hi_unit
      UNION ALL SELECT * FROM invalid_bilirubin_hi_unit
      UNION ALL SELECT * FROM orphan_bilirubin_hi_unit
      -- baby feeding
      UNION ALL SELECT * FROM missing_baby_feeding_disch
      UNION ALL SELECT * FROM invalid_baby_feeding_disch
      UNION ALL SELECT * FROM orphan_baby_feeding_disch

                               -- post discharge weight monitoring section (fields 467?485)
      -- visit 1
      UNION ALL SELECT * FROM orphan_post_weight_date1
      UNION ALL SELECT * FROM temporal_post_weight_date1
      UNION ALL SELECT * FROM missing_post_weight_unit1
      UNION ALL SELECT * FROM invalid_post_weight_unit1
      UNION ALL SELECT * FROM orphan_post_weight_unit1
      UNION ALL SELECT * FROM implausible_postdischarge_weight_1
      UNION ALL SELECT * FROM orphan_postdischarge_weight_1
      -- visit 2
      UNION ALL SELECT * FROM orphan_post_weight_date2
      UNION ALL SELECT * FROM temporal_post_weight_date2_adm
      UNION ALL SELECT * FROM temporal_post_weight_date2_seq
      UNION ALL SELECT * FROM missing_post_weight_unit2
      UNION ALL SELECT * FROM invalid_post_weight_unit2
      UNION ALL SELECT * FROM orphan_post_weight_unit2
      UNION ALL SELECT * FROM implausible_postdischarge_weight_2
      UNION ALL SELECT * FROM orphan_postdischarge_weight_2
      UNION ALL SELECT * FROM gap_postdischarge_weight_2
      -- visit 3
      UNION ALL SELECT * FROM orphan_post_weight_date3
      UNION ALL SELECT * FROM temporal_post_weight_date3_adm
      UNION ALL SELECT * FROM temporal_post_weight_date3_seq
      UNION ALL SELECT * FROM missing_post_weight_unit3
      UNION ALL SELECT * FROM invalid_post_weight_unit3
      UNION ALL SELECT * FROM orphan_post_weight_unit3
      UNION ALL SELECT * FROM implausible_postdischarge_weight_3
      UNION ALL SELECT * FROM orphan_postdischarge_weight_3
      UNION ALL SELECT * FROM gap_postdischarge_weight_3
      -- visit 4
      UNION ALL SELECT * FROM orphan_post_weight_date4
      UNION ALL SELECT * FROM temporal_post_weight_date4_adm
      UNION ALL SELECT * FROM temporal_post_weight_date4_seq
      UNION ALL SELECT * FROM missing_post_weight_unit4
      UNION ALL SELECT * FROM invalid_post_weight_unit4
      UNION ALL SELECT * FROM orphan_post_weight_unit4
      UNION ALL SELECT * FROM implausible_postdischarge_weight_4
      UNION ALL SELECT * FROM orphan_postdischarge_weight_4
      UNION ALL SELECT * FROM gap_postdischarge_weight_4
      -- visit 5
      UNION ALL SELECT * FROM orphan_post_weight_date5
      UNION ALL SELECT * FROM temporal_post_weight_date5_adm
      UNION ALL SELECT * FROM temporal_post_weight_date5_seq
      UNION ALL SELECT * FROM missing_post_weight_unit5
      UNION ALL SELECT * FROM invalid_post_weight_unit5
      UNION ALL SELECT * FROM orphan_post_weight_unit5
      UNION ALL SELECT * FROM implausible_postdischarge_weight_5
      UNION ALL SELECT * FROM orphan_postdischarge_weight_5
      UNION ALL SELECT * FROM gap_postdischarge_weight_5
      -- visit 6
      UNION ALL SELECT * FROM orphan_post_weight_date6
      UNION ALL SELECT * FROM temporal_post_weight_date6_adm
      UNION ALL SELECT * FROM temporal_post_weight_date6_seq
      UNION ALL SELECT * FROM missing_post_weight_unit6
      UNION ALL SELECT * FROM invalid_post_weight_unit6
      UNION ALL SELECT * FROM orphan_post_weight_unit6
      UNION ALL SELECT * FROM implausible_postdischarge_weight_6
      UNION ALL SELECT * FROM orphan_postdischarge_weight_6
      UNION ALL SELECT * FROM gap_postdischarge_weight_6











    )

SELECT *
FROM all_issues
WHERE CAST(date_today AS TIMESTAMP) >= '2026-01-01'
  AND CAST(date_today AS TIMESTAMP) <= '2030-06-22'
ORDER BY id, variable;
