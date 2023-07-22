WITH income_summary AS (
  SELECT
    acc_id,
    DATE_TRUNC('month', date) AS month,
    SUM(monthly_earning) AS monthly_income
  FROM income_channel
  GROUP BY acc_id, DATE_TRUNC('month', date)
),
expenses_summary AS (
  SELECT
    acc_id,
    DATE_TRUNC('month', date) AS month,
    SUM(cost) AS monthly_expenses,
    SUM(CASE WHEN expense_type = 'Want' THEN cost ELSE 0 END) AS wants,
    SUM(CASE WHEN expense_type = 'Need' THEN cost ELSE 0 END) AS needs
  FROM expense_list
  GROUP BY acc_id, DATE_TRUNC('month', date)
),
income_and_expenses AS (
  SELECT
    i.acc_id,
    i.month,
    i.monthly_income,
    e.monthly_expenses,
    e.wants,
    e.needs,
    i.monthly_income - e.monthly_expenses AS current_balance -- Add this line to calculate current balance
  FROM income_summary i
  JOIN expenses_summary e ON i.acc_id = e.acc_id AND i.month = e.month
)
SELECT
  acc_id,
  TO_CHAR(month, 'YYYY-MM-DD') AS month,
  current_balance, -- Include the new column here
  monthly_income,
  monthly_expenses,
  ROUND(wants / monthly_expenses * 100, 2) AS wants_percentage,
  ROUND(needs / monthly_expenses * 100, 2) AS needs_percentage,
  ROUND((100 - (wants / monthly_expenses * 100 + needs / monthly_expenses * 100)), 2) AS savings,
  ROUND((monthly_income - LAG(monthly_income, 1, monthly_income) OVER (PARTITION BY acc_id ORDER BY month)) /
  LAG(monthly_income, 1, monthly_income) OVER (PARTITION BY acc_id ORDER BY month) * 100, 2) AS increasedecrease
FROM income_and_expenses
ORDER BY acc_id, month;


