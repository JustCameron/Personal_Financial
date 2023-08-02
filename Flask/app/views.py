"""
Flask Documentation:     https://flask.palletsprojects.com/
Jinja2 Documentation:    https://jinja.palletsprojects.com/
Werkzeug Documentation:  https://werkzeug.palletsprojects.com/
This file contains the routes for your application.
"""
import os,json,csv,subprocess,time
import uuid
from app import app,db,login_manager,jwt
from flask import render_template, request, session,jsonify
from app.models import ExpenseList,IncomeChannel,Account,AllUsersData,RecommendationReport,Goals,UserMonthlyData
from werkzeug.utils import secure_filename
from decimal import Decimal
from datetime import timedelta, date 
import datetime
from dateutil.relativedelta import relativedelta
from werkzeug.security import check_password_hash
from flask_login import login_user, logout_user, current_user
from sqlalchemy import and_, text, extract
import pandas as pd
from flask_jwt_extended import create_access_token, jwt_required,get_jwt_identity

#to run flask, run flask --app Flask/app --debug run
#to migrate and dem tings deh, run  flask --app=Flask/App db init  and change init to  migrate/upgrade.
#git checkout main lib\main.dart to get UI file

###
# Routing for your application.
###

user_id = 0  ##Id of currently signed user     #set back to 0 after testing
demo = False #set back to False after testing get month data found in send_splits

@app.route('/login', methods=['POST', 'GET'])
def login(): 
    global user_id
    if (request.method=='POST'):
        #gets credentials from flutter
        email = request.form.get('email')
        email = email.lower()
        password = request.form.get('password')

        # Checks the username and password values from the flutter.
        user = db.session.execute(db.select(Account).filter_by(email=email)).scalar()
        

        if user is not None and check_password_hash(user.password, password): #checks password
            # Gets user id, load into session
            login_user(user)
            #print("user.id in login:",user.id)
            access_token = create_access_token(identity=email)
            #print(access_token)
            
            user_id = user.id
            print("user_id logged in:",user_id)
            user_goals = db.session.query(Goals).filter(and_(Goals.acc_id == user_id,Goals.name=='Other')).scalar()

            date = datetime.datetime.now()
            month,year=get_month_year(date)        

            ##Sends user data 
            if user_goals:           
                response_data = {'message': 'Success', 'beg_balance': user.beginning_balance, 'access_token': access_token,'month':month,'year':year, 'goal_amount': user_goals.goals, 'username':user.username}
                #print('valid user',access_token)
            else: 
                response_data = {'message': 'Success', 'beg_balance': user.beginning_balance, 'access_token': access_token,'month':month,'year':year,'username':user.username}
                #print('valid user',access_token)    
            return jsonify(response_data)
        else:
            response_data = {'message': 'Failed'}
            #print('invalid user or incorrect credentials')
            return jsonify(response_data)

@login_manager.user_loader
def load_user(id):   
    return db.session.execute(db.select(Account).filter_by(id=id)).scalar()   

@app.route('/logout', methods=['POST'] )
def logout():
    global user_id
    if (request.method=='POST'):
        user = db.session.execute(db.select(Account).filter_by(id=user_id)).scalar()
        user.last_login_date = datetime.datetime.now()
        db.session.commit()   
        #print("Logged out User:", user_id, user.username)
        user_id = 0
        #print(user_id)
        logout_user()
        response_data = {'message': 'Success'}
        return jsonify(response_data)

def get_expenses(month,year):   #based on id, month and year 
    global user_id
    e_list = []

    expenses = db.session.query(ExpenseList).filter(and_(
        ExpenseList.acc_id == user_id,extract('year', ExpenseList.date) == year,
        extract('month', ExpenseList.date) == month)).all()
    if expenses != []:
        for g in expenses: 
            e_list.append({
                'id': g.id,
                'name': g.name,
                'cost': g.cost,
                'tier': g.tier,
                'expense_type': g.expense_type,
                'frequency': g.frequency,
                'date': g.date
                        })
    return e_list

def get_income_channels(month,year):    #based on id, month and year 
    global user_id
    i_list = []

    incomechannels = db.session.query(IncomeChannel).filter(and_(
        IncomeChannel.acc_id == user_id,extract('year', IncomeChannel.date) == year,
        extract('month', IncomeChannel.date) == month)).all()

    if incomechannels != []:
        for g in incomechannels: 
            i_list.append({
                'id': g.id,
                'name': g.name,
                'monthly_earning': g.monthly_earning,
                'frequency': g.frequency,
                'date': g.date
                })
    return i_list

