[README.md](https://github.com/user-attachments/files/32020004/README.md)
# Sales Performance Analysis

An end-to-end sales analytics project: raw data → SQL cleaning → SQL analysis → interactive Power BI dashboard.

**Tools:** MySQL and Power BI Desktop

---

## Repository Structure

```text
/data
  /raw          → customers.csv, orders.csv, products.csv (as originally sourced)
  /clean        → customers_clean.csv, orders_clean.csv, products_clean.csv (post-SQL cleaning)
/sql
  01_create_database.sql
  02_import_data.sql
  03_data_cleaning.sql
  04_sql_analysis_queries.sql
/screenshots
  /sql_results              → phpMyAdmin proof of each analysis query running
  /dax_measures             → every DAX measure/column, as written in Power BI
  /page1_overview           → build process, Page 1
  /page2_products           → build process, Page 2
  /page3_customers          → build process, Page 3
  /page4_discount_shipping  → build process, Page 4
README.md
```

---

## 1. Database Setup

**[`sql/01_create_database.sql`](sql/01_create_database.sql)** creates the `sales_performance` database.

**[`sql/02_import_data.sql`](sql/02_import_data.sql)** imports the data. `customers` and `products` were imported directly; `orders` required a manually-scripted `CREATE TABLE` + `INSERT INTO` because the raw `order_date` values (`M/D/YYYY`) weren't in a format MySQL's `DATE` type would accept on import - so `order_date` was temporarily typed as `VARCHAR` and corrected later during cleaning.

---

## 2. Data Cleaning

Full process documented in **[`sql/03_data_cleaning.sql`](sql/03_data_cleaning.sql)**. Summary of what was found and fixed:

| Table                    | Issue found                                             | Fix                                                                                         |
| ------------------------ | ------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `orders`                 | Negative values in `quantity`                           | Updated to `ABS(quantity)`                                                                  |
| `orders`                 | NULL values in `sales`                                  | Recalculated as `ROUND(quantity * unit_price * (1 - discount), 2)` via join to `products`   |
| `orders`                 | `order_date` stored as text, wrong format (`M/D/YYYY`)  | Converted with `STR_TO_DATE()`, column altered to `DATE`                                    |
| `orders`                 | Duplicate rows (2,201 → 2,001)                          | Added an auto-increment `row_id`, then deleted exact duplicates keeping the lowest `row_id` |
| `customers`              | 8 empty strings in `city`                               | Converted to `NULL`                                                                         |
| `customers` / `products` | Possible duplicate IDs or misspelled categorical values | Checked via `GROUP BY … HAVING COUNT(*) > 1` and `DISTINCT` - none found                    |
| `products`               | Negative `unit_cost` / `unit_price`                     | Checked - none found                                                                        |

A manual review was also done on top of the SQL checks, given the dataset's small size, to confirm no remaining nulls, blanks, duplicates, or spelling inconsistencies.

Cleaned data is all in the resective folder (the individual files are written the same as the raw)

---

## 3. SQL Analysis

Six core queries in **[`sql/04_sql_analysis_queries.sql`](sql/04_sql_analysis_queries.sql)**, each verified directly in phpMyAdmin/MySQL:

| Query                                   | Result screenshot                                                                                                                                        |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Overall KPIs                            | [`SQL_Analysis_KPI.png`](SQL/SQL_Analysis_Queries_Photos/SQL_Analysis_KPI.png)                                                                           |
| Monthly sales & profit                  | [`SQL_Analysismonthly_sales_profit.png`](SQL/SQL_Analysis_Queries_Photos/SQL_Analysismonthly_sales_profit.png)                                           |
| Sales/profit by category & sub-category | [`SQL_Analysis_Sales-Profit_by_Category_and_SubCategory.png`](SQL/SQL_Analysis_Queries_Photos/SQL_Analysis_Sales-Profit_by_Category_and_SubCategory.png) |
| Sales/profit/orders by region & state   | [`SQL_Analysis_Sales-Profit_Orders_by_Region_and_State.png`](SQL/SQL_Analysis_Queries_Photos/SQL_Analysis_Sales-Profit_Orders_by_Region_and_State.png)   |
| Top 10 products by sales                | [`SQL_Analysis_Top_10_Products.png`](SQL/SQL_Analysis_Queries_Photos/SQL_Analysis_Top_10_Products.png)                                                   |
| Year-over-year comparison by month      | [`SQL_Analysis_YoY_Comparison_by_Month.png`](SQL/SQL_Analysis_Queries_Photos/SQL_Analysis_YoY_Comparison_by_Month.png)                                   |

**Headline numbers (verified in phpMyAdmin):**

* 2,001 orders across 250 customers
* $3,242,658.73 total sales
* $1,063,189.56 total profit
* 32.79% profit margin
* $1,620.52 average order value

---

## 4. Power BI Dashboard

Four pages, built on the cleaned data, with `Order Date`, `Category`, and `Segment` slicers synced across all pages so filtering on one page carries through the others.

### Core DAX Measures

| Measure         | Formula                                                         | Screenshot                                                                                                              |
| --------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Total Sales     | `SUM(orders[sales])`                                            | [Total_Sales_DAX.png](powerbi/DAX_Measures/Total_Sales_DAX.png)                                                         |
| Total Profit    | `SUM(orders[profit])`                                           | [Total_Profit_DAX.png](powerbi/DAX_Measures/Total_Profit_DAX.png)                                                       |
| Profit Margin % | `DIVIDE([Total Profit],[Total Sales],0)`                        | [Profit_Margin_DAX.png](powerbi/DAX_Measures/Profit_Margin_DAX.png)                                                     |
| Total Orders    | `DISTINCTCOUNT(orders[order_id])`                               | [Total_Orders_DAX.png](powerbi/DAX_Measures/Total_Orders_DAX.png)                                                       |
| Avg Order Value | `DIVIDE([Total Sales],[Total Orders],0)`                        | [Average_Order_Value_DAX.png](powerbi/DAX_Measures/Average_Order_Value_DAX.png)                                         |
| Discount Band   | `SWITCH(TRUE(), .)` grouping discount into bands                | [18_Page4_Discount_Band_DAX.png](powerbi/Visual_Process/18_Page4_Discount_Band_DAX.png)                                 |
| Customer Status | `VAR FirstOrderDate = CALCULATE(MIN(order_date), ALLEXCEPT(…))` | [15_DAX_Measure_for_New-Returning_Customers.png](powerbi/Visual_Process/15_DAX_Measure_for_New-Returning_Customers.png) |
| Avg Ship Days   | `AVERAGEX(orders, DATEDIFF(order_date, ship_date, DAY))`        | [20_Avg_Ship_Days_DAX.png](powerbi/Visual_Process/20_Avg_Ship_Days_DAX.png)                                             |

→ flags each order as the customer's first order or a repeat

---

### Page 1 - Executive Overview

KPI cards, monthly sales & profit trend, sales/profit by region.

**Build process:**

1. Title added - [`1_title.png`](powerbi/Visual_Process/1_title.png)
2. KPI cards added one at a time - [`2_adding_kpi.png`](powerbi/Visual_Process/2_adding_kpi.png)
3. Adding Slicers to make dashboard more interactive - [`3_adding_slicers(timeline,categories,segments).png`](powerbi/Visual_Process/3_adding_slicers%28timeline,categories,segments%29.png)
4. Line Chart showcasing total profit and sales by year and month - [`4_Line_Chart.png`](powerbi/Visual_Process/4_Line_Chart.png)
5. Regional Cluster Bar across four regions - [`5_clustered_bar_chart.png`](powerbi/Visual_Process/5_clustered_bar_chart.png)
6. Page 1 Final edits, card borders added, correct overall formatting, line smoothing turned off for line chart  [`6_Final_Edits_for_Page_1`](powerbi/Visual_Process/6_Final_Edits_for_Page_1)

**Key findings:**

* $3.24M total sales, $1.06M profit, 32.79% profit margin, $1,620.52 average order value
* Clear upward trend in sales and profit from 2023 to 2025, with recurring month-to-month volatility
* West region leads all regions in both sales ($1.13M) and profit; South trails

---

### Page 2 - Product Performance

Sales by sub-category, top 10 products by sales, bottom 10 products by profit margin.

**Build process:**

1. Adding Clustered Bar Chart that showcases total sales and profit by sub-category and category [`7_Page2_ClusteredBarChart.png`](powerbi/Visual_Process/7_Page2_ClusteredBarChart.png)
2. X-axis value fix so that it better represents the range of values [`8_Page2_ClusteredBarChart_edit_for_x-axis.png`](powerbi/Visual_Process/8_Page2_ClusteredBarChart_edit_for_x-axis.png)
3. Top 10 products by sales, showing the filter - [`9_Page2_Top10_by_Sales_Bar_Chart.png`](powerbi/Visual_Process/9_Page2_Top10_by_Sales_Bar_Chart.png)
4. Bottom 10 by profit margin, built using a Top N filter of Bottom 10 by `Profit Margin %` - [`10_Page2_Bottom10_by_Profit_Margin_Bar_Chart.png`](powerbi/Visual_Process/10_Page2_Bottom10_by_Profit_Margin_Bar_Chart.png)
5. Final Page 2 Edits, added slicers similar to page1,borders, data labels and category-based color coding across all charts - [`08_final.png`](powerbi/Visual_Process/08_final.png)

**Key findings:**

* Tables ($519K) and Accessories ($516K) are the top two sub-categories by sales; every Office Supplies sub-category sits at the bottom
* Laptop Stand is the single best-selling product ($306K)
* Ladder Bookcase and Folding Table appear in both the Top 10 by sales *and* the Bottom 10 by margin - high-revenue products that are comparatively low-profit (19.2% and 25.8% margin respectively)

---

### Page 3 - Customer Insights

Sales by segment, top 10 customers by lifetime sales, new vs. returning customer revenue by month.

**Build process:**

1. Donut chart built - [`12_Page3_Donut_Chart.png`](powerbi/Visual_Process/12_Page3_Donut_Chart.png)
2. Added different colors to help differentiate from Page 2's category colors - [`13_Page3_Donut_Color_Change.png`](powerbi/Visual_Process/13_Page3_Donut_Color_Change.png)
3. Top 10 customers by Lifetime sales chart built, - [`14_Top10_Customers_by_Lifetime_Sales_Chart.png`](powerbi/Visual_Process/14_Top10_Customers_by_Lifetime_Sales_Chart.png)
4. Added new  measure to help customer status(new vs returning) data label - [`15_DAX_Measure_for_New_Returning_Customers.png`](powerbi/Visual_Process/15_DAX_Measure_for_New_Returning_Customers.png)
5. New vs. Returning stacked column chart built, using the `Customer Status` measure (redefined mid-build from "ordered in signup month" to "customer's first order ever," since the original definition produced a near-zero "New" share) - [`16_New_vs_Returning_StackedBarChart.png`](powerbi/Visual_Process/16_New_vs_Returning_StackedBarChart.png)
6. Adding onto step 5, I had to make sure the chart was displaying the information in the correct order. Do to this, I had to simply change the axis setting to sort by ascending
7. Final Page 3 Edits, added corresponding slicers to the information needed, borders and data labels here possible — [`10_final.png`](powerbi/Visual_Process/10_final.png)

**Key findings:**

* The consumer segment drives 57.8% of total sales ($1.87M) - more than Corporate (25.8%) and Home Office (16.4%) combined
* Despite that, the top 10 individual customers by lifetime spend are fairly evenly split across all three segments
* Early 2023 revenue was effectively 100% from new customers; by 2024-2025, returning customers account for the large majority of monthly revenue. This shows a healthy retention signal

---

### Page 4 - Discount & Shipping

Profit margin by discount band, average shipping time by ship mode, sales & margin by ship mode.

**Build process:**

1. Need to add a new measure to help create the Discount Band Chart [`18_Page4_Discount_Band_DAX.png`](powerbi/Visual_Process/18_Page4_Discount_Band_DAX.png)
2. Discount Band chart built - [`19_discount_band_column_chart.png`](powerbi/Visual_Process/19_discount_band_column_chart.png)
3. New measure to calculate average shipping days [`20_Average_Ship_Days_DAX.png`](powerbi/Visual_Process/20_Average_Ship_Days_DAX.png)
4. Average Shipping Time chart built - [`21_average_shipping_time_bar_chart.png`](powerbi/Visual_Process/21_average_shipping_time_bar_chart.png)
5. Combo chart (Total Sales + Profit Margin % by ship mode) built - [`22_Total_Sales_Profit_Margin_Line_and_Stacked_Column.png`](powerbi/Visual_Process/22_Total_Sales_Profit_Margin_Line_and_Stacked_Column.png)
6. Bar color changed to match Total Sales' color in the dashboard
7. Rearranged so the combo chart spans full width for better readability - seen in the final png below
8. Final Page 4 Edits,added slicers, borders and data labels - [`23_Page4_FinalEdits.png`](powerbi/Visual_Process/23_Page4_FinalEdits.png)

**Key findings:**

* Profit margin declines steadily as discount increases: 36.0% with no discount → 31.2% at 1-10% discount → 23.7% at 11-20% discount
* Average shipping time (≈3.96-4.19 days) and profit margin (≈32.2-33.1%) are both essentially flat across all four ship modes - shipping speed does not measurably affect delivery time or profitability in this dataset
* Standard Class accounts for the large majority of order volume ($1.91M of $3.24M total sales)

---

## Tools & Skills Demonstrated

* **SQL**: database/table creation, manual data import with format handling, systematic data cleaning (nulls, duplicates, negative values, type conversion), joins, aggregation, `CASE`/`SWITCH` logic
* **Power BI**: data modeling, DAX measures & calculated columns (including `ALLEXCEPT`/`CALCULATE` window-style logic), multi-page interactive dashboards, synced slicers, dual-axis combo charts, custom formatting
* **Debugging**: diagnosed and resolved a text-typed numeric column, a hidden visual-level filter silently dropping categories, an incorrect chart sort order, and a data label readability issue - each caught by comparing the dashboard against the verified SQL results
