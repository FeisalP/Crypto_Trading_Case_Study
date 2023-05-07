# Cryptocurrency_Trading_Case_Study
A data analysis case study using PostgreSQL
<br />
<br />

In this project I have initially used pgAdmin IDE to write the SQL queries.
<br />
<br />

The schema for this project includes 3 tables from a dataset provided by Danny Ma as part of his SQL Masterclass:
1. members.csv
2. prices.csv
3. transactions.csv
<br />
<br />

Here is a breakdown of all the questions followed by their respective SQL queries:

```sql
-- Question: What is the region value for the 8th row?
SELECT * 
FROM members
LIMIT 1 OFFSET 7;
--
--
--
-- Question: What is the member_id value for the 14th row?
SELECT member_id FROM members
LIMIT 1 OFFSET 13;
--
--
--
-- Question: What is the first_name value in the 1st row when you sort by region in alphabetical order?
SELECT first_name
FROM members
ORDER BY region
LIMIT 1;
--
--
--
-- Question: What is the region value in the 10th row when you sort by member_id in alphabetical order?
SELECT region
FROM members
ORDER BY member_id
LIMIT 1 OFFSET 9;
--
--
--
-- Question: How many records are there per ticker value in the prices table?
SELECT 
	ticker, 
	COUNT(ticker) AS record_count
FROM prices
GROUP BY ticker;
--
--
--
-- Question: What is the maximum, minimum values for the price column 
-- for both Bitcoin and Ethereum in 2020?
SELECT 
	ticker,
	MIN(price) AS min_price,
	MAX(price) AS max_price
FROM prices
WHERE market_date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY ticker;
--
--
--
-- Question: What is the annual minimum, maximum and average price for each ticker?
-- Include a calendar_year column with the year from 2017 through to 2021
-- Calculate a spread column which calculates the difference between the min and max prices
-- Round the average price output to 2 decimal places
-- Sort the output in chronological order with 
-- Bitcoin records before Ethereum within each year
--
-- review the prices table
SELECT * FROM prices;
-- 
SELECT 
	EXTRACT(YEAR FROM market_date) AS calendar_year,
	ticker,
	MIN(price) AS min_price,
	MAX(price) AS max_price,
-- 	Need to cast average & spread to numeric for rounding
	ROUND(AVG(price):: NUMERIC, 2) AS average_price,
	ROUND((MAX(price)-MIN(price))::NUMERIC, 2) AS spread 
FROM prices
WHERE market_date BETWEEN '2017-01-01' AND '2021-12-31'
GROUP BY calendar_year, ticker
--
--
--
-- Question: What is the monthly average of the price column for each ticker from January 2020 and after?
-- order by market_date to find the ending year
-- Create a month_start column with the first day of each month
-- Sort the output by ticker in alphabetical order and months in chronological order
-- Round the average_price column to 2 decimal places
-- ORDER BY calendar_year, ticker
SELECT 
	ticker,
-- 	CAST as DATE to display the date only without the time
-- 	Use DATE_TRUNC to group the record by month
	DATE_TRUNC('MON', market_date)::DATE AS month_start,
	ROUND(AVG(price)::NUMERIC, 2) AS average_price
FROM prices
WHERE market_date >= '2020-01-01'
GROUP BY ticker, month_start 
ORDER BY ticker, month_start;
--
--
--
-- Question: Convert the volume column in the trading.prices table with 
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
--
-- Question: How many "breakout" days were there in 2020 where 
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
--
-- Question: What was the final quantity of Bitcoin and Ethereum held by 
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
--
--
--
-- Question: What are the market_date, price and volume and price_rank values 
-- for the days with the top 5 highest price values for each tickers in the trading.prices table?
--
-- The price_rank column is the ranking for price values for each ticker with rank = 1 for the highest value.
-- Return the output for Bitcoin, followed by Ethereum in price rank order.
--
SELECT * FROM prices;
--
-- generate the price_rank column using the RANK Window Function
-- the output is grouped by ticker using the PARTITION BY clause
SELECT 
	ticker, 
	price,
	RANK() OVER (
		PARTITION BY ticker
		ORDER BY price DESC
	) AS price_rank
FROM prices;
--
-- storing the resulting table as a new reference using the cte query
WITH cte_rank AS (
SELECT 
	ticker,
	market_date,
	price,
	volume,
	RANK() OVER (
		PARTITION BY ticker
		ORDER BY price DESC
	) AS price_rank
FROM prices
)
--
-- invoke the cte table by filtering the 5 highest price values for each ticker by 
-- ordering by  the ticker and price columns
-- to generate the final output
WITH cte_rank AS (
SELECT 
	ticker,
	market_date,
	price,
	volume,
	RANK() OVER (
		PARTITION BY ticker
		ORDER BY price DESC
	) AS price_rank
FROM prices
)
SELECT * FROM cte_rank
WHERE price_rank <= 5
ORDER BY ticker, price_rank;
--
--
--
-- Question: Calculate a 7 day rolling average for the price and volume columns 
-- in the trading.prices table for each ticker.

-- Return only the first 10 days of August 2021
--
SELECT * FROM prices;
--
-- the SQL code is broken down into multiple cte's and
-- in this first cte a CASE WHEN statement is used to adjust the volume string column
-- to a NUMERIC data type so that the AVG function can be applied 
-- to the moving average calculations
WITH cte_adjusted_prices AS (
SELECT
  ticker,
  market_date,
  price,
  CASE
    WHEN RIGHT(volume, 1) = 'K' THEN LEFT(volume, LENGTH(volume)-1)::NUMERIC * 1000
    WHEN RIGHT(volume, 1) = 'M' THEN LEFT(volume, LENGTH(volume)-1)::NUMERIC * 1000000
    WHEN volume = '-' THEN 0
  END AS volume
FROM prices
),
--
-- in this second cte, the AVG function is applied to the price column and 
-- the adjusted volume column
-- the PARTITION BY clause is used to group by the ticker column 
cte_moving_averages AS (
  SELECT
    ticker,
    market_date,
    price,
    AVG(price) OVER (
      PARTITION BY ticker
      ORDER BY market_date
      RANGE BETWEEN '7 DAYS' PRECEDING AND CURRENT ROW
    ) AS moving_avg_price,
    volume,
    AVG(volume) OVER (
      PARTITION BY ticker
      ORDER BY market_date
      RANGE BETWEEN '7 DAYS' PRECEDING AND CURRENT ROW
    ) AS moving_avg_volume
  FROM cte_adjusted_prices
)
-- the final output is achieved after the WHERE filter is applied
-- to return only the first 10 days of August 2021
SELECT * FROM cte_moving_averages
WHERE market_date BETWEEN '2021-08-01' AND '2021-08-10'
ORDER BY ticker, market_date;
--
--
--
-- Question: Calculate the monthly cumulative volume traded for each ticker in 2020
-- Sort the output by ticker in chronological order with the month_start as the first day of each month
WITH cte_monthly_volume AS (
  SELECT
    ticker,
    DATE_TRUNC('MON', market_date)::DATE AS month_start,
    SUM(
      CASE
      WHEN RIGHT(volume, 1) = 'K' THEN LEFT(volume, LENGTH(volume)-1)::NUMERIC * 1000
      WHEN RIGHT(volume, 1) = 'M' THEN LEFT(volume, LENGTH(volume)-1)::NUMERIC * 1000000
      WHEN volume = '-' THEN 0
    END
  ) AS monthly_volume
  FROM prices
  WHERE market_date BETWEEN '2020-01-01' AND '2020-12-31'
  GROUP BY ticker, month_start
)
-- final output
SELECT
  ticker,
  month_start,
  SUM(monthly_volume) OVER (
    PARTITION BY ticker
    ORDER BY month_start
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_monthly_volume
FROM cte_monthly_volume
ORDER BY ticker, month_start;
--
--
--
-- Question: Calculate the daily percentage change in volume for each ticker in the prices table
-- Percentage change can be calculated as (current - previous) / previous
-- Multiply the percentage by 100 and round the value to 2 decimal places
-- Return data for the first 10 days of August 2021
WITH cte_adjusted_prices AS (
  SELECT
    ticker,
    market_date,
    CASE
      WHEN RIGHT(volume, 1) = 'K' THEN LEFT(volume, LENGTH(volume)-1)::NUMERIC * 1000
      WHEN RIGHT(volume, 1) = 'M' THEN LEFT(volume, LENGTH(volume)-1)::NUMERIC * 1000000
      WHEN volume = '-' THEN 0
    END AS volume
  FROM prices
),
cte_previous_volume AS (
  SELECT
    ticker,
    market_date,
    volume,
    LAG(volume) OVER (
      PARTITION BY ticker
      ORDER BY market_date
    ) AS previous_volume
  FROM cte_adjusted_prices
  -- need to remove the single outlier record!
  WHERE volume != 0
)
-- final output
SELECT
  ticker,
  market_date,
  volume,
  previous_volume,
  ROUND(
    100 * (volume - previous_volume) / previous_volume,
    2
  ) AS daily_change
FROM cte_previous_volume
WHERE market_date BETWEEN '2021-08-01' AND '2021-08-10'
ORDER BY ticker, market_date;
--
--
--

```
