-- Data Cleaning Project where I took a world's layoffs dataset from 2022 and cleaned it.

-- Skills used: Window functions, CTEs, JOINS, Data standardization.

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns 

-- First thing I did was create another table to start cleaning the data from the main one.

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Then I look for duplicates.
SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
row_number() over (
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage 
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- The ones I want to delete are the ones which row number is greater than 1, that means they are duplicates.

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT *,
row_number() over (
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage 
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE  
FROM duplicate_cte
WHERE row_num > 1;

-- I was not able to delete them since a CTE is not a real table, therefore, I have to create another table in order to remove duplicates.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Insert the data from the first table we created to the new one.

INSERT INTO layoffs_staging2
SELECT *,
row_number() over (
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage 
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;



DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Now we finally deleted duplicates.

SELECT *
FROM layoffs_staging2;


-- Standardizing data

-- I had to get rid of white spaces and extra characters in the dataset.

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date column from a "text" column to a "date" column

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Find any null and blank values and get rid of them.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL OR t1.industry 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Lastly we just get rid of the row number column used for finding duplicates and with that the dataset is finally cleaned and ready for analyzing it.

ALTER TABLE layoffs_staging2
DROP Column row_num

SELECT *
FROM layoffs_staging2;
