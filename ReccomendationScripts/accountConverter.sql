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
          account.beginning_balance, -- Include the start_balance from the account table
          LAG(i.monthly_income - e.monthly_expenses, 1, account.beginning_balance) 
          OVER (PARTITION BY i.acc_id ORDER BY i.month) AS beginning_balancee,
          i.monthly_income - e.monthly_expenses AS current_balance
      FROM income_summary i
      JOIN expenses_summary e ON i.acc_id = e.acc_id AND i.month = e.month
      JOIN account ON i.acc_id = account.id
      ),
	  goals_summary AS (
	  SELECT
		acc_id,
		MIN(goals) AS min_goal,
		MAX(goals) AS max_goal
	  FROM user_goals
	  GROUP BY acc_id
		)
      SELECT
          income_and_expenses.acc_id,
          TO_CHAR(month, 'YYYY-MM-DD') AS month,
          beginning_balancee,
          current_balance,
          monthly_income,
          monthly_expenses,
          ROUND(wants / monthly_income * 100, 2) AS wants_percentage,
    	  ROUND(needs / monthly_income * 100, 2) AS needs_percentage,
    	  ROUND(((monthly_income - monthly_expenses) / monthly_income) * 100, 2) AS savings,
          ROUND((monthly_income - LAG(monthly_income, 1, monthly_income) 
          OVER (PARTITION BY income_and_expenses.acc_id ORDER BY month)) /
          LAG(monthly_income, 1, monthly_income) OVER (PARTITION BY income_and_expenses.acc_id ORDER BY month) * 100, 2) AS increase_decrease,
      	  goals_summary.min_goal,
  		  goals_summary.max_goal
	  FROM income_and_expenses
	  JOIN goals_summary ON income_and_expenses.acc_id = goals_summary.acc_id
	  WHERE income_and_expenses.acc_id = :acc_id
      ORDER BY acc_id, month DESC
	  FETCH FIRST 1 ROW ONLY;