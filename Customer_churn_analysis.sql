-- CREATING TABLE 
CREATE TABLE CustomerData (
    Customer_ID VARCHAR(20),
    Gender VARCHAR(10),
    Age INT,
    Married VARCHAR(10),
    Number_of_Dependents INT,
    City VARCHAR(100),
    Zip_Code INT,
    Latitude FLOAT,
    Number_of_Referrals INT,
    Tenure_in_Months INT,
    Offer VARCHAR(50),
    Phone_Service VARCHAR(10),
    Avg_Monthly_Long_Distance_Charges FLOAT,
    Multiple_Lines VARCHAR(10),
    Internet_Service VARCHAR(10),
    Internet_Type VARCHAR(20),
    Avg_Monthly_GB_Download INT,
    Online_Security VARCHAR(10),
    Online_Backup VARCHAR(10),
    Device_Protection_Plan VARCHAR(10),
    Premium_Tech_Support VARCHAR(10),
    Streaming_TV VARCHAR(10),
    Streaming_Movies VARCHAR(10),
    Streaming_Music VARCHAR(10),
    Unlimited_Data VARCHAR(10),
    Contract VARCHAR(20),
    Paperless_Billing VARCHAR(17),
    Payment_Method VARCHAR(50),
	Monthly_charge FLOAT,
    Total_Charges FLOAT,
    Total_Refunds FLOAT,
    Total_Extra_Data_Charges FLOAT,
    Total_Long_Distance_Charges FLOAT,
    Total_Revenue FLOAT,
    Customer_Status VARCHAR(20),
    Churn_Category VARCHAR(50),
    Churn_Reason VARCHAR(100)
);

SELECT COUNT(*) AS total_customer, 
		gender ,
		ROUND(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate
FROM customerdata 
GROUP BY gender;
-------------------------------------------------------------------------------------
-- 1. Identifying Duplicate Customer IDs
-- Using COUNT(*) to Identify Duplicate Customer IDs
SELECT customer_id , COUNT(*)
FROM customerdata 
GROUP BY customer_id
HAVING COUNT(*) > 1 ; 
-------------------------------------------------------------------------------------
-- 2. Identifying Duplicate Customer IDs\
-- Using ROW_NUMMBER to Identify Duplicate Customer IDs

WITH duplicate AS (
SELECT ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS row_num
FROM customerdata)
SELECT row_num
FROM duplicate
WHERE rn > 1 ; 
-------------------------------------------------------------------------------------
-- 3. Customer Churn Rate by Gender
SELECT COUNT(*) AS total_customer, 
		gender ,
		ROUND(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate
FROM customerdata 
GROUP BY gender;
-------------------------------------------------------------------------------------
-- 4. Customer Status Distribution

SELECT COUNT(*) , customer_status
FROM customerdata 
GROUP BY customer_status;
-------------------------------------------------------------------------------------
-- 5. Customer Churn Analysis and Churn Rate Calculation

SELECT COUNT(customer_id),
	   SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customer,
	   SUM(CASE WHEN customer_status = 'Stayed' THEN 1 ELSE 0 END ) AS stayed_customer,
	   SUM(CASE WHEN customer_status = 'Joined' THEN 1 ELSE 0 END ) AS joined_customer,
	   CONCAT(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) * 100/
	   COUNT(*),'%') AS customer_rate 
FROM customerdata; 
-------------------------------------------------------------------------------------
-- 6. Customer Churn Analysis and Churn Rate Calculation Excluding recently joined 
SELECT COUNT(customer_id),
	   SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customer,
	   SUM(CASE WHEN customer_status = 'Stayed' THEN 1 ELSE 0 END ) AS stayed_customer,
	   SUM(CASE WHEN customer_status = 'Joined' THEN 1 ELSE 0 END ) AS joined_customer,
	   CONCAT(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) * 100/
	  SUM(CASE WHEN customer_status IN('Churned','Stayed') THEN 1 ELSE 0 END),'%') AS customer_rate 
