/*
Cleaning Data in Nashville Housing database
*/


select *
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select SaleDateConverted, CONVERT(date,Saledate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,Saledate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,Saledate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar (300);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar (300);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress))

select *
from NashvilleHousing


select
Parsename(replace(OwnerAddress, ',' , '.'), 3),
Parsename(replace(OwnerAddress, ',' , '.'), 2),
Parsename(replace(OwnerAddress, ',' , '.'), 1)
from NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Varchar(300);

update NashvilleHousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress, ',' , '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity Varchar(300);

update NashvilleHousing
set OwnerSplitCity = Parsename(replace(OwnerAddress, ',' , '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Varchar(300);

update NashvilleHousing
set OwnerSplitState = Parsename(replace(OwnerAddress, ',' , '.'), 1)

select *
from NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

from NashvilleHousing

update NashvilleHousing

set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
						) row_num
from NashvilleHousing
--order by ParcelID
)

select * 
from RowNumCTE
where row_num > 1
order by  PropertyAddress


select *
from NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column Propertyaddress, OwnerAddress, SaleDate




