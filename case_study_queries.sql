/****** Script for Pens & Printers Data Analysis  ******/

USE pens_printers;

SELECT COUNT (*)
FROM office_supplies;

-- Checking total sales by Region
SELECT Region, SUM(Sales) AS Sales_by_Region
FROM office_supplies
GROUP BY Region
ORDER BY SUM(Sales) DESC;

-- Checking the period of orders in the dataset
SELECT MIN(YEAR(Order_Date)), MAX(YEAR(Order_Date))
FROM office_supplies;

-- Total amount of unique products
SELECT COUNT (DISTINCT Product_Name)
FROM office_supplies;

-- Grouping products that were only ordered in one region only and saving them into a new table: 'one_region' 
WITH CTE AS (SELECT Region, Product_Name, COUNT(Product_Name) AS no_of_orders
FROM office_supplies
GROUP BY Region, Product_Name)
SELECT Product_Name, COUNT(*) AS count_of_regions
INTO one_region
FROM CTE
GROUP BY Product_Name
HAVING COUNT(*) < 2;

-- Joining data in the one_region table with the office_supplies table to determine the total number of uniquely ordered products in each region
WITH CTE AS (SELECT DISTINCT o.Product_Name, os.Region
FROM dbo.one_region AS o
LEFT JOIN office_supplies AS os
ON o.Product_Name = os.Product_Name)
SELECT Region, COUNT(*) AS no_of_prod_reg
FROM CTE
GROUP BY Region
ORDER BY 2 DESC;

-- Extracting product names ordered only from the 'West' and their corresponding categories
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Product_Name NOT IN (SELECT DISTINCT Product_Name FROM office_supplies WHERE Region IN ('EAST', 'CENTRAL', 'SOUTH'))
ORDER BY 2;

-- Extracting product names ordered only from the 'East' and their corresponding categories
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Product_Name NOT IN (SELECT DISTINCT Product_Name FROM office_supplies WHERE Region IN ('WEST', 'CENTRAL', 'SOUTH'))
ORDER BY 2;

-- Extracting product names ordered only from the 'Central' region and their corresponding categories
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Product_Name NOT IN (SELECT DISTINCT Product_Name FROM office_supplies WHERE Region IN ('WEST', 'EAST', 'SOUTH'))
ORDER BY 2;

-- Extracting product names ordered only from the 'South' and their corresponding categories
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Product_Name NOT IN (SELECT DISTINCT Product_Name FROM office_supplies WHERE Region IN ('WEST', 'EAST', 'CENTRAL'))
ORDER BY 2;

-- Extracting the categories and count of products ordered in the 'Central' and 'South' but not in other regions
WITH CTE AS (SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'Central'
INTERSECT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'South'
EXCEPT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region IN ('West','East'))
SELECT Category, COUNT(Product_Name) FROM CTE GROUP BY Category ORDER BY 1;

-- Extracting products ordered in the 'Central' and 'South' but not in other regions and their corresponding categories
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'Central'
INTERSECT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'South'
EXCEPT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region IN ('West','East')

-- Extracting the categories and count of products ordered in the 'Central', 'South', and 'East' but not in the 'West'
WITH CTE AS (SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'Central'
INTERSECT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'South'
INTERSECT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'East'
EXCEPT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'West')
SELECT Category, COUNT(Product_Name) FROM CTE GROUP BY Category ORDER BY 1;

-- Extracting the categories and count of products ordered in the 'Central','South' and 'East' but not in the 'West'
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'Central'
INTERSECT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'South'
INTERSECT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'East'
EXCEPT
SELECT DISTINCT Product_Name, Category 
FROM office_supplies
WHERE Region = 'West'

-- Checking total sales by months
SELECT MONTH(Order_Date) AS Order_Month, SUM(Sales) AS Sales
FROM office_supplies
GROUP BY MONTH(Order_Date)
ORDER BY 2 DESC;

-- Checking total losses by months
SELECT MONTH(Order_Date) AS Month, SUM(Profit) AS Loss
FROM office_supplies
WHERE Profit < 0
GROUP BY MONTH(Order_Date)
ORDER BY 2;

-- Checking for products that incurred losses
SELECT Product_Name, SUM(Profit) AS Loss
FROM office_supplies
WHERE Profit < 0
GROUP BY Product_Name
ORDER BY 2;

-- Checking total losses by Regions
SELECT Region, SUM(Profit) AS Loss
FROM office_supplies
WHERE Profit < 0
GROUP BY Region
ORDER BY 2;


