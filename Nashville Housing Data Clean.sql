

/*
Cleaning Data in SQL Queries
*/
select *
from PortfolioProject..[Nashville Housing Data]




--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select SaleDate, convert(date,saledate)
from PortfolioProject.. [Nashville Housing Data]

update [Nashville Housing Data]
set SaleDate = CONVERT(date, saledate)

select *
from PortfolioProject..[Nashville Housing Data]

alter table [Nashville Housing Data]
add SaledateConverted date;

update [Nashville Housing Data]
set SaledateConverted = convert(date, saledate)


select saledateconverted, convert(date,saledate)
from PortfolioProject.. [Nashville Housing Data]


-- If it doesn't Update properly


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select PropertyAddress
from PortfolioProject..[Nashville Housing Data]
where PropertyAddress is null

-- Check the data to ensure we know if there is any 'null'
-- Some data my be duplicates, create code to remove duplicates
select *
from PortfolioProject..[Nashville Housing Data]
--where PropertyAddress is null
order by ParcelID

-- Need to create a 'join' to make sure data can match if duplicates are the same

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..[Nashville Housing Data] a
JOIN PortfolioProject..[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Check to is if parcelID is the same but is missing property address, and fill in property 
-- A new column is created with the data, check to make sure it matches
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[Nashville Housing Data] a
JOIN PortfolioProject..[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- this next part updates the columns 

update a -- is the the 'join' file
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[Nashville Housing Data] a
JOIN PortfolioProject..[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
-- update successful "29 rows affected"
-- check dataset again, there should be no null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..[Nashville Housing Data] a
JOIN PortfolioProject..[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
-- perfect data is clean



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..[Nashville Housing Data]

-- Looking at the PropertyAddress, need to sperate address and city, state but the delimiter ","
-- Substring() "look at column" PropertyAdress, starting in the 1st value
-- CHARINDEX(), look for "," , in the PropertyAdress and remove anything after the "," 
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Adress
from PortfolioProject..[Nashville Housing Data]

-- lets look at the location of the "," to be able to remove "," out of the address
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Adress, --<-- a comma is added to the end to look at the postion in the charater
CHARINDEX(',', PropertyAddress)  -- Remove one ")" 
from PortfolioProject..[Nashville Housing Data]

-- Remove the ","
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress
from PortfolioProject..[Nashville Housing Data]
-- "," is remove

-- this code is to get the city 
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from PortfolioProject..[Nashville Housing Data]

-- Add columns 'PropertySplitAddres' and 'PropterySplitCity'
ALTER TABLE [Nashville Housing Data]
ADD PropertySplitAddress nvarchar(255);

UPDATE [Nashville Housing Data]
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- City
ALTER TABLE [Nashville Housing Data]
ADD PropertySplitCity nvarchar(255);

UPDATE [Nashville Housing Data]
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

-- Check Dataset
select *
from [Nashville Housing Data]

-- getting owner address

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
from [Nashville Housing Data]
-- add column 
ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitState nvarchar(255);

-- update rows information OwnerSplitAddress
UPDATE [Nashville Housing Data]
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE [Nashville Housing Data]
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

UPDATE [Nashville Housing Data]
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Check dateset for update
select *
from PortfolioProject..[Nashville Housing Data]







--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..[Nashville Housing Data]
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE WHEN soldasvacant = 'Y' then 'Yes'
		WHEN SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
from PortfolioProject..[Nashville Housing Data]

update [Nashville Housing Data]
 SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' then 'Yes'
		WHEN SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates, CTE - (Common Table Expression)
WITH RowNumCTE AS (
Select *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
		ORDER BY UniqueID ) ROW_NUM
from PortfolioProject..[Nashville Housing Data]
--ORDER BY ParcelID
)
select *
from RowNumCTE
where ROW_NUM >1 
order by PropertyAddress

-- Delete the rows with duplicates, doing it this way will remove data from dataset
WITH RowNumCTE AS (
Select *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
		ORDER BY UniqueID ) ROW_NUM
from PortfolioProject..[Nashville Housing Data]
--ORDER BY ParcelID
)
Delete
from RowNumCTE
where ROW_NUM >1 
--order by PropertyAddress

-- check dataset 
WITH RowNumCTE AS (
Select *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					LegalReference
		ORDER BY UniqueID ) ROW_NUM
from PortfolioProject..[Nashville Housing Data]
--ORDER BY ParcelID
)
select *
from RowNumCTE
--where ROW_NUM >1
order by PropertyAddress


select *
from portfolioproject.. [Nashville Housing Data]

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
select *
from portfolioproject.. [Nashville Housing Data] 

ALTER TABLE portfolioproject.. [Nashville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioproject.. [Nashville Housing Data]
DROP COLUMN SaleDate











-----------------------------------------------------------------------------------------------
-
