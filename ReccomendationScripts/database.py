import csv
import os
#import mysql.connector
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

    if 'all_users_data' not in tables:
        # Create table 'all_user_data'   
        #DECIMAL(15,2)to  db.Column(db.Numeric(10, 2))    NUMERIC
        cursor.execute("""CREATE TABLE all_users_data (
            records INT AUTO_INCREMENT PRIMARY KEY,
            acc_id INT,
            month DATE,
            beginning_balance DECIMAL(15, 2),
            monthly_income DECIMAL(15, 2),
            monthly_expense DECIMAL(15, 2),
            current_balance DECIMAL(15, 2),
            wants_percent DECIMAL(5, 2),
            needs_percent DECIMAL(5, 2),
            savings_percent DECIMAL(4, 2),
            min_goal DECIMAL(15, 2),
            max_goal DECIMAL(15, 2),
            increase_decrease DECIMAL(6, 2),
            INDEX (acc_id)
        )""")
        cursor.execute("ALTER TABLE all_users_data AUTO_INCREMENT = 1")

    if 'user_goals' not in tables:
        # Create table 'user_goals' with foreign key constraint  #DECIMAL
        cursor.execute("""CREATE TABLE user_goals (
            records INT AUTO_INCREMENT PRIMARY KEY,
            acc_id INT,
            goals NUMERIC(15, 2),
            FOREIGN KEY (acc_id) REFERENCES all_users_data(records)
        )""")
        cursor.execute("ALTER TABLE user_goals AUTO_INCREMENT = 1")

    csv_folder = "ReccomendationScripts\csvs"
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
                    #goals.append(row[9])
                    goals.append((user,row[9]))
                    continue

                query1 = "INSERT INTO all_user_data (acc_id, month, beginning_balance, monthly_income, monthly_expense, current_balance, wants_percent, needs_percent, savings_percent, min_goal, max_goal, increase_decrease) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"

                values1 = (row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9],row[10], row[11])

                goals.append((row[0],row[9]))
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

    class AllUsersData(Base):
        __tablename__ = 'all_users_data'
        records = Column(Integer, primary_key=True)
        acc_id = Column(Integer)
        month = Column(Date)
        #curr_date = Column(Date)
        beginning_balance = Column(Numeric(15, 2))
        monthly_income = Column(Numeric(15, 2))
        monthly_expense = Column(Numeric(15, 2))
        current_balance = Column(Numeric(15, 2))
        wants_percent = Column(Numeric(5, 2))
        needs_percent = Column(Numeric(5, 2))
        savings_percent = Column(Numeric(4, 2))
        increase_decrease = Column(Numeric(6, 2))
        min_goal = Column(Numeric(15, 2))
        max_goal = Column(Numeric(15, 2))
        __table_args__ = (UniqueConstraint('records', name='uq_records_id'),)

    class AllUsersGoals(Base):
        __tablename__ = 'all_users_goals'
        records = Column(Integer, primary_key=True)
        #acc_id = Column(Integer, ForeignKey('all_user_data.records'))  
        acc_id = Column(Integer,nullable=False)
        goals = Column(Numeric(15, 2))
        __table_args__ = {'extend_existing': True}

    csv_folder = "ReccomendationScripts\csvs"
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
                    goals.append((user,row[9]))
                    continue

                all_users_data = AllUsersData(
                    acc_id=row[0],
                    month=row[1],
                    beginning_balance=row[2],
                    monthly_income=row[3],
                    monthly_expense=row[4],
                    current_balance=row[5],
                    wants_percent=row[6],
                    needs_percent=row[7],
                    savings_percent=row[8],
                    min_goal=row[9],
                    max_goal=row[10],
                    increase_decrease=row[11]
                )

                #goals.append(row[9])
                goals.append((user,row[9]))
                if user != int(row[0]):     #if the user is different then increment. 
                    user = int(row[0]) + 1
                session.add(all_users_data)
                session.flush()
                user_goals_id = all_users_data.records  #Records and not their id???

            goals = list(set(goals))
            total_goals += len(goals)

            for val in goals:
                user_goals = AllUsersGoals(
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
