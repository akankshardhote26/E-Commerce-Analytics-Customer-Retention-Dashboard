# Olist E-Commerce Analytics & Customer Retention Dashboard

**Python · SQL · Power BI · DAX · Customer Analytics · RFM Segmentation**

A data analyst portfolio project that transforms Brazilian e-commerce data into a five-page Power BI report covering sales, customer retention, product performance, delivery reliability, and customer value. The project connects data preparation and KPI development with interactive reporting to support business analysis.

## Project Overview

E-commerce teams need to understand both revenue performance and the customer experience behind it. This project brings commercial, customer, and logistics analysis into one report, helping users investigate purchasing patterns, identify valuable customer groups, and explore opportunities to improve retention and delivery performance.

## Power BI Dashboard Screenshots

Five report pages present sales, retention, product, delivery, and customer-segmentation analysis. Click an image to view it at full resolution.

### 1. Executive Sales Overview

[![Executive Sales Overview](screenshots/01_executive_sales_overview.png)](screenshots/01_executive_sales_overview.png)

### 2. Customer Retention & Cohort Analysis

[![Customer Retention & Cohort Analysis](screenshots/02_customer_retention_cohort.png)](screenshots/02_customer_retention_cohort.png)

### 3. Product & Payment Analysis

[![Product & Payment Analysis](screenshots/03_product_payment_analytics.png)](screenshots/03_product_payment_analytics.png)

### 4. Geographic Sales & Delivery Performance

[![Geographic Sales & Delivery Performance](screenshots/04_geographic_delivery.png)](screenshots/04_geographic_delivery.png)

### 5. Customer Segmentation & RFM Analysis

[![Customer Segmentation & RFM Analysis](screenshots/05_customer_rfm_segmentation.png)](screenshots/05_customer_rfm_segmentation.png)

## Business Questions

- How do revenue, order volume, and average order value change over time?
- How does customer retention vary across acquisition cohorts?
- Which product categories and payment methods contribute to sales?
- Which states have the weakest on-time delivery performance?
- How are customers distributed across RFM segments?
- Which customer segments contribute the most revenue and offer reactivation opportunities?

## Dataset

| Attribute | Description |
| --- | --- |
| Dataset | Olist Brazilian E-Commerce Public Dataset |
| Source | Kaggle — Olist |
| Coverage | Approximately 100,000 orders in the original dataset |
| Source structure | Nine CSV files covering orders, customers, items, products, sellers, payments, reviews, geolocation, and category translations |
| Currency | Brazilian real (R$) |
| Project use | Historical analysis and educational portfolio development |

Source record counts differ from the final analytical population after filtering and preparation. Report totals depend on the order-status rules and filters applied.

## Tools and Analytical Skills

| Tool | Application |
| --- | --- |
| Python / Pandas | Data preparation, transformation, and creation of analytical tables |
| SQL | Relational querying, joins, aggregation, and business analysis |
| Excel workbook | Prepared tabular input for the Power BI workflow |
| Power BI Service | Semantic model development and interactive report creation |
| DAX | KPI measures, calculated tables, customer scoring, and filter-aware calculations |

## Analytical Workflow

1. Prepare source data and align identifiers, dates, and numeric fields.
2. Combine relevant order, customer, product, payment, and geographic information at the required level of detail.
3. Create analytical outputs for sales, cohorts, delivery performance, and customer purchasing behavior.
4. Build the Power BI semantic model and reusable DAX measures.
5. Create a customer-level RFM snapshot from delivered orders.
6. Design five report pages with KPI cards, charts, tooltips, and slicers.
7. Review metric definitions, aggregation levels, and visual interactions before interpreting results.

## Dashboard Pages

| Page | Analytical focus | Business purpose |
| --- | --- | --- |
| **1. Executive Sales Overview** | Revenue, orders, customers, average order value, and sales trends | Monitor overall commercial performance |
| **2. Customer Retention & Cohort Analysis** | Customer retention and cohort purchasing patterns | Explore repeat purchasing and retention opportunities |
| **3. Product & Payment Analysis** | Product-category performance and payment behavior | Compare sales contributions and purchasing preferences |
| **4. Geographic Sales & Delivery Performance** | Geographic order distribution, state comparisons, on-time delivery, and delivery duration | Identify regional logistics priorities |
| **5. Customer Segmentation & RFM Analysis** | Customer distribution, segment revenue, recency versus frequency, and customer-value indicators | Support retention and reactivation planning |

