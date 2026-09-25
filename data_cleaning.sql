
-- Guest accounts Data Cleaning

SELECT *
FROM guest_accounts_raw;

-- Create staging table

CREATE TABLE guest_accounts_staging
LIKE guest_accounts_raw;

INSERT INTO guest_accounts_staging
SELECT *
FROM guest_accounts_raw;

-- Check and remove duplicates

WITH guest_account_cte AS (
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY guest_id, guest_name, country, room_number, credit_limit, current_balance, checkin_date, checkout_date) AS row_num
FROM guest_accounts_staging
)
SELECT *
FROM guest_account_cte
WHERE row_num > 1 ;

CREATE TABLE guest_accounts_staging2
LIKE guest_accounts_staging;

ALTER TABLE guest_accounts_staging2
ADD COLUMN row_num INT;

INSERT INTO guest_accounts_staging2
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY guest_id, guest_name, country, room_number, credit_limit, 
             current_balance, checkin_date, checkout_date) AS row_num
FROM guest_accounts_staging;

DELETE
FROM guest_accounts_staging2
WHERE row_num >1;

-- Standardize and clean data

SELECT guest_id, guest_name, country
FROM guest_accounts_staging2
WHERE guest_id <> TRIM(guest_id)
   OR guest_name <> TRIM(guest_name)
   OR country <> TRIM(country);

UPDATE guest_accounts_staging2
SET guest_id = TRIM(guest_id),
    guest_name = TRIM(guest_name),
    country = TRIM(country);

SELECT DISTINCT country
FROM guest_accounts_staging2
ORDER BY country;

SELECT  country
FROM guest_accounts_staging2
GROUP BY BINARY country, country
ORDER BY country;


UPDATE guest_accounts_staging2
SET country = CASE
   WHEN country = 'CANADA' THEN 'Canada'
   WHEN country = 'FRANCE' THEN 'France'
   WHEN country = 'GERMANY' THEN 'Germany'
   WHEN country = 'GHANA' THEN 'Ghana'
   WHEN country = 'IRELAND' THEN 'Ireland'
   WHEN country = 'ITALY' THEN 'Italy'
   WHEN country = 'NETHERLANDS' THEN 'Netherlands'
   WHEN country = 'NIGERIA' THEN 'Nigeria'
   WHEN country = 'south korea' THEN 'South Korea'
   WHEN country IN ( 'SPAIN', 'Spain.') THEN 'Spain'
   WHEN country IN ( 'United Kingdom', 'U.K.', 'uk') THEN 'UK'
   WHEN country IN ( 'United States', 'usa') THEN 'USA'
   ELSE country
END;

ALTER TABLE guest_accounts_staging2
MODIFY COLUMN checkin_date DATE,
MODIFY COLUMN checkout_date DATE,
MODIFY COLUMN credit_limit DECIMAL(10,2),
MODIFY COLUMN current_balance DECIMAL(10,2);

-- Check for NULL and blank values

SELECT *
FROM guest_accounts_staging2
WHERE guest_id IS NULL OR guest_id = ''
   OR guest_name IS NULL OR guest_name = ''
   OR country IS NULL OR country = ''
   OR room_number IS NULL
   OR credit_limit IS NULL
   OR current_balance IS NULL
   OR checkin_date IS NULL
   OR checkout_date IS NULL;
   
-- Final clean
   
SELECT *
FROM guest_accounts_staging2;

ALTER TABLE guest_accounts_staging2
DROP COLUMN row_num;


-- F&B charges data cleaning

SELECT *
FROM fb_charges_raw;

-- Create staging table

CREATE TABLE fb_charges_staging
LIKE fb_charges_raw;

INSERT INTO fb_charges_staging
SELECT *
FROM fb_charges_raw;

-- Check and remove duplicates

WITH fb_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY transaction_id, transaction_date, guest_id, room_number, outlet, charge_amount) AS row_num
FROM fb_charges_staging
)
SELECT *
FROM fb_cte
WHERE row_num > 1;


