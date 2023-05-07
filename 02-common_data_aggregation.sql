-- Question 1: How many records are there per ticker value in the prices table?
SELECT 
	ticker, 
	COUNT(ticker) AS record_count
FROM prices
GROUP BY ticker;
--
--
-- Question 2: What is the maximum, minimum values for the price column 
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
-- Question 3: What is the annual minimum, maximum and average price for each ticker?
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
-- Need to cast average & spread to numeric for rounding
	ROUND(AVG(price):: NUMERIC, 2) AS average_price,
	ROUND((MAX(price)-MIN(price))::NUMERIC, 2) AS spread 
FROM prices
WHERE market_date BETWEEN '2017-01-01' AND '2021-12-31'
GROUP BY calendar_year, ticker
--
--
-- Question 4: What is the monthly average of the price column for each ticker from January 2020 and after?
-- order by market_date to find the ending year
-- Create a month_start column with the first day of each month
-- Sort the output by ticker in alphabetical order and months in chronological order
-- Round the average_price column to 2 decimal places
-- ORDER BY calendar_year, ticker
SELECT 
	ticker,
-- CAST as DATE to display the date only without the time
-- Use DATE_TRUNC to group the record by month
	DATE_TRUNC('MON', market_date)::DATE AS month_start,
	ROUND(AVG(price)::NUMERIC, 2) AS average_price
FROM prices
WHERE market_date >= '2020-01-01'
GROUP BY ticker, month_start 
ORDER BY ticker, month_start;


