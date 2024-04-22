-- Ex1: ---------------------------------------------------------------------------------------------------------------------------------------------------------
/* There is no implicit (automatic) cast from text or varchar to integer 
(i.e. you cannot pass a varchar to a function expecting integer or assign a varchar field to an integer one), 
so you must specify an explicit cast using ALTER TABLE ... ALTER COLUMN ... TYPE ... USING */

ALTER TABLE SALES_DATASET_RFM_PRJ
	ALTER COLUMN ordernumber TYPE INT USING(ordernumber::integer),
	ALTER COLUMN quantityordered TYPE SMALLINT USING(quantityordered::smallint),
	ALTER COLUMN priceeach TYPE DECIMAL USING(priceeach::decimal),
	ALTER COLUMN orderlinenumber TYPE SMALLINT USING(orderlinenumber::smallint),
	ALTER COLUMN sales TYPE DECIMAL USING(sales::decimal),
	ALTER COLUMN msrp TYPE SMALLINT USING(msrp::smallint),
  	ALTER COLUMN contactfullname TYPE TEXT

/* chuyển đổi cột orderdate: dd/mm/yyyy -> yyyy-mmm-dd */
-- datatype: timestamp - date
  
-- C1:
/* SET DATASTYLE : specifies how to format date/time output for the current session */
SET datestyle = 'iso,mdy';  
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate TYPE timestamp USING (orderdate:: timestamp)    

-- C2:
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN dated DATE 

UPDATE SALES_DATASET_RFM_PRJ
SET dated = CAST(orderdate AS DATE)

  
-- Ex2: ---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE	ordernumber IS NULL
		OR quantityordered IS NULL
		OR priceeach IS NULL
		OR orderlinenumber IS NULL
		OR sales IS NULL
		OR orderdate IS NULL

-- KQ: 0 có dòng nào
  

-- Ex3: ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- thêm cột mới
  ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN contactlastname VARCHAR(50),
ADD COLUMN contactfirstname VARCHAR(50)

-- tách firstname
UPDATE SALES_DATASET_RFM_PRJ
SET contactfirstname = SUBSTRING(contactfullname,
						POSITION('-' IN contactfullname)+1
				)

-- chữ cái đầu viết hoa
UPDATE SALES_DATASET_RFM_PRJ 
SET contactfirstname = CONCAT(
				UPPER(LEFT(contactfirstname,1)),
				SUBSTRING(contactfirstname,2)
			     )

-- tách lastname
UPDATE SALES_DATASET_RFM_PRJ
SET contactlastname = LEFT(contactfullname,
					  LENGTH(contactfullname)
					  - (LENGTH (contactfirstname)+1)
			  )
  
-- chữ cái đầu viết 
UPDATE SALES_DATASET_RFM_PRJ 
SET contactlastname = CONCAT(
				UPPER(LEFT(contactlastname,1)),
				SUBSTRING(contactlastname,2)
			    )

  
-- Ex4: ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- thêm 3 cột
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN MONTH_ID SMALLINT,
ADD COLUMN QTR_ID SMALLINT,
ADD COLUMN YEAR_ID SMALLINT

-- UPDATE data
UPDATE SALES_DATASET_RFM_PRJ
SET MONTH_ID = EXTRACT(MONTH from orderdate)

UPDATE SALES_DATASET_RFM_PRJ
SET QTR_ID = EXTRACT(QUARTER from orderdate)

UPDATE SALES_DATASET_RFM_PRJ
SET YEAR_ID = EXTRACT(YEAR from orderdate)

	
-- Ex5: ---------------------------------------------------------------------------------------------------------------------------------------------------------

-- C1: BoxPlot

-- B1: Q1 - Q3 - IQR
WITH B1 AS (
SELECT	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS Q1,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) AS Q3,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered)
		- PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS IQR
FROM SALES_DATASET_RFM_PRJ
)
,
	
-- B2: MIN - MAX
B2 AS (
SELECT	(Q1-1.5*IQR) AS min,
		(Q3-1.5*IQR) AS max
FROM B1
)
	
-- B3: Outlier   						(bôi đen b1,2)
SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE	quantityordered < (SELECT min FROM B2)
		OR quantityordered > (SELECT max FROM B2)
ORDER BY quantityordered
	
-- B4: Xóa Outlier						(bôi đen b1,2)
DELETE FROM SALES_DATASET_RFM_PRJ
WHERE 	quantityordered < (SELECT min FROM B2)
		OR quantityordered > (SELECT max FROM B2)


-- C2: Z-Score
-- B1: Xác định AVERAGE - STANDARD_DEVIATION
WITH B1 AS (
SELECT	*,
		(SELECT AVG(quantityordered) as average 
		 	FROM SALES_DATASET_RFM_PRJ),
		(SELECT STDDEV(quantityordered) as standard_deviation 
		 	FROM SALES_DATASET_RFM_PRJ)
FROM SALES_DATASET_RFM_PRJ
)
,

-- B2: Z-Score -> Outlier ABS() > 2-3
B2 AS (
SELECT	*,
	(quantityordered - average) / standard_deviation as Z_Score
FROM B1
WHERE ABS((quantityordered - average) / standard_deviation) >2
)

-- B3: Xóa Outlier
DELETE FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered IN (SELECT quantityordered FROM B2)
	

-- Ex6: --------------------------------------------------------------------------------------------------------------------------------------------------------- 
CREATE TABLE sales_dataset_rfm_prj_clean
AS( SELECT * FROM SALES_DATASET_RFM_PRJ )



	

----------------------------------------------------------------------------------------------------------------------------------------------
/* chuyển dữ liệu date/time thành dạng "yyyy-mm-dd time" */
--b1: thêm cột mới
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN ordereddate varchar(50)

--b2: chỉnh ngày để thêm số 0 ở đầu
UPDATE SALES_DATASET_RFM_PRJ
SET ordereddate = CONCAT('0', orderdate)
WHERE substring(orderdate,2,1) = '/'

-- b3: thêm data vào các ô NULL
UPDATE SALES_DATASET_RFM_PRJ
SET ordereddate = orderdate
WHERE ordereddate IS NULL

-- b4: thêm cột mới
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN date varchar(50)

-- b5: tách dữ liệu (bỏ ngày) từ cột ordereddate
UPDATE SALES_DATASET_RFM_PRJ
SET date = SUBSTRING(ordereddate, 4)

-- b6: chỉnh tháng để thêm số 0 ở đầu
UPDATE SALES_DATASET_RFM_PRJ
SET date = CONCAT('0', date)
WHERE substring(date,2,1) = '/'

-- b7: thêm cột mới 
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN dated varchar(50)

-- b8: tách + concat cho đúg kiểu yyyy-mm-dd 
UPDATE SALES_DATASET_RFM_PRJ
SET dated = CONCAT(
					SUBSTRING(date,4,4),
					'-',
					LEFT(date,2),
					'-',
					LEFT(ordereddate,2),
					' ',
					SUBSTRING(date,9)
					)
-- b9: xóa cột orderdate, ordereddate, date
ALTER TABLE SALES_DATASET_RFM_PRJ
  DROP COLUMN orderdate,
  DROP COLUMN ordereddate,
  DROP COLUMN date

-- b10: đổi tên dated -> orderdate
ALTER TABLE SALES_DATASET_RFM_PRJ
  RENAME COLUMN dated TO orderdate
