"""
Flask Documentation:     https://flask.palletsprojects.com/
Jinja2 Documentation:    https://jinja.palletsprojects.com/
Werkzeug Documentation:  https://werkzeug.palletsprojects.com/
This file contains the routes for your application.
"""
import os,json,csv,subprocess,time
import uuid
from app import app,db,login_manager,jwt
from flask import render_template, request, redirect, url_for, flash, session, abort,send_from_directory,jsonify
from app.models import ExpenseCategories,ExpenseList,IncomeChannel,Account,AllUsersData,RecommendationReport,Goals,UserMonthlyData
from werkzeug.utils import secure_filename
from decimal import Decimal
from datetime import timedelta, date  #change
import datetime
from dateutil.relativedelta import relativedelta
from werkzeug.security import check_password_hash
from flask_login import login_user, logout_user, current_user, login_required
from sqlalchemy import and_, text, extract
import pandas as pd
from flask_jwt_extended import create_access_token, jwt_required,get_jwt_identity

#to run flask, run flask --app Flask/app --debug run
#to migrate and dem tings deh, run  flask --app=Flask/App db init  and change init to smthn migrate/upgrade.
#git checkout main lib\main.dart to get UI file

###
# Routing for your application.
###

user_id = 0  #set back to 0 after testing
demo = False #set back to False after testing

@app.route('/login', methods=['POST', 'GET'])
def login(): 
    global user_id
    if (request.method=='POST'):
        #add get credentials from flutter
        email = request.form.get('email')
        email = email.lower()
        print(email)
        password = request.form.get('password')

        # Checks the username and password values from the flutter.
        user = db.session.execute(db.select(Account).filter_by(email=email)).scalar()
        

        if user is not None and check_password_hash(user.password, password): #checks password
            # Gets user id, load into session
            login_user(user)
            print("user.id in login:",user.id)
            access_token = create_access_token(identity=email)
            #print(access_token)
            
            user_id = user.id
            print("user_id in login:",user_id)
            user_goals = db.session.query(Goals).filter(and_(Goals.acc_id == user_id,Goals.name=='Other')).scalar()

            date = datetime.datetime.now()
            month,year=get_month_year(date)        
            if user_goals:              #user.username
                response_data = {'message': 'Success', 'beg_balance': user.beginning_balance, 'access_token': access_token,'month':month,'year':year, 'goal_amount': user_goals.goals, 'username':user.username}
                print('valid user',access_token)
            else: 
                response_data = {'message': 'Success', 'beg_balance': user.beginning_balance, 'access_token': access_token,'month':month,'year':year,'username':user.username}
                print('valid user',access_token)    
            return jsonify(response_data)
        else:
            response_data = {'message': 'Failed'}
            print('invalid user or incorrect credentials')
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
        print("Logged out User:", user_id, user.username)
        user_id = 0
        print(user_id)
        logout_user()
        response_data = {'message': 'Success'}
        return jsonify(response_data)

def get_expenses(month,year):   #based on id and month only
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

def get_income_channels(month,year):    #based on id and month only
    global user_id
    i_list = []

    #Gets data from DB (incomechannels) and place in list of dictionaries
    #incomechannels=db.session.query(IncomeChannel).filter(IncomeChannel.acc_id == user_id).all()
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
    print(date)
    month = date.month
    year = date.year

    return month,year

@app.route('/')
def home():
    """Render website's home page."""
    return render_template('home.html')

@app.route('/about/')
def about():
    """Render the website's about page."""
    return render_template('about.html', name="Bob")

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
        print("IncomeChannel",name,"of",monthly_earning,"has been added for user", user_id)  
        newIncomeChannel = IncomeChannel(name,monthly_earning,frequency,date,acc_id)
        db.session.add(newIncomeChannel)
        db.session.commit()       
        
        #time.sleep(2)
        newID=newIncomeChannel.id 

        response_data = {'message': newID}
        return jsonify(response_data)

