-- Find top 10 revenue generating products
	select sub_category as products,
		   sum(sales_price) as revenue
    from retailorder.df_orders
	group by sub_category
    order by revenue desc
    limit 10;


-- Find top 5 highest selling products in each region
with cte as(
select 
	region, 
	sub_category as products,
	sum(sales_price) as revenue 
from retailorder.df_orders
group by region, products)
select * from(
select 
	*,
    row_number() 
    over (partition by region 
    order by revenue desc) as rn 
from cte) A
where rn<=5
;

-- Find month over month growth comparision for 2022 and 2023
-- eg,. jan2022 vs jan2023

with cte as 
(
select
	year(order_date) as order_year,
    month(order_date) as order_month,
    sum(sales_price) as revenue
from retailorder.df_orders
group by order_year, order_month
)
select 
		order_month,
        sum(case when order_year=2022 
				 then revenue 
                 else 0
                 end) as sales_2022,
		sum(case when order_year=2023 
				 then revenue 
                 else 0
                 end) as sales_2023
from cte
group by order_month
order by order_month
;
   
-- for each category which month has highest sales
with cte as (
select 
	category, 
    sum(sales_price) as sales,
    DATE_FORMAT(order_date, '%Y %m') as order_year_month
from retailorder.df_orders
group by order_year_month, category
)
select * from (
select * ,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1
;

-- which sub_category has highest growth by profit in 2023 compare to 2022
with cte as (
select 
	sub_category, 
    sum(sales_price) as sales,
    DATE_FORMAT(order_date, '%Y') as order_year
from retailorder.df_orders
group by order_year, sub_category
),
cte2 as(
select 
	sub_category ,
	sum(case when order_year=2022 
				 then sales 
                 else 0
                 end) as sales_2022,
	sum(case when order_year=2023 
				 then sales 
                 else 0
                 end) as sales_2023
from cte
group by sub_category
) 
select 
	*,
    (sales_2023 - sales_2022)*100/sales_2022 as sales_percent
from cte2
order by sales_percent desc
limit 1
;