def get_month_year(date_str):
    date_str=str(date_str)
    date_str = str(date_str.split()[0])
    date = datetime.datetime.strptime(date_str, '%Y-%m-%d')
    #date = datetime.datetime.now()
    #print(date)
    month = date.month
    year = date.year

    return month,year

@app.route('/expense/add',methods=['POST']) #Sends expense added to db
@jwt_required()
def add_expense():
    global user_id
    if (request.method=='POST'):  
        #gets form data
        name = request.form.get('name')
        cost = request.form.get('cost')
        tier = request.form.get('tier')
        expense_type = request.form.get('expenseType')
        frequency = request.form.get('frequency')
        date = datetime.datetime.now() #gets current date/time also use to run get expenses
        acc_id = user_id

        #print(name,cost,tier,expense_type,frequency,date,acc_id)     
        print("Expense",name,"of",cost,"has been added for user", user_id)  

        #Adds to database
        newExpense = ExpenseList(name,cost,tier,expense_type,frequency,date,acc_id)
        db.session.add(newExpense)
        db.session.commit()        

        newID=newExpense.id
        response_data = {'message': newID}
        return jsonify(response_data)

@app.route('/incomeChannel/add',methods=['POST']) #Sends income_channel added to db
@jwt_required()
def add_income_channel():
    global user_id
    if (request.method=='POST'):
        
        name = request.form.get('name')
        monthly_earning = request.form.get('monthly_earning')
        frequency = request.form.get('frequency')
        date = datetime.datetime.now() #gets current date/time 
        acc_id = user_id
        
        #print(name,monthly_earning,frequency,date,acc_id)   
        #print("IncomeChannel",name,"of",monthly_earning,"has been added for user", user_id)  
        
        #Adds to database
        newIncomeChannel = IncomeChannel(name,monthly_earning,frequency,date,acc_id)
        db.session.add(newIncomeChannel)
        db.session.commit()       
        
        newID=newIncomeChannel.id 

        response_data = {'message': newID}
        return jsonify(response_data)

@app.route('/populate',methods=['GET']) #get from db expense list and income list.
@jwt_required()
def populate():
    time.sleep(3) #helps prevent flutter running this before logging in the user.
    global user_id
    expenslis = []
    incomelis = []    

    curr_date = datetime.datetime.now() #gets current date/time 
    month,year = get_month_year(curr_date)
    expenslis=get_expenses(month,year)
    incomelis=get_income_channels(month,year)
    return jsonify(expense=expenslis,income=incomelis)

#This route is not jwt required as the user is not yet added to the database
@app.route('/signup', methods=['POST', 'GET'])  
def signup(): 
    global user_id
    if (request.method=='POST'):
        email = request.form.get('email')
        password = request.form.get('password')
        username = request.form.get('username')
        beginning_balance = request.form.get('beginning_balance')
        date = datetime.datetime.now()
        # Gets new user "Account" table details from the flutter.
    

        user = db.session.execute(db.select(Account).filter_by(email=email)).scalar()

        if user is None: #checks if user present     
            print('signup',email,password)     
            adduser = Account(email,password,beginning_balance,date,date,username)
            db.session.add(adduser)
            db.session.commit() 
            
            #Login user
            newuser = db.session.execute(db.select(Account).filter_by(email=email)).scalar()
            # Gets user id, load into session
            login_user(newuser)

            #print("signup user.id in login:",newuser.id)
            access_token = create_access_token(identity=email)
            
            user_id = newuser.id
            print("signup in login:",user_id)
            
            date = datetime.datetime.now()
            month,year=get_month_year(date)  
            response_data = {'message': 'Success', 'beg_balance': newuser.beginning_balance, 'access_token': access_token,'month':month,'year':year,'username':newuser.username}
            #print('valid user',access_token)
            return jsonify(response_data)
    
        else:
            print('email already in system!')
            response_data = {'message': 'error'}
            return jsonify(response_data)

#This route is not jwt required as the user is not yet added to the database
@app.route('/signup/goals', methods=['POST', 'GET'])  
def add_goals(): 
    time.sleep(1)
    global user_id
    if (request.method=='POST'):
        data = request.form.to_dict()
        for key, value in data.items():
            print(key, value)
            goals = Goals(user_id,key,value)
            db.session.add(goals)

        db.session.commit()
        response_data = {'message': 'Success'}
        return jsonify(response_data)
    

