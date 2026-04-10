DROP SCHEMA IF EXISTS medical_insurance;
CREATE SCHEMA medical_insurance;
USE medical_insurance;

-- Add BMI category column --

ALTER TABLE medical_insurance_cleaned
ADD COLUMN bmi_category VARCHAR(20);

UPDATE medical_insurance_cleaned
SET bmi_category = CASE
    WHEN `body_mass_value (bmi)` < 18.5 THEN 'Underweight'
    WHEN `body_mass_value (bmi)` < 25.0 THEN 'Normal'
    WHEN `body_mass_value (bmi)` < 30.0 THEN 'Overweight'
    ELSE 'Obese'
END
WHERE person_id > 0;

SELECT *
FROM medical_insurance_cleaned;

-- What is the total number of patients in the dataset?  --

SELECT COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned;

-- What is the average annual medical cost by age group?  --

SELECT 
    CASE 
        WHEN age BETWEEN 0 AND 17 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 35 THEN '18-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        WHEN age BETWEEN 51 AND 65 THEN '51-65'
        ELSE 'Over 65'
    END AS age_group,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY age_group
ORDER BY avg_medical_cost DESC;

--  Which region has the highest total claims paid?  --

SELECT 
    region,
    ROUND(SUM(total_claims_paid), 2) AS total_claims,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY region
ORDER BY total_claims DESC;

--   What is the average medical cost for smokers vs non-smokers?  --

SELECT 
    smoker,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    ROUND(AVG(total_claims_paid), 2) AS avg_claims_paid,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY smoker
ORDER BY avg_medical_cost DESC;

--  Which chronic conditions are most common among high-risk patients?  --

SELECT
    SUM(CASE WHEN hypertension = 'Yes' THEN 1 ELSE 0 END) AS hypertension_count,
    SUM(CASE WHEN diabetes = 'Yes' THEN 1 ELSE 0 END) AS diabetes_count,
    SUM(CASE WHEN cardiovascular_disease = 'Yes' THEN 1 ELSE 0 END) AS cardiovascular_count,
    SUM(CASE WHEN asthma = 'Yes' THEN 1 ELSE 0 END) AS asthma_count,
    SUM(CASE WHEN copd = 'Yes' THEN 1 ELSE 0 END) AS copd_count,
    SUM(CASE WHEN cancer_history = 'Yes' THEN 1 ELSE 0 END) AS cancer_count,
    SUM(CASE WHEN kidney_disease = 'Yes' THEN 1 ELSE 0 END) AS kidney_count,
    SUM(CASE WHEN mental_health = 'Yes' THEN 1 ELSE 0 END) AS mental_health_count
FROM medical_insurance.medical_insurance_cleaned
WHERE is_high_risk = 'Yes';

--  What is the average monthly premium by insurance plan type?  --

SELECT 
    plan_type,
    ROUND(AVG(monthly_premium), 2) AS avg_monthly_premium,
    ROUND(AVG(annual_premium), 2) AS avg_annual_premium,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY plan_type
ORDER BY avg_monthly_premium DESC;

--  What is the distribution of patients across risk categories?  --

SELECT 
    risk_category,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medical_insurance.medical_insurance_cleaned), 2) AS percentage
FROM medical_insurance.medical_insurance_cleaned
GROUP BY risk_category
ORDER BY total_patients DESC;

--  What is the average annual medical cost by BMI range?  --

SELECT 
    CASE 
        WHEN `body_mass_value (bmi)` < 18.5 THEN 'Underweight'
        WHEN `body_mass_value (bmi)` BETWEEN 18.5 AND 24.9 THEN 'Normal'
        WHEN `body_mass_value (bmi)` BETWEEN 25 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY bmi_category
ORDER BY avg_medical_cost DESC;

--  Which employment status has the highest average claims paid?  --

SELECT 
    employment_status,
    ROUND(AVG(total_claims_paid), 2) AS avg_claims_paid,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY employment_status
ORDER BY avg_claims_paid DESC;

--  How does income level affect annual medical cost?  --

SELECT 
    CASE 
        WHEN income < 20000 THEN 'Low (Under 20K)'
        WHEN income BETWEEN 20000 AND 50000 THEN 'Middle (20K-50K)'
        WHEN income BETWEEN 50001 AND 100000 THEN 'Upper Middle (50K-100K)'
        ELSE 'High (Over 100K)'
    END AS income_group,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    ROUND(AVG(total_claims_paid), 2) AS avg_claims_paid,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY income_group
ORDER BY avg_medical_cost DESC;

--  What percentage of patients with diabetes are classified as high risk?  --

SELECT 
    diabetes,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN is_high_risk = 'Yes' THEN 1 ELSE 0 END) AS high_risk_count,
    ROUND(SUM(CASE WHEN is_high_risk = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS high_risk_percentage
FROM medical_insurance.medical_insurance_cleaned
GROUP BY diabetes
ORDER BY high_risk_percentage DESC;

--  What is the average number of claims by network tier?  --

SELECT 
    network_tier,
    ROUND(AVG(claims_count), 2) AS avg_claims_count,
    ROUND(AVG(avg_claim_amount), 2) AS avg_claim_amount,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY network_tier
ORDER BY avg_claims_count DESC;

--   Which patients had major procedures and what was their average cost?  --

SELECT 
    had_major_procedure,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    ROUND(AVG(total_claims_paid), 2) AS avg_claims_paid,
    ROUND(AVG(days_hospitalized_last_3yrs), 2) AS avg_days_hospitalized,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY had_major_procedure
ORDER BY avg_medical_cost DESC;

--  What is the average risk score by education level?  --

SELECT 
    education,
    ROUND(AVG(risk_score), 4) AS avg_risk_score,
    ROUND(AVG(annual_medical_cost), 2) AS avg_medical_cost,
    COUNT(*) AS total_patients
FROM medical_insurance.medical_insurance_cleaned
GROUP BY education
ORDER BY avg_risk_score DESC;

--  What are the top 10 most expensive patients by total claims paid?  --

SELECT 
    person_id,
    age,
    sex,
    region,
    chronic_count,
    is_high_risk,
    ROUND(total_claims_paid, 2) AS total_claims_paid,
    ROUND(annual_medical_cost, 2) AS annual_medical_cost
FROM medical_insurance.medical_insurance_cleaned
ORDER BY total_claims_paid DESC
LIMIT 10;