CREATE TABLE `fb_charges_staging2` (
  `transaction_id` text,
  `transaction_date` text,
  `guest_id` text,
  `room_number` int DEFAULT NULL,
  `outlet` text,
  `charge_amount` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO fb_charges_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY transaction_id, transaction_date, guest_id, room_number, outlet, charge_amount) AS row_num
FROM fb_charges_staging;

DELETE 
FROM fb_charges_staging2
WHERE row_num > 1;

-- Standardize and clean data

SELECT transaction_id, guest_id, outlet
FROM fb_charges_staging2
WHERE transaction_id <> TRIM(transaction_id)
    OR guest_id <> TRIM(guest_id)
    OR outlet <> TRIM(outlet);

UPDATE fb_charges_staging2
SET transaction_id = TRIM(transaction_id),
	guest_id = TRIM(guest_id),
    outlet = TRIM(outlet);

SELECT DISTINCT outlet
FROM fb_charges_staging2
ORDER BY 1;

SELECT outlet
FROM fb_charges_staging2
GROUP BY BINARY outlet, outlet
ORDER BY 1;

UPDATE fb_charges_staging2
SET outlet = CASE
  WHEN outlet LIKE 'breakfast%' THEN 'Breakfast'
  WHEN outlet LIKE 'restaurant and bar%' THEN 'Restaurant & Bar'
  WHEN outlet LIKE 'room service%' THEN 'Room Service'
  ELSE outlet
END;

ALTER TABLE fb_charges_staging2
MODIFY COLUMN transaction_date DATE,
MODIFY COLUMN charge_amount DECIMAL(10,2);


-- Check for NULL and blank values

SELECT *
FROM fb_charges_staging2
WHERE transaction_id IS NULL OR transaction_id = ''
   OR transaction_date IS NULL
   OR guest_id IS NULL OR guest_id = ''
   OR room_number IS NULL
   OR outlet IS NULL OR outlet = ''
   OR charge_amount IS NULL;
   
-- Check for unmatched guest IDs

SELECT fb.guest_id
FROM fb_charges_staging2 AS fb
LEFT JOIN guest_accounts_staging2 AS ga
         ON fb.guest_id = ga.guest_id
WHERE ga.guest_id IS NULL;

SELECT
    COUNT(*) AS unmatched_transactions,
    COUNT(DISTINCT fb.guest_id) AS unmatched_guests
FROM fb_charges_staging2 AS fb
LEFT JOIN guest_accounts_staging2 AS ga
    ON fb.guest_id = ga.guest_id
WHERE ga.guest_id IS NULL;

 -- Final cleanup 
 
SELECT *
FROM fb_charges_staging2;

ALTER TABLE fb_charges_staging2
DROP COLUMN row_num;



-- Payments data cleaning

SELECT *
FROM payments_raw;

-- Create staging table

CREATE TABLE payments_staging
LIKE payments_raw;

INSERT INTO payments_staging
SELECT *
FROM payments_raw;

-- Check and remove duplicates

WITH payments_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY payment_id, guest_id, room_number, payment_amount, payment_date, payment_type ) AS row_num
FROM payments_staging
)
SELECT *
FROM payments_cte
WHERE row_num > 1 ;

CREATE TABLE payments_staging2
LIKE payments_staging;

ALTER TABLE payments_staging2
ADD COLUMN row_num INT;

INSERT INTO payments_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY payment_id, guest_id, room_number, payment_amount, payment_date, payment_type ) AS row_num
FROM payments_staging;

DELETE
FROM payments_staging2
WHERE row_num > 1;

--  Standardize and clean data

SELECT payment_id, guest_id, payment_type
FROM payments_staging2
WHERE payment_id <> TRIM(payment_id)
      OR guest_id <> TRIM(guest_id)
      OR payment_type <> TRIM(payment_type);
      
