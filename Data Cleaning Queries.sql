/* 
Cleaning Data in SQL
*/

Select *
From housingdatacleaning.dbo.nashvillehousing

-- Standardize date format

Select SaleDateConverted, Convert(Date,saledate)
From housingdatacleaning.dbo.nashvillehousing

update nashvillehousing
SET SaleDate = convert(date,saledate)

Alter table nashvillehousing
add SaleDateConverted Date;

Update nashvillehousing
set SaleDateConverted = convert (date,saledate)

--Populate property address

SELECT *
FROM housingdatacleaning.dbo.nashvillehousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housingdatacleaning.dbo.nashvillehousing a
JOIN housingdatacleaning.dbo.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housingdatacleaning.dbo.nashvillehousing a
JOIN housingdatacleaning.dbo.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress
FROM housingdatacleaning.dbo.nashvillehousing
WHERE PropertyAddress is NULL

--Breaking out full address into individual columns (address, city, state)

--property address

SELECT PropertyAddress
FROM housingdatacleaning.dbo.nashvillehousing


ALTER TABLE housingdatacleaning.dbo.nashvillehousing
ADD PropertyAddressStreet NVARCHAR(255);

UPDATE housingdatacleaning.dbo.nashvillehousing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE housingdatacleaning.dbo.nashvillehousing
ADD PropertyAddressCity NVARCHAR(255);

UPDATE housingdatacleaning.dbo.nashvillehousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

SELECT PropertyAddressStreet, PropertyAddressCity
FROM housingdatacleaning.dbo.nashvillehousing


-- Owner address

SELECT OwnerAddress
FROM housingdatacleaning.dbo.nashvillehousing


ALTER TABLE housingdatacleaning.dbo.nashvillehousing
ADD OwnerAddressStreet NVARCHAR(255);

UPDATE housingdatacleaning.dbo.nashvillehousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE housingdatacleaning.dbo.nashvillehousing
ADD OwnerAddressCity NVARCHAR(255);

UPDATE housingdatacleaning.dbo.nashvillehousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE housingdatacleaning.dbo.nashvillehousing
ADD OwnerAddressState NVARCHAR(255);

UPDATE housingdatacleaning.dbo.nashvillehousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


------------------------------------------------------------------------------
-- Change "Y" to "Yes" and "N" to "No" in the "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant
FROM housingdatacleaning.dbo.nashvillehousing


UPDATE housingdatacleaning.dbo.nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	
-------------------------------------------------------------------------------
-- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM housingdatacleaning.dbo.nashvillehousing
)
--SELECT *
DELETE
FROM RowNUMCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



----------------------------------------------------------------
-- Delete Unused Columns


SELECT *
FROM housingdatacleaning.dbo.nashvillehousing

ALTER TABLE housingdatacleaning.dbo.nashvillehousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress
