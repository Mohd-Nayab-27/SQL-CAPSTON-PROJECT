use Crypto;
Select * from pricedata;

-- 1 Number of sales occurred during this time period
select count(*) from pricedata ;

-- 2 Return the top 5 most expensive transactions (by USD price)
select name,eth_price, usd_price,event_date from pricedata
order by usd_price desc
limit 5 ;

--  3 moving average of USD price that averages the last 50 transactions.
SELECT
    event_date, usd_price,
    AVG(usd_price) OVER (ORDER BY transaction_hash ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_avg
FROM
    pricedata
ORDER BY
    transaction_hash;
    
 -- 4 Returning all the NFT names and their average sale price in USD.    
    SELECT name ,AVG(usd_price) AS average_price
     from pricedata
     group by name 
     order by average_price DESC;
     
   -- 5 Return each day of the week and the number of sales that occurred on that day of the week  
   SELECT
    DAYNAME(eth_price) AS day_of_week,
    COUNT(*) AS num_sales,
    AVG(eth_price) AS avg_sale_price_eth
FROM pricedata
GROUP BY DAYNAME(eth_price)
ORDER BY num_sales ASC;  

-- 6 Construct a column that describes each sale and is called summary.
SELECT
    name,
    seller_address,
    eth_price,
    usd_price,
    ROUND(usd_price, 3) AS Sale_price,
    CONCAT(name, ' was sold for $',usd_price, ' to ', buyer_address, ' from ', seller_address, ' on ', usd_price) AS summary
FROM pricedata;


-- 7 Creating a view called “1919_purchases” and containing all sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
CREATE VIEW 1919_purchases AS
SELECT name, seller_address, buyer_address, event_date, usd_price
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';
SELECT * FROM 1919_purchases;    


-- 8 Create a histogram of ETH price ranges. Round to the nearest hundred value. 
SELECT
  ROUND(eth_price, -2) AS price_range,
  COUNT(*) AS count_of_prices,
  RPAD('', COUNT(*), '*') AS bar 
FROM
  pricedata
GROUP BY
 price_range
ORDER BY
  price_range;
  
  
 -- Highest price and Lowest price for each NFT
-- 9  Add the main SELECT statement to retrieve the results from the CTEs

 SELECT
    name,
    MIN(usd_price) AS price,
    'lowest' AS status
FROM
    pricedata
GROUP BY
    name
UNION
SELECT
    name,
    MAX(usd_price) AS price,
    'highest' AS status
FROM
    pricedata
GROUP BY
    name
    ORDER BY
    price desc;
  
 -- 10 What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. 
WITH RankedSales AS (
    SELECT
        name,
        usd_price,
        event_date,
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(YEAR FROM event_date), EXTRACT(MONTH FROM event_date)
            ORDER BY usd_price DESC
        ) AS sale_rank
    FROM
        pricedata
)
SELECT
    name,
    usd_price,
    event_date,
    EXTRACT(YEAR FROM event_date) AS sale_year,
    EXTRACT(MONTH FROM event_date) AS sale_month
FROM
    RankedSales
WHERE
    sale_rank = 1
ORDER BY
    sale_year ASC,
    sale_month ASC,
    event_date ASC;
  
  -- 11 Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
  WITH MonthlySales AS (
    SELECT
        name,
        usd_price,
        event_date,
        EXTRACT(YEAR FROM event_date) AS sale_year,
        EXTRACT(MONTH FROM event_date) AS sale_month
    FROM
        pricedata
)
SELECT
    sale_year,
    sale_month,
    ROUND(SUM(usd_price), -2) AS total_volume
FROM
    MonthlySales
GROUP BY
    sale_year,
    sale_month
ORDER BY
    sale_year ASC,
    sale_month ASC;
  
-- 12 Count how many transactions the wallet Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period."had over this time period.
SELECT
    COUNT(*) AS transaction_count
FROM
    pricedata
WHERE
   transaction_hash = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

-- 13 (a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. 
-- Save it as a temporary table.
-- A part
CREATE TEMPORARY TABLE temp_avg_prices AS
SELECT
  event_date,
  usd_price,
  AVG(usd_price) OVER (PARTITION BY event_date) AS daily_avg_price
FROM pricedata;
-- 13 (b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value 
-- which is just the daily average of the filtered data
 -- B PART
SELECT
  event_date,
  AVG(usd_price) AS estimated_value
FROM temp_avg_prices
WHERE usd_price >= 0.1 * daily_avg_price
GROUP BY event_date
ORDER BY event_date; 

-- 14  Give a complete list ordered by wallet profitability (whether people have made or lost money)
-- given the complete profitibility details 

SELECT
    COALESCE(b.buyer_address, s.seller_address) AS wallet,
    ROUND(COALESCE(s.total_received, 0) - COALESCE(b.total_spent, 0), 2) AS profit,
    CASE
        WHEN COALESCE(s.total_received, 0) - COALESCE(b.total_spent, 0) >= 0 THEN 'Profit Maker'
        ELSE 'Loss Maker'
    END AS wallet_profitability,
    ROUND(ABS(COALESCE(s.total_received, 0) - COALESCE(b.total_spent, 0)), 2) AS absolute_profit_loss
FROM (
    SELECT
        buyer_address,
        SUM(usd_price) AS total_spent
    FROM
        pricedata
    GROUP BY
        buyer_address
) b
LEFT JOIN (
    SELECT
        seller_address,
        SUM(usd_price) AS total_received
    FROM
        pricedata
    GROUP BY
        seller_address
) s ON b.buyer_address = s.seller_address

UNION ALL

SELECT
    COALESCE(b.buyer_address, s.seller_address) AS wallet,
    ROUND(COALESCE(s.total_received, 0) - COALESCE(b.total_spent, 0), 2) AS profit,
    CASE
        WHEN COALESCE(s.total_received, 0) - COALESCE(b.total_spent, 0) >= 0 THEN 'Profit Maker'
        ELSE 'Loss Maker'
    END AS wallet_profitability,
    ROUND(ABS(COALESCE(s.total_received, 0) - COALESCE(b.total_spent, 0)), 2) AS absolute_profit_loss
FROM (
    SELECT
        buyer_address,
        SUM(usd_price) AS total_spent
    FROM
        pricedata
    GROUP BY
        buyer_address
) b
RIGHT JOIN (
    SELECT
        seller_address,
        SUM(usd_price) AS total_received
    FROM
        pricedata
    GROUP BY
        seller_address
) s ON b.buyer_address = s.seller_address
WHERE b.buyer_address IS NULL;





















