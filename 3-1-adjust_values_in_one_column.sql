-- Convert the volume column in the trading.prices table with 
-- an adjusted integer value to take into account the unit values
--
-- Return only the market_date, price, volume and 
-- adjusted_volume columns for the first 10 days of August 2021 for Ethereum only
--
SELECT * FROM prices;
--
--
-- returning the requested columns for the required days
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
