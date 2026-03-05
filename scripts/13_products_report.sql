CREATE OR REPLACE VIEW gold.products_report AS
WITH base_query AS (
	SELECT
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.dim_products p
	LEFT JOIN gold.fact_sales f
		ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
),

product_aggregations AS (
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		(
			DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12 +
			DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))
		) AS lifespan,
		MAX(order_date) AS last_sale_date,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(sales_amount::numeric / NULLIF(quantity, 0)), 1) AS avg_selling_price
	FROM base_query
	GROUP BY
	    product_key,
	    product_name,
	    category,
	    subcategory,
	    cost
)

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    (
        DATE_PART('year', AGE(CURRENT_DATE, last_sale_date)) * 12 +
        DATE_PART('month', AGE(CURRENT_DATE, last_sale_date))
    ) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    
    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales::numeric / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales::numeric / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;

SELECT * FROM gold.products_report; -- Testing the 'products_report' VIEW
