/* 
=====================================================
🎬 NETFLIX DATA ANALYSIS PROJECT
Comprehensive SQL Analysis of Streaming Data
=====================================================

Author: [Dinesh Barri]
Email: dineshbarri1997@gmail.com
Dataset: Netflix Titles (Kaggle)
Database: MySQL
-----------------------------------------------------
*/

-- =====================================================
-- 1️⃣  CREATE DATABASE AND TABLE STRUCTURE
-- =====================================================

CREATE DATABASE IF NOT EXISTS NetFlix_DB;
USE NetFlix_DB;

DROP TABLE IF EXISTS NetFlix;

CREATE TABLE NetFlix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    description TEXT
);

-- =====================================================
-- 2️⃣  LOAD DATA INTO TABLE
-- =====================================================

/*
Before executing, ensure:
1. CSV file path is correct.
2. LOCAL INFILE is enabled in MySQL configuration.
*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE NetFlix
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =====================================================
-- 3️⃣  BASIC CHECKS
-- =====================================================

SELECT COUNT(*) AS total_records FROM NetFlix;
SELECT * FROM NetFlix LIMIT 10;
DESCRIBE NetFlix;

-- =====================================================
-- 4️⃣  BUSINESS ANALYSIS QUERIES
-- =====================================================

-- 4.1: Count Movies vs TV Shows
SELECT type, COUNT(*) AS total_content
FROM NetFlix
GROUP BY type;

-- 4.2: Most Common Rating by Content Type
WITH Rating_CTE AS (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS rating_count,
        ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rn
    FROM NetFlix
    GROUP BY type, rating
)
SELECT type, rating, rating_count
FROM Rating_CTE
WHERE rn = 1;

-- 4.3: Top 10 Content-Producing Countries
SELECT country, COUNT(*) AS total_releases
FROM NetFlix
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_releases DESC
LIMIT 10;

-- 4.4: Movies Released in 2020
SELECT *
FROM NetFlix
WHERE release_year = 2020 AND type = 'Movie';

-- 4.5: Longest Movie Duration
SELECT title, director, duration
FROM NetFlix
WHERE type = 'Movie'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) = (
    SELECT MAX(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED))
    FROM NetFlix
    WHERE type = 'Movie'
);

-- 4.6: Recently Added Content (Last 5 Years)
SELECT 
    title, 
    type, 
    country, 
    STR_TO_DATE(date_added, '%M %d, %Y') AS date_added
FROM NetFlix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
ORDER BY date_added DESC;

-- 4.7: All Content by a Specific Director
SELECT *
FROM NetFlix
WHERE director LIKE '%Rajiv Chilaka%';

-- 4.8: TV Shows with More Than 5 Seasons
SELECT *
FROM NetFlix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 4.9: Indian Content Growth (Top 5 Years)
SELECT 
  YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
  COUNT(*) AS total_content,
  ROUND((COUNT(*) / (SELECT COUNT(*) FROM NetFlix WHERE country LIKE '%India%')) * 100, 2) AS percentage_share
FROM NetFlix
WHERE country LIKE '%India%'
GROUP BY year
ORDER BY total_content DESC
LIMIT 5;

-- 4.10: Documentaries List
SELECT *
FROM NetFlix
WHERE listed_in LIKE '%Documentaries%';

-- 4.11: Missing Director Data
SET SQL_SAFE_UPDATES = 0;
UPDATE NetFlix
SET director = NULL
WHERE TRIM(director) = '';

SELECT COUNT(*) AS missing_directors
FROM NetFlix
WHERE director IS NULL;

-- 4.12: Movies featuring 'Salman Khan' in the Last 10 Years
SELECT *
FROM NetFlix
WHERE cast LIKE '%Salman Khan%'
  AND STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR);

-- 4.13: Keyword-Based Categorization (Violence, Romance, etc.)
SELECT 
  CASE 
    WHEN description LIKE '%violence%' OR description LIKE '%kill%' THEN 'Dark/Thriller'
    WHEN description LIKE '%love%' OR description LIKE '%romance%' THEN 'Romantic'
    ELSE 'Other'
  END AS category,
  COUNT(*) AS total
FROM NetFlix
GROUP BY category
ORDER BY total DESC;

-- =====================================================
-- 5️⃣  DATA INSIGHT QUERIES
-- =====================================================

-- 5.1: Top Genres
SELECT listed_in, COUNT(*) AS total
FROM NetFlix
GROUP BY listed_in
ORDER BY total DESC
LIMIT 10;

-- 5.2: Most Frequent Directors
SELECT director, COUNT(*) AS total_titles
FROM NetFlix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;

-- 5.3: Average Yearly Content Release
SELECT release_year, COUNT(*) AS yearly_count
FROM NetFlix
GROUP BY release_year
ORDER BY release_year DESC;

-- =====================================================
-- ✅ END OF ANALYSIS
-- =====================================================
