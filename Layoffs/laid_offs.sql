SELECT * FROM new_db.db;
USE new_db;
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, COUNT(*) AS row_num
FROM db
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

-- REMOVING DUPLICATES

WITH dublicate_cte AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM db
)
DELETE FROM dublicate_cte
WHERE row_num > 1;






CREATE TABLE `db2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;




SELECT * FROM new_db.db2;

INSERT INTO new_db.db2
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM db;


SELECT * FROM new_db.db2
WHERE row_num > 1;

DELETE FROM new_db.db2
WHERE row_num > 1;

SELECT * FROM new_db.db2
WHERE row_num = 1;

-- Standardizing data

SELECT company, TRIM(company)
 FROM db2;

UPDATE db2
SET company = TRIM(company);

SELECT * FROM db2;

SELECT DISTINCT industry from db2
ORDER BY 1;

SELECT industry, TRIM(industry)
 FROM db2;

SELECT * FROM db2
WHERE industry LIKE 'Crypto%';


UPDATE db2
SET industry = 'Crypto'
WHERE industry Like 'Crypto%';


SELECT DISTINCT industry from db2
ORDER BY 1;

SELECT * from db2;


SELECT DISTINCT location
FROM db2
ORDER BY 1;

SELECT DISTINCT country
FROM db2
ORDER BY 1;

SELECT * FROM db2
WHERE country LIKE 'United States.';

UPDATE db2
SET country = 'United States'
WHERE country Like 'United States%';

SELECT * FROM db2
WHERE country LIKE 'United States.';

SELECT DISTINCT country
FROM db2
ORDER BY 1;

SELECT `date` 
FROM db2;

SELECT `date` ,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM db2;

UPDATE db2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT * 
FROM db2;

ALTER TABLE db2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM db2;

-- Handle null and blank values

SELECT * FROM db2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE db2
SET industry = NULL
WHERE industry = '';

SELECT * FROM db2
WHERE industry IS NULL
OR industry = '';

SELECT * FROM db2
WHERE company = 'Airbnb'; -- we can find the industry type like this

SELECT *
FROM db2 t1
JOIN db2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE db2 t1
JOIN db2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * FROM db2
WHERE company LIKE 'Bally%';

SELECT * FROM db2;

SELECT * FROM db2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM db2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT * FROM db2;

ALTER TABLE db2
DROP COLUMN row_num;

SELECT * FROM db2;
 
 -- ****************************************************** EXPLORATORY DATA ANALYSIS ********************************************************
 
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM db2;

SELECT * 
FROM db2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM db2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM db2;

SELECT industry, SUM(total_laid_off)
FROM db2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM db2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM db2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM db2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM db2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



SELECT company, SUM(total_laid_off)
FROM db2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM db2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM db2
GROUP BY company, YEAR(`date`);


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM db2
GROUP BY company, YEAR(`date`)
), Company_YEAR_RANK AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


SELECT * FROM db2;