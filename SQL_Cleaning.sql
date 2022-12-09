/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  /*
  Project objective is to clean and make the data more useful
  Cleaning Data in SQL Queries
  
  */
  Select *
  FROM PortfolioProject.dbo.NashvilleHousing

  -----------------------------------------------------------------------------------------------------------------------------------------------
  --- Standardize Date Format 
  -- Currently in date time format, we'll convert to Date format


  SELECT saleDateConverted, Convert(Date, SaleDate)
  FROM PortfolioProject.dbo.NashvilleHousing

  

   SELECT SaleDate
  FROM PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE NashvilleHousing
  Add SaleDateConverted Date;

  Update NashvilleHousing
  SET saleDateConverted = CONVERT(Date, SaleDate)


  -----------------------------------------------------------------------------------------------------------------------------------------------
  --Populate Property Address data

  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing
  --WHERE PropertyAddress is NULL
  ORDER BY ParcelID

  --We find that ParcelID goes along with Property Address
  --Therefore where the propertyaddress is empty we will populate with an address from a the match ParcelID that has an address
  --We will join the ParcelID to itself and see the ParcelID match but not the same row because of the UniqueID
  --We will then use ISNULL to look for null values in a.Property and populate with address values from b.Property


   SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is NULL

  
 SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is NULL
  

  UPDATE a
  SET  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
   WHERE a.PropertyAddress is NULL



  -----------------------------------------------------------------------------------------------------------------------------------------------
  --Breaking out Address into Individual Columns (Address, City, State)
  -- Substring will help us search for the delimeter in this case the comma separating the address and city
  ---Start at property column, first values till the comma

   SELECT PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing
  --WHERE PropertyAddress is NULL
 -- ORDER BY ParcelID

 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address
  FROM PortfolioProject.dbo.NashvilleHousing




 ALTER TABLE NashvilleHousing
 Add PropertySplitAddress Nvarchar(255);


 Update NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


 ALTER TABLE NashvilleHousing
 Add PropertySplitCity Nvarchar(255);


 Update NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


 SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing

 



 SELECT		OwnerAddress
  FROM PortfolioProject.dbo.NashvilleHousing




  --Instead of comma we replace with fullstop and split address, city and state
  Select 
  PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
   PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
    PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
  FROM PortfolioProject.dbo.NashvilleHousing


   ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255);


 Update NashvilleHousing
 SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)


 ALTER TABLE NashvilleHousing
 Add OwnerSplitCity Nvarchar(255);


 Update NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

  ALTER TABLE NashvilleHousing
 Add OwnerSplitState  Nvarchar(255);


 Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)





 SELECT *
 FROM PortfolioProject.dbo.NashvilleHousing





   -----------------------------------------------------------------------------------------------------------------------------------------------
   --Change Y and N to Yes and No in Sold as Vacant field

 SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
  
 FROM PortfolioProject.dbo.NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2


  -- Chnage to Yes and No since they have more values populated
 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
 WHEN SoldAsVacant = 'N' THEN 'NO'
 ELSE SoldAsVacant
 END
 FROM PortfolioProject.dbo.NashvilleHousing


 Update NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
 WHEN SoldAsVacant = 'N' THEN 'NO'
 ELSE SoldAsVacant
 END



  

	--Remove Duplicates

	WITH RowNumCTE AS(
	SELECT * ,

	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress, SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID ) row_num

	
	FROM PortfolioProject.dbo.NashvilleHousing
	--ORDER BY ParcelID
	)
	SELECT *
	FROM RowNumCTE
	WHERE row_num  > 1
	--ORDER BY PropertyAddress

	  -----------------------------------------------------------------------------------------------------------------------------------------------


	  -- Delete Unused Columns

	  SELECT *
	  FROM PortfolioProject.dbo.NashvilleHousing

	  ALTER TABLE PortfolioProject.dbo.NashvilleHousing
	  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

	  ALTER TABLE PortfolioProject.dbo.NashvilleHousing
	  DROP COLUMN SaleDate


	  -----------------------------------------------------------------------------------------------------------------------------------------------


	    --WRAP UP--


	  -- Using CONVERT we standardised the date format
	  -- Populated the Property Address
	  -- Changed the Y,N to Yes and No using Case Statement
	  --Remove duplicates using Partion by
	  -- Deleted unused columns