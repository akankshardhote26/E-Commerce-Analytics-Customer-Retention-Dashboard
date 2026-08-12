# 🛒 E-Commerce Analytics & Customer Retention Dashboard

An end-to-end **e-commerce analytics project** built using the Olist Brazilian E-Commerce dataset. This project transforms raw multi-table transactional data into a structured analytical database and an interactive dashboard for monitoring **sales performance, customer retention, product categories, and delivery operations**.

The project demonstrates a complete data analytics workflow — from **data ingestion and ETL to SQL analysis, KPI development, cohort analysis, and dashboard visualization**.

---

## 📌 Project Overview

E-commerce businesses need a reliable way to understand sales trends, customer purchasing behavior, product performance, and logistics efficiency.

The objective of this project is to build a **single source of truth for e-commerce business metrics** using properly structured and joined transactional data.

The analysis focuses on:

- Revenue and order performance
- Average Order Value (AOV)
- Month-over-Month (MoM) growth
- Customer repeat-purchase behavior
- Cohort-based customer retention
- Product category performance
- Delivery time and late-delivery rates
- Regional logistics performance

---

## 🎯 Business Questions

This project answers the following key business questions:

1. How much revenue is being generated over time?
2. How is monthly sales performance changing?
3. What is the average value of each order?
4. Which product categories contribute the most revenue?
5. How many customers return to make another purchase?
6. What does customer retention look like across cohorts?
7. How long does it take to deliver orders?
8. Which regions experience higher late-delivery rates?
9. Is business growth primarily driven by customer retention or new customer acquisition?

---

## 📊 Dataset

The project uses the **Olist Brazilian E-Commerce Public Dataset**, containing approximately 100K orders from a Brazilian e-commerce marketplace.

**Source:** Kaggle — Olist Brazilian E-Commerce Dataset

### Dataset Tables

The analysis integrates **9 relational CSV files**:

| Table | Description |
|---|---|
| `orders` | Order status and timestamps |
| `customers` | Customer and location information |
| `order_items` | Products purchased within each order |
| `order_payments` | Payment information |
| `order_reviews` | Customer review information |
| `products` | Product attributes |
| `sellers` | Seller information |
| `geolocation` | Brazilian geographic information |
| `category_translation` | Portuguese-to-English category mapping |

### ⚠️ Important Data Modeling Consideration

One of the most important aspects of this dataset is the distinction between:

- `customer_id` → identifies a customer record associated with an order
- `customer_unique_id` → identifies the actual customer across orders

A returning customer can have a different `customer_id` for a subsequent order.

Therefore, all **repeat-purchase, retention, and customer-level analyses use `customer_unique_id`** as the stable customer identifier.

This prevents customer retention from being incorrectly calculated as nearly zero.

---

## 🏗️ Data & Analytics Architecture

```text
Raw CSV Files
     │
     ▼
Python ETL Pipeline
     │
     ▼
DuckDB Database
     │
     ├── SQL KPI Analysis
     ├── Sales Trend Analysis
     ├── Product Analysis
     ├── Cohort Retention
     └── Logistics Analysis
     │
     ▼
Python / Jupyter Notebook
     │
     ▼
Streamlit + Plotly Dashboard
```

The project uses a **SQL-first analytical approach**, with DuckDB acting as the central analytical database.

---

## 🔄 ETL Process

The raw CSV files are loaded into a persistent DuckDB database using Python.

### ETL Workflow

1. Download the raw Olist dataset.
2. Load all 9 CSV files.
3. Create corresponding DuckDB tables.
4. Establish relationships between tables through their keys.
5. Store the database as:

```text
data/olist.duckdb
```

6. Run analytical SQL queries against the persistent database.
7. Use the same analytical queries for both the notebook and dashboard.

This approach avoids repeatedly loading raw CSV files and provides a cleaner, production-style analytical workflow.

---

## 🛠️ Technology Stack

| Area | Technology |
|---|---|
| Programming | Python |
| Database | DuckDB |
| Data Processing | Pandas |
| Query Language | SQL |
| Data Analysis | Jupyter Notebook |
| Visualization | Matplotlib, Seaborn |
| Interactive Dashboard | Streamlit |
| Dashboard Charts | Plotly |
| Data Source | Kaggle |

---

## 📈 Key KPIs

The dashboard provides an overview of the most important e-commerce performance indicators.

### Sales KPIs

- Total Revenue: **~R$15.4M**
- Delivered Orders: **~96.5K**
- Distinct Customers: **~93.4K**
- Average Order Value: **~R$159.86**

### Logistics KPIs

- Average Delivery Time: **~12.5 days**
- Overall Late-Delivery Rate: **~8%**

### Customer KPI

- Repeat-Purchase Rate: **~3%**

The low repeat-purchase rate is particularly important because it indicates that marketplace growth is largely **acquisition-driven rather than retention-driven**.

---

## 📊 Analysis Performed

### 1. Sales Performance Analysis

Monthly revenue and order trends are analyzed to understand business growth and seasonality.

The analysis includes:

- Monthly revenue
- Monthly order volume
- Average Order Value
- Month-over-Month revenue growth
- Revenue trends over time

The initial months of 2016 contain limited seed data and are therefore excluded from the main trend visualization to avoid misleading interpretations.

Similarly, the January 2017 growth percentage is excluded from the MoM growth visualization because the December 2016 baseline is extremely small and would distort the scale of the chart.

These exclusions are explicitly documented rather than silently removing data.

---

### 2. Product Category Analysis

Product-level and category-level revenue is analyzed to identify the strongest contributors to overall sales.

Top-performing categories include:

1. **Health & Beauty**
2. **Watches & Gifts**
3. **Bed, Bath & Table**