@app.route('/populate',methods=['GET']) #get from db expense list and income list.
@jwt_required()
def populate():
    time.sleep(3) #helps prevent flutter running this before logging in the user.
    #current_user = get_jwt_identity()
    #print("WAH DIS"current_user)
    global user_id
    expenslis = []
    incomelis = []    

    """  """
    curr_date = datetime.datetime.now() #gets current date/time 
    month,year = get_month_year(curr_date)
    expenslis=get_expenses(month,year)
    incomelis=get_income_channels(month,year)
    return jsonify(expense=expenslis,income=incomelis)

    
    
    #Gets data from DB and place in list of dictionaries

    print('populate user_id',user_id, "commencing...")
    expenses = db.session.query(ExpenseList).filter(ExpenseList.acc_id == user_id).all()
    
    """ 
        expenses = db.session.query(ExpenseList).filter(and_(
        ExpenseList.acc_id == user_id,extract('year', ExpenseList.date) == 2023,
        extract('month', ExpenseList.date) == 6)).all()
    """
    
    #print('populate user_id',user_id)
    #print(expenses).

    #Gets data from DB (expenses) and place in list of dictionaries
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
    #incomechannels = db.session.execute(db.select(IncomeChannel).filter_by(acc_id=user_id)).all() #also add where the account id is the same as logged in
    
    #Gets data from DB (incomechannels) and place in list of dictionaries
    incomechannels=db.session.query(IncomeChannel).filter(IncomeChannel.acc_id == user_id).all()
    if incomechannels != []:
        for g in incomechannels: 
                i_list.append({
                    'id': g.id,
                    'name': g.name,
                    'monthly_earning': g.monthly_earning,
                    'frequency': g.frequency,
                    'date': g.date
                            })
            
    print(jsonify(expense=e_list,income=i_list))
    return jsonify(expense=e_list,income=i_list)


@app.route('/signup', methods=['POST', 'GET'])  
def signup(): 
    global user_id
    if (request.method=='POST'):
        email = request.form.get('email')
        password = request.form.get('password')
        username = request.form.get('username')
        beginning_balance = request.form.get('beginning_balance')
        date = datetime.datetime.now()
        #fix so that i have a route to check if its present in system
        # Gets the username and password values from the flutter.
        #also get  goals and beg_balance here

        user = db.session.execute(db.select(Account).filter_by(email=email)).scalar()

        if user is None: #checks if user present     
            print('signup',email,password)     
            #adduser = Account(email,password,beginning_balance,date,date)
            adduser = Account(email,password,beginning_balance,date,date,username)
            db.session.add(adduser)
            db.session.commit() #Login user

            newuser = db.session.execute(db.select(Account).filter_by(email=email)).scalar()
            # Gets user id, load into session
            login_user(newuser)
            print("signup user.id in login:",newuser.id)
            access_token = create_access_token(identity=email)
            #print(access_token)
            
            user_id = newuser.id
            print("signup in login:",user_id)
            
            date = datetime.datetime.now()
            month,year=get_month_year(date)  #newuser.username
            response_data = {'message': 'Success', 'beg_balance': newuser.beginning_balance, 'access_token': access_token,'month':month,'year':year,'username':newuser.username}
            print('valid user',access_token)
            return jsonify(response_data)
    
        else:
            print('email already in system!')
            response_data = {'message': 'error'}
            return jsonify(response_data)

@app.route('/signup/goals', methods=['POST', 'GET'])  
#@jwt_required()
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
        
            # else:
            #     print('email already in system!')
            #     response_data = {'message': 'email already in system!'}
            #     return jsonify(response_data)
    

@app.route('/remove',methods=['POST']) 
@jwt_required()
def remove():
    global user_id
    
    if (request.method=='POST'):
        
        table = request.form.get('table') #IncomeChannel #ExpenseList  #Classes in models.py
        recordID = request.form.get('record_id')

        #print(table)
        #print(recordID)

        table_obj = globals()[table] #Checks for this class in models.py 
        #print(table_obj)
        record = db.session.execute(db.select(table_obj).filter_by(id=recordID)).scalar()
        #record = db.session.execute(db.select(table).filter(and_(id.recordID == value1, table.column2 == value2))).scalar()
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


