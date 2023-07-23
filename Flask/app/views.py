"""
Flask Documentation:     https://flask.palletsprojects.com/
Jinja2 Documentation:    https://jinja.palletsprojects.com/
Werkzeug Documentation:  https://werkzeug.palletsprojects.com/
This file contains the routes for your application.
"""
import os,json,csv,subprocess,time
from app import app,db,login_manager
from flask import render_template, request, redirect, url_for, flash, session, abort,send_from_directory,jsonify
from app.models import ExpenseCategories,ExpenseList,IncomeChannel,Account,AllUserData,RecommendationReport
from werkzeug.utils import secure_filename
from decimal import Decimal
import datetime
from werkzeug.security import check_password_hash
from flask_login import login_user, logout_user, current_user, login_required
from sqlalchemy import and_, text
import pandas as pd

#to run flask, run flask --app Flask/app --debug run
#to migrate and dem tings deh, run  flask --app=Flask/App db init  and change init to smthn migrate/upgrade.
#git checkout main lib\main.dart to get UI file

###
# Routing for your application.
###

user_id = 0

@app.route('/login', methods=['POST', 'GET'])
def login(): 
    global user_id
    if (request.method=='POST'):
        email = request.form.get('email')
        print(email)
        password = request.form.get('password')
        # Get the username and password values from the flutter.
        user = db.session.execute(db.select(Account).filter_by(email=email)).scalar()

        if user is not None and check_password_hash(user.password, password): #checks password
            
            # Gets user id, load into session
            login_user(user)
            print("user.id in login:",user.id)
            user_id = user.id
            print("user_id in login:",user_id)
            #print(current_user.is_authenticated())
            
            response_data = {'message': 'Success'}
            print('valid user')
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
        print(user_id)
        user_id = 0
        print(user_id)
        logout_user()
        response_data = {'message': 'Success'}
        return jsonify(response_data)

@app.route('/')
def home():
    """Render website's home page."""
    return render_template('home.html')

@app.route('/about/')
def about():
    """Render the website's about page."""
    return render_template('about.html', name="Bob")

@app.route('/expense/add',methods=['POST']) #Sends expense added to db
def add_expense():
    global user_id
    if (request.method=='POST'):
        
        name = request.form.get('name')
        cost = request.form.get('cost')
        tier = request.form.get('tier')
        expense_type = request.form.get('expenseType')
        frequency = request.form.get('frequency')
        date = datetime.datetime.now() #assuming we get current date/time and place it in the DB
        acc_id = user_id

        print(name,cost,tier,expense_type,frequency,date,acc_id)     
        newExpense = ExpenseList(name,cost,tier,expense_type,frequency,date,acc_id)
        db.session.add(newExpense)
        db.session.commit()        

        newID=newExpense.id
        response_data = {'message': newID}
        return jsonify(response_data)

@app.route('/incomeChannel/add',methods=['POST']) #Sends income_channel added to db
def add_income_channel():
    global user_id
    if (request.method=='POST'):
        
        name = request.form.get('name')
        monthly_earning = request.form.get('monthly_earning')
        frequency = request.form.get('frequency')
        date = datetime.datetime.now() #assuming we get current date/time and place it in the DB
        acc_id = user_id
        
        print(name,monthly_earning,frequency,date,acc_id)     
        newIncomeChannel = IncomeChannel(name,monthly_earning,frequency,date,acc_id)
        db.session.add(newIncomeChannel)
        db.session.commit()       
        
        #time.sleep(2)
        newID=newIncomeChannel.id 

        response_data = {'message': newID}
        return jsonify(response_data)

