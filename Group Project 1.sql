CREATE TABLE IF NOT EXISTS yellevate_invoices (
	country varchar,
	customer_id varchar,
	invoice_number numeric,
	invoice_date date,
	due_date date,
	invoice_amount numeric,
	disputed numeric,
	disputed_lost numeric,
	settled_date date,
	days_settled integer,
	days_late integer
)

SELECT * FROM yellevate_invoices

--checking
SELECT country FROM yellevate_invoices
GROUP BY country

SELECT customer_id FROM yellevate_invoices
GROUP BY customer_id

SELECT country, customer_id FROM yellevate_invoices
GROUP BY country, customer_id

--updating the table
ALTER TABLE yellevate_invoices
ADD COLUMN disputed_upd varchar

UPDATE yellevate_invoices
SET disputed_upd = disputed

UPDATE yellevate_invoices
SET disputed_upd = CASE
	WHEN disputed_upd = '0' THEN 'non disputed invoices'
	WHEN disputed_upd = '1' THEN 'disputed invoices'
	ELSE disputed_upd
END 

ALTER TABLE yellevate_invoices
ADD COLUMN disputed_lost_upd varchar

UPDATE yellevate_invoices
SET disputed_lost_upd = disputed_lost

UPDATE yellevate_invoices
SET disputed_lost_upd = CASE
	WHEN disputed_lost_upd = '0' THEN 'yellevate won'
	WHEN disputed_lost_upd = '1' THEN 'yellevate lost'
	ELSE disputed_lost_upd
END 

ALTER TABLE yellevate_invoices
ADD COLUMN disputed_lost varchar


UPDATE yellevate_invoices
SET disputed_lost = CASE
	WHEN (disputed_upd = 'non disputed invoices' 
		 AND disputed_lost_upd = 'yellevate won') THEN 'non disputed invoices'
	WHEN (disputed_upd = 'disputed invoices' 
		 AND disputed_lost_upd = 'yellevate won') THEN 'yellevate won'
	ELSE 'yellevate lost'
	

END

ALTER TABLE yellevate_invoices
DROP COLUMN disputed,
DROP COLUMN disputed_lost

ALTER TABLE yellevate_invoices
DROP COLUMN disputed_lost_upd

--additional table

ALTER TABLE yellevate_invoices
ADD COLUMN disputed_amount numeric,
ADD COLUMN invoice_lost_amount numeric

UPDATE yellevate_invoices
SET disputed_amount = CASE
	WHEN disputed_upd = 'disputed invoices' THEN invoice_amount
	ELSE 0
END

UPDATE yellevate_invoices
SET invoice_lost_amount = CASE
	WHEN disputed_lost = 'yellevate lost' THEN invoice_amount
	ELSE 0
END

ALTER TABLE yellevate_invoices
ADD COLUMN remarks varchar

UPDATE yellevate_invoices
SET remarks = CASE
	WHEN days_late = '0' THEN 'On Time'
	ELSE 'Delayed'
END

--1
SELECT round(AVG(days_settled),0)
FROM yellevate_invoices

--2
SELECT disputed_upd, settled_date, days_settled
FROM yellevate_invoices
WHERE disputed_upd= 'disputed invoices'


SELECT round(AVG(days_settleD),0)
FROM yellevate_invoices
WHERE disputed_upd= 'disputed invoices'

--3
THE COMPANY LOST

SELECT disputed_upd, disputed_lost
FROM yellevate_invoices
WHERE disputed_upd = 'disputed invoices' 
AND disputed_lost = 'yellevate lost'


--TOTAL ROWS WHERE COMPANY LOST - 101 disputes where the company lost

SELECT COUNT(*)
FROM yellevate_invoices
WHERE disputed_upd = 'disputed invoices' 
AND disputed_lost = 'yellevate lost'

--TOTAL ROWS WHERE CUSTOMER DISPUTED - 571 disputes of the invoice by the customers

SELECT COUNT (invoice_number)
FROM yellevate_invoices

SELECT disputed_lost, (COUNT (*) * 100.0 / 
SUM(COUNT(*)) OVER () ) as "percentage loss"
FROM yellevate_invoices
GROUP BY disputed_lost

PERCENTAGE = (101/2466) * 100 = 4.10%

--4

--TOTAL REVENUE LOST FROM DISPUTES - $690,167

SELECT SUM(invoice_amount)
FROM yellevate_invoices
WHERE disputed_upd = 'disputed invoices'
AND disputed_lost = 'yellevate lost'

--TOTAL REVENUE FROM DISPUTES WHETHER THE COMPANY LOST OR WON - $3,748,744

SELECT SUM(invoice_amount)
FROM yellevate_invoices
WHERE disputed_upd = 'disputed invoices' 

--PERCENTAGE = (690,167 / 3,748,744) * 100 = 18.41%


--TOTAL REVENUE FROM ALL INVOICES - $14,770,318

SELECT SUM(invoice_amount)
FROM yellevate_invoices

SELECT round((690167.0/14770318.0)*100,2) AS "revenue from all invoices"

--5 

SELECT country, invoice_amount
FROM  yellevate_invoices
WHERE disputed_upd = 'disputed invoices' 
AND disputed_lost = 'yellevate lost'
ORDER BY invoice_amount desc

SELECT country, SUM(invoice_amount) AS sum_amount
FROM 	yellevate_invoices
WHERE disputed_upd = 'disputed invoices' 
AND disputed_lost = 'yellevate lost'
GROUP BY country
ORDER BY sum_amount desc
