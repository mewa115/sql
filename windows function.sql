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
2018-09-01	489	337
