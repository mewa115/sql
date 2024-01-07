--You have a suggestion for Bob's pitch deck: Instead of showing registrations by month in 
--the line chart, he can show the registrations running total by month. 
--The numbers are bigger that way, and investors always love bigger numbers! 
--He agrees, and you begin to work on a query that returns a table of the registrations running total by month.


WITH reg_dates AS (
  SELECT
    user_id,
    MIN(order_date) AS reg_date
  FROM orders
  GROUP BY user_id)

SELECT
  -- Select the month and the registrations
  DATE_TRUNC('month', reg_dates.reg_date) :: DATE AS delivr_month,
  count(user_id) AS regs
FROM reg_dates
GROUP BY delivr_month
-- Order by month in ascending order
ORDER BY delivr_month; 




--Registrations running total
--You have a suggestion for Bob's pitch deck: Instead of showing registrations by month in the line chart,
--he can show the registrations running total by month. The numbers are bigger that way, and investors always 
--love bigger numbers! He agrees, and you begin to work on a query that returns a table of the registrations running total by month.

WITH reg_dates AS (
  SELECT
    user_id,
    MIN(order_date) AS reg_date
  FROM orders
  GROUP BY user_id),

  regs AS (
  SELECT
    DATE_TRUNC('month', reg_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS regs
  FROM reg_dates
  GROUP BY delivr_month)

SELECT
  -- Calculate the registrations running total by month
  delivr_month,
  regs,
  SUM(regs) OVER (ORDER BY delivr_month ASC) AS regs_rt
FROM regs
-- Order by month in ascending order
ORDER BY delivr_month ASC; 




--MAU monitor (I)
--Carol from the Product team noticed that you're working with a lot of user-centric KPIs for Bob's pitch deck. 
--While you're at it, she says, you can help build an idea of hers involving a user-centric KPI. 
--She wants to build a monitor that compares the MAUs of the previous and current month, raising a red flag to the
--Product team if the current month's active users are less than those of the previous month.
--To start, write a query that returns a table of MAUs and the previous month's MAU for every month.

WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month)

SELECT
  -- Select the month and the MAU
  delivr_month,
  mau,
COALESCE (
LAG (mau) OVER (ORDER BY delivr_month ASC),
  0) AS last_mau
FROM mau
-- Order by month in ascending order
ORDER BY delivr_month ASC;

-- It produces the result 
-- delivr_month -- 	mau -- 	last_mau
-- 2018-06-01	      123	    0 
-- 2018-07-01	      226	    123
-- 2018-08-01	      337   	226
-- 2018-09-01	      489	    337


--MAU monitor (II)
--Now that you've built the basis for Carol's MAU monitor, write a query 
-- that returns a table of months and the deltas of each month's current and previous MAUs.
--If the delta is negative, less users were active in the current month than in the previous month, 
--which triggers the monitor to raise a red flag so the Product team can investigate.

WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month),

  mau_with_lag AS (
  SELECT
    delivr_month,
    mau,
    -- Fetch the previous month's MAU
    COALESCE(
      lag(mau) over (order by delivr_month),
    0) AS last_mau
  FROM mau)

SELECT
  -- Calculate each month's delta of MAUs
  delivr_month,
  mau,
  (mau - last_mau) AS mau_delta
FROM mau_with_lag
-- Order by month in ascending order
ORDER BY delivr_month;

-- The result is 
--delivr_month	mau	mau_delta
--2018-06-01	  123	123
--2018-07-01	  226	103
--2018-08-01	  337	111
--2018-09-01	  489	152
--2018-10-01	  689	200


--MAU monitor (III)
--Carol is very pleased with your last query, but she's requested one change: 
--She prefers to have the month-on-month (MoM) MAU growth rate over a raw delta of MAUs. 
--That way, the MAU monitor can have more complex triggers, like raising a yellow flag if the growth rate is -2% and a red flag if the growth rate is -5%.
--Write a query that returns a table of months and each month's MoM MAU growth rate to finalize the MAU monitor.

WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month),

  mau_with_lag AS (
  SELECT
    delivr_month,
    mau,
    GREATEST(
      LAG(mau) OVER (ORDER BY delivr_month ASC),
    1) AS last_mau
  FROM mau)

SELECT
  -- Calculate the MoM MAU growth rates
  delivr_month,
 ROUND (
(mau - last_mau) :: NUMERIC / last_mau,
2) AS growth
FROM mau_with_lag
-- Order by month in ascending order
ORDER BY delivr_month;



--Order growth rate
--Bob needs one more chart to wrap up his pitch deck. He's covered Delivr's gain of new users, 
--its growing MAUs, and its high retention rates. Something is missing, though. 
--Throughout the pitch deck, there's not a single mention of the best indicator of user activity: the users' orders!
--The more orders users make, the more active they are on Delivr, and the more money Delivr generates.
--Send Bob a table of MoM order growth rates.
--(Recap: MoM means month-on-month.)\

WITH orders AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    --  Count the unique order IDs
    count(distinct(order_id)) AS orders
  FROM orders
  GROUP BY delivr_month),

  orders_with_lag AS (
  SELECT
    delivr_month,
    -- Fetch each month's current and previous orders
    orders,
    COALESCE(
      lag(orders) over (order by delivr_month),
    1) AS last_orders
  FROM orders)

SELECT
  delivr_month,
  orders,last_orders,
  -- Calculate the MoM order growth rate
  ROUND(
    (orders - last_orders) / last_orders :: NUMERIC,
  2) AS growth
FROM orders_with_lag
ORDER BY delivr_month ASC;


--Output
--delivr_month	orders	last_orders	growth
--2018-06-01	  282   	1	           281.00
--2018-07-01	  445	    282	         0.58
--2018-08-01	  670	    445	         0.51
