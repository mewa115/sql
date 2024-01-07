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
