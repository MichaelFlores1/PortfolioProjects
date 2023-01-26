/*
Nashville Housing Data Set Data Cleaning
Guide Project from AlexTheAnalyst Video
Skills used: Data Cleaning, Identifying nonstandardized values, Self-Joins, Case Statements, Window Functions
*/


-- Selecting all data to get a feel for what the data set looks like

SELECT *
FROM PortfolioProject..NashvilleHousing;


-- Standardizing Date Format from Date timestamp to Date

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted  -- Selecting new column to verify data was added correctly
FROM PortfolioProject..NashvilleHousing;



-- Identifying and replacing missing data. PropertyAddress present in one record, but not in another record describing the same property

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- Breaking out PropertyAddress into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing;
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 1, LEN(PropertyAddress)) AS Address2
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1) + 1, LEN(PropertyAddress));


-- Splitting OwnerAddress field into three fields for Address, City, and State

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing;


-- Adding new split values from OwnerAddress (Address, City, State)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Standardizing values in SoldAsVacant Column. This column contained 4 values indicating yes or no. 'Y', 'N', 'Yes', 'No'
--  Identifying which format is more common to choose which one to change other values to
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant END
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant END;

-- Remove Duplicates. Identifying duplicates by looking for common values in several fields.

WITH RowNumCTE AS  (
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
FROM PortfolioProject..NashvilleHousing;
)

-- DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1;


-- Deleting Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate;


/* Data set is now in a more usable state. Dates have timestamps removed. Addresses are split up into Address, City, State. SoldAsVacant column
has been standardized to two possible values instead of 4. */