@app.route('/populate',methods=['GET']) #get from db expense list and income list.
def populate():
    time.sleep(2)
    global user_id
    e_list = []
    i_list = []

    #expenses = db.session.execute(db.select(ExpenseList)).scalars() #also addd where the account id is the same as logged in
    expenses = db.session.query(ExpenseList).filter(ExpenseList.acc_id == user_id).all()
    print('populate user_id',user_id)
    print(expenses)
    
    if expenses == []:
        return []
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
    incomechannels=db.session.query(IncomeChannel).filter(IncomeChannel.acc_id == user_id).all()
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
    if (request.method=='POST'):
        email = request.form.get('email')
        password = request.form.get('password')
        # Get the username and password values from the flutter.

        user = db.session.execute(db.select(Account).filter_by(email=email)).scalar()

        if user is None: #checks if user present
            
            print(email,password)     
            newuser = Account(email,password)
            db.session.add(newuser)
            db.session.commit() #LOGIN USER AFTER DIS
            
            response_data = {'message': 'Success'}
            print('200')
            return jsonify(response_data)
        else:
            print('email already in system!')
            response_data = {'message': 'Failed'}
            return jsonify(response_data)

@app.route('/remove',methods=['POST']) #
def remove():
    global user_id
    
    if (request.method=='POST'):
        
        table = request.form.get('table') #IncomeChannel #ExpenseList
        recordID = request.form.get('record_id')
        record = db.session.execute(db.select(table).filter_by(id=recordID)).scalar()
        #record = db.session.execute(db.select(table).filter(and_(id.recordID == value1, table.column2 == value2))).scalar()
    
        db.session.delete(record)
        db.session.commit()        

        #flutter code
        #final sendExpense= {'table': 'ModelTableName', 'record_id': 'bro idek.'};                                
        #final sentExpense= MyApp.of(context).flaskConnect.sendData('remove', sendExpense);

        response_data = {'message': 'Success'}
        return jsonify(response_data)
    

def make_csv():
    # Query the table and fetch the data into a list of dictionaries
    #table_data = session.query(AllUserData).all()
    table_data = db.session.query(AllUserData).all()

    # Define the CSV file path and name
    csv_file_path = 'ReccomendationScripts\\csvs\\sql_to_.csv' #change this
    

    # Write the data to the CSV file
    with open(csv_file_path, 'w', newline='') as csvfile:
        #fieldnames = ['id', 'name', 'cost', 'tier', 'expense_type', 'frequency', 'date', 'acc_id']
        #Needs_Percent changed to Needs%
        fieldnames = ['Records','Account_ID','Start_Date', 'Current_Date', 'Beginning_Balance', 'Monthly_Income','Monthly_Expense', 'Current_Balance', 'Wants%', 'Needs%','Savings%', 'Min_Goal','Max_Goal','Budget_Increase']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # Write the header row
        writer.writeheader()

        # Write each row of data
        for row in table_data:
            writer.writerow({
                'Records': row.records,
                'Account_ID': row.acc_id,
                'Start_Date': row.start_date,
                'Current_Date': row.curr_date,
                'Beginning_Balance': row.beginning_balance,
                'Monthly_Income': row.monthly_income,
                'Monthly_Expense': row.monthly_expense,
                'Current_Balance': row.current_balance,
                'Wants%': row.wants_percent,
                'Needs%': row.needs_percent,
                'Savings%': row.savings_percent,
                'Min_Goal': row.min_goal,
                'Max_Goal': row.max_goal,
                'Budget_Increase': row.budget_increase
            })


def run_script():
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
def compare(refnum,num):
    diff= abs(((refnum-num)/((refnum+num)/2))*100)
    if diff<=20:
        return True
    else:
        return False

# This function scans the dataframe for users that meets the requirements of having within a 20% difference of income and
# expense of the current user.
#def recommend(vec2): #what it should be
def recommend_ratios():
    path= 'ReccomendationScripts\csvs\sql_to_.csv'
    df=pd.read_csv(path)
    df = df.dropna()
    df = df.reset_index()
    df=df.drop(['index'],axis=1)

    df = df.drop(['Start_Date','Current_Date'],axis=1)

    #user value is the last entry within the table:
    user = df.tail(1)
    lendf= len(df)-20
    head=df.head(lendf)
    
    refvec1=user 
    vec2=head
    
    indx=[]
    Monthly_Income=refvec1["Monthly_Income"] # user monthly income
    Monthly_Expense=refvec1["Monthly_Income"] #user monthly expense
    for index,row in vec2.iterrows():
        if  compare(row["Monthly_Income"],int(Monthly_Income)) and compare(row["Monthly_Expense"],int(Monthly_Expense)) and row["Budget_Increase"]>0 :
            indx.append(index)
    if indx != []:
        df_filtered=vec2.filter(items=indx,axis=0)
        needs=int(df_filtered["Needs%"].mean())
        wants=int(df_filtered["Wants%"].mean())
        savings= 100 - (needs+wants)
        return needs,wants,savings
    else:
        return (50.00,30.00,20.00)


