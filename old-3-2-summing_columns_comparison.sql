-- How many "breakout" days were there in 2020 where 
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

