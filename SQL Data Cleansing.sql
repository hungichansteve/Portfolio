--Explore the whole dataset
Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format
Select SaleDateConverted
From PortfolioProject..NashvilleHousing

Alter Table	NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

--Populate Property address
Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
On a.[UniqueID ] <> b.[UniqueID ] AND
a.ParcelID = b.ParcelID
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
On a.[UniqueID ] <> b.[UniqueID ] AND
a.ParcelID = b.ParcelID
Where a.PropertyAddress is null

--Split address into multiple columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table	NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table	NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Split Owner Address
Select PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table	NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table	NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table	NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" Column

Select SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing;

--Remove Duplicates (Dont recommend)

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				  ) row_num

From PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
Where row_num>1

--Delete Unused Columns (Dont recommend)
Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject..NashvilleHousing
