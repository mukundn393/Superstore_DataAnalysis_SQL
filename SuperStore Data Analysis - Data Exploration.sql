--   SUPERSTORE DATA ANALYSIS
---> DATA EXPLORATION

---> BEGINNER

-- 1) List the top 10 orders with the highest sales from the EachOrderBreakdown table
select top 10 * from eachorderbreakdown order by sales desc;

-- 2) Show the number of orders for each product category in the EachOrderBreakdown table
select category,count(OrderID) as num_of_orders from eachorderbreakdown
group by category

-- 3) Find the total profit for each sub-category in the EachOrderBreakdown table
select SubCategory,sum(profit) as total_profit from eachorderbreakdown
group by SubCategory;

---> INTERMEDIATE

-- 1) Identify the customer with the highest total sales across all orders
select top 1 CustomerName,SUM(Sales) as highest_sale from orderslist o
inner join eachorderbreakdown e on e.OrderID = o.OrderID
group by CustomerName
order by highest_sale desc;

-- 2) Find the month with highest average sales in OrdersList Table
select top 1 month(o.Orderdate) as month_of_order,datename(month,o.OrderDate) as month_name
,round(avg(sales),2) as avg_sales
from orderslist o
inner join eachorderbreakdown e on e.OrderID = o.OrderID
group by month(o.Orderdate),datename(month,o.OrderDate)
order by avg(sales) desc;

-- 3) Find out the average quantity ordered by customers whose first name starts with the alphabet 's'
select round(avg(e.quantity),2) as avg_quantity from orderslist o
join eachorderbreakdown e on e.OrderID = o.OrderID
where o.CustomerName like 's%'

--->  ADVANCED

--    1) Find out how many new customers were acquired in the year 2014 
with cte_2014 as 
(select CustomerName,min(OrderDate) as first_order_date from orderslist 
group by CustomerName having min(year(OrderDate)) = 2014)
select count(*) as new_customers_2014 from cte_2014

--    2) Calculate the percentage of total profit contributed by each sub-category to the overall profit
select SubCategory,
sum(profit) as subcat_profit,
sum(profit)/(select sum(profit) from eachorderbreakdown) * 100 as contrbution_percentage
from eachorderbreakdown
group by SubCategory

--    3) Find the average sales per customer, considering only customers who made more than one order
select CustomerName,avg(sales) as average_sales from orderslist o 
join eachorderbreakdown e on e.OrderID = o.OrderID
group by CustomerName having count(distinct o.OrderID) > 1
order by average_sales desc;

--    4) Identify the top-performing subcategory in each category based on total sales. 
--    Include the sub-category name, total sales, and a ranking of sub-category within each category
with sub_top as 
(select category,SubCategory,sum(sales) as total_sales,
rank() over (partition by category order by sum(sales) desc) as subcat_rank from eachorderbreakdown
group by category,SubCategory)
select * from sub_top where subcat_rank = 1