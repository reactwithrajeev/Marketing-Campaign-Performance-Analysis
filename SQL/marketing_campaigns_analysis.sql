CREATE DATABASE Marketing_Campaign_Analysis;
USE Marketing_Campaign_Analysis;

-- =========================================================================
-- Query 1: Channel wise Performance Summary
/* Business Question: Which channel is the most efficient 
in terms of revenue and ROI? */ 
-- =========================================================================

CREATE VIEW vw_Channel_Summary AS
SELECT
	Channel,
    COUNT(DISTINCT Campaign_ID) as Total_Capmaigns, 
    ROUND(SUM(SPEND),2) as Total_Spend,
	ROUND(SUM(Revenue),2) as Total_Revenue,
    ROUND(SUM(Revenue)- SUM(SPEND),2) as Total_Profit, 
	ROUND(AVG(ROAS),2) as Avg_ROAS, 
    ROUND(AVG(ROI_Pct),2) as Avg_ROI_Pct,
    ROUND(AVG(CTR),2) as Avg_CTR, 
    ROUND(AVG(CVR),2) as Avg_CVR, 
    ROUND(SUM(Revenue)/SUM(Spend),2) as Overall_ROAS
FROM marketing_master 
GROUP BY Channel
ORDER BY Total_Revenue DESC;
    
SELECT * FROM vw_Channel_Summary;



/* Query 1 Insights:
-Email Marketing leads with ₹849M revenue and 1048% ROI
-despite having only 110 campaigns
-Google Ads has the most campaigns (181) but ROAS is only 5.25
-Influencer is the worst performer — 2.75 ROAS, 174% ROI
-SEO is highly efficient — 8.49 ROAS with only 90 campaigns
-Recommendation: Increase Email Marketing and SEO budget
     Review Influencer and YouTube Ads strategy */ 
	
-- =========================================================================
-- Query 2: Month over Month Revenue Growth
-- Business Question: How is revenue trending month over month?
-- Which months showed decline? 
-- =========================================================================
WITH Monthly_Revenue as (SELECT 
	Year, 
    Month, 
    CONCAT(Year, '-',LPAD(Month,2,'0')) as Period, 
    ROUND(SUM(Revenue),2) as Total_revenue, 
    ROUND(SUM(Spend),2) as Total_Spend
FROM marketing_master 
GROUP BY Year,Month 
ORDER BY Year,Month), 
Mom_Growth as (SELECT 
	Period,
    Total_Revenue, 
    Total_Spend, 
    LAG(Total_Revenue) OVER(ORDER BY Period) AS Prev_Month_Revenue,
	ROUND((Total_Revenue - LAG(Total_Revenue) OVER(ORDER BY Period))/LAG(Total_Revenue) OVER(ORDER BY Period) *100,2) as MOM_Revenue_Growth_Pct
FROM 
	Monthly_Revenue)
SELECT 
	Period,
    Total_Revenue, 
    Prev_Month_Revenue, 
    MOM_Revenue_Growth_Pct, 
    CASE 
		WHEN MOM_Revenue_Growth_Pct >0 THEN 'GROWTH'
        WHEN MOM_Revenue_Growth_Pct < 0 THEN 'DECLINE'
        WHEN MOM_Revenue_Growth_Pct = 0 THEN 'FLAT'
        ELSE 'FIRST MONTH'
	END as Trend
FROM Mom_Growth
ORDER BY Period;

/* Query 2 Insights:
-Revenue grew aggressively from Jan 2022 — peak growth of 
-139% in February 2022
-Growth started slowing after September 2022 — single digit %
-Decline started from January 2023 — campaigns ending
-Steepest decline in Nov 2023 (-50%) and Dec 2023 (-54%)
-Last recorded month Jan 2024 shows -89.92% decline
-Recommendation: New campaigns needed to replace ending ones
to avoid revenue cliff in 2024 */


-- ============================================================
-- Query 3: Which Campaigns Should Be Stopped?
-- Business Question: Which active campaigns are underperforming
--                    and should be reviewed or stopped?
-- ============================================================


