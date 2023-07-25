import random
import datetime
import csv
import os

#THIS IS NOT BEING USED IN SYSTEM 
acc_id=30 #start here so the flutter dart system run and create table, it nuh affect it.
ttlfiles = input("Enter how much users you want to develop ")
file_name = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=8)) + '.csv'
folder_name = "ReccomendationScripts\csvs"
os.makedirs(folder_name, exist_ok=True)
sectionpath = os.path.join(folder_name, file_name)

with open(sectionpath, mode='a', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Account_ID','Month', 'Beginning_Balance', 'Monthly_Income','Monthly_Expense', 'Current_Balance', 'Wants%', 'Needs%','Savings%', 'Min_Goal','Max_Goal', 'Increase_Decrease'])

for x in range(int(ttlfiles)):
    # Generate start date and current date randomly within a 30 day anywhere from jan1 of 2012 up to dec 30 2022
    increment=random.randint(15,30)
    randmonth = random.randint(1,12)
    randdate = random.randint(1,30)
    randyear = random.randint(2012,2022)

    try:
        datetime.datetime(randyear, randmonth, randdate)
    except ValueError:
        continue
    except OverflowError:
        continue

    # WARNING THERE IS A POSSIBILITY FEB 29 ON NOT A LEAP YEAR CAN BE PUT IN, IF IT BRUK JUST RERUN IT AND A NEW RANDOM DATE MEK

    start_date = datetime.date(randyear, randmonth, randdate)
    user_start = start_date
    one_month_delta = datetime.timedelta(days=increment)
    month = start_date + one_month_delta

    # Cook up some random floats for beginning balance, and monthly income, accumulate the balance and the i chefed up a random expense value. assuming US money for costs btw
    beginning_balance = round(random.uniform(10000.00, 100000.00), 2)
    monthly_income = round(random.uniform(50000.00, 150000.00), 2)
    moneysum = beginning_balance + monthly_income

    # For expenses i couldnt come up with much so i have it do a random value between 60-90% of the total balance above that ill use to get wants and needs ig?
    spent_expense = random.uniform(60, 90)
    savings = round(100 - spent_expense,2)
    monthly_expenses = round(spent_expense/ 100 * moneysum, 2)
    balance = round(moneysum - monthly_expenses, 2)

    # I gave the needs and wants a 3:2 ratio so change this if preferred ig.
    needs = round((3 / 5) * spent_expense, 2)
    wants = round((2 / 5) * spent_expense, 2)


    # Goals values going to put at most like 3 for now, with a max of 2.5m ig
    goals = []
    numgoals = random.randint(1,3)

    for i in range(numgoals):
        goalval = round(random.uniform(50000.00, 2500000.00), 2)
        goals.append(goalval)


    # Increase percent calculations
    inc_dec = round((((balance - beginning_balance) / beginning_balance) * 100),2)


    # This is just to print the values to see them.
    # print(f"\nStart Date: {start_date}\nCurrent Date: {current_date}\nBeginning Balance: {beginning_balance}\nMonthly Income: {monthly_income}\nMonthly Expense: {monthly_expenses}\nBalance: {balance}\nNeeds Percentage: {needs}\nWants Percentage: {wants}\nSavings Percentage: {savings}")


    

    
    with open(sectionpath, mode='a', newline='') as file:
        writer = csv.writer(file)
        #writer.writerow(['month', 'Beginning_Balance', 'Monthly_Income','Monthly_Expense', 'Current_Balance', 'Needs%', 'Wants%','Savings%', 'goals', 'Increase_Decrease'])
        writer.writerow([acc_id,month,beginning_balance,monthly_income,monthly_expenses,balance,wants,needs,savings,min(goals),max(goals),inc_dec])
        
        """ 
        if len(goals) >= 2:
            for i in range(1,len(goals)):
                writer.writerow(["","","","","","","","","","",goals[i]])
        """
        dataperperson= random.randint(3,12)

        
        for x in range(dataperperson):

            # New current date for the next records
            start_date = month
            increment=random.randint(15,30)
            one_month_delta = datetime.timedelta(days=increment)
            month = start_date + one_month_delta 
        
            # Beginning balance from previous month, along with new income and sum
            beginning_balance=balance
            monthly_income = round(random.uniform(50000.00, 150000.00), 2)
            moneysum = beginning_balance + monthly_income

            
            spent_expense = random.uniform(60, 90)
            savings = round(100 - spent_expense,2)
            monthly_expenses = round(spent_expense/ 100 * moneysum, 2)
            balance = round(moneysum - monthly_expenses, 2)

            needs = round((3 / 5) * spent_expense, 2)
            wants = round((2 / 5) * spent_expense, 2)

            inc_dec = round((((balance - beginning_balance) / beginning_balance) * 100),2)

            writer.writerow([acc_id,month,beginning_balance,monthly_income,monthly_expenses,balance,wants,needs,savings,min(goals),max(goals),inc_dec])
            """ 
            if len(goals) >= 2:
                for i in range(1,len(goals)):
                    writer.writerow(["","","","","","","","","","",goals[i]])
            """

    acc_id += 1
    print("User ",acc_id-1, " Added")
print("Generated file: ", file_name)