WITH hiv_codes AS (
  SELECT c2.concept_id
  FROM `bigquery-public-data.cms_synthetic_patient_data_omop.concept` AS c
  JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept_relationship` AS cr
    ON c.concept_id = cr.concept_id_1
  JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept` AS c2
    ON c2.concept_id = cr.concept_id_2
  WHERE (c.vocabulary_id = "ICD10CM" AND c.concept_code LIKE "B20%")
     OR (c.vocabulary_id = "ICD9CM" AND c.concept_code LIKE "042%")
),

drug_codes AS (
  SELECT concept_id
  FROM `bigquery-public-data.cms_synthetic_patient_data_omop.concept`
  WHERE vocabulary_id = 'RxNorm'
    AND concept_code IN ('643067', '643068', '643070', '1172891', '1172892', '643069')
)

SELECT p.person_id,
       p.gender_concept_id
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.person` AS p
LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence` AS co
  ON p.person_id = co.person_id
LEFT JOIN hiv_codes AS hc
  ON co.condition_concept_id = hc.concept_id
LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.drug_exposure` AS d
  ON p.person_id = d.person_id
LEFT JOIN drug_codes AS dc
  ON d.drug_concept_id = dc.concept_id
WHERE p.gender_concept_id = 8532   -- only female
  AND hc.concept_id IS NOT NULL    -- only HIV-positive
  AND dc.concept_id IS NOT NULL    -- only taking target drugs
LIMIT 1000;

