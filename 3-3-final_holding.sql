-- What was the final quantity of Bitcoin and Ethereum held by 
-- all Data With Danny mentors based off the trading.transactions table?
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

