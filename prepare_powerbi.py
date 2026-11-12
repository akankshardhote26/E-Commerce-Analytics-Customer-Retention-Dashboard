
from pathlib import Path
import pandas as pd

DATA = Path("data")

files = {
    "orders": "olist_orders_dataset.csv",
    "items": "olist_order_items_dataset.csv",
    "customers": "olist_customers_dataset.csv",
    "products": "olist_products_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "categories": "product_category_name_translation.csv"
}

tables = {}

for name, filename in files.items():
    tables[name] = pd.read_csv(DATA / filename)
    print(f"{name}: {len(tables[name]):,} rows")

print("\nAll nine CSV files loaded successfully!")


orders = tables["orders"].copy()

items = tables["items"].groupby(
    "order_id", as_index=False
).agg(
    revenue=("price", "sum"),
    freight_cost=("freight_value", "sum"),
    item_count=("order_item_id", "count")
)

payments = tables["payments"].groupby(
    "order_id", as_index=False
).agg(
    payment_total=("payment_value", "sum")
)

reviews = tables["reviews"].groupby(
    "order_id", as_index=False
).agg(
    review_score=("review_score", "mean")
)

df = orders.merge(
    tables["customers"],
    on="customer_id",
    how="left",
    validate="many_to_one"
)

df = df.merge(
    items, on="order_id",
    how="left",
    validate="one_to_one"
)

df = df.merge(
    payments, on="order_id",
    how="left",
    validate="one_to_one"
)

df = df.merge(
    reviews, on="order_id",
    how="left",
    validate="one_to_one"
)