@app.route('/remove',methods=['POST']) 
@jwt_required()
def remove():
    global user_id
    
    if (request.method=='POST'):
        
        table = request.form.get('table') #IncomeChannel or ExpenseList Tables
        recordID = request.form.get('record_id')

        #print(table)
        #print(recordID)

        table_obj = globals()[table] #Checks for this class in models.py 
        #print(table_obj) 

        record = db.session.execute(db.select(table_obj).filter_by(id=recordID)).scalar()
       
        print("Record",record.name,"in",table, "has been removed.")
        db.session.delete(record) #removes record in DB
        db.session.commit()        

        response_data = {'message': 'Success'}
        return jsonify(response_data)
    

def make_csv():
    # Query the table in DB and fetch the data into a list of dictionaries
    table_data = db.session.query(AllUsersData).all()

    # Define the CSV file path and name
    csv_file_path = 'ReccomendationScripts\\csvs\\sql_to_.csv' #change this
    

    # Write the data to the CSV file
    with open(csv_file_path, 'w', newline='') as csvfile:
        fieldnames = ['Records','Account_ID','Month', 'Beginning_Balance', 'Monthly_Income','Monthly_Expense', 'Current_Balance', 'Wants%', 'Needs%','Savings%', 'Min_Goal','Max_Goal','Increase_Decrease']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # Write the header row
        writer.writeheader()

        # Write each row of data
        for row in table_data:
            writer.writerow({
                'Records': row.records,
                'Account_ID': row.acc_id,
                'Month': row.month,
                'Beginning_Balance': row.beginning_balance,
                'Monthly_Income': row.monthly_income,
                'Monthly_Expense': row.monthly_expense,
                'Current_Balance': row.current_balance,
                'Wants%': row.wants_percent,
                'Needs%': row.needs_percent,
                'Savings%': row.savings_percent,
                'Min_Goal': row.min_goal,
                'Max_Goal': row.max_goal,
                'Increase_Decrease': row.increase_decrease
            })


#Used for testing.
# Display Flask WTF errors as Flash messages
def flash_errors(form):
    for field, errors in form.errors.items():
        for error in errors:
            flash(u"Error in the %s field - %s" % (
                getattr(form, field).label.text,
                error
            ), 'danger')

@app.route('/<file_name>.txt')
def send_text_file(file_name):
    """Send your static text file."""
    file_dot_text = file_name + '.txt'
    return app.send_static_file(file_dot_text)


@app.after_request
def add_header(response):
    """
    Add headers to both force latest IE rendering engine or Chrome Frame,
    and also tell the browser not to cache the rendered page. If we wanted
    to we could change max-age to 600 seconds which would be 10 minutes.
    """
    response.headers['X-UA-Compatible'] = 'IE=Edge,chrome=1'
    response.headers['Cache-Control'] = 'public, max-age=0'
    return response


@app.errorhandler(404)
def page_not_found(error):
    """Custom 404 page."""
    return render_template('404.html'), 404

############## ########### ################## ################################




#This function returns True if num is within (abs)20% of the refnum 
def compare(refnum,num,val):
    diff= abs(((refnum-num)/((refnum+num)/2))*100)
    if diff<=val:
        return True
    else:
        return False

# This function scans the dataframe for users that meets the requirements of-
# having within a 20% difference of income and expense of the current user.


def recommend_ratios(users):  #dictionary passes here

    path= 'ReccomendationScripts\csvs\sql_to_.csv'
    df=pd.read_csv(path)
    df = df.dropna()
    df = df.reset_index()
    df=df.drop(['index'],axis=1)

    df = df.drop(['Month'],axis=1)  
    
    user =  users
    lendf= len(df)
    head=df.head(lendf)
    
    refvec1=user 
    vec2=head
    
    indx=[]
    Monthly_Income=refvec1["Monthly_Income"] # user monthly income
    Monthly_Expense=refvec1["Monthly_Expense"] #user monthly expense
    user_needs=refvec1["Needs%"] 
    for index,row in vec2.iterrows():
        if  compare(row["Monthly_Income"],int(Monthly_Income),20) and compare(row["Monthly_Expense"],int(Monthly_Expense),20)and row["Increase_Decrease"]>0 :
            if compare(row["Needs%"],int(user_needs),30):
                indx.append(index)
    if indx != []:
        df_filtered=vec2.filter(items=indx,axis=0)
        needs=int(df_filtered["Needs%"].mean())
        wants=int(df_filtered["Wants%"].mean())
        savings= 100 - (needs+wants)
        return needs,wants,savings
    else:
        if refvec1["Needs%"] > 50.00 and refvec1["Needs%"]> 0.00:
            return (20.00,20.00,60.00)
        return (50.00,30.00,20.00)