FROM customerdata; 
-------------------------------------------------------------------------------------
-- 7. How does monthly charge impact churn?

SELECT COUNT(DISTINCT customer_id),
		CASE WHEN monthly_charge < 65 THEN 'Low' 
			 WHEN monthly_charge BETWEEN 65 AND 100 THEN 'Medium'
		ELSE 'High' 
		END AS charge_bracket ,
		churn_reason 
FROM customerdata 
WHERE customer_status = 'Churned'
GROUP BY 2,3 
ORDER BY 1 DESC
;
------------------------------------------------------------------
--  8. Churn Reasons Analysis

WITH Churn_reason AS (
SELECT COUNT(*) AS customer_churned,
	   churn_category,
	   churn_reason
FROM customerdata
WHERE customer_status = 'Churned'
GROUP BY churn_category,
	   churn_reason
)
SELECT customer_churned ,churn_category, churn_reason
FROM Churn_reason
ORDER BY customer_churned DESC; 
------------------------------------------------------------------
-- 9. Customer Churn Rate by Tenure Range
SELECT COUNT(customer_id),
		CASE WHEN Tenure_in_Months BETWEEN 0 AND 6 THEN '0-6 Months'
		WHEN Tenure_in_Months BETWEEN 7 AND 12 THEN '7-12 Months'
		WHEN Tenure_in_Months BETWEEN 13 AND 24 THEN '12 -24 Months'
		ELSE '24 Months'
		END AS tenure_range,
	COUNT(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customer, 
	CONCAT(ROUND(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END)*100/
	COUNT(*),0),'%') AS churn_rate
FROM customerdata 
GROUP BY 2
ORDER BY churn_rate DESC;

------------------------------------------------------------------
-- 10. Customer Churn Rate by Internet Service Type
SELECT 
    Internet_Service,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate
FROM CustomerData
GROUP BY Internet_Service;

------------------------------------------------------------------
-- 11. Customer Churn Rate by Offer Type
WITH offer_churn_rate AS (
SELECT offer, 
		COUNT(*) AS total_customer, 
		SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customer
FROM customerdata
GROUP BY 1
)
SELECT offer,
		total_customer,
		churned_customer,
		ROUND(Churned_Customer * 100.0 / Total_Customer, 2) AS Churn_Rate
FROM offer_churn_rate 
ORDER BY churn_rate DESC; 
------------------------------------------------------------------
-- 12. Churn Analysis and Customer Lifetime Value (LTV) by Status and Multiple Lines

SELECT COUNT(*) AS customer , 
		multiple_lines,
		churn_category , 
		ROUND(SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate
FROM customerdata 
GROUP BY 2,3
ORDER BY 4,2 DESC;

SELECT 
    customer_status,
    SUM(total_revenue) AS total_revenue,
    COUNT(customer_id) AS total_customers,
    SUM(total_revenue) / COUNT(customer_id) AS ltv
FROM customerdata
WHERE customer_status IN ('Churned', 'Stayed')
GROUP BY customer_status;
--------------------------------------------------------------------------
-- 13. Churn Rate Analysis by Demographics (Age Range and Gender)

WITH cte AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 0 AND 19 THEN 'Teen'
            WHEN age BETWEEN 20 AND 30 THEN 'Young Adult'
            WHEN age BETWEEN 31 AND 45 THEN 'Adult'
            ELSE 'Old'
        END AS age_range,
        Gender,
        COUNT(customer_id) AS total_customers,
        SUM(CASE WHEN customer_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customer
    FROM customerdata
    GROUP BY age_range, gender
)
SELECT 
    age_range, 
    gender, 
    total_customers, 
    churned_customer,
    CONCAT(
        ROUND(churned_customer * 100.0 / total_customers, 2), '%'
    ) AS churn_rate_by_demographics
FROM cte
ORDER BY churned_customer DESC;



