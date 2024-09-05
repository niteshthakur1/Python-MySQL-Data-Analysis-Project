use retail_db;
select * from df_orders;
-- find the top 10 highest  revenue generating products--
Select product_id ,sum(sale_price) as sale  from df_orders
group by product_id
order by sale desc
limit 10;

-- find the top 5 highest  selling products in each regions--
with cte as(
select region ,product_id,sum(sale_price)as sales
from df_orders
group by region,product_id)
select * from(
select *
, row_number() over (partition by region order by sales desc) as rn
from cte) A
where rn <=5;

-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as(
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price)as sales
 from df_orders
 group by year(order_date),month(order_date)
 order by year(order_date),month(order_date)
 )
select order_month
,sum(case when order_year=2022 then sales  else 0 end) as sales_2022
,sum(case when order_year=2023 then sales  else 0 end)  as sales_2023
 from cte
group by order_month
order by order_month;

-- which sub category had highest growth by profit in 2023 compare to 2022

WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM 
        df_orders
    GROUP BY 
        sub_category, 
        YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM 
        cte
    GROUP BY 
        sub_category
)
SELECT 
    sub_category,
    sales_2022,
    sales_2023,
    ROUND(((sales_2023 - sales_2022) * 100 / sales_2022), 2) AS growth_percentage
FROM  
    cte2
WHERE 
    sales_2022 > 0  -- Ensures no division by zero
ORDER BY 
    growth_percentage DESC
LIMIT 1;