SELECT 
	Campaign_ID,
    Campaign_Name,
    Channel,
    Region,
    Product_Category,
    Campaign_Status,
    ROUND(SUM(Spend), 2)  as Total_Spend,
    ROUND(SUM(Revenue), 2)as Total_Revenue,
    ROUND(AVG(ROAS), 2)  as Avg_ROAS,
    ROUND(AVG(ROI_Pct), 2) as Avg_ROI_Pct,
    ROUND(AVG(CTR), 2) as Avg_CTR,
    CASE 
		WHEN AVG(ROAS) < 2 THEN 'Stop_Immediately'
        WHEN AVG(ROAS) BETWEEN 2 AND 3 THEN 'Review Urgently'
		WHEN AVG(ROAS) BETWEEN 3 AND 4  THEN 'Needs Improvement'
        ELSE 'Monitor'
	END as Action_Required 
FROM Marketing_Master
WHERE Campaign_Status = 'Active'
GROUP BY 
    Campaign_ID,
    Campaign_Name,
    Channel,
    Region,
    Product_Category,
    Campaign_Status
HAVING AVG(ROAS) < (
SELECT AVG(ROAS) * 0.70 
FROM Marketing_master
WHERE Campaign_Status = 'Active'
)
ORDER BY Avg_ROAS ASC;
        


/* Query 3 Insights:
- 94 active campaigns are underperforming below 70% of avg ROAS
- All 27 "Review Urgently" campaigns belong to Influencer channel
 with ROAS between 2.67 and 2.83
- YouTube Ads has 57 campaigns needing improvement
 with ROAS between 3.17 and 3.33
- Meta Ads campaigns are borderline — ROAS between 3.87 and 4.07
- Email Marketing, SEO, and Affiliate have zero underperforming
   campaigns — all above benchmark
- Recommendation: Stop budget allocation to Influencer channel
  Review YouTube Ads creative and targeting strategy */



-- ============================================================
-- Query 4: Top Performing Campaign per Channel
-- Business Question: Which is the single best campaign in each
--                    channel based on total revenue generated?
-- ============================================================

 WITH Campaign_Revenue as (SELECT
        Channel,
        Campaign_ID,
        Campaign_Name,
        Product_Category,
        Region,
        ROUND(SUM(Revenue), 2)   AS Total_Revenue,
        ROUND(SUM(Spend), 2)     AS Total_Spend,
        ROUND(AVG(ROAS), 2)      AS Avg_ROAS,
        ROUND(AVG(ROI_Pct), 2)   AS Avg_ROI_Pct
    FROM marketing_master
    GROUP BY
        Channel,
        Campaign_ID,
        Campaign_Name,
        Product_Category,
        Region),
Ranked_Campaign as (SELECT
	*,
	ROW_NUMBER() OVER (
            PARTITION BY Channel
            ORDER BY Total_Revenue DESC
        ) AS Revenue_Rank
    FROM Campaign_Revenue)
SELECT
    Channel,
    Campaign_ID,
    Campaign_Name,
    Product_Category,
    Region,
    Total_Revenue,
    Total_Spend,
    Avg_ROAS,
    Avg_ROI_Pct,
    Revenue_Rank
FROM Ranked_Campaign
WHERE Revenue_Rank = 1
ORDER BY Total_Revenue DESC;


/*
Query 4 Insights:
- Email Marketing top campaign (CMP_0510) generated ₹29.6M
  with 1078% ROI — best single campaign across all channels
- SEO top campaign (CMP_0659) shows 8.62 ROAS — highly efficient
- Even the best Influencer campaign (CMP_0224) has only 2.83 ROAS
  — lower than the worst Email Marketing campaign
- Google Ads best campaign (CMP_0410) has only 5.33 ROAS despite
  being the top campaign — channel ceiling is low
- Recommendation: Study CMP_0510 and CMP_0659 as benchmark
  campaigns for strategy replication
*/

-- ============================================================
-- Query 5: Region wise Campaign Performance Percentile
-- Business Question: Which regions have the most underperforming
--                    campaigns and where should we focus
-- ============================================================

    WITH Campaigns_Stats as (SELECT
        Region,
        Campaign_ID,
        Campaign_Name,
        Channel,
        Product_Category,
        ROUND(SUM(Revenue), 2)  AS Total_Revenue,
        ROUND(SUM(Spend), 2)    AS Total_Spend,
        ROUND(AVG(ROAS), 2)     AS Avg_ROAS,
        ROUND(AVG(ROI_Pct), 2)  AS Avg_ROI_Pct
    FROM marketing_master
    GROUP BY
        Region,
        Campaign_ID,
        Campaign_Name,
        Channel,
        Product_Category),