dates = [
    "order_purchase_timestamp",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

for col in dates:
    df[col] = pd.to_datetime(df[col], errors="coerce")

df["purchase_month"] = (
    df["order_purchase_timestamp"]
    .dt.to_period("M").astype(str)
)

df["delivery_days"] = (
    df["order_delivered_customer_date"]
    - df["order_purchase_timestamp"]
).dt.total_seconds() / 86400

df["on_time_delivery"] = (
    df["order_delivered_customer_date"]
    <= df["order_estimated_delivery_date"]
)

df["revenue"] = df["revenue"].fillna(0)
df["freight_cost"] = df["freight_cost"].fillna(0)

assert df["order_id"].is_unique
assert len(df) == len(orders)

df.to_csv(
    "ecommerce_orders_powerbi.csv",
    index=False
)

print("Order-level analytics table created!")
print("Rows:", len(df))
print("Columns:", len(df.columns))



# PRODUCT AND CATEGORY ANALYTICS

product_items = tables["items"].merge(
    tables["products"],
    on="product_id",
    how="left",
    validate="many_to_one"
)

product_items = product_items.merge(
    tables["categories"],
    on="product_category_name",
    how="left",
    validate="many_to_one"
)

product_items = product_items.merge(
    tables["orders"][
        ["order_id", "order_status", "order_purchase_timestamp"]
    ],
    on="order_id",
    how="left",
    validate="many_to_one"
)

product_items["category"] = (
    product_items["product_category_name_english"]
    .fillna("Unknown")
)

product_items["order_purchase_timestamp"] = pd.to_datetime(
    product_items["order_purchase_timestamp"]
)

product_items["purchase_month"] = (
    product_items["order_purchase_timestamp"]
    .dt.to_period("M")
    .astype(str)
)

# Use delivered orders for completed-sales analysis
product_items = product_items[
    product_items["order_status"] == "delivered"
].copy()

product_items.to_csv(
    "ecommerce_products_powerbi.csv",
    index=False
)

print("Product analytics table created!")
print("Rows:", len(product_items))



# STEP 3: CUSTOMER COHORT RETENTION ANALYSIS

customer_orders = tables["orders"].merge(
    tables["customers"][
        ["customer_id", "customer_unique_id"]
    ],
    on="customer_id",
    how="left",
    validate="many_to_one"
)

# Use delivered orders for completed purchases
customer_orders = customer_orders[
    customer_orders["order_status"] == "delivered"
].copy()

customer_orders["order_purchase_timestamp"] = pd.to_datetime(
    customer_orders["order_purchase_timestamp"],
    errors="coerce"
)

customer_orders = customer_orders.dropna(
    subset=["customer_unique_id", "order_purchase_timestamp"]
)

customer_orders["purchase_period"] = (
    customer_orders["order_purchase_timestamp"].dt.to_period("M")
)

# Find each customer's first purchase month
customer_orders["cohort_period"] = (
    customer_orders.groupby("customer_unique_id")[
        "purchase_period"
    ].transform("min")
)

# Months elapsed since first purchase
customer_orders["cohort_index"] = (
    (customer_orders["purchase_period"].dt.year -
     customer_orders["cohort_period"].dt.year) * 12
    + (customer_orders["purchase_period"].dt.month -
       customer_orders["cohort_period"].dt.month)
)

# Count distinct active customers by cohort and month
cohort = customer_orders.groupby(
    ["cohort_period", "cohort_index"]
)["customer_unique_id"].nunique().reset_index(
    name="active_customers"
)

# Initial cohort size
cohort_sizes = cohort[
    cohort["cohort_index"] == 0
][["cohort_period", "active_customers"]].rename(
    columns={"active_customers": "cohort_size"}
)

cohort = cohort.merge(
    cohort_sizes,
    on="cohort_period",
    how="left"
)

cohort["retention_rate"] = (
    cohort["active_customers"] / cohort["cohort_size"]
)

cohort["cohort_month"] = cohort["cohort_period"].astype(str)

cohort = cohort[
    ["cohort_month", "cohort_index",
     "active_customers", "cohort_size", "retention_rate"]
]

cohort.to_csv(
    "ecommerce_cohort_powerbi.csv",
    index=False
)

print("Cohort retention dataset created!")
print("Rows:", len(cohort))
print(cohort.head(10))



# STEP 4: PAYMENT, SELLER AND GEOGRAPHIC ANALYTICS

# 1. PAYMENT ANALYTICS
payment_data = tables["payments"].merge(
    tables["orders"][
        ["order_id", "order_status",
         "order_purchase_timestamp"]
    ],
    on="order_id",
    how="left",
    validate="many_to_one"
)

payment_data = payment_data[
    payment_data["order_status"] == "delivered"
].copy()

payment_data["purchase_month"] = (
    pd.to_datetime(
        payment_data["order_purchase_timestamp"]
    ).dt.to_period("M").astype(str)
)

payment_data.to_csv(
    "ecommerce_payments_powerbi.csv",
    index=False
)

print("Payment analytics dataset created!")


# 2. SELLER ANALYTICS
seller_data = tables["items"].merge(
    tables["sellers"],
    on="seller_id",
    how="left",
    validate="many_to_one"
)

seller_data = seller_data.merge(
    tables["orders"][
        ["order_id", "order_status",
         "order_purchase_timestamp"]
    ],
    on="order_id",
    how="left",
    validate="many_to_one"
)

seller_data = seller_data[
    seller_data["order_status"] == "delivered"
].copy()

seller_data["purchase_month"] = (
    pd.to_datetime(
        seller_data["order_purchase_timestamp"]
    ).dt.to_period("M").astype(str)
)

seller_data.to_csv(
    "ecommerce_sellers_powerbi.csv",
    index=False
)

print("Seller analytics dataset created!")


# 3. GEOGRAPHIC ANALYTICS
# Aggregate geolocation by ZIP prefix to prevent
# duplicate rows when joining to customer locations.

geo = tables["geolocation"].groupby(
    "geolocation_zip_code_prefix",
    as_index=False
).agg(
    latitude=("geolocation_lat", "median"),
    longitude=("geolocation_lng", "median")
)

geographic_data = df.merge(
    geo,
    left_on="customer_zip_code_prefix",
    right_on="geolocation_zip_code_prefix",
    how="left",
    validate="many_to_one"
)

geographic_data = geographic_data[
    geographic_data["order_status"] == "delivered"
].copy()

geographic_data.to_csv(
    "ecommerce_geographic_powerbi.csv",
    index=False
)

print("Geographic analytics dataset created!")

print("\nAll analytics datasets generated!")


# STEP 5: CREATE EXCEL WORKBOOK FOR POWER BI

import pandas as pd

files = {
    "Orders": "ecommerce_orders_powerbi.csv",
    "Products": "ecommerce_products_powerbi.csv",
    "Cohorts": "ecommerce_cohort_powerbi.csv",
    "Payments": "ecommerce_payments_powerbi.csv",
    "Sellers": "ecommerce_sellers_powerbi.csv",
    "Geography": "ecommerce_geographic_powerbi.csv"
}

with pd.ExcelWriter(
    "Ecommerce_PowerBI_Dataset.xlsx",
    engine="openpyxl"
) as writer:

    for sheet_name, filename in files.items():
        data = pd.read_csv(filename)

        data.to_excel(
            writer,
            sheet_name=sheet_name,
            index=False
        )

        print(
            f"{sheet_name}: {len(data):,} rows exported"
        )

print("Excel workbook created successfully!")

# CUSTOMER ORDER TYPE CLASSIFICATION

customer_history = df[
    df["order_status"] == "delivered"
].copy()

customer_history = customer_history.sort_values(
    ["customer_unique_id", "order_purchase_timestamp", "order_id"]
)

customer_history["purchase_number"] = (
    customer_history.groupby("customer_unique_id")
    .cumcount() + 1
)

customer_history["customer_type"] = (
    customer_history["purchase_number"]
    .apply(
        lambda x: "New" if x == 1 else "Returning"
    )
)

customer_history.to_csv(
    "ecommerce_customer_segments_powerbi.csv",
    index=False
)

print("Customer segmentation dataset created!")



# Add CustomerSegments to the Power BI Excel workbook

import pandas as pd

segments = pd.read_csv(
    "ecommerce_customer_segments_powerbi.csv"
)

with pd.ExcelWriter(
    "Ecommerce_PowerBI_Dataset.xlsx",
    engine="openpyxl",
    mode="a",
    if_sheet_exists="replace"
) as writer:
    segments.to_excel(
        writer,
        sheet_name="CustomerSegments",
        index=False
    )

print("CustomerSegments sheet added successfully!")