### Interactive Features

- Slicers for exploring relevant report dimensions, including customer segment.
- Ranked charts for comparing categories, regions, and customer groups.
- Tooltips with supporting revenue, customer-count, and RFM metrics.
- Customer-level scatter analysis using recency, frequency, and spending.
- Consistent currency, percentage, and numeric formatting across report pages.

## Key Metric Definitions

| Metric | Definition |
| --- | --- |
| Total Orders | Distinct order IDs within the relevant analytical population |
| Total Customers | Distinct `customer_unique_id` values within the relevant population |
| Average Order Value | Revenue divided by distinct orders, using the same population and revenue definition |
| Average Customer Spend | Revenue divided by distinct customers |
| Average Orders per Customer | Distinct orders divided by distinct customers |
| On-Time Delivery Rate | Delivered orders received on or before the estimated delivery date, divided by eligible delivered orders |
| Average Delivery Days | Average elapsed days from purchase to customer delivery for eligible delivered orders |
| Average Late Delivery Days | Average days beyond the estimated delivery date for late delivered orders only |
| Total RFM Revenue | Sum of customer-level `Monetary` values in the RFM snapshot |
| High-Value Customers | Customers with a monetary score of 4 or 5 |

Revenue comparisons must use the same source amount and order population. Item revenue, freight-inclusive amounts, and payment totals are different definitions and should not be used interchangeably.

## Customer Segmentation Methodology

`CustomerSegments` contains order-level purchasing information. A separate calculated table, `CustomerRFM`, summarizes delivered orders into one row per `customer_unique_id`.

| RFM metric | Calculation |
| --- | --- |
| **Recency** | Days between the customer's most recent delivered-order purchase and the reference date |
| **Frequency** | Distinct delivered orders per customer |
| **Monetary** | Total recorded revenue from delivered orders per customer |

The RFM reference date is **30 August 2018**, aligned between SQL and Power BI. This anchors the analysis to the historical dataset rather than today's date.

### Scoring Rules

| Score | Recency | Frequency |
| --- | --- | --- |
| 5 | Up to 30 days | 5 or more orders |
| 4 | 31–60 days | 4 orders |
| 3 | 61–90 days | 3 orders |
| 2 | 91–180 days | 2 orders |
| 1 | More than 180 days | 1 order |

Monetary scores use ascending dense ranks over distinct spending amounts, scaled to a 1–5 score. Equal spending amounts receive equal scores; groups are not necessarily equal in customer count. The total RFM score is the sum of the three scores and ranges from 3 to 15 for valid records.

### Customer Segments

Rules are evaluated in the order shown; the first matching rule determines the segment.

| Segment | Rule | Potential business application |
| --- | --- | --- |
| Champions | R ≥ 4, F ≥ 4, and M ≥ 4 | Explore recognition and premium retention offers |
| Loyal Customers | R ≥ 3 and F ≥ 3 | Encourage continued engagement and relevant cross-selling |
| Potential Loyalists | R ≥ 4 and F ≤ 2 | Encourage a second or subsequent purchase |
| At Risk | R ≤ 2 and F ≥ 3 | Prioritize investigation and reactivation outreach |
| Hibernating | R ≤ 2 and F ≤ 2 | Assess selective win-back opportunities |
| Regular Customers | Remaining valid combinations | Explore behavior before choosing a campaign |

These are rule-based analytical labels rather than machine-learning clusters. Suggested actions are hypotheses for further testing, not measured campaign outcomes. Inactivity is relative to the dataset reference date.

## Selected DAX Measures

### RFM Customer Count

```dax
Total RFM Customers =
DISTINCTCOUNT(CustomerRFM[customer_unique_id])
```

### Revenue and Average Customer Spend

