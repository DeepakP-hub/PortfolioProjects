--Standardize date format

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashivilleHousing

Update NashivilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--if doesn't work properly

ALTER TABLE NashivilleHousing
Add SaleDateConverted Date;

Update NashivilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data

Select *
From PortfolioProject..NashivilleHousing
where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashivilleHousing a
JOIN PortfolioProject..NashivilleHousing b
	ON a.ParcelID=b.ParcelID
	and
	a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashivilleHousing a
JOIN PortfolioProject..NashivilleHousing b
	ON a.ParcelID=b.ParcelID
	and
	a.[UniqueID ]<>b.[UniqueID ]

--seperating address into different columns

Select PropertyAddress
From PortfolioProject..NashivilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From PortfolioProject..NashivilleHousing

ALTER TABLE NashivilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashivilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashivilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashivilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From PortfolioProject..NashivilleHousing

--Using Parsename

Select OwnerAddress
From PortfolioProject..NashivilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashivilleHousing

ALTER TABLE NashivilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashivilleHousing
SET OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashivilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashivilleHousing
SET OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashivilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashivilleHousing
SET OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashivilleHousing

--Converting N and Y to No and yes respectively in SoldAsVacant Field

Select SoldAsVacant,COUNT(SoldAsVacant)
From PortfolioProject..NashivilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NashivilleHousing

Update NashivilleHousing
SET SoldAsVacant= CASE
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by
	UniqueID
	) as row_num

From PortfolioProject..NashivilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject..NashivilleHousing

-- Removing unused columns

Select *
From PortfolioProject..NashivilleHousing

ALTER TABLE PortfolioProject..NashivilleHousing
DROP COLUMN SaleDate