Percentile_Ranked as (SELECT *,
	ROUND(PERCENT_RANK() OVER(
					PARTITION BY Region 
                    ORDER BY Avg_ROAS ASC) *100,2)as ROAS_Percentile, 
	CASE 
		WHEN PERCENT_RANK() OVER(
					PARTITION BY Region 
                    ORDER BY Avg_ROAS ASC) <= 0.25 THEN 'Bottom 25% - Underperforming'
		WHEN PERCENT_RANK() OVER(
					PARTITION BY Region 
                    ORDER BY Avg_ROAS ASC) <= 0.50 THEN 'Bottom 50% - Below Average'
		WHEN PERCENT_RANK() OVER(
					PARTITION BY Region 
                    ORDER BY Avg_ROAS ASC) <= 0.75 THEN 'Top 50% - Above Average'
		ELSE 'Top 25% - Best Performer'
        END As Performer_Tier 
        FROM Campaigns_Stats),
Region_Summary as (SELECT 
	Region,
    COUNT(Campaign_ID) As Total_Campaigns,
    SUM( CASE WHEN Performer_Tier = 'Bottom 25% - Underperforming' 
			THEN 1 ELSE 0 END) AS 'Underperforming_Count',
     ROUND(AVG(Avg_ROAS),2) as Region_Avg_ROAS,
     ROUND(AVG(Avg_ROI_Pct),2) as Region_Avg_ROI
    FROM Percentile_Ranked
    GROUP BY Region)
SELECT *
FROM region_summary
ORDER BY Underperforming_Count DESC;

/*
Query 5 Insights:
- East region has the most underperforming campaigns (46 out
  of 181) — highest count and lowest ROAS of 5.58
- North region is the best performer with avg ROAS of 6.22
  and ROI of 522% despite having same campaigns as Central
- West region has fewest underperforming campaigns (36 out
  of 141) — most efficient region overall
- All regions have similar ROAS (5.58 to 6.22) — gap is small
  suggesting no single region is critically underperforming
- Recommendation: Review East region campaign targeting and
  channel mix — shift budget toward North region strategy
*/

-- ============================================================
-- Query 6: Top 25% Campaigns Pattern Analysis
-- Business Question: What are the common characteristics of
--                   top performing campaigns?
-- ============================================================

WITH Campaign_Stats AS ( SELECT
        Campaign_ID,
        Campaign_Name,
        Channel,
        Region,
        Product_Category,
        Campaign_Type,
        Budget_Category,
        Campaign_Duration_Days,
        ROUND(SUM(Revenue), 2)  AS Total_Revenue,
        ROUND(SUM(Spend), 2)    AS Total_Spend,
        ROUND(AVG(ROAS), 2)     AS Avg_ROAS,
        ROUND(AVG(ROI_Pct), 2)  AS Avg_ROI_Pct,
        ROUND(AVG(CTR), 2)      AS Avg_CTR
    FROM marketing_master
    GROUP BY
        Campaign_ID,
        Campaign_Name,
        Channel,
        Region,
        Product_Category,
        Campaign_Type,
        Budget_Category,
        Campaign_Duration_Days),
ntile_ranked  AS (SELECT
	*,
	NTILE(4) OVER (
            ORDER BY Avg_ROAS DESC
        ) AS Performance_Bucket
FROM campaign_stats),
Top25 AS (SELECT *
    FROM ntile_ranked
    WHERE Performance_Bucket = 1)
SELECT
    Channel,
    Region,
    Product_Category,
    Campaign_Type,
    Budget_Category,
    COUNT(Campaign_ID)              AS Campaign_Count,
    ROUND(AVG(Avg_ROAS), 2)        AS Avg_ROAS,
    ROUND(AVG(Avg_ROI_Pct), 2)     AS Avg_ROI,
    ROUND(AVG(Campaign_Duration_Days), 0) AS Avg_Duration_Days,
    ROUND(AVG(Avg_CTR), 2)         AS Avg_CTR