```dax
Total RFM Revenue =
SUM(CustomerRFM[Monetary])
```

```dax
RFM Avg Spend per Customer =
DIVIDE(
    [Total RFM Revenue],
    [Total RFM Customers],
    0
)
```

### Revenue Contribution by Segment

```dax
RFM Revenue Contribution % =
DIVIDE(
    [Total RFM Revenue],
    CALCULATE(
        [Total RFM Revenue],
        REMOVEFILTERS(CustomerRFM[Customer_Segment])
    ),
    0
)
```

The denominator removes the segment filter while preserving other active filters. With a segment slicer applied, displayed segment shares may total less than 100% because the denominator includes all segments allowed by the remaining filters.

## Data Quality and Interpretation

- **Customer identity:** Use `customer_unique_id` for repeat-customer analysis. Order-associated customer IDs should not be treated as persistent customer identities.
- **Join granularity:** Items, payments, and reviews can introduce multiple records per order. Aggregate at the intended grain before joining to avoid duplicated revenue.
- **RFM input:** Customer-level monetary totals rely on `CustomerSegments` containing revenue once per order. This assumption should be reconciled against the source data.
- **Order population:** RFM uses delivered orders. Its revenue and customer totals can differ from report pages that include other statuses.
- **Snapshot behavior:** `CustomerRFM` is computed at model refresh. A date slicer does not dynamically recalculate its recency, frequency, monetary values, or segment assignments.
- **Filter propagation:** A slicer on `CustomerRFM` filters its own visuals. Filtering other tables depends on configured model relationships and interaction settings.
- **Purchase frequency:** Many customers make only one purchase. Overlap around frequency 1 in the scatter chart is expected.
- **Delivery analysis:** Exclude missing or invalid delivery dates consistently when defining eligible orders.

The six RFM segment counts were reconciled exactly between SQL and Power BI: Hibernating 74,799; Potential Loyalists 12,337; Regular Customers 5,994; At Risk 169; Loyal Customers 50; Champions 9 — totaling 93,358 customers. Other cross-page comparisons require consistent order populations and metric definitions.

## Business Value

The report provides a framework for identifying revenue drivers, exploring customer retention, prioritizing regional delivery investigations, and developing customer engagement hypotheses. It demonstrates how a data analyst can translate transaction data into understandable metrics and actionable questions without claiming unmeasured business improvements.

## How to Explore the Project

1. Review the data preparation code and SQL queries provided in the repository.
2. Review the prepared analytical tables and measure definitions to understand the reporting logic.
3. Open the Power BI report using a shared report link, or a `.pbix` file if one is provided.
4. Start with the Executive Sales Overview and continue through retention, products, logistics, and RFM analysis.
5. Apply filters to explore specific groups, and clear them before comparing overall totals.

Power BI report access depends on the sharing permissions configured by the author. If no report link or export is available, dashboard screenshots can provide a static walkthrough.

## Skills Demonstrated

- Data cleaning, transformation, and relational analysis with Python and SQL.
- KPI definition and awareness of order-level versus customer-level data.
- DAX measures, calculated columns, and calculated tables.
- Customer retention, cohort analysis, and RFM segmentation.
- Product, payment, geographic, and delivery performance analysis.
- Interactive dashboard design and business communication.
- Documentation of assumptions, metric definitions, and analytical limitations.

## Future Improvements

- Add an interactive report-access link alongside the dashboard screenshots.
- Document the final source-to-model mapping and complete DAX measure catalog.
- Complete reconciliation of revenue, order counts, customer counts, and delivery metrics.
- Compare alternative RFM thresholds and assess segment stability.
- Extend the snapshot approach to support historical segment comparisons.
- Evaluate retention recommendations through controlled campaign experiments.

## Author

**Akanksha Rajendra Dhote**  
Data Analytics | Python | SQL | Power BI  
[GitHub Profile](https://github.com/akankshardhote26)

## Acknowledgments

This educational portfolio project uses the Olist Brazilian E-Commerce Public Dataset distributed on Kaggle. Credit belongs to Olist and the original data contributors. Refer to the dataset's original terms before redistributing source files.
