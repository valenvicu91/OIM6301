PRAGMA foreign_keys = ON;

/* ============================================================
1) TOP 3 BESTSELLERS IN THE LAST MONTH (BY QUANTITY)
Business question:
Which 3 products sold the most units in the most recent full calendar month?

How it’s used:
Inform purchasing and merchandising (prioritize inventory, feature in promos).
============================================================ */
SELECT
  p.product_id,
  p.product_name,
  SUM(oli.quantity) AS total_qty
FROM OrderLineItem oli
JOIN "Order" o  ON o.order_id = oli.order_id
JOIN Product p  ON p.product_id = oli.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_qty DESC
LIMIT 3;

/* ============================================================
2) CUSTOMERS ABOVE THE AVERAGE TICKET VALUE (ATV)
Business question:
For each customer, compute total spend, order count, and average ticket value; 
filter to customers whose ATV is above the overall average order value.

How it’s used:
Identify higher-value customers for loyalty perks or targeted offers.
============================================================ */
WITH order_totals AS (
  SELECT
    o.order_id,
    o.customer_id,
    SUM(oli.quantity * oli.unit_price) AS order_total
  FROM "Order" o
  JOIN OrderLineItem oli ON oli.order_id = o.order_id
  GROUP BY o.order_id
),
overall AS (
  SELECT AVG(order_total) AS overall_atv
  FROM order_totals
),
per_customer AS (
  SELECT
    ot.customer_id,
    COUNT(*)                         AS order_count,
    SUM(ot.order_total)              AS total_spend,
    SUM(ot.order_total) * 1.0 / COUNT(*) AS atv
  FROM order_totals ot
  GROUP BY ot.customer_id
)
SELECT
  c.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  pc.order_count,
  ROUND(pc.total_spend, 2) AS total_spend,
  ROUND(pc.atv, 2)         AS avg_ticket_value
FROM per_customer pc
JOIN overall ov
JOIN Customer c ON c.customer_id = pc.customer_id
WHERE pc.atv > ov.overall_atv
ORDER BY pc.atv DESC;


/* ============================================================
3) MARGINS BY PRODUCT CATEGORY
Business question:
By category, what are revenue, cost, gross margin, and margin %?

How it’s used:
Understand profitability mix; guide pricing and category emphasis.
============================================================ */
SELECT
  p.category,
  ROUND(SUM(oli.quantity * oli.unit_price), 2) AS revenue,
  ROUND(SUM(oli.quantity * oli.unit_cost), 2)  AS cost,
  ROUND(SUM(oli.quantity * (oli.unit_price - oli.unit_cost)), 2) AS gross_margin,
  ROUND(
    CASE WHEN SUM(oli.quantity * oli.unit_price) = 0
         THEN 0
         ELSE SUM(oli.quantity * (oli.unit_price - oli.unit_cost))
              / SUM(oli.quantity * oli.unit_price)
    END * 100, 2
  ) AS margin_pct
FROM OrderLineItem oli
JOIN Product p ON p.product_id = oli.product_id
GROUP BY p.category
ORDER BY margin_pct DESC;


/* ============================================================
4) HIGH-POINT CUSTOMERS WITH NO ORDERS IN LAST 60 DAYS
Business question:
Which customers have high points but haven’t ordered in the last 60 days?

How it’s used:
Build a re-engagement list (send targeted win-back offers).
============================================================ */
SELECT
  c.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.email,
  c.points_balance,
  MAX(o.order_datetime) AS last_order_dt
FROM Customer c
LEFT JOIN "Order" o
  ON o.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING
  c.points_balance >= 100
  AND (
    last_order_dt IS NULL
    OR date(last_order_dt) < date('now','-60 day')
  )
ORDER BY c.points_balance DESC, last_order_dt NULLS FIRST;


