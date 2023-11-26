-- SELECT name FROM sqlite_master WHERE type='table';

-- SELECT *
-- FROM AppleStore;


-- -- Since our description files are four Tables, we will be combining them into a single table

-- CREATE TABLE appleStore_description_combined as 
-- SELECT *
-- from appleStore_description1

-- UNION ALL
-- SELECT *
-- from appleStore_description2


-- UNION ALL
-- SELECT *
-- from appleStore_description3

-- UNION ALL
-- SELECT *
-- from appleStore_description4;

-- SELECT name FROM sqlite_master WHERE type='table';

-- SELECT *
-- FROM appleStore_description_combined
-- LIMIT 10;

/* Introduction:
In this app project analysis, our focus is to derive actionable insights 
from an extensive dataset sourced from the App Store. By applying data-driven 
methodologies, we aim to empower app developers with the knowledge needed to 
make informed decisions for the strategic development, marketing, and optimization 
of their applications. The project delves into key metrics, user behaviors, 
and market trends to provide a comprehensive understanding of the app */

-- Data Analysis

-- Let's make a count of our total rows in both columns

SELECT COUNT(*) AS Count
FROM appleStore_description_combined;
-- So we could see that the newly created Table appleStore_description_combined has 7197 data input

SELECT COUNT(*) as Count
FROM AppleStore;

-- Exploratory Data Analysis

-- 1.0 A closer look at our columns

PRAGMA table_info(AppleStore);
PRAGMA table_info(appleStore_description_combined);

-- 2.0: Lets confirm we have equal number of unique apps in both table 

SELECT Count(DISTINCT id) as Unique_Count
from AppleStore;

SELECT Count(DISTINCT id) as Unique_Count
from appleStore_description_combined;

-- 3.0: Check for any missing values in both tables
-- SELECT Count(*) AS missingCount
-- from AppleStore
-- where prime_genre IS NULL OR user_rating IS NULL OR track_name IS NULL;

-- SELECT Count(*) AS missingCount
-- from appleStore_description_combined
-- where app_desc IS NULL OR track_name IS NULL;

-- Renaming "track_name" column as App-name and prime_genre as category

-- ALTER TABLE AppleStore
-- RENAME COLUMN track_name TO App_name;

-- ALTER TABLE AppleStore
-- RENAME COLUMN prime_genre TO App_category;

SELECT *
FROM AppleStore
LIMIT 10;


-- Questions

-- 1.0a: Which App Categories Are Most Popular?

SELECT 
    App_category,
    COUNT(*) as NumberOfApps
FROM AppleStore 
GROUP BY App_category
ORDER BY NumberOfApps DESC
LIMIT 10;
/*It was shown from the above that majority of the apps realeased on the apple store were either Games or Entertainment or Education. With most actually being Games*/

-- 1.0b: Which App Categories Are the least Popular?
SELECT 
    App_category,
    COUNT(*) as NumberOfApps
FROM AppleStore 
GROUP BY App_category
ORDER BY NumberOfApps ASC
LIMIT 10;

-- We could see apps like Catalog, medical, Navigation and business apps are the least realeased category on the apple store

-- 2.0: Gathering an overview of the app ratings

select MIN(user_rating) AS min_ratings,
       max(user_rating) as max_ratings,
       AVG(user_rating) as Avg_ratings
from AppleStore;

-- Lets check the app with the minimum ratings
select *
from AppleStore
where user_rating = (select MIN(user_rating)
                    from AppleStore
                    );

SELECT COUNT(*) AS CountOfAppWithNoratings
from (select *
        from AppleStore
        where user_rating = (select MIN(user_rating)
                            from AppleStore
                    )
     ); 

select *
from AppleStore
where user_rating = (select MAX(user_rating)
                    from AppleStore);

SELECT COUNT(*) AS CountOfAppWithMaxratings
from (select *
        from AppleStore
        where user_rating = (select MAX(user_rating)
                            from AppleStore
                    )
     );

-- So basically there 929 apps with zero ratings

-- Lets get an overview of the apps above and below average user ratings

SELECT *
from AppleStore
where user_rating > (SELECT AVG(user_rating)
                    FROM AppleStore
                    );

select count(*)
from (SELECT *
from AppleStore
where user_rating > (SELECT AVG(user_rating)
                    FROM AppleStore
                    ));

-- Question 3: What Is the Average User Rating for Apps in Different Categories?
-- Lets Check average ratings by each app categories
SELECT 
    App_category,
    COUNT(*) as NumberOfApps, 
    AVG(user_rating) AS avg_ratings
from AppleStore
GROUP BY App_category
ORDER BY avg_ratings DESC
limit 20;

-- So its became clearer why apps in the Games category are the most released as they have pretty good average ratings. 
-- Also, apps in the Productivity categories have better average rating than all other categories.

