---Total Revenue
select SUM(total_price) as Total_Revenue from pizza_sales
select * from pizza_sales
---Average Order Value
select SUM(total_price)/ count (distinct order_id) as avg_order_value from pizza_sales
---Total Pizza Sold
select sum(quantity) as total_pizza_sold from pizza_sales
---Total Orders
select COUNT(DISTINCT order_id) AS total_orders FROM pizza_sales
---Average Pizza Orders
SELECT CAST (CAST (SUM(quantity) AS DECIMAL (10,2))/
       CAST (count(distinct order_id) AS DECIMAL (10,2)) AS DECIMAL(10,2))  as avg_pizza_order from pizza_sales
use [Pizza DB] 
---1) Daily Trend
select DATENAME(weekday,order_date) as order_day, count(distinct order_id) as total_orders from pizza_sales
group by DATENAME(weekday,order_date)
---2) Hourly Trend
select DATEPART(hour, order_time) as order_hour, count(distinct order_id) as total_orders from pizza_sales
group by(DATEPART(hour, order_time))
order by(DATEPART(hour, order_time))
---3) percentage of Sales by Pizza Category
select pizza_category, sum(total_price) *100/ (select sum(total_price)from pizza_sales where MONTH(order_date) = 1) as percent_sales
from pizza_sales
where MONTH(order_date) = 1
group by pizza_category
---4) Percentage of Sales by Pizza Size
select pizza_size, CAST (sum(total_price) AS DECIMAL (10,2))  as Total_Sales , CAST(sum(total_price)*100/ (select sum(total_price)from pizza_sales) AS DECIMAL (10,2)) as percent_sales
from pizza_sales
WHERE (DATEPART(QUARTER,order_date))= 1
GROUP BY (pizza_size)
order by percent_sales desc
---5) Total Pizza Sold by the pizza Category
select pizza_category, sum(quantity) as total_pizzas_sold from pizza_sales
group by(pizza_category)
order by (sum(quantity)) desc
---6) Top 5 best seller by Total Pizza Sold
select TOP 5 pizza_name, sum(quantity) as top5_total_pizzas_sold from pizza_sales
group by(pizza_name)
order by (sum(quantity)) desc
---7) Bottom 5 Worst Seller by Total Pizza Sold
select TOP 5 pizza_name, sum(quantity) as worst5_total_pizzas_sold from pizza_sales
group by(pizza_name)
order by (sum(quantity)) 