@app.route('/recommendation/report',methods=['GET']) 
def recommendation():
    global user_id #remove l8r
    users=[]
    with open('ReccomendationScripts\\accountConverter.sql', 'r') as file:
        sql_script = file.read()
        with app.app_context():
            usertbl= db.session.execute(text(sql_script)).fetchall()
    if usertbl: 
        print(usertbl)
        for j in usertbl:  #This should run only once right?
            beginningBalance=100000.00
            mingoal=20000.00  #Month goals can be added into the table from goals table  
            maxgoal=500000.00
            #month needs to be changed.
            #j.savings= (float(j.monthly_income) + float(beginningBalance)) - float(j.monthly_expenses)
            #j.increasedecrease=13.00

            user_month_data = AllUserData(j.acc_id,j.month,j.month,beginningBalance,float(j.monthly_income),
                                          float(j.monthly_expenses),float(j.current_balance),float(j.wants_percentage),
                                          float(j.needs_percentage),float(j.savings),mingoal,maxgoal,float(j.increasedecrease))
            #db.session.add(user_month_data) #uncomment
            #db.session.commit() 

            users = {   
                        'acc_id': j.acc_id,
                        'month': j.month, #format needs to change.
                        'current_balance': float(j.current_balance),
                        'monthly_income': float(j.monthly_income),
                        'monthly_expenses': float(j.monthly_expenses),
                        'wants': float(j.wants_percentage),
                        'needs': float(j.needs_percentage),
                        'savings': float(j.savings),
                        'increasedecrease': float(j.increasedecrease)
                    }
            
        #return jsonify(users)

    ans=None
    #create to add to all_user_data table
    #make_csv()
    #ans=run_script() #remove

    ans = recommend_ratios()  #dis gonna change to a list from the user
    print("Recommendation Splits are as follows",ans)

    #DROP TABLE user_goals,all_user_data
    splits = {
        'rwants': ans[1],
        'rneeds': ans[0],
        'rsavings': ans[2]
    }

    send_to_rec_table = RecommendationReport(users['acc_id'],users['month'],users['wants'],users['needs'],users['savings'],splits['rwants'],splits['rneeds'],splits['rsavings'])
    db.session.add(send_to_rec_table) #uncomment
    db.session.commit() 


    # Return a JSON response with the recommendation data
    return jsonify(splits)
    
    #We can have a section that would allow the user to pick their ratio. This would run the reccomend() function,
        #with the percentages as the parameters (so we need to figure how to add the record from the function's param)
        #SO the next function would be the result that would recomend the user what to cut.
        #So the sql also needs to for a specific month. So have the reccomend function run for reach month.


@app.route('/splits',methods=['GET']) #get from db RecommendationReport
def splits():
    #time.sleep(2)
    global user_id
    recList = []

    #expenses = db.session.execute(db.select(ExpenseList)).scalars() #also addd where the account id is the same as logged in
    recSplits = db.session.query(RecommendationReport).filter(RecommendationReport.acc_id == user_id).all()
    print('populate user_id',user_id)
    print(recSplits)
    
    if recSplits == []:
        return []
    for g in recSplits: 
            recList.append({
                'id': g.id,
                'acc_id': g.acc_id,
                'date': g.date,
                'wants': g.wants,
                'needs': g.needs,
                'savings': g.savings,
                'rwants': g.rwants,
                'rneeds': g.rneeds,
                'rsavings': g.rsavings
                        })
    return jsonify(splits=recList)
    