def run_script(): #not being used
    # Replace 'path_to_script.py' with the actual path to your Python script
    script_path = 'ReccomendationScripts\\reccomender.py'
    #result=None
    #result = subprocess.run(['python3', script_path], capture_output=True, text=True)
    result = subprocess.run(['python', script_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    #time.sleep(5)
    #return f"Script output: {result.stdout}"
    output= result.stdout.strip()
    try:
        needs, wants, savings = map(int, output.split(","))
        return needs, wants, savings
    except ValueError:
        print("Error parsing output")
        return None



##########################################################################################################
# The functions below should be applicable to all Flask apps.
###

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
##### #### ### ########### ##### # ######### ############  ########################
######## ###### ############# #### ############################################
############################ ###### ######## #################################




#This function returns True if num is within (abs)20% of the refnum 
def compare(refnum,num,val):
    diff= abs(((refnum-num)/((refnum+num)/2))*100)
    if diff<=val:
        return True
    else:
        return False

# This function scans the dataframe for users that meets the requirements of having within a 20% difference of income and
# expense of the current user.
#def recommend(vec2): #what it should be

def recommend_ratios(users):  #dictionary passes here

    path= 'ReccomendationScripts\csvs\sql_to_.csv'
    df=pd.read_csv(path)
    df = df.dropna()
    df = df.reset_index()
    df=df.drop(['index'],axis=1)

    df = df.drop(['Month'],axis=1)  
    

    #user value is the last entry within the table if tail was used
    user =  users#df.tail(1)
    lendf= len(df)-10
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
        if refvec1["Needs%"] > 50.00:
            return (20.00,20.00,60.00)
        return (50.00,30.00,20.00)


#@app.route('/recommendation/report',methods=['GET']) 
#@jwt_required() remove
def recommendation(): #how to simulate this?
    global user_id #remove l8r
    users=[]
    with open('ReccomendationScripts\\accountConverter.sql', 'r') as file:
        sql_script = file.read()
        with app.app_context(): #this runs for all users
            usertbl = db.session.execute(text(sql_script), {'acc_id': user_id}).fetchall() #places user info into AllUsersData format
    print('505',usertbl)
    if usertbl: 
        print(usertbl)
        #last_value = usertbl[-1]
        for j in usertbl: 
            #month needs to be changed.
            user_month_data = UserMonthlyData(j.acc_id,j.month,float(j.beginning_balancee),float(j.monthly_income),
                                          float(j.monthly_expenses),float(j.current_balance),float(j.wants_percentage),
                                          float(j.needs_percentage),float(j.savings),float(j.min_goal),float(j.max_goal),float(j.increase_decrease))
            db.session.add(user_month_data) #uncomment
            db.session.commit()  ##Dis should happen end of each month
            #create to add to all_user_data table

            users = {   
                        'Account_ID': j.acc_id,
                        'Month': j.month, #format needs to change.
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
    print('532',users)
        #return jsonify(users)  #should be in the for statement above

    bestSplits=None
    
    
    
    if (db.session.execute(db.select(AllUsersData)).scalar() != []):  #dis for smthn different
        make_csv()

    #ans=run_script() #remove

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

    db.session.add(send_to_rec_table) #Adds rec splits + current splits to DB
    db.session.commit() 


    # Return a JSON response with the recommendation data
    #return jsonify(splits)
    
    #We can have a section that would allow the user to pick their ratio. This would run the reccomend() function,
        #with the percentages as the parameters (so we need to figure how to add the record from the function's param)
        #SO the next function would be the result that would recomend the user what to cut.
        #So the sql also needs to for a specific month. So have the reccomend function run for reach month.


@app.route('/splits',methods=['GET']) #get from db RecommendationReport Cannot send this @start.because data will be different for each month in reccomendation section.
@jwt_required() #remove function....not needed no more as u cant get current splits, so change to last months
def send_splits(): 
    time.sleep(1) #try removing
    new_month_update() #Check if its a 1st of a month
    global user_id
    recList = [] #get last month splits.
    recSplits = db.session.query(RecommendationReport).filter(RecommendationReport.acc_id == user_id).all()
    #change to get current month
    print('populate user_id',user_id)
    print(recSplits)
    
    #how to make 
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
                'beginning_balance': f'{round(float(rec.beginning_balance), 2)}' #READD/APPLY            
                            })
                print(recList)
    return jsonify(splits=recList)

    #run the function that goes to another page for smooth update
    #if statement for when the ting empty
    #app state, create controller,and 
    #if themm ask bout secuity, den jah...need to workpon dat.
    #Adding commmas to money values 
    #Create a function that runs every month to do a rollover ting so  user should have option to cancel subscription or monthly tings.
        #Store another table that would have a true/false column for rolover which would be checked when adding an expense.
            #also would have to remove it from the table at the end of month den.
    #:if the user has an increase meds there movements
    #at least have in settings to set their default ratio wants/needs/savings.
    #Notification for a monthly payment
    #recommendation value be close to the original if they dont find a given user....cuz the user 1 rn recommendation kinda ugly
    #tolower() input values for login //done
    #have a threshold for expenses that +higher than max value (change to 700k)
    #Give a on click buttonto add a given goal to the expense list if reached. Can automatically make it a tier 3 want / need maybe SO as to not recommend to reuce it at the end of the month 


@app.route('/month/data',methods=['POST']) #get from db expense list and income list.
#@jwt_required()
def month_data():
    time.sleep(1)
    global user_id
    #e_list = []
    #i_list = []
    recList = []


    target_year = request.form.get('year')
    target_month = request.form.get('month')

    #target_year = '8'
    #target_month = '2023'
    
    
    #month,year = get_month_year(curr_date)
    #print()
    e_list=get_expenses(target_month,target_year)
    i_list=get_income_channels(target_month,target_year)

    recSplits = db.session.query(RecommendationReport).filter(and_(
        RecommendationReport.acc_id == user_id,extract('year', RecommendationReport.date) == target_year,
        extract('month', RecommendationReport.date) == target_month)).all()
    '''  
    #expenses = db.session.execute(db.select(ExpenseList)).scalars() #also addd where the account id is the same as logged in
    expenses = db.session.query(ExpenseList).filter(and_(
        ExpenseList.acc_id == user_id,extract('year', ExpenseList.date) == target_year,
        extract('month', ExpenseList.date) == target_month)).all()
    
    incomechannels = db.session.query(IncomeChannel).filter(and_(
        IncomeChannel.acc_id == user_id,extract('year', IncomeChannel.date) == target_year,
        extract('month', IncomeChannel.date) == target_month)).all()
    
    
    #incomechannels = db.session.execute(db.select(table).filter(and_(id.recordID == value1, table.column2 == value2))).scalar()

    
    #Expenses
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
    #incomechannels = db.session.execute(db.select(IncomeChannel).filter_by(acc_id=user_id)).all() #also add where the account id is the same as logged in
    #incomechannels=db.session.query(IncomeChannel).filter(IncomeChannel.acc_id == user_id).all()
    
    #Income Channels
    if incomechannels != []:
        for g in incomechannels: 
                i_list.append({
                    'id': g.id,
                    'name': g.name,
                    'monthly_earning': g.monthly_earning,
                    'frequency': g.frequency,
                    'date': g.date
                            })
    '''
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
                #'increase_decrease': '20.00'
                            })
    print(jsonify(expense=e_list,income=i_list,splits=recList))
    return jsonify(expense=e_list,income=i_list,splits=recList)


