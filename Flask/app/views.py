"""
Flask Documentation:     https://flask.palletsprojects.com/
Jinja2 Documentation:    https://jinja.palletsprojects.com/
Werkzeug Documentation:  https://werkzeug.palletsprojects.com/
This file contains the routes for your application.
"""
import os
from app import app,db
from flask import render_template, request, redirect, url_for, flash, session, abort,send_from_directory,jsonify
from app.models import ExpenseCategories,ExpenseList,IncomeChannel
from werkzeug.utils import secure_filename
import json
from decimal import Decimal
import datetime

#to run flask, run flask --app Flask/app --debug run
#to migrate and dem tings deh, run  flask --app=Flask/App db init  and change init to smthn migrate/upgrade.

###
# Routing for your application.
###

@app.route('/')
def home():
    """Render website's home page."""
    return render_template('home.html')

@app.route('/about/')
def about():
    """Render the website's about page."""
    return render_template('about.html', name="Bob")

@app.route('/test',methods=['POST']) #sen ttl category to db
def test():
    if (request.method=='POST'):
        """ 
        data = request.get_json()
        value1 = data['user']
        value2 = data['test']
        """
    value1 = request.form.get('name')
    value2 = request.form.get('cost')
    """Render the website's about page."""
    print(value1)
    print(value2)
    response_data = {'message': 'Success'}
    #return render_template('about.html', name="Bob")
    return jsonify(response_data)

@app.route('/test2',methods=['GET']) #get from db.
def test2():
    p_list =[]
    """ 
    #expense = Expense.query.filter_by(id=1).first()
    expense=db.session.execute(db.select(ExpenseCategories)).scalars()
    expense_json = json.dumps(expense.serialize())
    return jsonify(expense=expense_json)
    """

    """
    expense = db.session.execute(db.select(ExpenseCategories)).scalars()
    expense_list = [item_to_dict(item) for item in expense]
    expense_json = json.dumps(expense_list, default=convert_decimal_to_float)
    print(expense_json)
    print(jsonify(expense_list))
    return jsonify(expense=expense_json)
    """
    expense = db.session.execute(db.select(ExpenseCategories)).scalars()
    for g in expense:
            p_list.append({
                'id': g.id,
                'name': g.name,
                'ttl_cost': g.ttl_cost
                        })
    print(jsonify(expense=p_list))
    return jsonify(expense=p_list)

""" #unecessary functions
def item_to_dict(item):
    return {
        'id': item.id,
        'name': item.name,
        'ttl_cost': item.ttl_cost}

def convert_decimal_to_float(value):
    if isinstance(value, Decimal):
        return float(value)
    raise TypeError(f'Object of type {value.__class__.__name__} is not JSON  serializable.')




@app.route('/puploads/<filename>')
def get_image(filename):
    return send_from_directory(os.path.join(os.getcwd(), app.config['P_FOLDER']), filename)

@app.route("/ppic")
def showProperties():
    #ppic = db.session.execute(db.select(Photography)).scalars()
    return render_template('show_properties.html')#,ppic=ppic) 
"""

@app.route('/expense/add',methods=['POST']) #Sends expense added to db
def add_expense():
    if (request.method=='POST'):
        
        name = request.form.get('name')
        cost = request.form.get('cost')
        tier = request.form.get('tier')
        expense_type = request.form.get('expenseType')
        frequency = request.form.get('frequency')
        date = datetime.datetime.now() #assuming we get current date/time and place it in the DB
        
        print(name,cost,tier,expense_type,frequency,date)     
        newExpense = ExpenseList(name,cost,tier,expense_type,frequency,date)
        db.session.add(newExpense)
        db.session.commit()        

        response_data = {'message': 'Success'}
        return jsonify(response_data)

@app.route('/incomeChannel/add',methods=['POST']) #Sends income_channel added to db
def add_income_channel():
    if (request.method=='POST'):
        
        name = request.form.get('name')
        monthly_earning = request.form.get('monthly_earning')
        frequency = request.form.get('frequency')
        date = datetime.datetime.now() #assuming we get current date/time and place it in the DB
        
        print(name,monthly_earning,frequency,date)     
        newIncomeChannel = IncomeChannel(name,monthly_earning,frequency,date)
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
###
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
