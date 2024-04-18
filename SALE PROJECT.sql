SELECT *
FROM salesdata

ALTER TABLE SALESDATA
ALTER COLUMN ORDERDATE DATE 

--checking unique values
select distinct(status)
from salesdata

select distinct(country)
from salesdata

select distinct(productline)
from salesdata

select (year_id)
from salesdata

select(dealsize)
from salesdata

select(territory)
from salesdata

--analyis
---grouping sales by productline
SELECT PRODUCTLINE,ROUND(MAX(SALES),1) AS REVENUE
FROM salesdata
GROUP BY PRODUCTLINE
ORDER  BY 1,2

SELECT PRODUCTLINE,ROUND(SUM(SALES),1) AS REVENUE
FROM salesdata
GROUP BY PRODUCTLINE
ORDER  BY 2 DESC

--GROUPING SALES BY YEAR
SELECT YEAR_ID,ROUND(SUM(SALES),1) AS REVENUE
FROM salesdata
GROUP BY YEAR_ID
ORDER  BY 2 DESC
--CHECKING FULL YEAR OPERATIOJN
SELECT DISTINCT(MONTH_ID)
FROM salesdata
WHERE YEAR_ID=2005

SELECT DISTINCT(MONTH_ID)
FROM salesdata
WHERE YEAR_ID=2003

SELECT DISTINCT(MONTH_ID)
FROM salesdata
WHERE YEAR_ID=2004

--GROUPING BY DEALSIZE

SELECT DEALSIZE,ROUND(SUM(SALES),1) AS REVENUE
FROM salesdata
GROUP BY DEALSIZE
ORDER  BY 2 DESC

---WHAT WAS THE BEST MONTH FOR SALES IN A SPECIFIC YEAR AND HOW MUCH WAS MADE
SELECT MONTH_ID,sum(sales) as revenue,count(ordernumber) as frequency
from salesdata
where YEAR_ID=2003
group by MONTH_ID
order by 1 desc

--november seems to be the best month,what product did they see in nov
SELECT MONTH_ID,productline,sum(sales) as revenue,count(ordernumber) as frequency
from salesdata
where YEAR_ID=2003 and MONTH_ID=11
group by MONTH_ID,PRODUCTLINE
order by 1 desc
  


----who's our best customer(this could be best answered with rfm analysis)
drop table if exists #rmf
;with rmf as 
(
select customername,sum(sales) as monetaryvalue,avg(SALES) AS AVGMONETARYVALUE,COUNT(ORDERNUMBER) AS FREQUENCY,MAX(ORDERDATE) AS LASTORDERDATE,(SELECT MAX(ORDERDATE) FROM salesdata) AS maxorderdate,DATEDIFF(dd,MAX(ORDERDATE),(SELECT MAX(ORDERDATE) FROM salesdata)) as recency
from salesdata
group by CUSTOMERNAME
),
 rmf_cal AS
(
select  *,
NTILE(4) OVER (ORDER BY RECENCY DESC) RMFRECENCY,
NTILE(4) OVER (ORDER BY FREQUENCY) RMFFREQUENCY,
NTILE(4) OVER (ORDER BY MONETARYVALUE) RMFMONETARYVALUE
FROM rmf 
)

SELECT *,RMFRECENCY+RMFFREQUENCY+RMFmonetaryvalue AS RMFCELL,CAST(RMFRECENCY AS VARCHAR)+CAST(RMFFREQUENCY AS varchar)+CAST(RMFmonetaryvalue AS varchar) RMF_CELL_STRING
into #rmf
FROM rmf_cal


select CUSTOMERNAME,RMFRECENCY,RMFFREQUENCY,RMFMONETARYVALUE,
case
when RMF_CELL_STRING in (111,112,121,122,123,132,211,212,114,141) then 'lostcustomer'
when RMF_CELL_STRING in(133,134,143,244,334,343,344) then 'slippingaway,cannot lose'
when RMF_CELL_STRING in(311,411,331) then 'new customer'
when RMF_CELL_STRING in (222,223,233,322) then 'potential churners'
when RMF_CELL_STRING in (323,333,321,422,332,432) then 'active'
when RMF_CELL_STRING in (433,434,443,444) then 'loyal'
end AS RMF_SEGMENT
from #rmf

 
---WHAT PRODUCT ARE MOST OFTEN SOLD TOGETHER 
--XML ANALYSIS
SELECT DISTINCT(ORDERNUMBER), STUFF (

(SELECT ','+ PRODUCTCODE
FROM salesdata AS P
WHERE ORDERNUMBER IN (
select ordernumber
from (
SELECT ORDERNUMBER ,COUNT(*) AS RN
FROM salesdata
WHERE STATUS='SHIPPED'
GROUP BY ORDERNUMBER
) M
where RN=2
)

AND P.ORDERNUMBER=S.ORDERNUMBER
FOR XML PATH ('')),1,1,'') AS PRODUCTCODES
FROM  salesdata AS S
ORDER BY 2 DESC

select ORDERNUMBER,count(ordernumber)
from salesdata
group by ORDERNUMBER
having count(ORDERNUMBER)>1

----product that are often sold together

select *
from salesdata



select ','+PRODUCTCODE
from salesdata
where ordernumber in(
select ordernumber 
from 
(select ORDERNUMBER,count(ordernumber) as rn
from salesdata
where status='shipped' 
group by ORDERNUMBER
) m
where rn=2
)
for xml path ('')







----checking for duplicate
with cte as (
select ROW_NUMBER () over
         (partition by
		ordernumber,
		quantityordered,
		orderlinenumber,
		priceeach
		order by sales)
		row_num
from salesdata
)


select *
from cte
where row_num>1

		

		select *
		from salesdata
					