@app.route('/test', methods=['GET'])
def test():
    make_csv()
    
    
    
def rollover(): #runs for at the end of the month
    #target_year = request.form.get('year')
    #target_month = request.form.get('month')
    global user_id
    # target_year = 2023
    # target_month = 7 
    target_month,target_year = get_month_year(datetime.datetime.now())
    target_month-=1 #UNCOMMENT if not testing
    
    #user_id = 2 #used for testing...remove
    roll_list = []

    #if item == 'expense':
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
            #also create a table that allows user to choose if they want to rollover or not
    #else:
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

    #print(expenses)
    for j in roll_list:
        #print(j['date'])

        # Convert the timestamps to datetime objects
        #datetime_objects = datetime.strptime(str(j['date']), '%Y-%m-%d %H:%M:%S.%f')

        # Add one month to each datetime object
        #j['date'] = (datetime_objects + timedelta(days=30)).replace(day=1) 
        j['date'] = j['date'] + relativedelta(months=1)

        #Add user to expense to next month
        if j['roll_type'] == 'expense':
            newExpense = ExpenseList(j['name'],j['cost'],j['tier'],j['expense_type'],j['frequency'],j['date'],user_id)
            db.session.add(newExpense)
        # db.session.commit()
        else:
            newIncomeChannel = IncomeChannel(j['name'],j['monthly_earning'],j['frequency'],j['date'],user_id)
            db.session.add(newIncomeChannel)
    db.session.commit() 
    
    
    #add expense to next5 month.
    return jsonify(exp=roll_list)

def reduce_recommendation(): #work  on now
    e_list =[]
    target_month,target_year = get_month_year(datetime.datetime.now())
    #target_month-=1 #UNCOMMENT if not for testing   #For previous month
    
    #expenses=get_expenses(target_month,target_year)
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
    #for 

    



#Savings to goal
#Features to add to the system in the next
#Recommend closely to value 
#Cap being 700K
#recommend 60% 40% for a goal


def new_month_update():  #Runs @login but does update @the start of a new month 
    global user_id
    #should run before recommended splits are sent to the DB
    user = db.session.execute(db.select(Account).filter_by(id=user_id)).scalar()   
    # start_month,start_year = get_month_year(user.signup_date)
    # current_month,current_year = get_month_year(datetime.datetime.now()) 
    now=datetime.datetime.now()
    print("now,isn",now)
    # Get the current date
    current_date = date.today()
    print('currentday',current_date)

    # Extract the day from the current date
    current_day = current_date.day
    if not demo:
        if current_day==1: #check the current date yzm ##This runs less when comparing other if statement
            # if (current_year != start_year) and (current_month != start_month):
            if now-user.signup_date >= 10:  #can change value change to something different
                # can send a text ofer to flutter, theres not enought time given to do calculations..
                recommendation()
                rollover()
                #reduce_recommendation()

                #return [] #change
            else:
                return 0 #tell the user dem cah see nthn or send to flutter an empty list
        #return []
    else:
        print('Running Else condition')
        recommendation()
        rollover()
        #reduce_recommendation()
            
    #beginning_balance = db.Column(db.Numeric(10, 2))