def recommendation(): 
    global user_id 
    users=[]
    with open('ReccomendationScripts\\accountConverter.sql', 'r') as file: 
        sql_script = file.read()
        with app.app_context(): 
            #gets user info from the previous monthand converts into AllUsersData format
            usertbl = db.session.execute(text(sql_script), {'acc_id': user_id}).fetchall() 
    if usertbl: 
        print(usertbl)
        for j in usertbl: 
            user_month_data = UserMonthlyData(j.acc_id,j.month,float(j.beginning_balancee),float(j.monthly_income),
                                          float(j.monthly_expenses),float(j.current_balance),float(j.wants_percentage),
                                          float(j.needs_percentage),float(j.savings),float(j.min_goal),float(j.max_goal),float(j.increase_decrease))
            db.session.add(user_month_data) 
            db.session.commit()  #This should happen end of each month and then later added to AllUsersData
            #create to add to all_user_data table

            users = {   
                'Account_ID': j.acc_id,
                'Month': j.month, 
                'Beginning_Balance': float(j.beginning_balancee),
                'Current_Balance': float(j.current_balance),
                'Monthly_Income': float(j.monthly_income),
                'Monthly_Expense': float(j.monthly_expenses),
                'Wants%': float(j.wants_percentage),
                'Needs%': float(j.needs_percentage),
                'Savings%': float(j.savings),
                'Min_Goal': float(j.min_goal),
                'Max_Goal': float(j.max_goal),
                'Increase_Decrease': float(j.increase_decrease)
                }

    bestSplits=None
    
    if (db.session.execute(db.select(AllUsersData)).scalar() != []):  #Creates csv of All User Data
        make_csv()


    bestSplits = recommend_ratios(users)  #gets the ratios based on all users in db
    print("Recommendation Splits are as follows",bestSplits)

    splits = {
        'rwants': bestSplits[1],
        'rneeds': bestSplits[0],
        'rsavings': bestSplits[2]
    }

    send_to_rec_table = RecommendationReport(users['Account_ID'],users['Month'],users['Wants%'],users['Needs%'],users['Savings%'],splits['rwants'],splits['rneeds'],splits['rsavings'],users['Increase_Decrease'],users['Beginning_Balance'])
    userAcc= db.session.execute(db.select(Account).filter_by(id=user_id)).scalar()   
    userAcc.beginning_balance = users['Current_Balance']  
    #changes the balance user had at the end of the month to the beginning_balnce of new month

    #Adds rec splits + current splits to DB
    db.session.add(send_to_rec_table) 
    db.session.commit() 


@app.route('/splits',methods=['GET']) 
@jwt_required() #Should get previous month data, but for demo, current month was used.
def send_splits(): 
    time.sleep(1) 
    #new_month_update() #Checks if its a 1st of a month
    global user_id
    recList = [] #get last month splits.
    recSplits = db.session.query(RecommendationReport).filter(RecommendationReport.acc_id == user_id).all()
    #change to get current month
    print('populate user_id',user_id)
    print(recSplits)
    
 
    if recSplits != []:
        #recSplits = recSplits[-1]
        for rec in recSplits: 
                recList.append({
                'id': rec.id,
                'acc_id': rec.acc_id,
                'date': rec.date,
                'wants': f'{round(float(rec.wants), 2)}', 
                'needs': f'{round(float(rec.needs), 2)}',  
                'savings': f'{round(float(rec.savings), 2)}', 
                'rwants': f'{round(float(rec.rwants), 2)}',  
                'rneeds': f'{round(float(rec.rneeds), 2)}', 
                'rsavings': f'{round(float(rec.rsavings), 2)}',  
                'increase_decrease': f'{round(float(rec.increase_decrease), 2)}',     
                'beginning_balance': f'{round(float(rec.beginning_balance), 2)}'      
                            })
                print(recList)
    return jsonify(splits=recList)


@app.route('/month/data',methods=['POST']) #get from db expense list, income channel list adnd recommended splits
def month_data():
    time.sleep(1)
    global user_id
    recList = []

    target_year = request.form.get('year')
    target_month = request.form.get('month')
    
    e_list=get_expenses(target_month,target_year)
    i_list=get_income_channels(target_month,target_year)

    recSplits = db.session.query(RecommendationReport).filter(and_(
        RecommendationReport.acc_id == user_id,extract('year', RecommendationReport.date) == target_year,
        extract('month', RecommendationReport.date) == target_month)).all()

    #Recommendation of Splits    
    if recSplits != []:
        for rec in recSplits: 
                recList.append({
                'id': rec.id,
                'acc_id': rec.acc_id,
                'date': rec.date,
                'wants': f'{round(float(rec.wants), 2)}', 
                'needs': f'{round(float(rec.needs), 2)}',  
                'savings': f'{round(float(rec.savings), 2)}', 
                'rwants': f'{round(float(rec.rwants), 2)}',  
                'rneeds': f'{round(float(rec.rneeds), 2)}', 
                'rsavings': f'{round(float(rec.rsavings), 2)}',  
                'increase_decrease': f'{round(float(rec.increase_decrease), 2)}', 
                'beginning_balance': f'{round(float(rec.beginning_balance), 2)}'
                            })
    print(jsonify(expense=e_list,income=i_list,splits=recList))
    return jsonify(expense=e_list,income=i_list,splits=recList)



    
    
    
