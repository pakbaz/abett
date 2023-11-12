-- 1. How many active employees are currently employed by Glorious Gumball?
-- Per dictionary.md Any employee who has NULL in emp_end_date is considered active
-- but we should also check for those who have emp_end_date that is in the future they are still technically employees

SELECT COUNT(*) AS Active_Employees
FROM employees
WHERE emp_end_date IS NULL OR emp_end_date > CURRENT_DATE;



-- 2. What are the email addresses of all active employees?

SELECT email
FROM employees
WHERE emp_end_date IS NULL OR emp_end_date > CURRENT_DATE;


-- 3. How many retirees, who used to be covered by Glorious Gumball, are no longer covered?

SELECT COUNT(*) AS Retirees_No_Longer_Covered
FROM retirees
WHERE term_date IS NOT NULL;


-- 4. How many employees have become retirees, versus how many have just dropped out of the Glorious Gumball system?

-- Employees who became retirees
SELECT COUNT(*) AS Became_Retirees
FROM Employees
JOIN Retirees ON Employees.employee_id = Retirees.employee_id;

-- Employees who dropped out
SELECT COUNT(*) AS Dropped_Out
FROM Employees
WHERE emp_end_date IS NOT NULL
AND employee_id NOT IN (SELECT employee_id FROM Retirees);


-- Combined Query using CASE statements and LEFT JOIN
SELECT 
  SUM(CASE 
        WHEN R.employee_id IS NOT NULL THEN 1 
        ELSE 0 
      END) AS Became_Retirees,
  SUM(CASE 
        WHEN R.employee_id IS NULL AND E.emp_end_date IS NOT NULL THEN 1 
        ELSE 0 
      END) AS Dropped_Out
FROM employees E
LEFT JOIN retirees R ON E.employee_id = R.employee_id;

-- 5. What is the average number of dependents per employee?

SELECT AVG(Dependent_Count) AS Avg_Dependents_Per_Employee
FROM (
    SELECT employee_id, COUNT(dependent_id) AS Dependent_Count
    FROM dependents
    GROUP BY employee_id
) AS Dependent_Totals;

-- 6. How many employees have no dependents?

SELECT COUNT(*) AS Employees_No_Dependents
FROM employees
WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM dependents);

-- 7. How many claims exist with each claimant type?

SELECT claimant_type, COUNT(*) AS Claim_Count
FROM claims
GROUP BY claimant_type;


-- 8. Generate a list of dependents and the number of claims each dependent has, for dependents with at least 10 claims in the past year

SELECT claimant_id, COUNT(claim_id) AS Claim_Count
FROM claims
WHERE claimant_type = 'dependent'
AND claim_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY claimant_id
HAVING Claim_Count >= 10;

-- 9. Retrieve a list of all claims for the retiree with employee_id=100 (for that person only, no dependents)

SELECT *
FROM claims
WHERE claimant_id = 100
AND claimant_type = 'retiree';


-- 10. What is the total claim amounts per "family" (i.e. an employee/retiree and their dependents)? For this report, we only want one row per family, with: the employee_id as the family identifier, the employee's first and last name for reference, and the summed claim amounts

SELECT employees.employee_id, employees.first_name, employees.last_name, SUM(claims.claim_amount) AS Total_Claims
FROM employees
LEFT JOIN claims ON employees.employee_id = claims.claimant_id AND claims.claimant_type = 'employee'
LEFT JOIN dependents ON employees.employee_id = dependents.employee_id
LEFT JOIN claims dependent_claims ON dependents.dependent_id = dependent_claims.claimant_id AND dependent_claims.claimant_type = 'dependent'
GROUP BY employees.employee_id, employees.first_name, employees.last_name;

-- 11. What is the total claim amount for all dependents, and what percentage is this amount out of all (summed) claims amounts?

SELECT SUM(claim_amount) AS Total_Dependent_Claims,
       (SUM(claim_amount) / (SELECT SUM(claim_amount) FROM claims)) * 100 AS Percentage_Of_All_Claims
FROM claims
WHERE claimant_type = 'dependent';

-- 12. Who is the person (employee, retiree, or dependent) with the highest number of claims, and how many claims do they have?

SELECT claimant_id, claimant_type, COUNT(claim_id) AS Claim_Count
FROM claims
GROUP BY claimant_id, claimant_type
ORDER BY Claim_Count DESC
LIMIT 1;

-- 13. Who is the person (employee, retiree, or dependent) with the highest claim_amount in their claims, and what is that total claim_amount?

SELECT claimant_id, claimant_type, SUM(claim_amount) AS Total_Claim_Amount
FROM claims
GROUP BY claimant_id, claimant_type
ORDER BY Total_Claim_Amount DESC
LIMIT 1;