UPDATE payments_staging2
SET payment_id = TRIM(payment_id),
    guest_id = TRIM(guest_id),
    payment_type = TRIM(payment_type);
    
SELECT DISTINCT payment_type
FROM payments_staging2
ORDER BY 1;

SELECT payment_type
FROM payments_staging2
GROUP BY BINARY payment_type, payment_type
ORDER BY 1;

UPDATE payments_staging2
SET payment_type = CASE
   WHEN payment_type LIKE 'card%' THEN 'Card'
   WHEN payment_type LIKE 'cash%' THEN 'Cash'
   WHEN payment_type LIKE 'stripe%' THEN 'Stripe'
   ELSE payment_type
END;

ALTER TABLE payments_staging2
MODIFY COLUMN payment_amount DECIMAL(10,2),
MODIFY COLUMN payment_date DATE;

-- Check for NULL and blank values

SELECT *
FROM payments_staging2
WHERE payment_id IS NULL OR payment_id = ''
    OR guest_id IS NULL OR guest_id = ''
    OR room_number IS NULL
    OR payment_amount IS NULL
    OR payment_date IS NULL
    OR payment_type IS NULL OR payment_type = '';
    
-- Final clean up

SELECT *
FROM payments_staging2;

ALTER TABLE payments_staging2
DROP COLUMN row_num;


-- Checkout data cleaning

SELECT *
FROM checkout_raw;

-- Create staging table

CREATE TABLE checkout_staging
LIKE checkout_raw;

INSERT INTO checkout_staging
SELECT *
FROM checkout_raw;

-- Check and remove duplicates

WITH checkout_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY guest_id, room_number, checkout_date, checkout_status, unpaid_amount, disputed_amount) AS row_num
FROM checkout_staging
)
SELECT *
FROM checkout_cte
WHERE row_num >1 ;

CREATE TABLE checkout_staging2
LIKE checkout_staging;

ALTER TABLE checkout_staging2
ADD COLUMN row_num INT;

INSERT INTO checkout_staging2
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY guest_id, room_number, checkout_date, checkout_status, unpaid_amount, disputed_amount) AS row_num
FROM checkout_staging;

DELETE
FROM checkout_staging2
WHERE row_num >1 ;

-- Standardize and clean data

SELECT guest_id, checkout_status
FROM checkout_staging2
WHERE guest_id <> TRIM(guest_id)
    OR checkout_status <> TRIM(checkout_status);
    
UPDATE checkout_staging2
SET guest_id = TRIM(guest_id),
    checkout_status = TRIM(checkout_status);

SELECT DISTINCT checkout_status
FROM checkout_staging2
ORDER BY 1;

SELECT checkout_status
FROM checkout_staging2
GROUP BY BINARY checkout_status, checkout_status
ORDER BY 1;

UPDATE checkout_staging2
SET checkout_status = CASE
  WHEN checkout_status LIKE 'disputed%' THEN 'Disputed'
  WHEN checkout_status LIKE 'paid%' THEN 'Paid'
  WHEN checkout_status LIKE 'unpaid%' THEN 'Unpaid'
  ELSE checkout_status
END ;

ALTER TABLE checkout_staging2
MODIFY COLUMN checkout_date DATE,
MODIFY COLUMN unpaid_amount DECIMAL(10,2),
MODIFY COLUMN disputed_amount DECIMAL(10,2);

-- Check for NULL and  blank values

SELECT *
FROM checkout_staging2
WHERE guest_id IS NULL OR guest_id = ''
   OR room_number IS NULL
   OR checkout_date IS NULL
   OR checkout_status IS NULL OR checkout_status = ''
   OR unpaid_amount IS NULL
   OR disputed_amount IS NULL;
   
-- Final clean

SELECT *
FROM checkout_staging2;

ALTER TABLE checkout_staging2
DROP COLUMN row_num;