FROM top25
GROUP BY
    Channel,
    Region,
    Product_Category,
    Campaign_Type,
    Budget_Category
ORDER BY Campaign_Count DESC
LIMIT 15;

/*
Query 6 Insights:
- Top 25% campaigns are dominated by Email Marketing and SEO
  — no other channel appears in top 15 combinations
- Email Marketing top campaigns show consistent ROAS of 11.38
  to 11.56 with ROI above 1037% across all regions
- SEO top campaigns show ROAS of 8.48 to 8.59 — strong and
  consistent across regions and product categories
- Campaign duration of top performers ranges from 248 to 375
  days — longer campaigns tend to perform better
- Small and Medium budget campaigns appear in top 25% —
  proving that budget size alone does not drive performance
- CTR of Email Marketing (24-25%) is 3x higher than SEO (8-9%)
  — Email drives more clicks per impression
- Recommendation: Replicate Email Marketing and SEO strategy
  across all regions and product categories
*/


-- ============================================================
-- Query 7: Campaign Duration vs Performance Analysis
-- Business Question: Do longer campaigns perform better than
--                    shorter ones? What is the optimal duration?
-- ============================================================

WITH Campaigns_Stats AS ( SELECT
        Campaign_ID,
        Campaign_Name,
        Channel,
        Campaign_Duration_Days,
        Campaign_Type,
        Budget_Category,
        ROUND(SUM(Revenue), 2)  AS Total_Revenue,
        ROUND(SUM(Spend), 2)    AS Total_Spend,
        ROUND(AVG(ROAS), 2)     AS Avg_ROAS,
        ROUND(AVG(ROI_Pct), 2)  AS Avg_ROI_Pct,
        ROUND(AVG(CTR), 2)      AS Avg_CTR
    FROM marketing_master
    GROUP BY
        Campaign_ID,
        Campaign_Name,
        Channel,
        Campaign_Duration_Days,
        Campaign_Type,
        Budget_Category),
Duration_Bucket AS (SELECT
        *,
        CASE
            WHEN Campaign_Duration_Days BETWEEN 200 AND 250 THEN '200-250 Days'
            WHEN Campaign_Duration_Days BETWEEN 251 AND 300 THEN '251-300 Days'
            WHEN Campaign_Duration_Days BETWEEN 301 AND 350 THEN '301-350 Days'
            WHEN Campaign_Duration_Days BETWEEN 351 AND 400 THEN '351-400 Days'
            ELSE '400+ Days'
        END AS Duration_Bucket
FROM Campaigns_Stats)
SELECT
    Duration_Bucket,
    COUNT(Campaign_ID)              AS Total_Campaigns,
    ROUND(AVG(Avg_ROAS), 2)        AS Avg_ROAS,
    ROUND(AVG(Avg_ROI_Pct), 2)     AS Avg_ROI,
    ROUND(AVG(Total_Revenue), 2)   AS Avg_Revenue,
    ROUND(AVG(Avg_CTR), 2)         AS Avg_CTR,
    ROUND(AVG(Campaign_Duration_Days), 0) AS Avg_Duration
FROM Duration_Bucket
GROUP BY Duration_Bucket
ORDER BY Avg_ROAS DESC;

/*
Query 7 Insights:
- Campaigns running 301-350 days show the best average ROAS
  of 5.86 and highest average revenue of ₹3.95M
- Campaigns in 251-300 day range show the weakest performance
  with ROAS of 5.75 and ROI of 475% — lowest across all buckets
- Short campaigns (200-250 days) show highest CTR of 8.22%
  — they generate more clicks but lower overall revenue
- The ROAS difference across all duration buckets is small
  (5.75 to 5.86) — duration alone is not a strong predictor
  of performance in this dataset
- Recommendation: Target 301-350 day campaign duration for
  optimal revenue and ROAS balance
*/

