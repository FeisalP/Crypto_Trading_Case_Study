-- Question 1: What is the region value for the 8th row?
SELECT * 
FROM members
LIMIT 1 OFFSET 7;
--
--
-- Question 2: What is the member_id value for the 14th row?
SELECT member_id FROM members
LIMIT 1 OFFSET 13;
--
--
-- Question 3: What is the first_name value in the 1st row when you sort by region in alphabetical order?
SELECT first_name
FROM members
ORDER BY region
LIMIT 1;
--
--
-- Question 4: What is the region value in the 10th row when you sort by member_id in alphabetical order?
SELECT region
FROM members
ORDER BY member_id
LIMIT 1 OFFSET 9;

