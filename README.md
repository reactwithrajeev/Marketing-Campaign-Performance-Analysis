# 📊 Marketing Campaign Performance Analysis

### End-to-End Data Analytics Project | Python • SQL • Excel • Power BI

An end-to-end marketing analytics project built for a fictional digital marketing agency, **DigitX Media Agency**. This project covers the complete analytics pipeline — from data generation and cleaning to exploratory analysis, advanced SQL querying, an interactive Excel dashboard, and a multi-page Power BI report with AI-driven insights.

---

## 🎯 Project Overview

DigitX Media Agency runs marketing campaigns across **7 channels**, **5 regions**, and **8 product categories** for multiple clients. The agency wanted to understand:

- Which marketing channels deliver the best return on ad spend (ROAS)?
- How does campaign performance vary by region, product category, and budget size?
- Which campaigns and clients are the most profitable?
- What would happen to revenue if marketing efficiency improved (what-if scenarios)?
- Which factors most strongly influence campaign success?

This project answers these questions through a complete analytics workflow — **data cleaning → exploratory analysis → SQL reporting → Excel dashboards → Power BI dashboards**.

---

## 📈 Quick Stats (at a glance)

| Metric | Value |
|---|---|
| Total Campaigns | 800 |
| Total Revenue | ₹282.22 Cr |
| Total Spend | ₹47.49 Cr |
| Total Profit | ₹234.73 Cr |
| Overall ROAS | 5.94 |
| Overall ROI | 494.26% |
| Best Performing Channel | Email Marketing (ROAS 11.49) |
| Best Performing Region | North (ROAS 6.16) |

---

## 🗂️ Dataset

The dataset is a synthetically generated, realistic marketing dataset consisting of **3 related tables**:

| Table | Rows | Columns | Description |
|---|---|---|---|
| `campaigns.csv` | 800 | 12 | Campaign-level details — channel, type, audience, region, budget, client, dates, status |
| `campaign_performance.csv` | 242,487 | 15 | Daily performance metrics per campaign — impressions, clicks, conversions, spend, revenue, CTR, CVR, CPC, CPA, ROAS, bounce rate, session duration |
| `influencer_affiliate.csv` | 25,000 | 13 | Influencer & affiliate partner-level data — platform, tier, reach, engagement, commission, revenue generated |

After cleaning and feature engineering, these were merged into a single analytical table: **`marketing_master.csv`** (242,487 rows × 42 columns).

---

## 🛠️ Tools & Technologies

| Category | Tools |
|---|---|
| Programming | Python (Pandas, NumPy, Matplotlib, Seaborn) |
| Database | MySQL Workbench |
| Spreadsheet | Microsoft Excel |
| BI / Visualization | Power BI Desktop |
| Version Control | Git & GitHub |

---

## 🔄 Project Workflow

```
Raw CSV Data
     │
     ▼
Python (Data Cleaning + Feature Engineering)
     │
     ▼
Python EDA (10 charts, business insights)
     │
     ▼
MySQL (Advanced queries, View, Stored Procedures)
     │
     ▼
Excel Dashboard (Pivot Tables, KPI cards, advanced formulas)
     │
     ▼
Power BI Dashboard (5-page interactive report, DAX, AI visuals)
```

---

## 🐍 Phase 1 — Python: Data Cleaning & EDA

📁 `python/`

### Data Cleaning (`02_Data_Cleaning.ipynb`)
- Loaded and inspected all 3 raw tables (no missing values found)
- Converted 4 date columns from `object` → `datetime64`
- Checked for and confirmed zero duplicate records
- **Feature Engineering:**
  - `campaigns` table → `Campaign_Duration_Days`, `Budget_Category`
  - `campaign_performance` table → `ROI_Pct` (via `.apply()` + `lambda`), `ROAS_Category`, `CTR_Category`, `Month`, `Quarter`, `Year`, `Revenue_Per_Impression`
  - `influencer_affiliate` aggregated to `Campaign_ID` level to resolve a many-to-many relationship before merging
- Merged all 3 tables into `marketing_master.csv` (242,487 rows × 42 columns)

### Exploratory Data Analysis (`03_EDA.ipynb`)

📁 `python/charts/`

| # | Chart | Technique Used | Key Insight |
|---|---|---|---|
| 1 | Monthly Spend vs Revenue | Dual-axis (`twinx`) | Overall ROI of 494.26% — ₹4.94 returned per ₹1 spent |
| 2 | Channel-wise ROAS vs Benchmark | Bar chart + benchmark line | Email Marketing best (11.49), Influencer worst (2.75) |
| 3 | Monthly Revenue Trend | Rolling 3-month moving average (`rolling()`) | Strong growth through 2022, decline through 2023–24 |
| 4 | Campaign Type vs CVR | Bar chart | All campaign types perform similarly (~4.50%) |
| 5 | Region-wise Revenue | Bar chart | East has highest revenue (₹64.96 Cr); North is most efficient |
| 6 | Product Category vs ROAS | Bar chart | Education leads (6.00), Beauty & Skincare lowest (5.39) |
| 7 | Top 10 Campaigns by Revenue | Bar chart | All top 10 belong to Email Marketing |
| 8 | CTR vs CVR (bubble = ROAS) | Scatter plot | Email Marketing CTR (25–26%) far exceeds all other channels (2–10%) |
| 9 | Influencer vs Affiliate | Grouped bar (`pd.melt`) | Affiliate delivers ~2x the ROAS of Influencer marketing |
| 10 | Correlation Heatmap | Seaborn heatmap | Spend–Impressions correlation: 0.98; ROAS–ROI correlation: 1.00 |