-- ============================================================
-- Query 8: Revenue Decline Detection
-- Business Question: Which months had the steepest revenue
--                    decline and what was the consecutive
--                    decline pattern?
-- ============================================================


 WITH Monthly_Revenue AS (SELECT
        Year,
        Month,
        CONCAT(Year, '-', LPAD(Month, 2, '0'))  AS Period,
        ROUND(SUM(Revenue), 2)AS Total_Revenue,
        ROUND(SUM(Spend), 2)AS Total_Spend
FROM marketing_master
GROUP BY Year, Month
ORDER BY Year, Month),
MOM_Comparison AS (SELECT
        Period,
        Total_Revenue,
        Total_Spend,
        LAG(Total_Revenue) OVER (ORDER BY Period) AS Prev_Revenue,
        LAG(Total_Spend)   OVER (ORDER BY Period) AS Prev_Spend,
        ROUND(
            (Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY Period))
            / LAG(Total_Revenue) OVER (ORDER BY Period) * 100
        , 2) AS Revenue_Change_Pct,
        ROUND(
            (Total_Spend - LAG(Total_Spend) OVER (ORDER BY Period))
            / LAG(Total_Spend) OVER (ORDER BY Period) * 100
        , 2) AS Spend_Change_Pct
FROM Monthly_Revenue),
Decline_Analysis AS ( SELECT
        *,
        CASE
            WHEN Revenue_Change_Pct < -40  THEN 'Severe Decline'
            WHEN Revenue_Change_Pct < -20  THEN 'Major Decline'
            WHEN Revenue_Change_Pct < -10  THEN 'Moderate Decline'
            WHEN Revenue_Change_Pct < 0    THEN 'Minor Decline'
            WHEN Revenue_Change_Pct >= 0   THEN 'Growth'
            ELSE                                'First Month'
        END  AS Decline_Category,
        CASE
            WHEN Revenue_Change_Pct < 0
             AND Spend_Change_Pct   < 0  THEN 'Both Declining'
            WHEN Revenue_Change_Pct < 0
             AND Spend_Change_Pct  >= 0  THEN 'Revenue Only'
            WHEN Revenue_Change_Pct >= 0 THEN 'Growing'
            ELSE                              'First Month'
        END AS Decline_Type
FROM MOM_Comparison) 
SELECT
    Period,
    Total_Revenue,
    Prev_Revenue,
    Revenue_Change_Pct,
    Spend_Change_Pct,
    Decline_Category,
    Decline_Type
FROM decline_analysis
WHERE Revenue_Change_Pct < 0
   OR Period = '2022-01'
ORDER BY Revenue_Change_Pct ASC;

/*
Query 8 Insights:
- Decline started from January 2023 with a minor -5.80% drop
  — this was the early warning signal
- 3 months show Severe Decline — Nov 2023 (-50%), Dec 2023
  (-54%), Jan 2024 (-90%) — campaigns almost completely ended
- All declining months show "Both Declining" type — Revenue
  and Spend declined together — no efficiency loss detected
- This confirms the decline was due to campaigns ending
  naturally — not due to poor performance or strategy failure
- Major decline phase was April to October 2023 — agency lost
  roughly 20-30% revenue every month during this period
- Recommendation: New campaigns should have been launched by
  mid 2023 to avoid the revenue cliff in late 2023
*/


-- ============================================================
-- Query 9: Top Clients by Revenue and Efficiency
-- Business Question: Which clients generate the most revenue
--                    and which ones should be prioritized
--                    for retention?
-- ============================================================
WITH Client_Stats As ( SELECT
        Client_Name,
        COUNT(DISTINCT Campaign_ID)AS Total_Campaigns,
        ROUND(SUM(Revenue), 2) AS Total_Revenue,
        ROUND(SUM(Spend), 2) AS Total_Spend,
        ROUND(SUM(Revenue) - SUM(Spend), 2) AS Total_Profit,
        ROUND(AVG(ROAS), 2) AS Avg_ROAS,
        ROUND(AVG(ROI_Pct), 2) AS Avg_ROI_Pct,
        ROUND(AVG(CTR), 2)  AS Avg_CTR,
        COUNT(DISTINCT Channel) AS Channels_Used
FROM marketing_master
GROUP BY Client_Name),
Client_Ranked AS (SELECT
        *,
        RANK() OVER (
            ORDER BY Total_Revenue DESC)  AS Revenue_Rank,
        DENSE_RANK() OVER (
            ORDER BY Avg_ROAS DESC)  AS ROAS_Rank,
        CASE
            WHEN Total_Revenue >= (SELECT AVG(Total_Revenue) * 1.5 
                                   FROM client_stats)
             AND Avg_ROAS >= (SELECT AVG(Avg_ROAS) 
                                   FROM client_stats)
                                            THEN 'Priority — Retain'
            WHEN Total_Revenue >= (SELECT AVG(Total_Revenue) 
                                   FROM client_stats)
                                            THEN 'Important — Grow'
            WHEN Avg_ROAS >= (SELECT AVG(Avg_ROAS) 
                                   FROM client_stats) THEN 'Efficient — Invest'
            ELSE 'Review — At Risk'
        END AS Client_Priority
FROM client_stats)
SELECT
    Client_Name,
    Total_Campaigns,
    Total_Revenue,
    Total_Profit,
    Avg_ROAS,
    Avg_ROI_Pct,
    Channels_Used,
    Revenue_Rank,
    ROAS_Rank,
    Client_Priority
