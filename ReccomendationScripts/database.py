import csv
import os
import mysql.connector
from sqlalchemy import create_engine, Column, Integer, String, Date, Numeric, ForeignKey, UniqueConstraint
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

#THIS IS NOT BEING USED IN SYSTEM 
# This script adds all the files that you've generated that are within the csvs folder. If you add more, then drop the table and rerun this code.
# Please don't enter sorcery; I'm not user entry optimizing this part of the code.
dbms = input("[1] For MYSQL\n[2] For PGAdmin\nWhich DBMS are you using: ")

if dbms == "1":
    mydb = mysql.connector.connect(host="localhost", user="root", password="pass1nee")

    cursor = mydb.cursor()

    cursor.execute("SHOW DATABASES")
    databases = [database[0] for database in cursor]

    if 'personalfinancial' not in databases:
        cursor.execute("CREATE DATABASE personalfinancial")

    cursor.execute("USE personalfinancial")

    cursor.execute("SHOW TABLES")
    tables = [table[0] for table in cursor]

    if 'all_user_data' not in tables:
        # Create table 'all_user_data'
        cursor.execute("""CREATE TABLE all_user_data (
            records INT AUTO_INCREMENT PRIMARY KEY,
            acc_id INT,
            start_date DATE,
            curr_date DATE,
            beginning_balance DECIMAL(15, 2),
            monthly_income DECIMAL(15, 2),
            monthly_expense DECIMAL(15, 2),
            current_balance DECIMAL(15, 2),
            wants_percent DECIMAL(5, 2),
            needs_percent DECIMAL(5, 2),
            savings_percent DECIMAL(4, 2),
            min_goal DECIMAL(15, 2),
            max_goal DECIMAL(15, 2),
            budget_increase DECIMAL(6, 2),
            INDEX (acc_id)
        )""")
        cursor.execute("ALTER TABLE all_user_data AUTO_INCREMENT = 1")

    if 'user_goals' not in tables:
        # Create table 'user_goals' with foreign key constraint
        cursor.execute("""CREATE TABLE user_goals (
            records INT AUTO_INCREMENT PRIMARY KEY,
            acc_id INT,
            goals DECIMAL(15, 2),
            FOREIGN KEY (acc_id) REFERENCES all_user_data(records)
        )""")
        cursor.execute("ALTER TABLE user_goals AUTO_INCREMENT = 1")

    csv_folder = "csvs"
    user = 0
    totalgoals = 0
    files = 0

    file_names = os.listdir(csv_folder)
    for file_name in file_names:
        file_path = os.path.join(csv_folder, file_name)
        files += 1

        with open(file_path, newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            next(reader)

            goals = []  #also contains id
            ids=[]
            #user += 1  

            user = 30 #default start value from Sampledata.py
            i=0
            for row in reader:
                i+=1
                if row[0] == '':     #if the theres only goal in the row of data (so the same user)
                    #goals.append(row[10])
                    goals.append((user,row[10]))
                    continue

                query1 = "INSERT INTO all_user_data (acc_id, start_date, curr_date, beginning_balance, monthly_income, monthly_expense, current_balance, wants_percent, needs_percent, savings_percent, min_goal, max_goal, budget_increase) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"

                values1 = (row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9],row[10], row[11],row[12])

                goals.append((row[0],row[10]))
                if user != int(row[0]):     #if the user is different then increment. 
                    user = int(row[0]) + 1
                cursor = mydb.cursor()
                cursor.execute(query1, values1)
                #user = row[0]
                 
                

            goals = list(set(goals)) #removes duplicates
            totalgoals += len(goals)
            #print(row[0])
            print(goals)
            print(i)
            
            for val in goals:
                query2 = "INSERT INTO user_goals (acc_id, goals) VALUES (%s, %s)"
                values2 = (val[0], val[1])
                #values2 = (ids[i], val)
                cursor = mydb.cursor()
                cursor.execute(query2, values2)
                

    print("Number of files added to the database:", files)

    mydb.commit()
    mydb.close()

elif dbms == "2":
    #order: postgresql://username:password@LH/DBName
    #engine = create_engine('postgresql://capstone:password@localhost/personalfinancial')
    engine = create_engine('postgresql://pfinance:pfinance@localhost/pfinance')
    Session = sessionmaker(bind=engine)
    session = Session()
    Base = declarative_base()

    class AllUserData(Base):
        __tablename__ = 'all_user_data'
        records = Column(Integer, primary_key=True)
        acc_id = Column(Integer)
        start_date = Column(Date)
        curr_date = Column(Date)
        beginning_balance = Column(Numeric(15, 2))
        monthly_income = Column(Numeric(15, 2))
        monthly_expense = Column(Numeric(15, 2))
        current_balance = Column(Numeric(15, 2))
        wants_percent = Column(Numeric(5, 2))
        needs_percent = Column(Numeric(5, 2))
        savings_percent = Column(Numeric(4, 2))
        budget_increase = Column(Numeric(6, 2))
        min_goal = Column(Numeric(15, 2))
        max_goal = Column(Numeric(15, 2))
        __table_args__ = (UniqueConstraint('records', name='uq_records_id'),)

    class UserGoals(Base):
        __tablename__ = 'user_goals'
        records = Column(Integer, primary_key=True)
        acc_id = Column(Integer, ForeignKey('all_user_data.records'))  #shouldnt this be acc_id?
        goals = Column(Numeric(15, 2))
        __table_args__ = {'extend_existing': True}

    csv_folder = "csvs"
    user = 0
    total_goals = 0
    files = 0

    Base.metadata.create_all(engine)

    file_names = os.listdir(csv_folder)
    for file_name in file_names:
        file_path = os.path.join(csv_folder, file_name)
        files += 1

        with open(file_path, newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            next(reader)

            goals = []
            #user += 1

            user = 30
            for row in reader:
                if row[0] == '':    #if the theres only goal in the row of data (so the same user)
                    goals.append((user,row[10]))
                    continue

                all_user_data = AllUserData(
                    acc_id=row[0],
                    start_date=row[1],
                    curr_date=row[2],
                    beginning_balance=row[3],
                    monthly_income=row[4],
                    monthly_expense=row[5],
                    current_balance=row[6],
                    wants_percent=row[7],
                    needs_percent=row[8],
                    savings_percent=row[9],
                    min_goal=row[10],
                    max_goal=row[11],
                    budget_increase=row[12]
                )

                #goals.append(row[10])
                goals.append((user,row[10]))
                if user != int(row[0]):     #if the user is different then increment. 
                    user = int(row[0]) + 1
                session.add(all_user_data)
                session.flush()
                user_goals_id = all_user_data.records  #Records and not their id???

            goals = list(set(goals))
            total_goals += len(goals)

            for val in goals:
                user_goals = UserGoals(
                    #acc_id=user_goals_id,
                    #goals=val
                    acc_id = val[0],
                    goals = val[1]
                )
                session.add(user_goals)

    print("Number of files added to the database:", files)

    session.commit()
    session.close()
else:
    print("Invalid option. Please select either '1' or '2' for the DBMS.")
