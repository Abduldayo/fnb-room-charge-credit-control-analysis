
-- F&B Room Charge & Credit Control Analysis


-- Question 1. How much F&B revenue was charged to guest rooms overall?

SELECT SUM(charge_amount) AS total_fb_charges,
       COUNT(transaction_id) AS total_transactions,
       ROUND(AVG(charge_amount), 2) AS average_fnb_charges,
       COUNT(DISTINCT guest_id) AS total_guests
FROM fb_charges_staging2;

-- Question 2. Which guests had F&B charges despite having no credit or insufficient available credit?

SELECT ga.guest_name, ga.room_number, ga.credit_limit, ga.current_balance, fb.charge_amount
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
    ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
    OR  fb.charge_amount > (ga.credit_limit - ga.current_balance)
    ORDER BY ga.room_number;
    
-- Question 3. How much money was charged outside the intended credit limits?

SELECT  SUM(fb.charge_amount)
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
    ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
    OR  fb.charge_amount > (ga.credit_limit - ga.current_balance);
    
-- Question 4. Of those at-risk charges, how much was associated with Paid, Unpaid, or Disputed checkout outcomes?

SELECT co.checkout_status, SUM(fb.charge_amount)
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
    ON fb.guest_id = ga.guest_id
JOIN checkout_staging2 AS co
    ON fb.guest_id = co.guest_id
WHERE ga.credit_limit = 0
   OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
   GROUP BY 1;

-- Question 5. How much money actually remained unpaid at checkout for these at-risk guests?

WITH at_risk_guests AS (
    SELECT DISTINCT fb.guest_id
    FROM fb_charges_staging2 AS fb
    JOIN guest_accounts_staging2 AS ga
        ON fb.guest_id = ga.guest_id
    WHERE ga.credit_limit = 0
       OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
)

SELECT SUM(unpaid_amount)
FROM at_risk_guests AS ag
JOIN checkout_staging2 AS co
   ON ag.guest_id = co.guest_id;

-- Question 6. How much money was actually disputed at checkout for the at-risk guests?

WITH disputed_checkout AS (
SELECT DISTINCT (fb.guest_id)
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
	ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
       OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
)
SELECT SUM(co.disputed_amount)
FROM disputed_checkout AS ag
JOIN checkout_staging2 AS co
   ON ag.guest_id = co.guest_id;

-- Question 7. Are guests with no/insufficient credit more likely to leave unpaid or disputed balances

-- Total at-risk guests

WITH at_risk_guests AS (
SELECT DISTINCT fb.guest_id
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
	ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
	OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
)
SELECT COUNT(*)
FROM at_risk_guests;

-- At-risk guests with unpaid or disputed balances

WITH at_risk_guests AS (
SELECT DISTINCT fb.guest_id
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
   ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
	OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
)
SELECT COUNT(ar.guest_id)
FROM at_risk_guests AS ar
JOIN checkout_staging2 AS co
    ON ar.guest_id = co.guest_id
WHERE co.unpaid_amount > 0
   OR co.disputed_amount > 0;
   
SELECT ROUND((660.0 / 2155) * 100, 2) AS at_risk_rate;

-- Total not-at-risk guests

WITH at_risk_guests AS (
SELECT DISTINCT fb.guest_id
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
   ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
   OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
),
not_at_risk_guests AS (
SELECT DISTINCT fb.guest_id
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
   ON fb.guest_id = ga.guest_id
WHERE fb.guest_id NOT IN (
SELECT guest_id
FROM at_risk_guests
)
)
SELECT COUNT(*)
FROM not_at_risk_guests;

-- Not-at-risk guests with unpaid or disputed balances

WITH at_risk_guests AS (
SELECT DISTINCT fb.guest_id
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
   ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
   OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
),
not_at_risk_guests AS (
SELECT DISTINCT fb.guest_id
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
   ON fb.guest_id = ga.guest_id
WHERE fb.guest_id NOT IN (
SELECT guest_id
FROM at_risk_guests
)
)
SELECT COUNT(nar.guest_id)
FROM not_at_risk_guests AS nar
JOIN checkout_staging2 AS co
    ON nar.guest_id = co.guest_id
WHERE co.unpaid_amount > 0
   OR co.disputed_amount > 0;
   
SELECT ROUND((138.0 / 1044) * 100, 2) AS not_at_risk_rate;


-- Question 8. Which outlet contributed the most money to at-risk charges.

SELECT outlet, SUM(fb.charge_amount)
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
    OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
GROUP BY outlet
ORDER BY SUM(fb.charge_amount);


-- Question 9. Were there particular months where the problem was worse?

SELECT MONTH(fb.transaction_date), SUM(fb.charge_amount)
FROM fb_charges_staging2 AS fb
JOIN guest_accounts_staging2 AS ga
ON fb.guest_id = ga.guest_id
WHERE ga.credit_limit = 0
    OR fb.charge_amount > (ga.credit_limit - ga.current_balance)
GROUP BY MONTH(fb.transaction_date)
ORDER BY MONTH(fb.transaction_date);

