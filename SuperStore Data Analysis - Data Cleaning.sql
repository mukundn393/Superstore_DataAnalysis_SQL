-- SUPERSTORE DATA ANALYSIS PORTFOLIO PROJECT

---> I) DATA CLEANING

--> 1) Establish the relationship between the tables as per ER Diagram
--  i) Making the OrderID column in OrdersList table as PRIMARY KEY
--  Making the OrderID column non nullable first to add the Primary Key constraint
alter table orderslist alter column OrderID nvarchar(255) not null
--  now adding the primary key constraint to OrderID column of OrdersList table
alter table orderslist add constraint pk_OrderID primary key (OrderID)

--  ii) Adding the Foreign Key constraint to the OrderID column of EachOrderBreakdown table
--  Making the OrderID column non nullable first to add the Foreign Key constraint
alter table eachorderbreakdown alter column OrderID nvarchar(255) not null
--  now adding the primary key constraint to OrderID column of OrdersList table
alter table eachorderbreakdown add constraint fk_OrderID foreign key (OrderID) 
references orderslist (OrderID)

--> 2) Split City State Country into 3 individual columns namely 'City','State','Country'
--  i) Firstly adding new columns onto the OrdersList Table
alter table orderslist add Country nvarchar(255),State nvarchar(255),City nvarchar(255)
-- ii) Now Updating the 3 individuals as 'City','State' and 'Country' using update statement
update orderslist
set Country = PARSENAME(replace(city_state_country,',','.'),1),
    State = PARSENAME(replace(city_state_country,',','.'),2),
	City = PARSENAME(replace(city_state_country,',','.'),3);

--> 3) Add a new category column using the following mapping as per the first three or four 
--  characters in Product Name column
--  a. TECH - Technology
--  b. OFS - Office Supplies
--  c. FUR - Furniture
--  i) Firstly adding new 'category' column onto the eachorderbreakdown Table
alter table eachorderbreakdown add category nvarchar(255)
-- ii) now splitting to update the category column based on first three characters
update eachorderbreakdown
set category = case when left(ProductName,3) = 'OFS' then 'Office Supplies'
                    when left(ProductName,3) = 'FUR' then 'Furniture'
					when left(ProductName,4) = 'TECH' then 'Technology'
					end 

--> 4) Delete the first four characters in ProductName column of EachOrderBreakdown table
update eachorderbreakdown
set ProductName = trim(substring(ProductName,CHARINDEX('-',ProductName)+1,len(ProductName)))

--> 5) Remove duplicate rows from EachOrderBreakdown table, if all column values are matching
with cte_eob as
(select *,
ROW_NUMBER() over (partition by OrderID,ProductName,Discount,Sales,Profit,Quantity,SubCategory,category
order by OrderID ) as rn
from eachorderbreakdown)
delete from cte_eob where rn > 1
-- -- crosschecking for unique 8045 rows after removing duplicates  
select distinct * from eachorderbreakdown -- 8045 = 8045

--> 6) Replace blank with NA in OrderPriority Column in OrdersList table
update orderslist
set OrderPriority = isnull(OrderPriority,'NA')