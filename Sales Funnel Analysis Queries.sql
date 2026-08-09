explain user_events;
select count(*) from user_events;

-- Data cleaning 
UPDATE user_events 
SET amount = NULL 
WHERE amount = '';

set sql_safe_updates = 1; -- Allows to change Safe update mode || 0 allows 1 restricts
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- (1) - Define sales funnel and different stages

WITH funnel_stages AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS pageview,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS addtocart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS paymentinfo,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase
  FROM user_events
  JOIN (SELECT MAX(event_date) AS max_dt FROM user_events) m
    ON user_events.event_date >= DATE_SUB(m.max_dt, INTERVAL 30 DAY)
)
SELECT * FROM funnel_stages;


-- (2) Conversion rates through the funnel

WITH funnel_stagesstages AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS pageview,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS addtocart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS paymentinfo,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase
  FROM user_events
  JOIN (SELECT MAX(event_date) AS max_dt FROM user_events) m
    ON user_events.event_date >= DATE_SUB(m.max_dt, INTERVAL 30 DAY)
)

select
pageview,
addtocart,
concat(round((addtocart * 100) / pageview), "%") as atc_to_pageview_ratio,
checkout,
concat(round((checkout * 100) / pageview),"%") as checkout_to_pageview_ratio,
paymentinfo,
concat(round((paymentinfo * 100) / pageview),"%") as payinfo_to_pageview_ratio,
purchase,
concat(round((purchase * 100) / pageview),"%") as purchase_to_pageview_ratio
from funnel_stages;


-- (3) Funnel by source

with funnel_stages as (
SELECT
traffic_source, 
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase
  FROM user_events
  JOIN (SELECT MAX(event_date) AS max_dt FROM user_events) m
    ON user_events.event_date >= DATE_SUB(m.max_dt, INTERVAL 30 DAY)
group by 1
)

select traffic_source, views, cart, purchase,
concat(round((cart * 100) / views), "%") as cart_conversion_rate,
concat(round((purchase * 100) / views), "%") as pageview_to_purchase_rate,
concat(round((purchase * 100) / cart), "%") as purchase_conversion_rate
 
from funnel_stages;


-- (4) Time to conversion analysis

WITH user_journey AS (
  SELECT
  user_id,
    min(CASE WHEN event_type = 'page_view' THEN event_date END) AS viewtime,
    min(CASE WHEN event_type = 'add_to_cart' THEN event_Date END) AS carttime,
    min(CASE WHEN event_type = 'purchase' THEN event_Date END) AS purchasetime
  FROM user_events
  JOIN (SELECT MAX(event_date) AS max_dt FROM user_events) m
    ON user_events.event_date >= DATE_SUB(m.max_dt, INTERVAL 30 DAY)
    group by 1
    having min(CASE WHEN event_type = 'purchase' THEN event_Date END) is not null
)

select 
count(*) as converted_users,
round(avg(timestampdiff(minute, viewtime, carttime)),2) as avg_view_to_cart_diff,
round(avg(timestampdiff(minute, carttime, purchasetime)),2) as avg_cart_to_purchase_diff,
round(avg(timestampdiff(minute, viewtime, purchasetime)),2) as avg_total_journey
from user_journey;


-- (5) Revenue funnel analysis

WITH funnel_revenue AS (
  SELECT
    count(distinct CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
    count(distinct CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
    sum(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,
	count(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders
  FROM user_events
  JOIN (SELECT MAX(event_date) AS max_dt FROM user_events) m
    ON user_events.event_date >= DATE_SUB(m.max_dt, INTERVAL 30 DAY)
)

select
total_visitors,
total_buyers,
total_orders,
round(total_revenue, 2),
round(total_revenue / total_orders, 2) as avg_order_value,
round(total_revenue / total_buyers,2) as revenue_per_buyer,
round(total_revenue / total_visitors,2) as revenue_per_visitor
from funnel_revenue;