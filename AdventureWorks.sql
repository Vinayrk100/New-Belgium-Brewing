--What are the sales, product costs, profit, number of orders & quantity ordered for internet sales by product category and ranked by sales?
select sum(SalesAmount) as Sales,  
sum(ProductStandardCost) as Product_Costs, sum(SalesAmount - ProductStandardCost) as Profit,
sum(OrderQuantity) as Quantity_Ordered, count(SalesOrderNumber) as Number_of_Orders, DimPC.ProductCategoryKey, 
Rank() over(order by sum(SalesAmount) desc) as Rank_Product  from dbo.FactInternetSales as FIS
INNER JOIN dbo.DimProduct as DimP on FIS.ProductKey = DimP.ProductKey
INNER JOIN dbo.DimProductSubCategory as DimPSC on DimP.ProductSubcategoryKey = DimPSC.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory as DimPC on DimPSC.ProductCategoryKey = DimPC.ProductCategoryKey
group by DimPC.ProductCategoryKey;



-- What are the sales, product costs, profit, number of orders & quantity ordered for product category Accessories broken-down by Product Hierarchy (Category, Subcategory, Model & Product) for both internet & reseller sales?
select sum(SalesAmount) as Sales, 
sum(ProductStandardCost) as Product_Cost, 
sum(SalesAmount - ProductStandardCost) as Profit, 
sum(OrderQuantity) as Quantity_Ordered, 
count(SalesOrderNumber) as Number_of_Orders, 
DimP.ProductSubcategoryKey, DimP.ModelName, DimP.ProductKey, DimPC.ProductCategoryKey 
from dbo.FactInternetSales as FIS
INNER JOIN dbo.DimProduct as DimP on FIS.ProductKey = DimP.ProductKey
INNER JOIN dbo.DimProductSubCategory as DimPSC on DimP.ProductSubcategoryKey = DimPSC.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory as DimPC on DimPSC.ProductCategoryKey = DimPC.ProductCategoryKey
group by DimPC.ProductCategoryKey, DimP.ProductSubcategoryKey, DimP.ModelName, DimP.ProductKey

Union all

select sum(SalesAmount) as Sales, 
sum(ProductStandardCost) as Product_Cost, 
sum(SalesAmount - ProductStandardCost) as Profit, 
sum(OrderQuantity) as Quantity_Ordered, 
count(SalesOrderNumber) as Number_of_Orders, 
DimP.ProductSubcategoryKey, DimP.ModelName, DimP.ProductKey, DimPC.ProductCategoryKey 
from dbo.FactResellerSales as FRS
INNER JOIN dbo.DimProduct as DimP on FRS.ProductKey = DimP.ProductKey
INNER JOIN dbo.DimProductSubCategory as DimPSC on DimP.ProductSubcategoryKey = DimPSC.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory as DimPC on DimPSC.ProductCategoryKey = DimPC.ProductCategoryKey
group by DimPC.ProductCategoryKey, DimP.ProductSubcategoryKey, DimP.ModelName, DimP.ProductKey;


--What are the sales, discount amounts (promotion discounts), profit and promotion % of sales for Reseller Sales by Promotion Hierarchy (Category, Type & Name) – sorted descending by sales.?
select sum(SalesAmount) as Sales,
sum(DiscountAmount) as Discount_Amount,
sum(SalesAmount - ProductStandardCost) as Profit,
(sum((UnitPriceDiscountPct)*(OrderQuantity))/100) as PromotionPct_of_Sales,
DimP.EnglishPromotionType as Promotion_Type, DimP.EnglishPromotionName as Promotion_Name, DimP.EnglishPromotionCategory as Promotion_Category,
Rank() over(order by sum(SalesAmount) desc) as Rank_Product 
from dbo.FactResellerSales as FRS
inner join dbo.DimPromotion as DimP on FRS.PromotionKey = DimP.PromotionKey
group by DimP.EnglishPromotionType, DimP.EnglishPromotionName, DimP.EnglishPromotionCategory


-- Find the customer who has the highest sale amount in Internet Sales
select distinct customerKey 
from dbo.FactInternetSales 
group by customerKey
having sum(SalesAmount) > (select max(total) from 
(select customerKey, sum(SalesAmount) as total from dbo.FactInternetSales group by CustomerKey) as a)

--Find sales orders whose average is greater than the total average for internet sales
select SalesOrderNumber, avg(SalesAmount) as Avg_Sales
from dbo.FactInternetSales
group by SalesOrderNumber
having avg(SalesAmount) > (select avg(SalesAmount) from dbo.FactInternetSales)


--What are the sales by year by sales channels (internet, reseller & total)?
select YEAR(dbo.FactInternetSales.ShipDate) as years_internet,
sum(dbo.FactInternetSales.SalesAmount) as totalsales_internet,
YEAR(dbo.FactResellerSales.ShipDate) as years_reseller, 
sum(dbo.FactResellerSales.SalesAmount) as totalsales_reseller, 
sum(dbo.FactInternetSales.SalesAmount+dbo.FactResellerSales.SalesAmount) as total 
from dbo.FactInternetSales
inner join dbo.FactResellerSales on dbo.FactResellerSales.ProductKey=dbo.FactInternetSales.ProductKey
group by YEAR(dbo.FactInternetSales.ShipDate),YEAR(dbo.FactResellerSales.ShipDate);


--What are the total sales by month (& year)?
select 'Internet Sales' as type, 
sum(dbo.FactInternetSales.SalesAmount) as total_sales,
dbo.DimDate.CalendarYear as year, 
dbo.DimDate.EnglishMonthName as month
from dbo.FactInternetSales
inner join dbo.DimDate on dbo.FactInternetSales.OrderDateKey=dbo.DimDate.DateKey
group by dbo.DimDate.CalendarYear, dbo.DimDate.EnglishMonthName

union all

select 'Reseller Sales' as type, 
sum(dbo.FactResellerSales.SalesAmount) as total_sales,
dbo.DimDate.CalendarYear as year, 
dbo.DimDate.EnglishMonthName as month
from dbo.FactResellerSales
inner join dbo.DimDate on dbo.FactResellerSales.OrderDateKey=dbo.DimDate.DateKey
group by dbo.DimDate.CalendarYear, dbo.DimDate.EnglishMonthName
order by dbo.DimDate.CalendarYear, dbo.DimDate.EnglishMonthName;
