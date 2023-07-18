"""
Flask Documentation:     https://flask.palletsprojects.com/
Jinja2 Documentation:    https://jinja.palletsprojects.com/
Werkzeug Documentation:  https://werkzeug.palletsprojects.com/
This file contains the routes for your application.
"""
import os
from app import app,db,login_manager
from flask import render_template, request, redirect, url_for, flash, session, abort,send_from_directory,jsonify
from app.models import ExpenseCategories,ExpenseList,IncomeChannel,Account
from werkzeug.utils import secure_filename
import json
from decimal import Decimal
import datetime
from werkzeug.security import check_password_hash
from flask_login import login_user, logout_user, current_user, login_required

#to run flask, run flask --app Flask/app --debug run
#to migrate and dem tings deh, run  flask --app=Flask/App db init  and change init to smthn migrate/upgrade.

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
            user_id = user.id
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

        response_data = {'message': 'Success'}
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

        response_data = {'message': 'Success'}
        return jsonify(response_data)

@app.route('/populate',methods=['GET']) #get from db expense list and income list.
def populate():
    e_list = []
    i_list = []

    expenses = db.session.execute(db.select(ExpenseList)).scalars() #also addd where the account id is the same as logged in
    for g in expenses: 
            e_list.append({
                'name': g.name,
                'cost': g.cost,
                'tier': g.tier,
                'expense_type': g.expense_type,
                'frequency': g.frequency,
                'date': g.date
                        })
    incomechannels = db.session.execute(db.select(IncomeChannel)).scalars() #also add where the account id is the same as logged in
    for g in incomechannels: 
            i_list.append({
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