FROM client_ranked
ORDER BY Revenue_Rank
LIMIT 20;

/* Query 9 Insights:
- Client_002 is the top revenue generator at ₹108M with
  ROAS of 5.92 — highest priority for retention
- Only 4 clients qualify as "Priority Retain" — both high
  revenue and above average ROAS
- Client_048 has the highest ROAS of 8.04 among top 20
  but ranks 11th in revenue — significant growth potential
  if campaign count is increased
- Client_047 runs the most campaigns (25) but has below
  average ROAS of 5.62 — quantity is not driving efficiency
- All top 20 clients use 5-7 different channels — multi
  channel approach is common among high revenue clients
- Recommendation: Focus retention efforts on 4 Priority
  clients — invest in Client_048 and Client_025 to grow
  their revenue given their high ROAS efficiency
*/


-- ============================================================
-- Query 10: Quarterly Revenue Trend with Subtotals
-- Business Question: How did revenue and spend trend across
--                    quarters and years? What were the totals?
-- ============================================================

SELECT
    COALESCE(CAST(Year AS CHAR), 'Grand Total') AS Year,
    COALESCE(
        CASE
            WHEN Quarter = 1 THEN 'Q1 (Jan-Mar)'
            WHEN Quarter = 2 THEN 'Q2 (Apr-Jun)'
            WHEN Quarter = 3 THEN 'Q3 (Jul-Sep)'
            WHEN Quarter = 4 THEN 'Q4 (Oct-Dec)'
        END,
        CASE
            WHEN Year IS NOT NULL THEN 'Year Total'
            ELSE 'Grand Total'
        END
    ) AS Quarter,
    COUNT(DISTINCT Campaign_ID)AS Total_Campaigns,
    ROUND(SUM(Spend), 2)  AS Total_Spend,
    ROUND(SUM(Revenue), 2)   AS Total_Revenue,
    ROUND(SUM(Revenue) - SUM(Spend), 2) AS Total_Profit,
    ROUND(SUM(Revenue) / SUM(Spend), 2)AS Overall_ROAS,
    ROUND(AVG(ROI_Pct), 2)AS Avg_ROI_Pct
FROM marketing_master
GROUP BY ROLLUP(Year, Quarter)
ORDER BY Year, Quarter;

-- ============================================================
-- Stored Procedure 1: Client Performance Report
-- Business Question: Give me a complete performance summary
--                    for any client on demand
-- ============================================================

DELIMITER $$

