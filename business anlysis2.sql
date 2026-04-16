select * from [dbo].[business analysis]
##2.............
SELECT 
    Product_Category,
    SUM(Total_Revenue) AS total_revenue,
    AVG(Total_Revenue) AS avg_order_value,
    SUM(Profit) AS total_profit
FROM [dbo].[business analysis]
GROUP BY Product_Category;
##########3...................
WITH category_summary AS (
    SELECT 
        Product_Category,
        SUM(Total_Revenue) AS total_revenue,
        AVG(Total_Revenue) AS avg_order_value,
        SUM(Profit) AS total_profit
    FROM [dbo].[business analysis]
    GROUP BY Product_Category
)
################4....................
WITH monthly_sales AS (
    SELECT 
        Order_Month,
        SUM(Total_Revenue) AS monthly_revenue,
        SUM(Profit) AS monthly_profit
    FROM [dbo].[business analysis]
    GROUP BY Order_Month
)

SELECT 
    Order_Month,
    monthly_revenue,
    monthly_profit,
    LAG(monthly_revenue) OVER (ORDER BY Order_Month) AS prev_month_revenue,
    (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY Order_Month)) AS revenue_growth
FROM monthly_sales;
##########5............

WITH customer_profit AS (
    SELECT 
        Customer_Name,
        SUM(Profit) AS total_profit
    FROM [dbo].[business analysis]
   
    GROUP BY Customer_Name
)

SELECT 
    Customer_Name,
    total_profit,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM customer_profit
WHERE total_profit IS NOT NULL
ORDER BY total_profit DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
#############6.............
WITH monthly_revenue AS (
    SELECT 
        FORMAT(Signup_Date, 'yyyy-MM') AS order_month,
        SUM(Total_Revenue) AS revenue
    FROM [dbo].[business analysis]
   
    GROUP BY FORMAT(Signup_Date, 'yyyy-MM')
)

SELECT 
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    
    CASE 
        WHEN LAG(revenue) OVER (ORDER BY order_month) IS NULL THEN NULL
        ELSE 
            (revenue - LAG(revenue) OVER (ORDER BY order_month)) * 100.0 
            / LAG(revenue) OVER (ORDER BY order_month)
    END AS mom_growth_percent

FROM monthly_revenue
ORDER BY order_month;
##############7..............
WITH customer_orders AS (
    SELECT 
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS order_count
    FROM [dbo].[business analysis]
    GROUP BY Customer_ID
)

SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) AS repeat_customer_rate_percent
FROM customer_orders;
###############8...
WITH customer_revenue AS (
    SELECT 
        City,
        Customer_ID,
        Customer_Name,
        SUM(Total_Revenue) AS total_revenue
    FROM [dbo].[business analysis]
    GROUP BY City, Customer_ID, Customer_Name
)

SELECT 
    City,
    Customer_ID,
    Customer_Name,
    total_revenue,
    RANK() OVER (PARTITION BY City ORDER BY total_revenue DESC) AS city_rank
FROM customer_revenue
ORDER BY City, city_rank;
##################9..............
WITH monthly_product_sales AS (
    SELECT 
        Product_Name,
        DATEFROMPARTS(YEAR(Signup_Date), MONTH(Signup_Date), 1) AS order_month,
        SUM(Total_Revenue) AS revenue
    FROM [dbo].[business analysis]
    GROUP BY 
        Product_Name,
        DATEFROMPARTS(YEAR(Signup_Date), MONTH(Signup_Date), 1)
),

sales_trend AS (
    SELECT 
        Product_Name,
        order_month,
        revenue,
        LAG(revenue) OVER (PARTITION BY Product_Name ORDER BY order_month) AS prev_revenue
    FROM monthly_product_sales
)

SELECT DISTINCT Product_Name
FROM sales_trend
WHERE prev_revenue IS NOT NULL
  AND revenue > prev_revenue;

  SELECT Customer_ID FROM [dbo].[business analysis]
WHERE MONTH(Signup_Date) = 1

INTERSECT

SELECT Customer_ID FROM [dbo].[business analysis]
WHERE MONTH(Signup_Date) = 2

EXCEPT

SELECT Customer_ID FROM [dbo].[business analysis]
WHERE MONTH(Signup_Date) = 3;
#######################10................
WITH product_revenue AS (
    SELECT 
        Product_Category,
        Product_Name,
        SUM(Total_Revenue) AS total_revenue
    FROM [dbo].[business analysis]
    GROUP BY Product_Category, Product_Name
)

SELECT 
    Product_Category,
    Product_Name,
    total_revenue
FROM (
    SELECT *,
           RANK() OVER (
               PARTITION BY Product_Category 
               ORDER BY total_revenue DESC
           ) AS rank_in_category
    FROM product_revenue
) t
WHERE rank_in_category = 1;
###################11.....................
WITH daily_revenue AS (
    SELECT 
        CAST(Signup_Date AS DATE) AS order_date,
        SUM(Total_Revenue) AS revenue
    FROM [dbo].[business analysis]
    
    GROUP BY CAST(Signup_Date AS DATE)
)

SELECT 
    order_date,
    revenue,
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_date;

