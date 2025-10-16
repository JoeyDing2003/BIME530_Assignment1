-- plz comment snippets to each assignment numbered section in the format!
WITH hiv_codes AS (
  SELECT
    c.concept_id AS source_concept_id,
    c.concept_code AS icd_code,
    c.concept_name AS icd_name,
    c2.concept_id AS standard_concept_id,
    c2.concept_code AS snomed_code,
    c2.concept_name AS snomed_name
  FROM `bigquery-public-data.cms_synthetic_patient_data_omop.concept` AS c
  JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept_relationship` AS cr
    ON cr.concept_id_1 = c.concept_id
  JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept` AS c2
    ON c2.concept_id = cr.concept_id_2
  WHERE ((c.vocabulary_id = "ICD10CM") AND (c.concept_code LIKE "B20%"))
     OR ((c.vocabulary_id = "ICD9CM") AND (c.concept_code LIKE "042%"))
)

-- Step 2: Main query using person, location, and drug tables
SELECT 
  p.person_id,
  p.gender_concept_id,
  c.concept_name AS gender_name,
  l.location_id,
  l.state,
  l.city,
  d.drug_concept_id,
  d.drug_exposure_start_date
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.person` AS p
JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept` AS c
  ON p.gender_concept_id = c.concept_id       -- gender mapping
LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.location` AS l
  ON p.location_id = l.location_id            -- person location mapping
JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.drug_exposure` AS d
  ON p.person_id = d.person_id
JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence` AS co
  ON p.person_id = co.person_id
JOIN hiv_codes AS hc
  ON co.condition_concept_id = hc.standard_concept_id   -- restrict to HIV diagnoses
WHERE
  p.gender_concept_id = 8532  -- Female
  AND d.drug_concept_id IN (561401)  -- Atripla or Lamivudine
  AND co.condition_start_date >= '2008-01-01'
LIMIT 1000;
