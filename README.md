[README.md](https://github.com/user-attachments/files/32030898/README.md)
# Sales Performance Analysis

An end-to-end sales analytics project: raw data → SQL cleaning → SQL analysis → interactive Power BI dashboard.

**Tools:** MySQL and Power BI Desktop

---

## Repository Structure

```text
/data
  /raw          → customers.csv, orders.csv, products.csv (as originally sourced)
  /clean        → customers.csv, orders.csv, products.csv (post-SQL cleaning)
/sql
  01_create_database.sql
  02_import_data.sql
  03_data_cleaning.sql
  04_sql_analysis_queries.sql
  /Analysis Photos   → phpMyAdmin proof of each analysis query running
/powerbi
  /DAX Measures     → every DAX measure/column, as written in Power BI
  /Visual Process   → build process screenshots, Pages 1-4, plus the .pbix file
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

Cleaned data is all in the [`data/clean`](data/clean) folder (the individual files are named the same as the raw versions in [`data/raw`](data/raw)).

---

## 3. SQL Analysis

Six core queries in **[`sql/04_sql_analysis_queries.sql`](sql/04_sql_analysis_queries.sql)**, each verified directly in phpMyAdmin/MySQL:

| Query                                   | Result screenshot                                                                                                                                                             |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Overall KPIs                            | [SQL_Analysis_KPI.png](sql/Analysis%20Photos/SQL_Analysis_KPI.png)                                                                                             |
| Monthly sales & profit                  | [SQL_Analysis_MonthlySales-Profit.png](sql/Analysis%20Photos/SQL_Analysis_MonthlySales-Profit.png)                                                             |
| Sales/profit by category & sub-category | [SQL_Analysis_Sales-Profit by Category and SubCategory.png](<sql/Analysis%20Photos/SQL_Analysis_Sales-Profit%20by%20Category%20and%20SubCategory.png>)           |
| Sales/profit/orders by region & state   | [SQL_Analysis_Sales-Profit-Orders by Region and State.png](<sql/Analysis%20Photos/SQL_Analysis_Sales-Profit-Orders%20by%20Region%20and%20State.png>)             |
| Top 10 products by sales                | [SQL_Analysis_Top 10 Products.png](<sql/Analysis%20Photos/SQL_Analysis_Top%2010%20Products.png>)                                                                 |
| Year-over-year comparison by month      | [SQL_Analysis_YoY comparion by Month.png](<sql/Analysis%20Photos/SQL_Analysis_YoY%20comparion%20by%20Month.png>)                                                 |

**Headline numbers (verified in phpMyAdmin):**

* 2,001 orders across 250 customers
* $3,242,658.73 total sales
* $1,063,189.56 total profit
* 32.79% profit margin
* $1,620.52 average order value

---

## 4. Power BI Dashboard

Four pages, built on the cleaned data, with `Order Date`, `Category`, and `Segment` slicers synced across all pages so filtering on one page carries through the others. Full working file: [`Sales Analysis.pbix`](powerbi/Visual%20Process/Sales%20Analysis.pbix).

### Core DAX Measures

| Measure         | Formula                                                         | Screenshot                                                                                                     |
| --------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Total Sales     | `SUM(orders[sales])`                                            | [Total Sales DAX.png](powerbi/DAX%20Measures/Total%20Sales%20DAX.png)                                             |
| Total Profit    | `SUM(orders[profit])`                                           | [Total Profit DAX.png](powerbi/DAX%20Measures/Total%20Profit%20DAX.png)                                           |
| Profit Margin % | `DIVIDE([Total Profit],[Total Sales],0)`                        | [Profit Margin DAX .png](powerbi/DAX%20Measures/Profit%20Margin%20DAX%20.png)                                     |
| Total Orders    | `DISTINCTCOUNT(orders[order_id])`                               | [Total Orders DAX.png](powerbi/DAX%20Measures/Total%20Orders%20DAX.png)                                           |
| Avg Order Value | `DIVIDE([Total Sales],[Total Orders],0)`                        | [Average Order Value DAX.png](powerbi/DAX%20Measures/Average%20Order%20Value%20DAX.png)                           |
| Discount Band   | `SWITCH(TRUE(), …)` grouping discount into bands                | [18_Page4_Discount Band DAX .png](powerbi/Visual%20Process/18_Page4_Discount%20Band%20DAX%20.png)                 |
| Customer Status | `VAR FirstOrderDate = CALCULATE(MIN(order_date), ALLEXCEPT(…))` → flags each order as the customer's first order or a repeat | [15_DAX Measure for New-Returning Customer.png](powerbi/Visual%20Process/15_DAX%20Measure%20for%20New-Returning%20Customer.png) |
| Avg Ship Days   | `AVERAGEX(orders, DATEDIFF(order_date, ship_date, DAY))`        | [20_Avg Ship Days DAX.png](powerbi/Visual%20Process/20_Avg%20Ship%20Days%20DAX.png)                               |

---

### Page 1 - Executive Overview

KPI cards, monthly sales & profit trend, sales/profit by region.

**Build process:**

1. Title added - [1_Title.png](powerbi/Visual%20Process/1_Title.png)
2. KPI cards added one at a time - [2_Adding KPI's.png](powerbi/Visual%20Process/2_Adding%20KPI's.png)
3. Slicers added to make the dashboard interactive (timeline, categories, segments) - [3_Adding Slicers (timeline, categories, segments).png](<powerbi/Visual%20Process/3_Adding%20Slicers%20(timeline,%20categories,%20segments).png>)
4. Line chart showcasing total profit and sales by year and month - [4_Line Chart.png](powerbi/Visual%20Process/4_Line%20Chart.png)
5. Regional clustered bar chart across four regions - [5_Clustered Bar Chart.png](powerbi/Visual%20Process/5_Clustered%20Bar%20Chart.png)
6. Page 1 final edits - card borders added, correct overall formatting, line smoothing turned off for the line chart - [6_Final Edits for Page 1.png](powerbi/Visual%20Process/6_Final%20Edits%20for%20Page%201.png)

**Key findings:**

* $3.24M total sales, $1.06M profit, 32.79% profit margin, $1,620.52 average order value
* Clear upward trend in sales and profit from 2023 to 2025, with recurring month-to-month volatility
* West region leads all regions in both sales ($1.13M) and profit; South trails

---

### Page 2 - Product Performance

Sales by sub-category, top 10 products by sales, bottom 10 products by profit margin.

**Build process:**

1. Clustered bar chart added showcasing total sales and profit by sub-category and category - [7_Page2_ClusteredBarChart.png](powerbi/Visual%20Process/7_Page2_ClusteredBarChart.png)
2. X-axis value fix so it better represents the range of values - [8_Page2_ClusteredBarChart edit for X-axis.png](powerbi/Visual%20Process/8_Page2_ClusteredBarChart%20edit%20for%20X-axis.png)
3. Top 10 products by sales, showing the filter - [9_Page2_Top 10 by Sales Bar Chart.png](powerbi/Visual%20Process/9_Page2_Top%2010%20by%20Sales%20Bar%20Chart.png)
4. Bottom 10 by profit margin, built using a Top N filter set to Bottom 10 by `Profit Margin %` - [10_Page2_Top10 by Profit Margin Bar Chart.png](<powerbi/Visual%20Process/10_Page2_Top10%20by%20Profit%20Margin%20Bar%20Chart.png>)
5. Final Page 2 edits - slicers added (matching Page 1), borders, data labels, and category-based color coding applied across all charts - [11_Page2_Final Edits.png](powerbi/Visual%20Process/11_Page2_Final%20Edits.png)

**Key findings:**

* Tables ($519K) and Accessories ($516K) are the top two sub-categories by sales; every Office Supplies sub-category sits at the bottom
* Laptop Stand is the single best-selling product ($306K)
* Ladder Bookcase and Folding Table appear in both the Top 10 by sales *and* the Bottom 10 by margin - high-revenue products that are comparatively low-profit (19.2% and 25.8% margin respectively)

---

### Page 3 - Customer Insights

Sales by segment, top 10 customers by lifetime sales, new vs. returning customer revenue by month.

**Build process:**

1. Donut chart built - [12_Page3_DonutChart.png](powerbi/Visual%20Process/12_Page3_DonutChart.png)
2. Colors changed to differentiate from Page 2's category colors - [13_Page3_DonutColorChange.png](powerbi/Visual%20Process/13_Page3_DonutColorChange.png)
3. Top 10 customers by lifetime sales chart built - [14_Top10 Customers by Lifetime sales chart.png](<powerbi/Visual%20Process/14_Top10%20Customers%20by%20Lifetime%20sales%20chart.png>)
4. New measure added to support the customer status (new vs. returning) label - [15_DAX Measure for New-Returning Customer.png](powerbi/Visual%20Process/15_DAX%20Measure%20for%20New-Returning%20Customer.png)
5. New vs. Returning stacked column chart built, using the `Customer Status` measure (redefined mid-build from "ordered in signup month" to "customer's first order ever," since the original definition produced a near-zero "New" share) - [16_NewVSReturning StackedBarChart.png](<powerbi/Visual%20Process/16_NewVSReturning%20StackedBarChart.png>)
6. Chart's sort order fixed so months display chronologically, by changing the axis sort setting to ascending (no separate screenshot for this step)
7. Final Page 3 edits - corresponding slicers, borders, and data labels added where possible - [17_Page3_FinalEdits.png](powerbi/Visual%20Process/17_Page3_FinalEdits.png)

**Key findings:**

* The Consumer segment drives 57.8% of total sales ($1.87M) - more than Corporate (25.8%) and Home Office (16.4%) combined
* Despite that, the top 10 individual customers by lifetime spend are fairly evenly split across all three segments
* Early 2023 revenue was effectively 100% from new customers; by 2024-2025, returning customers account for the large majority of monthly revenue. This shows a healthy retention signal

---

### Page 4 - Discount & Shipping

Profit margin by discount band, average shipping time by ship mode, sales & margin by ship mode.

**Build process:**

1. New measure added to support the Discount Band chart - [18_Page4_Discount Band DAX .png](powerbi/Visual%20Process/18_Page4_Discount%20Band%20DAX%20.png)
2. Discount Band chart built - [19_DiscountBand Column Chart.png](powerbi/Visual%20Process/19_DiscountBand%20Column%20Chart.png)
3. New measure added to calculate average shipping days - [20_Avg Ship Days DAX.png](powerbi/Visual%20Process/20_Avg%20Ship%20Days%20DAX.png)
4. Average Shipping Time chart built - [21_Average ShippingTime Bar Chart.png](<powerbi/Visual%20Process/21_Average%20ShippingTime%20Bar%20Chart.png>)
5. Combo chart (Total Sales + Profit Margin % by ship mode) built - [22_Total Sales_ProfitMargin Line and Stacked Column Chart.png](<powerbi/Visual%20Process/22_Total%20Sales_ProfitMargin%20Line%20and%20Stacked%20Column%20Chart.png>)
6. Bar color changed to match Total Sales' color used elsewhere in the dashboard (no separate screenshot for this step)
7. Rearranged so the combo chart spans full width for better readability (seen in the final image below)
8. Final Page 4 edits - slicers, borders, and data labels added - [23_Page4_FinalEdits.png](powerbi/Visual%20Process/23_Page4_FinalEdits.png)

**Key findings:**

* Profit margin declines steadily as discount increases: 36.0% with no discount → 31.2% at 1-10% discount → 23.7% at 11-20% discount
* Average shipping time (≈3.96-4.19 days) and profit margin (≈32.2-33.1%) are both essentially flat across all four ship modes - shipping speed does not measurably affect delivery time or profitability in this dataset
* Standard Class accounts for the large majority of order volume ($1.91M of $3.24M total sales)

---

## Tools & Skills Demonstrated

* **SQL**: database/table creation, manual data import with format handling, systematic data cleaning (nulls, duplicates, negative values, type conversion), joins, aggregation, `CASE`/`SWITCH` logic
* **Power BI**: data modeling, DAX measures & calculated columns (including `ALLEXCEPT`/`CALCULATE` window-style logic), multi-page interactive dashboards, synced slicers, dual-axis combo charts, custom formatting
* **Debugging**: diagnosed and resolved a text-typed numeric column, a hidden visual-level filter silently dropping categories, an incorrect chart sort order, and a data label readability issue - each caught by comparing the dashboard against the verified SQL results