---

## 🗄️ Phase 2 — SQL Analysis (MySQL)

📁 `sql/marketing_campaigns_analysis.sql`

A series of advanced SQL queries (including 1 View) plus 2 Stored Procedures, written against the `marketing_master` table.

**Concepts demonstrated:**
- `CREATE VIEW` for a reusable channel summary
- Common Table Expressions (CTEs) — used across most queries
- Window functions: `LAG()`, `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `PERCENT_RANK()`, `NTILE()`
- `ROLLUP` for quarterly subtotals with `COALESCE` for clean labels
- Correlated subqueries inside `CASE WHEN` logic
- Month-over-month growth analysis using `LAG()`

**Stored Procedures:**

| Procedure | Purpose | Output |
|---|---|---|
| `sp_Client_Report(client_name)` | Generates a full performance report for any client | 3 result sets: overall summary, channel-wise breakdown, top 5 campaigns |
| `sp_Channel_Audit(channel_name)` | Generates a full audit for any marketing channel | 3 result sets: overall summary, region-wise performance, monthly revenue trend |

> Example: `CALL sp_Channel_Audit('Email Marketing');` revealed that Email Marketing maintained a consistent **ROAS of ~11.5 and ROI of ~1050%** across every region and month — making it DigitX's strongest channel by far.

---

## 📈 Phase 3 — Excel Dashboard

📁 `excel/Marketing_Campaign_Analysis_Dashboard.xlsx`

A 6-sheet interactive Excel workbook: **Raw_Data, Lookup_Tables, Calculations, Dashboard_1, Dashboard_2, Dashboard_3**.

### Dashboard_1 — Executive Overview
- 6 KPI cards (Total Revenue, Spend, Profit, Overall ROAS, Avg CTR, Avg ROI) with embedded **Sparklines** showing quarterly trends
- 2 Pivot Charts — Channel-wise Revenue (bar) and Monthly Revenue vs Spend Trend (line)
- A **Channel Slicer** and **Date Timeline**, connected to both charts via Report Connections

### Dashboard_2 — Channel & Campaign Analysis
- Pivot Chart of **Top 10 Campaigns by Revenue** (Top 10 filter applied)
- **Channel Deep Dive** — a dynamic dropdown-driven tool using **GETPIVOTDATA** to pull Revenue, Spend, ROAS, and ROI for any selected channel directly from a Pivot Table
- **What-If Analysis** — a ROAS-improvement scenario tool (dropdown from -20% to +40%) that projects total revenue impact if marketing efficiency improves with the same spend

### Dashboard_3 — Region & Product Analysis
- Pivot Chart of Region-wise Revenue & ROAS
- **Smart Performance Lookup tool** — combines **CHOOSE + INDIRECT + XLOOKUP** with a fully dynamic dropdown (the dropdown's options themselves change based on whether "Region" or "Category" is selected, using `INDIRECT` inside Data Validation)

### Other Excel Concepts Used
`XLOOKUP`, `INDEX+MATCH`, `VLOOKUP`, `SUMIFS`, `AVERAGEIFS`, `IF`, `RANK`, `PERCENTILE.INC`, `UNIQUE`, `SORT`, Named Ranges, Data Validation (static & dynamic), Conditional Formatting, multiple linked Pivot Tables, Pivot Charts, Slicers, Timeline, Sparklines.

---

## 📊 Phase 4 — Power BI Dashboard

📁 `powerbi/Marketing_Campaigns_PBI_Report.pbix`
📁 `powerbi/dashboard_screenshots/`

A 5-page interactive Power BI report with synced Channel and Region slicers on every page.

| Page | Contents |
|---|---|
| **1. Executive Summary** | KPI cards, Monthly Revenue vs Spend trend, Channel-wise Revenue, Revenue by Region, Top 5 Campaigns table |
| **2. Channel Performance Analysis** | Channel performance summary table with **Channel Rank (RANKX)**, ROAS by Channel, Revenue share donut chart, CTR vs CVR scatter plot |
| **3. Campaign Analysis** | Top 10 Campaigns, Budget Category performance, **Decomposition Tree** (Total Revenue → Channel → Region → Product Category), ROAS by Campaign Duration Bucket |
| **4. Region & Client Analysis** | Revenue vs Spend by Region, Top 10 Clients table, **Key Influencers AI visual**, Average CTR by Region |
| **5. Trend Analysis** | **Field Parameters**-based Metric Selector, dynamic monthly trend chart, drillable Quarterly Performance matrix, Revenue Last 3 Months (**DATESINPERIOD**) |

### DAX Measures (`All_Measures`)
`Total Revenue`, `Total Spend`, `Total Profit`, `Total Campaigns`, `Overall ROAS`, `Overall ROI Pct`, `Average CTR`, `Average CVR`, `Channel Rank` (RANKX), `Revenue Last 3 Months` (DATESINPERIOD)

### Advanced Power BI Concepts Used
`RANKX`, **Field Parameters** (dynamic Metric Selector), `DATESINPERIOD` (time intelligence), **Decomposition Tree**, **Key Influencers (AI visual)**, synced slicers across pages, drillable matrix.

---

## 🔑 Key Insights & Recommendations

- **Email Marketing is the standout channel** — ROAS of 11.49 and ROI of ~1050%, contributing ~30% of total revenue. Power BI's AI "Key Influencers" visual independently confirmed this, showing Email Marketing increases average ROAS by 6.52.
- **Influencer marketing is the weakest channel** (ROAS 2.75) — budget reallocated from Influencer to Email Marketing could significantly increase overall returns *without any additional spend*.
- **North region is the most efficient** (ROAS 6.16), while **East generates the highest absolute revenue** (₹64.96 Cr).
- **Campaign duration matters** — campaigns running 200–250 days achieve the highest ROAS (6.2), suggesting an optimal campaign length.
- **Larger budget campaigns are slightly more efficient** (ROAS 6.0) than medium (5.9) and small (5.7) budget campaigns.
- **What-if simulation**: a 20% improvement in overall ROAS — achievable through smarter budget allocation alone — could increase total revenue from ₹282 Cr to ₹339 Cr.

---

## 📸 Dashboard Screenshots

> Screenshots of all Power BI pages and Excel dashboards are available in `powerbi/dashboard_screenshots/`.

![Executive Summary](POWER%20BI/dashboard_screenshots/Marketing_Campaigns_PBI_Report_page-0002.jpg)
![Channel Performance Analysis](POWER%20BI/dashboard_screenshots/Marketing_Campaigns_PBI_Report_page-0003.jpg)
![Campaign Analysis](POWER%20BI/dashboard_screenshots/Marketing_Campaigns_PBI_Report_page-0004.jpg)
![Region & Client Analysis](POWER%20BI/dashboard_screenshots/Marketing_Campaigns_PBI_Report_page-0005.jpg)
![Trend Analysis](POWER%20BI/dashboard_screenshots/Marketing_Campaigns_PBI_Report_page-0006.jpg)

---

## 📁 Repository Structure

```
Marketing-Campaign-Performance-Analysis/
├── python/
│   ├── charts/
│   ├── 01_Dataset_Generation.ipynb
│   ├── 02_Data_Cleaning.ipynb
│   └── 03_EDA.ipynb
├── sql/
│   └── marketing_campaigns_analysis.sql
├── excel/
│   └── Marketing_Campaign_Analysis_Dashboard.xlsx
├── powerbi/
│   ├── dashboard_screenshots/
│   └── Marketing_Campaigns_PBI_Report.pbix
└── README.md
```

---

## 🚀 How to Use This Project

1. Clone this repository
2. **Python**: Open the notebooks in `python/` using Jupyter Notebook (requires `pandas`, `numpy`, `matplotlib`, `seaborn`)
3. **SQL**: Import `marketing_master.csv` into MySQL and run `sql/marketing_campaigns_analysis.sql` in MySQL Workbench
4. **Excel**: Open `excel/Marketing_Campaign_Analysis_Dashboard.xlsx` in Microsoft Excel (365 recommended for dynamic array functions)
5. **Power BI**: Open `powerbi/Marketing_Campaigns_PBI_Report.pbix` in Power BI Desktop

---

## 🔮 Future Enhancements

- Add `LEAD()` window function for next-period revenue forecasting
- Add a `CROSS JOIN`-based Channel × Region coverage matrix
- Automate data refresh using Power Query / scheduled SQL jobs
- Publish the Power BI report to Power BI Service for live sharing

---

## 👤 About Me

I'm **Rajeev**, a data analytics professional transitioning from operations/MIS into data analytics, based in Gurgaon, India. I build end-to-end analytics projects across Python, SQL, Excel, and Power BI, and share tutorials on my YouTube channel.

- 📺 YouTube: [Tuning Data](https://youtube.com/@tuningdata)
- 💻 GitHub: [reactwithrajeev](https://github.com/reactwithrajeev)
- 💼 LinkedIn:(https://www.linkedin.com/in/reactwithrajeev)

---

⭐ If you found this project helpful, consider giving it a star!