-- Lets group our Apps into Paid or Free using the price as a condition and see which has on average highest user_ratings

-- Question 4: Are Paid Apps More rated by users Than Free Apps?
SELECT 
    CASE
        WHEN price > 0 THEN "Paid"
        ELSE "Free"
    END AS App_type,
    COUNT(*) AS count,
    AVG(user_rating) as avg_ratings
from AppleStore
group by App_type
ORDER BY avg_ratings DESC;

-- From my analysis, Paid apps are rated more on average than the free ones
--  This could be due to any of the following reasons
/*
1. Quality Expectations:

    Users may expect higher quality from a paid app compared to a free one. 
    When users invest money in an app, they often anticipate a higher level of 
    functionality, performance, and overall user experience, leading to more 
    positive reviews.

2. Reduced Ad Intrusiveness:

    Free apps often rely on advertisements for revenue, which can impact user 
    experience. In contrast, paid apps are not dependent on ad revenue and can 
    provide a more seamless and ad-free experience, contributing to higher user 
    satisfaction.

3.0 Perceived Value:

    Users may associate a monetary investment with higher perceived value. 
    The act of paying for an app can create a psychological effect where users 
    feel they have made a deliberate choice, influencing their perception of 
    the app's value and quality.
*/

-- Question 5: Do Apps that support different languages have any relationship with user ratings

SELECT 
    CASE
        WHEN lang_num < 10 THEN "<10 Languages"
        WHEN lang_num BETWEEN 10 AND 30 THEN "10-30 Languages"
        ELSE ">30 Languages"
    END AS NumOfLanguage,
    COUNT(*) AS count,
    AVG(user_rating) as avg_ratings
FROM AppleStore
GROUP BY NumOfLanguage
ORDER BY avg_ratings DESC;

/*
Insights from the Analysis:
Our investigation has revealed a noteworthy trend – apps with a language support 
range of 10 to 30 exhibit the highest average ratings. This finding suggests that 
there might not be a strong necessity to incorporate an extensive array of language 
support into applications. Rather than overwhelming the app with an abundance of 
languages, focusing on a targeted and effective language support strategy within 
this optimal range may enhance user satisfaction and contribute to higher average ratings.
*/

-- Question 6: Check if there is any correlation between app's description length and user ratings

SELECT 
    CASE
        when LENGTH(b.app_desc) < 500 THEN "short description"
        WHEN LENGTH(b.app_desc) BETWEEN 500 AND 1000 THEN "Medium description"
        ELSE "Long description"
    END AS desc_length_bucket,
    COUNT(*) AS count,
    AVG(user_rating) AS avg_ratings
FROM AppleStore as a
JOIN appleStore_description_combined as b
ON 
   a.id = b.id
GROUP BY desc_length_bucket 
ORDER BY avg_ratings DESC;


/*
Observation:
A clear trend emerges from the analysis: apps with longer descriptions tend to boast 
higher average ratings. This suggests that comprehensive and detailed descriptions 
might contribute positively to user perception and satisfaction, potentially 
influencing users to assign higher ratings to these applications.
*/


-- Question 7: Check the top most rated apps from eacg App categories
SELECT 
    App_category,
    App_name,
    user_rating
FROM 
    (
        SELECT App_category,
               App_name,
               user_rating,
               RANK() OVER(PARTITION BY App_category ORDER BY user_rating DESC, rating_count_tot DESC) AS rank_
        FROM AppleStore
    ) as a
WHERE a.rank_ = 1;

/*
Insight for the Client:
By examining the most rated app in each category, we can derive valuable 
insights into the key factors driving user engagement and satisfaction 
across diverse app genres. Understanding the commonalities and standout 
features of these top-rated apps can inform strategic decision-making. 
Whether it's a user-friendly interface, innovative features, or 
effective monetization strategies, identifying and implementing these 
successful elements in your app development and marketing approach could 
potentially enhance overall user satisfaction and drive increased 
engagement within your specific category.
*/

-- Quwattion 8: What is the correlation between app ratings and the pricing strategy (free, paid) within each category?
SELECT
    CASE 
        WHEN price > 0 THEN "Paid"
        ELSE "Free"
    end as PriceStatus,
    App_category,
    AVG(user_rating) AS average_rating,
    COUNT(*) AS app_count
FROM
    AppleStore
GROUP BY
    App_category, PriceStatus
ORDER BY
    App_category, PriceStatus;

  
-- Question 9 : Does Payment have any impact of relationship with the size of the app

SELECT  
    CASE 
        WHEN price > 0 THEN "Paid"
        ELSE "Free"
    END AS PaymentStatus,
    AVG(size_bytes) AS AverageSize
FROM
    AppleStore
GROUP BY
    PaymentStatus
ORDER BY AverageSize DESC;




































