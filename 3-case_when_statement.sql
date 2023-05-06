-- Question 1: Convert the volume column in the trading.prices table with 
-- an adjusted integer value to take into account the unit values
--
-- Return only the market_date, price, volume and 
-- adjusted_volume columns for the first 10 days of August 2021 for Ethereum only
--
SELECT * FROM prices;
--
--
-- return the requested columns for the required days
SELECT 
	market_date, 
	price,
	volume
FROM prices
WHERE ticker = 'ETH'
AND market_date BETWEEN '2021-08-01' AND '2021-08-10'
ORDER BY market_date;
--
-- verify the number of last characters in the volume column
SELECT
	RIGHT(volume, 1) AS last_character,
	COUNT(*) AS record_count
FROM prices
GROUP BY last_character
--
-- the output includes a '-' (dash line)
-- verifying the row of data containing the dash line
-- the date can be verified to see what happened on that particular day
-- i.e. whether it was a holiday, etc.
SELECT * FROM prices
WHERE RIGHT(volume, 1) = '-';
--
--
-- select the last character of the volume column
SELECT
	market_date, 
	price,
	volume,
	RIGHT(volume, 1) AS last_character
FROM prices
WHERE ticker = 'ETH'
AND market_date BETWEEN '2021-08-01' AND '2021-08-10'
--
-- check the length of the values in the volume column
SELECT
	market_date, 
	price,
	volume,
	RIGHT(volume, 1) AS last_character,
	LENGTH(volume) AS length_volume
FROM prices
WHERE ticker = 'ETH'
AND market_date BETWEEN '2021-08-01' AND '2021-08-10'
--
-- remove the last character from the values in the volume column
-- to retrieve the volume number only
SELECT
	market_date, 
	price,
	volume,
	RIGHT(volume, 1) AS last_character,
	LEFT(volume, LENGTH(volume) - 1) AS volume_number
FROM prices
WHERE ticker = 'ETH'
AND market_date BETWEEN '2021-08-01' AND '2021-08-10'
-- 
-- and add the CASE WHEN statement to edit the last character in the volume column
SELECT 
	market_date, 
	price,
	volume,
	CASE
		WHEN RIGHT(volume, 1) = 'M'
		THEN LEFT(volume, LENGTH(volume) - 1)::NUMERIC * 1000000
		WHEN RIGHT(volume, 1) = 'K'
		THEN LEFT(volume, LENGTH(volume) - 1)::NUMERIC * 1000
		ELSE 0
		END AS adjusted_volume
FROM prices
WHERE ticker = 'ETH'
AND market_date BETWEEN '2021-08-01' AND '2021-08-10'
ORDER BY market_date;
-- 
--
-- cast the CASE-WHEN statement as an interger as per the question
SELECT 
	market_date, 
	price,
	volume,
	CAST(
	CASE
		WHEN RIGHT(volume, 1) = 'M'
		THEN LEFT(volume, LENGTH(volume) - 1)::NUMERIC * 1000000
		WHEN RIGHT(volume, 1) = 'K'
		THEN LEFT(volume, LENGTH(volume) - 1)::NUMERIC * 1000
		ELSE 0
		END 
		AS INTEGER) AS adjusted_volume
FROM prices
WHERE ticker = 'ETH'
AND market_date BETWEEN '2021-08-01' AND '2021-08-10'
ORDER BY market_date;
--
--
-- Question 2: How many "breakout" days were there in 2020 where 
-- the price column is greater than the open column for each ticker? 
-- In the same query also calculate the number of "non breakout" days where 
-- the price column was lower than or equal to the open column.
--
SELECT *
FROM prices;
--
-- selected columns for the year 2020
SELECT 
	ticker, 
	market_date, 
	price, 
	open
FROM prices
WHERE market_date BETWEEN '2020-01-01' AND '2020-12-31'
ORDER BY market_date;
--
SELECT 
	ticker, 
	market_date, 
	price, 
	open
FROM prices
WHERE market_date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY ticker, market_date, price, open
ORDER BY market_date;
--
-- sum breakout_days using the CASE WHEN clause 
SELECT 
	ticker,
	SUM(
		CASE 
		WHEN price > open
		THEN 1
		ELSE 0
		END
		) AS breakout_days
FROM prices
WHERE market_date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY ticker
--
-- sum breakout_days & non-breakout_days using the CASE WHEN clause
-- this code produces similar results to that of a COUNTIF function in MS Excel
SELECT 
	ticker,
	SUM(
		CASE 
		WHEN price > open
		THEN 1
		ELSE 0
		END
		) AS breakout_days,
	SUM(
		CASE 
		WHEN price <= open
		THEN 1
		ELSE 0
		END
		) AS non_breakout_days
FROM prices
WHERE market_date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY ticker
--
--
-- Question 3: What was the final quantity of Bitcoin and Ethereum held by 
-- all Data With Danny mentors based off the transactions table?
-- 
-- review the transactions table
SELECT *
FROM transactions;
--
-- count (txn_type) transaction_types for both 'BUY' & 'SELL'
SELECT 
	txn_type,
	COUNT(*) as txn_count
FROM transactions
GROUP BY txn_type;
--
-- verify if 'SELL' under quantity is a positive or negative value
-- this will determine what computation is needed for the sold currencies
SELECT *
FROM transactions
WHERE txn_type = 'SELL'
LIMIT 10;
--
-- since 'SELL' values are positive, 
-- those values are multiplied by -1 to substract the sold currencies
SELECT 
	ticker,
	CASE
		WHEN txn_type = 'BUY' THEN quantity
		WHEN txn_type = 'SELL' THEN -1 * quantity
		END AS actual_quantity
FROM transactions;
--
-- now that we have positive values for bought currencies 'BUY',
-- and negative values for sold currencies 'SELL',
-- the two values are added using a SUM clause around the CASE WHEN statement
-- to obtain the final holding for each currency
-- this is the SQL equivalent of the MS EXCEL SUMIF function
SELECT 
	ticker,
	SUM(
		CASE
			WHEN txn_type = 'BUY' THEN quantity
			WHEN txn_type = 'SELL' THEN -1 * quantity
		END
	) AS final_holding
FROM transactions
GROUP BY ticker

-- NOTE: in this example we don't need an ELSE statement following the CASE WHEN clause
-- as we don't need to call for a third option since what we needed to compute is achieved
-- with the two transactions i.e. 'BUY' & 'SELL'
-- in this instance, the ELSE statement becomes optional 
-- however, the END statement is needed




