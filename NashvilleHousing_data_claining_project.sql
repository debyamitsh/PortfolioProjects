/*
Data Cleaning in SQL
*/

select *
from NashvilleHousing


--Standardize Date format

select SaleDate --datetime
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

/* Done */
update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted
from NashvilleHousing

--Populate Property Address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.ParcelID, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

/* Done */
update a
set PropertyAddress = ISNULL(a.ParcelID, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

	

--Breaking out Address into individual columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NashvilleHousing

/* Done */
Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
from NashvilleHousing



select OwnerAddress
from NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

/* Done */
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashvilleHousing

--Change Y and N to Yes and No in 'Sold as vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
CASE when SoldASVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

/* Done */
update NashvilleHousing
set SoldAsVacant = CASE when SoldASVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

--Remove Duplicates

select * 
from NashvilleHousing


with RowNumCTE as 
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) rowNum

From NashvilleHousing
)
select *
from RowNumCTE
where rowNum > 1
order by PropertyAddress

/* Done */
with RowNumCTE as 
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) rowNum

From NashvilleHousing
)
delete
from RowNumCTE
where rowNum > 1

--Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
