-- Question 1: What are the market_date, price and volume and price_rank values 
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
-- Question 2: Calculate a 7 day rolling average for the price and volume columns 
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
-- Question 3: Calculate the monthly cumulative volume traded for each ticker in 2020
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
-- Question 4: Calculate the daily percentage change in volume for each ticker in the prices table
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







