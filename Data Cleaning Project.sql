
--Cleaning data in SQL queries

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

--Standardise date format
SELECT SaleDateConverted, CONVERT(date, SaleDate) 
FROM PortfolioProject.dbo.Nashvillehousing

Update Nashvillehousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Nashvillehousing
ADD SaleDateConverted date;

Update Nashvillehousing
SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate Property address data
SELECT *
FROM PortfolioProject.dbo.Nashvillehousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out adress into individual columns (Address, City,State)

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN (PropertyAddress)) as Address
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE Nashvillehousing
ADD PropertySplitCity nvarchar(255);

Update Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN (PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.Nashvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress ,',','.'), 3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity nvarchar(255);

Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress ,',','.'), 2)

ALTER TABLE Nashvillehousing
ADD OwnerSplitState nvarchar(255);

Update Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

--Change Y and N to Yes and No in "Sold As Vacant " Field

SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashvillehousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject.dbo.Nashvillehousing

Update Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
--Removing Duplicates

WITH RowNumCTE AS(
SELECT * ,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID 
			   ) row_num
FROM PortfolioProject.dbo.Nashvillehousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Delete unused columns
SELECT *
FROM PortfolioProject.dbo.Nashvillehousing

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN PropertyAddress , TaxDistrict , OwnerAddress

ALTER TABLE PortfolioProject.dbo.Nashvillehousing
DROP COLUMN SaleDate
