# 🎬 Netflix Analytics 

<div align="center">

![Netflix](https://img.shields.io/badge/Netflix-E50914?style=for-the-badge&logo=netflix&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![Data Analysis](https://img.shields.io/badge/Data_Analysis-4285F4?style=for-the-badge&logo=google-analytics&logoColor=white)

</div>

---

## 📊 Project Overview

This project delivers an in-depth analytical deep-dive into Netflix's movies and TV shows catalog using advanced MySQL querying techniques. By leveraging a rich dataset of over 8,000+ titles, we uncover content distribution patterns, rating trends, geographical insights, and temporal release strategies.

### 🎯 Core Objectives

- 📈 **Content Distribution Analysis** - Examine the balance between movies and TV shows
- ⭐ **Rating Intelligence** - Identify dominant rating categories across content types
- 🌍 **Geographic Insights** - Map content production and availability by country
- 📅 **Temporal Trends** - Track content release patterns and additions over time
- 🔍 **Content Categorization** - Deep-dive analysis using keywords and metadata

---

## 🗂️ Dataset Information

**Source:** [Kaggle - Netflix Movies and TV Shows Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows)

### Dataset Schema

| Column | Type | Description |
|--------|------|-------------|
| `show_id` | VARCHAR(10) | Unique identifier for each title |
| `type` | VARCHAR(20) | Content type (Movie/TV Show) |
| `title` | VARCHAR(255) | Name of the content |
| `director` | VARCHAR(255) | Director(s) of the content |
| `cast` | VARCHAR(1000) | Main cast members |
| `country` | VARCHAR(150) | Country of production |
| `date_added` | VARCHAR(50) | Date added to Netflix |
| `release_year` | INT | Original release year |
| `rating` | VARCHAR(10) | Content rating (PG, TV-MA, etc.) |
| `duration` | VARCHAR(50) | Movie duration or TV show seasons |
| `listed_in` | VARCHAR(255) | Genre categories |
| `description` | VARCHAR(255) | Brief synopsis |

---

## 🚀 Installation

### Prerequisites

- MySQL Server 8.0+
- MySQL Workbench (optional)
- Netflix dataset CSV file

### Setup Steps

**1. Clone the Repository**
```bash
git clone https://github.com/dineshbarri/Netflix_Sql_Analysis.git
cd netflix_sql_analysis
```

**2. Database Initialization**
```sql
CREATE DATABASE Netflix_Analytics;
USE Netflix_Analytics;
```

**3. Create Table Structure**
```sql
CREATE TABLE Netflix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    cast VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    description VARCHAR(255)
);
```

**4. Import Dataset**
```sql
LOAD DATA INFILE 'path/to/netflix_titles.csv'
INTO TABLE Netflix
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS;
```

---

## 🔬 Analysis Queries

### 1️⃣ Content Type Distribution
**Objective:** Quantify the split between Movies and TV Shows

```sql
SELECT 
    type, 
    COUNT(*) AS total_content,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Netflix), 2) AS percentage
FROM Netflix
GROUP BY type;
```

### 2️⃣ Most Common Ratings by Content Type
**Objective:** Identify dominant rating categories

```sql
WITH RatingRank AS (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS count_rating,
        ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank_position
    FROM Netflix
    GROUP BY type, rating
)
SELECT 
    type, 
    rating, 
    count_rating
FROM RatingRank
WHERE rank_position = 1;
```

### 3️⃣ Recent Movie Releases (2020)
**Objective:** Filter movies from a specific year

```sql
SELECT 
    title, 
    director, 
    rating, 
    duration
FROM Netflix
WHERE release_year = 2020 
    AND type = 'Movie'
ORDER BY title;
```

### 4️⃣ Longest Movie Analysis
**Objective:** Discover the most extended film

```sql
SELECT 
    title, 
    director, 
    duration, 
    release_year
FROM Netflix 
WHERE type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM Netflix WHERE type = 'Movie');
```

### 5️⃣ Recently Added Content (5 Years)
**Objective:** Track recent platform additions

```sql
SELECT 
    type,
    title,
    date_added,
    release_year
FROM Netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
ORDER BY STR_TO_DATE(date_added, '%M %d, %Y') DESC;
```

### 6️⃣ Director Spotlight: Rajiv Chilaka
**Objective:** Analyze specific director's portfolio

```sql
SELECT 
    type,
    title,
    country,
    release_year,
    rating
FROM Netflix
WHERE director LIKE '%Rajiv Chilaka%'
ORDER BY release_year DESC;
```

### 7️⃣ Long-Running TV Shows
**Objective:** Identify shows with 5+ seasons

```sql
SELECT 
    title,
    duration,
    release_year,
    rating
FROM Netflix
WHERE type = 'TV Show'
    AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;
```

### 8️⃣ India Content Release Trends
**Objective:** Analyze yearly content growth in India (Top 5 years)

```sql
SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year, 
    COUNT(*) AS total_releases,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM Netflix WHERE country = 'India')) * 100, 2) AS percentage_of_total
FROM Netflix
WHERE country = 'India'
GROUP BY year
ORDER BY percentage_of_total DESC
LIMIT 5;
```

### 9️⃣ Documentary Collection
**Objective:** Extract all documentary content

```sql
SELECT 
    title,
    director,
    release_year,
    duration
FROM Netflix
WHERE listed_in LIKE '%Documentaries%'
ORDER BY release_year DESC;
```

### 🔟 Content Without Directors
**Objective:** Identify titles missing director information

```sql
-- Clean empty director fields
UPDATE Netflix
SET director = NULL
WHERE TRIM(director) = '';

-- Query undirected content
SELECT 
    type,
    title,
    country,
    release_year
FROM Netflix
WHERE director IS NULL;
```

### 1️⃣1️⃣ Salman Khan's Recent Work
**Objective:** Track actor's appearances (last 10 years)

```sql
SELECT 
    title,
    type,
    release_year,
    date_added
FROM Netflix 
WHERE cast LIKE '%Salman Khan%'
    AND STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR)
ORDER BY release_year DESC;
```

### 1️⃣2️⃣ Content Safety Classification
**Objective:** Categorize content by violence/mature themes

```sql
SELECT 
    category,
    COUNT(*) AS content_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Netflix), 2) AS percentage
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Mature Content'
            ELSE 'Family Friendly'
        END AS category
    FROM Netflix
) AS categorized_content
GROUP BY category;
```

---

## 💡 Key Insights

### 📌 Major Findings

- **Content Split:** Movies dominate Netflix's library, comprising approximately 70% of total content
- **Rating Trends:** TV-MA and TV-14 are the most common ratings for TV shows, while PG-13 and R lead for movies
- **Geographic Distribution:** United States and India are the top content-producing countries
- **Growth Pattern:** Significant content addition spikes observed in 2019-2020
- **Genre Popularity:** International TV Shows, Dramas, and Comedies are the most prevalent categories

### 🎭 Content Characteristics

- Documentary content shows steady growth year-over-year
- TV shows with multiple seasons (5+) represent premium, long-form content
- Director-less content exists primarily in documentary and reality TV categories
- Family-friendly content slightly outweighs mature-rated titles

---

## 🛠️ Technologies Used

- **Database:** MySQL 8.0
- **Analysis:** SQL (Advanced Queries, CTEs, Window Functions)
- **Data Source:** Kaggle
- **Documentation:** Markdown

---

## 📈 Future Enhancements

- [ ] Add data visualization dashboards using Python/Tableau
- [ ] Implement predictive analytics for content trends
- [ ] Integrate sentiment analysis on descriptions
- [ ] Create automated reporting pipeline
- [ ] Expand dataset to include viewer ratings and metrics

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Dinesh Barri**

-  [![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/dineshbarri)
-  [![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/dinesh-barri-7654b010b)

---




<div align="center">

### ⭐ Star this repository if you find it helpful!

**Made with ❤️ and SQL**

</div>
