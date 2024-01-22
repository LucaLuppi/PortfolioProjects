SELECT * 
FROM Portfolio.dbo.[Nashville Housing Data]

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio.dbo.[Nashville Housing Data]

Update [Nashville Housing Data]
SET SaleDate = CONVERT (Date,SaleDate)


ALTER TABLE [Nashville Housing Data]
Add SaleDateConverted Date;

Update [Nashville Housing Data]
SET SaleDateConverted = CONVERT (Date,SaleDate)



--Populate Property Address Data


Select *
FROM Portfolio.dbo.[Nashville Housing Data]
--WHERE PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio.dbo.[Nashville Housing Data] a
JOIN Portfolio.dbo.[Nashville Housing Data] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio.dbo.[Nashville Housing Data] a
JOIN Portfolio.dbo.[Nashville Housing Data] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null



--Breaking out Address into individual Columns (Address, City, State)


Select PropertyAddress
FROM Portfolio.dbo.[Nashville Housing Data]


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM Portfolio.dbo.[Nashville Housing Data]


ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
Add PropertySplitAddress Nvarchar(255);

Update Portfolio.dbo.[Nashville Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
Add PropertySplitCity Nvarchar(255);

Update Portfolio.dbo.[Nashville Housing Data]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM Portfolio.dbo.[Nashville Housing Data]


SELECT OwnerAddress
FROM Portfolio.dbo.[Nashville Housing Data]

SELECT
PARSENAME (REPLACE(OwnerAddress, ',' , '.') ,3)
,PARSENAME (REPLACE(OwnerAddress, ',' , '.') ,2)
,PARSENAME (REPLACE(OwnerAddress, ',' , '.') ,1)
FROM Portfolio.dbo.[Nashville Housing Data]


ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio.dbo.[Nashville Housing Data]
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',' , '.') ,3)

ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
Add OwnerSplitCity Nvarchar(255);

Update Portfolio.dbo.[Nashville Housing Data]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
Add OwnerSplitState Nvarchar(255);

Update Portfolio.dbo.[Nashville Housing Data]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',' , '.') ,1)


SELECT *
FROM Portfolio.dbo.[Nashville Housing Data]



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct (SoldAsVacant), Count(SoldAsVacant)
FROM Portfolio.dbo.[Nashville Housing Data]
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM Portfolio.dbo.[Nashville Housing Data]

Update Portfolio.dbo.[Nashville Housing Data]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END



--Remove Duplactes

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
FROM Portfolio.dbo.[Nashville Housing Data]
--Order by ParcelID
)
SELECT *
FROM RowNumCTE
WHere Row_num > 1
Order By PropertyAddress




-- Delete Unused Columns

SELECT * 
FROM Portfolio.dbo.[Nashville Housing Data]


ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio.dbo.[Nashville Housing Data]
DROP COLUMN SaleDate