This analysis helps identify the categories that have the greatest impact on marketplace revenue.

---

### 3. Customer Retention & Cohort Analysis

Customer retention is one of the main analytical components of the project.

The cohort analysis follows this process:

```text
Customer Orders
      ↓
Identify First Purchase
      ↓
Assign Customer Cohort
      ↓
Calculate Months Since First Purchase
      ↓
Aggregate Cohort × Month
      ↓
Calculate Retention %
      ↓
Create Retention Heatmap
```

The analysis shows that only approximately **3% of customers place a second order**.

The result is independently validated using:

- Repeat-purchase analysis
- Cohort-retention analysis
- Retention heatmap

The consistency between these analyses increases confidence in the result.

---

### 4. Logistics & Delivery Analysis

Delivery performance is analyzed using order and customer location information.

Key metrics include:

- Average delivery duration
- Late-delivery percentage
- Regional delivery performance
- State-level comparison

The overall average delivery time is approximately **12.5 days**, with an overall late-delivery rate of around **8%**.

However, delivery performance varies significantly across Brazilian states, with some regions experiencing late-delivery rates several times higher than others.

Low-volume states are filtered before ranking regional performance to prevent small sample sizes from producing misleading results.

---

## 🧠 SQL Techniques Demonstrated

The project uses advanced SQL techniques commonly used in data analytics.

### Multi-table JOINs

Data is combined across multiple relational tables, including:

```sql
orders
order_items
products
customers
order_reviews
```

### Common Table Expressions

CTEs are used to divide complex analytical logic into readable steps.

### Date Analysis

DuckDB date functions are used for:

- Monthly aggregation
- Delivery duration
- Cohort month calculations

Examples include:

```sql
DATE_TRUNC()
DATE_DIFF()
```

### Window Functions

`LAG()` is used to calculate Month-over-Month growth.

### Aggregation

The project uses:

```sql
GROUP BY
HAVING
COUNT()
SUM()
AVG()
```

to create business-level metrics.

---

## 📁 Project Structure

```text
05-olist-ecommerce-dashboard/
│
├── data/
│   ├── *.csv
│   └── olist.duckdb
│
├── app.py
├── db.py
├── download_data.py
├── load_to_duckdb.py
├── queries.sql
├── analysis.ipynb
├── requirements.txt
└── README.md
```

### File Description

| File | Purpose |
|---|---|
| `download_data.py` | Downloads the dataset |
| `load_to_duckdb.py` | Performs the ETL process |
| `olist.duckdb` | Persistent analytical database |
| `queries.sql` | Contains analytical SQL queries |
| `db.py` | Handles DuckDB connection and query execution |
| `analysis.ipynb` | Detailed analysis and visualizations |
| `app.py` | Interactive Streamlit dashboard |
| `requirements.txt` | Project dependencies |

---

## 🚀 How to Run

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd <repository-name>
```

### 2. Create a virtual environment

```bash
python -m venv .venv
```

Activate it:

**macOS / Linux**

```bash
source .venv/bin/activate
```

**Windows**

```bash
.venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Download the dataset

```bash
python download_data.py
```

This downloads the raw Olist CSV files into the `data/` directory.

### 5. Run the ETL pipeline

```bash
python load_to_duckdb.py
```

This creates:

```text
data/olist.duckdb
```

### 6. Explore the analysis

```bash
jupyter notebook analysis.ipynb
```

### 7. Launch the dashboard

```bash
streamlit run app.py
```

---

## 💡 Key Business Insights

### 📌 Growth is primarily acquisition-driven

Although the marketplace generates substantial sales volume, only around **3% of customers make another purchase**.

This suggests that increasing customer retention and repeat purchasing could represent a significant business opportunity.

### 📌 Revenue is concentrated in specific categories

A relatively small number of product categories contribute a significant share of overall revenue, with Health & Beauty, Watches & Gifts, and Bed, Bath & Table among the strongest performers.

### 📌 Logistics performance varies by geography

Overall delivery performance appears reasonable, but state-level analysis reveals considerable variation in late-delivery rates.

This indicates that logistics optimization should consider **regional characteristics rather than relying only on marketplace-wide averages**.

---

## 🎯 Skills Demonstrated

This project demonstrates practical experience in:

- Data Cleaning & Preparation
- ETL Pipeline Development
- Relational Data Modeling
- SQL Analytics
- Multi-table JOINs
- CTEs
- Window Functions
- Time-Series Analysis
- KPI Development
- Customer Retention Analysis
- Cohort Analysis
- Data Visualization
- Business Intelligence
- Dashboard Development
- Python
- DuckDB
- Streamlit
- Plotly

---

## 🔍 What This Project Demonstrates

Rather than analyzing a single flat dataset, this project demonstrates the ability to work with **real-world relational data** and convert it into business insights.

The workflow covers the complete analytics lifecycle:

**Raw Data → ETL → Database → SQL Analysis → KPIs → Customer Analytics → Visualization → Business Insights**

This makes the project suitable as a portfolio example for **Data Analyst, Business Analyst, and Junior Data Scientist roles**.

---

## 📌 Future Improvements

Potential extensions include:

- Customer Lifetime Value (CLV) analysis
- Customer segmentation using RFM
- Seller performance analysis
- Payment-method analysis
- Review-score sentiment analysis
- Predictive delivery-delay modeling
- Customer churn prediction
- Automated dashboard refresh
- Cloud database deployment
- Advanced Power BI / Tableau version

---

## 📜 Dataset Attribution

Dataset: **Brazilian E-Commerce Public Dataset by Olist**

The dataset is publicly available through Kaggle and is used for educational and analytical purposes.