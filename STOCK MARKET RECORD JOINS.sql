CREATE TABLE stock_market (
    stock_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100),
    symbol VARCHAR(10),
    market_cap DECIMAL(18,2),
    price DECIMAL(18,2),
    opening_price DECIMAL(18,2),
    closing_price DECIMAL(18,2),
    highest_price DECIMAL(18,2),
    lowest_price DECIMAL(18,2),
    volume_traded DECIMAL(18,2),
    percent_change_1d DECIMAL(5,2),
    percent_change_7d DECIMAL(5,2),
    percent_change_30d DECIMAL(5,2),
    dividend_yield DECIMAL(5,2),
    earnings_per_share DECIMAL(10,2),
    sector VARCHAR(50),
    industry VARCHAR(50),
    exchange VARCHAR(50),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) -- Active, Delisted, Suspended
);

SELECT * FROM stock_market;

-- 1. Company Details (Unique Company Data)
CREATE TABLE Company_Details AS 
SELECT DISTINCT company_name, symbol, sector, industry FROM stock_market;

SELECT * FROM company_details;

-- 2. Stock Prices (Daily Trading Prices)
CREATE TABLE Stock_Prices AS 
SELECT DISTINCT symbol, price, opening_price, closing_price, highest_price, lowest_price, last_updated FROM stock_market;

SELECT * FROM stock_prices;

-- 3. Market Performance (Tracking Volume & Percentage Changes)
CREATE TABLE Market_Performance AS 
SELECT DISTINCT symbol, volume_traded, percent_change_1d, percent_change_7d, percent_change_30d FROM stock_market;

SELECT * FROM market_performance;

-- 4. Financials (Key Financial Metrics)
CREATE TABLE Financials AS 
SELECT DISTINCT symbol, dividend_yield, earnings_per_share FROM stock_market;

SELECT * FROM financials;

-- 5. Stock Exchange (Exchange & Status)
CREATE TABLE Stock_Exchange AS 
SELECT DISTINCT symbol, exchange, status FROM stock_market;

SELECT * FROM stock_exchange;


-- 10 Query  which should cover aggregation, having , group by , order by and joins

-- 1. Aggregate Trading Volume per Sector
SELECT cd.sector, SUM(mp.volume_traded) AS total_volume
FROM Market_Performance mp
JOIN Company_Details cd ON mp.symbol = cd.symbol
GROUP BY cd.sector
ORDER BY total_volume DESC;


-- 2.  Average Stock Price per Industry
SELECT cd.industry, AVG(sp.price) AS avg_price
FROM Stock_Prices sp
JOIN Company_Details cd ON sp.symbol = cd.symbol
GROUP BY cd.industry
ORDER BY avg_price DESC;


-- 3. Companies with High Dividend Yield 
SELECT cd.company_name, f.dividend_yield
FROM Financials f
JOIN Company_Details cd ON f.symbol = cd.symbol
GROUP BY cd.company_name, f.dividend_yield
HAVING f.dividend_yield > 3.0
ORDER BY f.dividend_yield DESC;


-- 4. Most Volatile Stocks 
SELECT mp.symbol, cd.company_name, MAX(mp.percent_change_30d) AS max_change
FROM Market_Performance mp
JOIN Company_Details cd ON mp.symbol = cd.symbol
GROUP BY mp.symbol, cd.company_name
ORDER BY max_change DESC;


-- 5. Stocks with Highest Market Cap per Industry
SELECT cd.industry, cd.company_name, sm.market_cap
FROM Company_Details cd
JOIN stock_market sm ON cd.symbol = sm.symbol
GROUP BY cd.industry, cd.company_name, sm.market_cap
ORDER BY sm.market_cap DESC;


-- 6. Stocks Listed on Multiple Exchanges
SELECT cd.company_name, se.exchange, se.status
FROM Company_Details cd
LEFT JOIN Stock_Exchange se ON cd.symbol = se.symbol
ORDER BY cd.company_name;


-- 7. Stock Performance Compared to Sector Average 
SELECT cd.company_name, cd.sector, sp.price
FROM Stock_Prices sp
JOIN Company_Details cd ON sp.symbol = cd.symbol
WHERE sp.price > (SELECT AVG(price) FROM Stock_Prices WHERE symbol IN 
    (SELECT symbol FROM Company_Details WHERE sector = cd.sector))
ORDER BY cd.sector, sp.price DESC;


-- 8. Top 10 Most Profitable Companies 
SELECT cd.company_name, f.earnings_per_share
FROM Financials f
JOIN Company_Details cd ON f.symbol = cd.symbol
ORDER BY f.earnings_per_share DESC
LIMIT 10;


-- 9. Percentage Change in Stock Prices Across Sectors 
SELECT cd.sector, AVG(mp.percent_change_1d) AS avg_daily_change
FROM Market_Performance mp
JOIN Company_Details cd ON mp.symbol = cd.symbol
GROUP BY cd.sector
ORDER BY avg_daily_change DESC;


-- 10. Companies That Are Delisted 
SELECT se.symbol, cd.company_name, se.status
FROM Stock_Exchange se
RIGHT JOIN Company_Details cd ON se.symbol = cd.symbol
WHERE se.status = 'Active';


