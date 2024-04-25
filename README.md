Crypto Price Data Analysis with SQL
This repository contains a comprehensive set of SQL queries designed for analyzing cryptocurrency price data related to Non-Fungible Tokens (NFTs). The dataset named pricedata is utilized for this analysis, containing information about NFT transactions such as transaction hashes, event dates, prices in USD and ETH, buyer and seller addresses, and NFT names.

Queries Overview
1. Number of Sales
Query: Count the total number of sales occurred during the given time period.

2. Top 5 Expensive Transactions
Query: Retrieve the top 5 most expensive transactions in USD.

3. Moving Average of USD Price
Query: Calculate the moving average of the USD price using the last 50 transactions. This query uses a window function to compute the average USD price over a rolling window of the last 50 transactions.

4. Average Sale Price per NFT
Query: Get the average sale price in USD for each NFT. This query groups the data by NFT names and calculates the average sale price.

5. Sales Count by Day of the Week
Query: Count the number of sales that occurred on each day of the week. The DAYNAME function is used to extract the day of the week from the event_date column.

6. Sale Summary
Query: Construct a summary column describing each sale, including the NFT name, seller and buyer addresses, ETH and USD prices, and a concatenated summary string.

7. Sales to Specific Buyer
Query: Create a view named 1919_purchases containing all sales where a specific wallet (0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685) was the buyer.

8. ETH Price Histogram
Query: Create a histogram of ETH price ranges rounded to the nearest hundred. This query groups the data by rounded ETH price ranges and counts the number of transactions falling into each range.

9. Highest and Lowest Price per NFT
Query: Retrieve the highest and lowest prices for each NFT. This query uses a UNION to combine two subqueries that calculate the highest and lowest prices separately for each NFT.

10. Most Sold NFT per Month/Year
Query: Identify the NFT that sold the most each month/year combination. This query uses a Common Table Expression (CTE) to rank the sales within each month/year and filters the results to only include the highest-ranked sales.

11. Total Sales Volume
Query: Calculate the total sales volume rounded to the nearest hundred on a monthly basis. This query groups the data by month and year, summing up the USD prices of all transactions.

12. Transaction Count for a Wallet
Query: Count the number of transactions for a specific wallet (0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685).

13. Estimated Value Calculation
Part A: Calculate the daily average USD price using a window function.
Part B: Filter the data based on the price being above 10% of the daily average and return a new estimated value.
14. Wallet Profitability
Query: Calculate the profitability for each wallet, whether they made a profit or incurred a loss. This query calculates the total amount spent and received by each wallet and determines the profitability status.

Usage
To execute these SQL queries, follow these steps:

Ensure the pricedata table is available and populated with the necessary data.
Copy and paste the desired query into your SQL database management system (DBMS) interface or script.
Execute the query to retrieve the results.
Note
Some queries utilize advanced SQL features such as Common Table Expressions (CTEs), Window Functions, and Views for efficient and detailed analysis.
Make sure to replace placeholders like wallet addresses or specific values with actual data as needed before executing the queries.