CREATE PROCEDURE sp_Client_Report(IN p_Client_Name VARCHAR(50))
BEGIN

    -- Section 1: Overall Summary
    SELECT
        Client_Name,
        COUNT(DISTINCT Campaign_ID)         AS Total_Campaigns,
        COUNT(DISTINCT Channel)             AS Channels_Used,
        ROUND(SUM(Spend), 2)                AS Total_Spend,
        ROUND(SUM(Revenue), 2)              AS Total_Revenue,
        ROUND(SUM(Revenue) - SUM(Spend), 2) AS Total_Profit,
        ROUND(SUM(Revenue) / SUM(Spend), 2) AS Overall_ROAS,
        ROUND(AVG(ROI_Pct), 2)              AS Avg_ROI_Pct,
        ROUND(AVG(CTR), 2)                  AS Avg_CTR,
        ROUND(AVG(CVR), 2)                  AS Avg_CVR
    FROM marketing_master
    WHERE Client_Name = p_Client_Name
    GROUP BY Client_Name;

    -- Section 2: Channel wise Breakdown
    SELECT
        Channel,
        COUNT(DISTINCT Campaign_ID)         AS Total_Campaigns,
        ROUND(SUM(Spend), 2)                AS Total_Spend,
        ROUND(SUM(Revenue), 2)              AS Total_Revenue,
        ROUND(SUM(Revenue) / SUM(Spend), 2) AS ROAS,
        ROUND(AVG(ROI_Pct), 2)              AS Avg_ROI_Pct
    FROM marketing_master
    WHERE Client_Name = p_Client_Name
    GROUP BY Channel
    ORDER BY Total_Revenue DESC;

    -- Section 3: Best Campaign
    SELECT
        Campaign_ID,
        Campaign_Name,
        Channel,
        Product_Category,
        Region,
        ROUND(SUM(Revenue), 2)  AS Total_Revenue,
        ROUND(AVG(ROAS), 2)     AS Avg_ROAS,
        ROUND(AVG(ROI_Pct), 2)  AS Avg_ROI_Pct
    FROM marketing_master
    WHERE Client_Name = p_Client_Name
    GROUP BY
        Campaign_ID,
        Campaign_Name,
        Channel,
        Product_Category,
        Region
    ORDER BY Total_Revenue DESC
    LIMIT 5;

END$$

DELIMITER ;

CALL sp_Client_Report('Client_001');


-- ============================================================
-- Stored Procedure 2: Channel Audit Report
-- Business Question: Give me a complete audit of any channel
--                    on demand
-- ============================================================

DELIMITER //

CREATE PROCEDURE sp_Channel_Audit(IN p_Channel VARCHAR(50))
BEGIN

    -- Section 1: Channel Overall Summary
    SELECT
        Channel,
        COUNT(DISTINCT Campaign_ID)         AS Total_Campaigns,
        COUNT(DISTINCT Region)              AS Regions_Covered,
        COUNT(DISTINCT Product_Category)    AS Categories_Covered,
        ROUND(SUM(Spend), 2)                AS Total_Spend,
        ROUND(SUM(Revenue), 2)              AS Total_Revenue,
        ROUND(SUM(Revenue) - SUM(Spend), 2) AS Total_Profit,
        ROUND(SUM(Revenue) / SUM(Spend), 2) AS Overall_ROAS,
        ROUND(AVG(ROI_Pct), 2)              AS Avg_ROI_Pct,
        ROUND(AVG(CTR), 2)                  AS Avg_CTR,
        ROUND(AVG(CVR), 2)                  AS Avg_CVR
    FROM marketing_master
    WHERE Channel = p_Channel
    GROUP BY Channel;

    -- Section 2: Region wise Performance
    SELECT
        Region,
        COUNT(DISTINCT Campaign_ID)         AS Total_Campaigns,
        ROUND(SUM(Spend), 2)                AS Total_Spend,
        ROUND(SUM(Revenue), 2)              AS Total_Revenue,
        ROUND(SUM(Revenue) / SUM(Spend), 2) AS ROAS,
        ROUND(AVG(ROI_Pct), 2)              AS Avg_ROI_Pct,
        ROUND(AVG(CTR), 2)                  AS Avg_CTR
    FROM marketing_master
    WHERE Channel = p_Channel
    GROUP BY Region
    ORDER BY Total_Revenue DESC;

    -- Section 3: Monthly Revenue Trend
    SELECT
        CONCAT(Year, '-', LPAD(Month, 2, '0')) AS Period,
        ROUND(SUM(Spend), 2)                   AS Total_Spend,
        ROUND(SUM(Revenue), 2)                 AS Total_Revenue,
        ROUND(SUM(Revenue) / SUM(Spend), 2)    AS ROAS,
        ROUND(AVG(ROI_Pct), 2)                 AS Avg_ROI_Pct
    FROM marketing_master
    WHERE Channel = p_Channel
    GROUP BY Year, Month
    ORDER BY Period;

END//

DELIMITER ;

CALL sp_Channel_Audit('Email Marketing');



























