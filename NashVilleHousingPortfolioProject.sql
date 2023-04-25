

-- Cleaning Data in SQL Queries 


Select*
From NashvilleHousingPortfolioProject..NashvilleHousing


--Standardize Date Format


Select SaleDateConverted, Convert(Date, SaleDate)
From NashvilleHousingPortfolioProject..NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted  = CONVERT(Date,SaleDate)


--Populate Property Address


Select *
From NashvilleHousingPortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From NashvilleHousingPortfolioProject..NashvilleHousing a
JOIN NashvilleHousingPortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From NashvilleHousingPortfolioProject..NashvilleHousing a
JOIN NashvilleHousingPortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID]
Where a.PropertyAddress is null 


-- Seperating Adress into Individual Colums (Adress, City, State)


Select PropertyAddress
From NashvilleHousingPortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
--order by ParcelID


Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From NashvilleHousingPortfolioProject..NashvilleHousing



Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress  = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




Select OwnerAddress
From NashvilleHousingPortfolioProject..NashvilleHousing


Select 
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)
From NashvilleHousingPortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress  = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity  = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState  = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)


Select *
From NashvilleHousingPortfolioProject..NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousingPortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2 


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From NashvilleHousingPortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


--Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

From NashvilleHousingPortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--Delete Unused Columns


Select *
From NashvilleHousingPortfolioProject..NashvilleHousing


Alter Table NashvilleHousingPortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate