/* Data CLeaning Project 2
download the Dataset here -- credit to Alex The Analyst (https://www.youtube.com/watch?v=8rO7ztF4NtU&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=3)
*/

-- Import the dataset using
-- Inspect the total row of data imported and compare with data in the orginal spreadsheet
SELECT COUNT(*)
FROM [portfolio_project].[dbo].[nashville_housing]

-- Check the top 10 rows
SELECT TOP (10) *
FROM portfolio_project..nashville_housing

-- Populate PropertyAddress data. (Null = 29)
SELECT COUNT(*) 
FROM portfolio_project..nashville_housing
WHERE PropertyAddress IS NULL;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress
FROM portfolio_project..nashville_housing AS a
LEFT JOIN portfolio_project..nashville_housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
GROUP BY a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress;

-- Update the null values in the original dataset, then reconfirm update by counting the number of PropertyAddresses with nulls again

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..nashville_housing AS a
LEFT JOIN portfolio_project..nashville_housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

USE portfolio_project;

-- Breaking out PropertyAddress into Individual columns (Address, City, State) and saving into a new table 'nashville_housing_new'
SELECT *, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS 'Property Address',
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS 'Property City',
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS 'Owner Address',
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS 'Owner City',
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS 'Owner State'
INTO nashville_housing_new
FROM nashville_housing;

SELECT *
FROM nashville_housing_new;

-- Change Yes and No to Y and N respectively in the SoldAsVacant column for uniformity

UPDATE nashville_housing_new
SET SoldAsVacant = 'Y'
WHERE SoldAsVacant = 'Yes';

UPDATE nashville_housing_new
SET SoldAsVacant = 'N'
WHERE SoldAsVacant = 'No';

SELECT DISTINCT (SoldAsVacant)
FROM nashville_housing_new;
/* Remove duplicate rows (same details but separate unique IDs) by assigning ranks or row numbers to the rows via a windows function, 
the duplicate rows are then deleted using a CTE */

WITH duprows AS
(SELECT *, RANK() OVER(PARTITION BY ParcelID, PropertyAddress,
	   SaleDate, SalePrice, LegalReference
	   ORDER BY UniqueID) AS ranks
FROM nashville_housing_new)
DELETE
FROM duprows
WHERE ranks > 1;