def rollover(): #runs for at the end of the month
    global user_id
    target_month,target_year = get_month_year(datetime.datetime.now())
    target_month-=1 #UNCOMMENT if not testing
    roll_list = []

    expenses = db.session.query(ExpenseList).filter(and_(
        ExpenseList.acc_id == user_id,extract('year', ExpenseList.date) == target_year,
        extract('month', ExpenseList.date) == target_month),ExpenseList.frequency == 'Monthly').all()
    if expenses != []:
        for g in expenses: 
                roll_list.append({
                    'roll_type': 'expense',
                    'id': g.id,
                    'name': g.name,
                    'cost': g.cost,
                    'tier': g.tier,
                    'expense_type': g.expense_type,
                    'frequency': g.frequency,
                    'date': g.date
                        })
 
    incomechannels = db.session.query(IncomeChannel).filter(and_(
        IncomeChannel.acc_id == user_id,extract('year', IncomeChannel.date) == target_year,
        extract('month', IncomeChannel.date) == target_month),IncomeChannel.frequency == 'Monthly').all()
    if incomechannels != []:
        for g in incomechannels: 
            roll_list.append({
                'roll_type': 'incomechannel',
                'id': g.id,
                'name': g.name,
                'monthly_earning': g.monthly_earning, #
                'frequency': g.frequency,
                'date': g.date
            })

    for j in roll_list:
        j['date'] = j['date'] + relativedelta(months=1)

        #Add user to expense and or income channel to next month
        if j['roll_type'] == 'expense':
            newExpense = ExpenseList(j['name'],j['cost'],j['tier'],j['expense_type'],j['frequency'],j['date'],user_id)
            db.session.add(newExpense)
        else:
            newIncomeChannel = IncomeChannel(j['name'],j['monthly_earning'],j['frequency'],j['date'],user_id)
            db.session.add(newIncomeChannel)
    db.session.commit() 
    
    
    #add expense/channel to next5month.
    return jsonify(exp=roll_list)

def reduce_recommendation(): 
    e_list =[]
    target_month,target_year = get_month_year(datetime.datetime.now())
    expenses = db.session.query(ExpenseList).filter(and_(
        ExpenseList.acc_id == user_id,extract('year', ExpenseList.date) == target_year,
        extract('month', ExpenseList.date) == target_month),ExpenseList.tier == 'T2').all()
    expenses.extend( db.session.query(ExpenseList).filter(and_(
        ExpenseList.acc_id == user_id,extract('year', ExpenseList.date) == target_year,
        extract('month', ExpenseList.date) == target_month),ExpenseList.tier == 'T3').all())
    
    print(expenses)
    if expenses != []:
        for g in expenses: 
            e_list.append({
                'id': g.id,
                'name': g.name,
                'cost': g.cost,
                'tier': g.tier,
                'expense_type': g.expense_type,
                'frequency': g.frequency,
                'date': g.date
                        })
    return jsonify(reduce=e_list)
    
def new_month_update(): 
    global user_id
    #should run before recommended splits are sent to the DB
    user = db.session.execute(db.select(Account).filter_by(id=user_id)).scalar()   
    start_month,start_year = get_month_year(user.signup_date)
    last_login_month,last_login_year = get_month_year(user.signup_date)
    current_month,current_year = get_month_year(datetime.datetime.now()) 
    now=datetime.datetime.now()
    print("now,isn",now)
    # Get the current date
    current_date = date.today()
    print('currentday',current_date)

    # Extract the day from the current date
    current_day = current_date.day
    if not demo:
        
            if ((current_year == start_year) and (current_month != start_month)) :
                if now-user.signup_date >= 10:  #can change value change to something different with more research
                    recommendation()
                    rollover()
                    reduce_recommendation()
                else:
                    return []
    else:
        print('Running Else condition')
        recommendation()
        rollover()
        reduce_recommendation()
            



@app.route('/test')
def test():
    global user_id
    user_id=17
    recommendation()


