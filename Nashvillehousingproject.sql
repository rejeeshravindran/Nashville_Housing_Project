
select * from NashvilleHousing


--cleaning the data 
select SaleDate from NashvilleHousing
order by 1;

--Standardizing the date format - here the date column is not standardized since there are zero's which we don't need-
-- we tried a query with the 'update' function but it was not working so we used alter table to create a new column-
--and inserted the correct date format into the new column 'saledate1'

select Saledate , convert (Date, Saledate) from sql_pro.dbo.NashvilleHousing ;

update NashvilleHousing
SET SaleDate =  convert (Date, Saledate);
-- we tried a query with the 'update' function, but it was not working
select Saledate from NashvilleHousing 


--so we are using alter table to create a new column and inserted the correct date format into the new column 'saledate1'

ALTER table sql_pro.dbo.NashvilleHousing
ADD saledate1 Date;

update NashvilleHousing
SET Saledate1 =  convert (Date, Saledate);

select Saledate1 from NashvilleHousing ;


----------------------------------------------------------------------------------------------------------
--populate address data 

--here there are multiple null values in the column  of 'property address', but we can also see that-
-- there is same 'parcel id' corresponding to the 'property address' in most of the null value columns-
--hence we are going to join the same column data with the column of parcel ID and populating the property address.

--

select a.ParcelID , a.PropertyAddress ,b.ParcelID , b.PropertyAddress ,  isnull(a.PropertyAddress,b.PropertyAddress)
from sql_pro.dbo.NashvilleHousing as a
join  sql_pro.dbo.NashvilleHousing as b on  a.ParcelID=b.ParcelID and  a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null
order by a.ParcelID;

--isnull is used to check if the a.PropertyAddress is null, then we will populate with the value of b.PropertyAddress into it 

update a set a.PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)

from sql_pro.dbo.NashvilleHousing as a
join  sql_pro.dbo.NashvilleHousing as b on  a.ParcelID=b.ParcelID and  a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null 
order by parcelid;



---------------------------------------------------------------------------------------------------


--breaking out address into individual columns (address,city, state )
--here we uses substring to select the data string  and also uses charindex-
--to specify the length of characters we need on the address

--select PropertyAddress from sql_pro.dbo.NashvilleHousing 

select
substring (PropertyAddress,1, charindex(',',PropertyAddress) -1  )     as address,

substring (PropertyAddress, charindex(',',PropertyAddress) +1 , len(PropertyAddress ) )     as address

from sql_pro.dbo.NashvilleHousing 

--adding and updating another column to accomodate the new data


alter table sql_pro.dbo.NashvilleHousing 
add Addressname nvarchar(222)

update sql_pro.dbo.NashvilleHousing 
set  Addressname = substring (PropertyAddress,1, charindex(',',PropertyAddress) -1  )

--adding and updating another column to accomodate the new data

alter table sql_pro.dbo.NashvilleHousing 
add CityName nvarchar(222)

update sql_pro.dbo.NashvilleHousing
set CityName = substring (PropertyAddress, charindex(',',PropertyAddress) +1 , len(PropertyAddress ) )    

-------------------------------------------------------------------------------------------------------

--breaking out owneraddress into individual columns (address,city, state )
--here we uses parsename and replace to select the required  data string-
--to specify the length of characters we need on the address


select 
parsename( replace( owneraddress, ',' , '.') , 3) ,
parsename( replace( owneraddress, ',' , '.') , 2) ,
parsename( replace( owneraddress, ',' , '.') , 1) 

from  sql_pro.dbo.NashvilleHousing


alter table sql_pro.dbo.NashvilleHousing
add owneraddressname nvarchar(255),
 ownercity nvarchar(255),
ownerstate nvarchar(255);

update sql_pro.dbo.NashvilleHousing

set owneraddressname = parsename( replace( owneraddress, ',' , '.') , 3),

ownercity= parsename( replace( owneraddress, ',' , '.') , 2),

ownerstate = parsename( replace( owneraddress, ',' , '.') , 1);


----------------------------------------------------------------------------------------------------------------------



--while exploring  on the soldasvacant column, we are going to update y to yes and n to no 

select distinct soldasvacant , count(soldasvacant) from sql_pro.dbo.NashvilleHousing
group by soldasvacant
order by 2 ;

select soldasvacant ,
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No' 
	 ELSE soldasvacant END 
	from sql_pro.dbo.NashvilleHousing



update sql_pro.dbo.NashvilleHousing
set soldasvacant  =  
case when soldasvacant = 'Y' then 'Yes'
     when soldasvacant = 'N' then 'No' 
	 ELSE soldasvacant END 

	-- checking once again if the updates are done. 
	 select distinct soldasvacant , count(soldasvacant) from sql_pro.dbo.NashvilleHousing
group by soldasvacant
order by 2 ;

------------------------------------------------------------------------------------------------

--removing the duplicates

-- here we are using 'partition by' so that we can find the corresponding row with duplicates-
--if we use groupby it will only gives us the count of the rownumber and not the complete row where the duplicate is present
--row_number will identify the number of rows 

--after finding the duplicate rows, we need to sort the duplicate rows seperately- for the deletion that is why we are using-
-- CTE table/subquery to store the required table and using it for the seperation.

with row_numbercte as
(
select *  , ROW_NUMBER() over ( 
partition by   Parcelid,
				propertyaddress,
				saledate,
				legalreference 
				order by uniqueid
				)  as 'rownumber'

from sql_pro.dbo.NashvilleHousing
--order by parcelid 
)

select * from row_numbercte 
where rownumber >1 
order by PropertyAddress
				
--now the duplicates are seperated we can delete it 

with row_numbercte as
(
select *  , ROW_NUMBER() over ( 
partition by   Parcelid,
				propertyaddress,
				saledate,
				legalreference 
				order by uniqueid
				)  as 'rownumber'

from sql_pro.dbo.NashvilleHousing
--order by parcelid 
)

delete from row_numbercte 
where rownumber >1 

----------------------------------------------------------------

--delete unused columns 

select * from sql_pro.dbo.NashvilleHousing

alter table sql_pro.dbo.NashvilleHousing
drop column  SaleDate