/* ============================================================
5) DISTRIBUTION OF ORDERS BY PAYMENT METHOD
Business question:
What % of orders are cash vs card vs mobile?

How it’s used:
Guide POS setup, payment partnerships, and ops planning.
============================================================ */
WITH counts AS (
  SELECT payment_method, COUNT(*) AS cnt
  FROM "Order"
  GROUP BY payment_method
),
total AS (
  SELECT SUM(cnt) AS total_orders FROM counts
)
SELECT
  c.payment_method,
  c.cnt                            AS orders,
  ROUND(c.cnt * 100.0 / t.total_orders, 2) AS pct_of_total
FROM counts c CROSS JOIN total t
ORDER BY c.cnt DESC;


/* ============================================================
/* ============================================================
6) BASKET SIZE BY ORDER CHANNEL (REPLACEMENT FOR MONTHLY TREND)
Business question:
How many items do customers buy per order, overall and by channel (in-store vs app)?

How it’s used:
Plan staffing: if app baskets are larger, feature bundles/promos there;
if in-store is smaller, speed up checkout and cross-sell.

============================================================ */
WITH items_per_order AS (
  SELECT
    order_id,
    SUM(quantity) AS items
  FROM OrderLineItem
  GROUP BY order_id
)
SELECT
  COALESCE(o.order_channel, 'unknown') AS order_channel,
  COUNT(*)                              AS orders,
  ROUND(AVG(i.items), 2)                AS avg_items_per_order,
  SUM(i.items)                          AS total_items
FROM "Order" o
JOIN items_per_order i ON i.order_id = o.order_id
GROUP BY COALESCE(o.order_channel, 'unknown')
ORDER BY orders DESC;

/* ============================================================
7) BARISTA PERFORMANCE LEADERBOARD
Business question:
Which baristas drive the most orders and revenue? What is their avg order value?

How it’s used:
Staffing, training, and recognition; align top performers with peak hours.
============================================================ */
WITH order_totals AS (
  SELECT
    o.order_id,
    o.barista_id,
    SUM(oli.quantity * oli.unit_price) AS order_total
  FROM "Order" o
  JOIN OrderLineItem oli ON oli.order_id = o.order_id
  GROUP BY o.order_id
),
per_barista AS (
  SELECT
    barista_id,
    COUNT(*)                    AS orders_handled,
    SUM(order_total)            AS revenue,
    AVG(order_total)            AS avg_order_value
  FROM order_totals
  GROUP BY barista_id
)
SELECT
  b.barista_id,
  b.first_name || ' ' || b.last_name AS barista_name,
  orders_handled,
  ROUND(revenue, 2)        AS revenue,
  ROUND(avg_order_value,2) AS avg_order_value,
  RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM per_barista pb
JOIN Barista b ON b.barista_id = pb.barista_id
ORDER BY revenue DESC;


/* ============================================================
8) PROMOTION EFFECTIVENESS: USAGE & AOV IMPACT
Business question:
How do orders with a promotion compare to those without?

How it’s used:
Measure promo lift, decide whether to continue/adjust campaigns.
============================================================ */
WITH order_totals AS (
  SELECT
    o.order_id,
    CASE WHEN o.coupon_code IS NULL OR o.coupon_code = '' THEN 'No Promo' ELSE 'Promo Used' END AS promo_flag,
    SUM(oli.quantity * oli.unit_price) AS order_total
  FROM "Order" o
  JOIN OrderLineItem oli ON oli.order_id = o.order_id
  GROUP BY o.order_id
),
agg AS (
  SELECT
    promo_flag,
    COUNT(*)                AS orders,
    ROUND(AVG(order_total),2) AS avg_ticket_value
  FROM order_totals
  GROUP BY promo_flag
),
total AS (
  SELECT SUM(orders) AS total_orders FROM agg
)
SELECT
  a.promo_flag,
  a.orders,
  ROUND(a.orders * 100.0 / t.total_orders, 2) AS pct_of_orders,
  a.avg_ticket_value
FROM agg a CROSS JOIN total t
ORDER BY a.promo_flag DESC;   -- 'Promo Used' row first
