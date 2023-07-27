from . import db
#from sqlalchemy import ForeignKey
from werkzeug.security import generate_password_hash

class Account(db.Model):
    __tablename__ = 'account'
    id = db.Column(db.Integer, primary_key=True)   #we should change these to like "PFI1" Personal Finince Indentification  
    email = db.Column(db.String(255),nullable=False)
    password = db.Column(db.String(255),nullable=False) #add beginning balance here.
    beginning_balance = db.Column(db.Numeric(10, 2))
    signup_date = db.Column(db.DateTime)
    last_login_date =db.Column(db.DateTime) 

    def __init__(self, email, password, beginning_balance,signup_date,last_login_date):
        self.email = email
        self.password = generate_password_hash(password, method='pbkdf2:sha256')
        self.beginning_balance = beginning_balance
        self.signup_date = signup_date
        self.last_login_date = last_login_date

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        try:
            return unicode(self.id)  # python 2 support
        except NameError:
            return str(self.id)  # python 3 support


    def __repr__(self):
        return '<Account %r>' % self.email
    
    #create goals based on one in lin code.


class ExpenseList(db.Model):
    __tablename__ = 'expense_list'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    cost = db.Column(db.Numeric(10, 2))
    tier = db.Column(db.String(2))
    expense_type = db.Column(db.String(255))
    frequency = db.Column(db.String(255))
    date = db.Column(db.DateTime)
    acc_id = db.Column(db.Integer, db.ForeignKey('account.id'),nullable=False)

    def __init__(self, name, cost, tier, expense_type, frequency, date,acc_id):
        self.name = name
        self.cost = cost
        self.tier = tier
        self.expense_type = expense_type
        self.frequency = frequency
        self.date = date
        self.acc_id = acc_id

    def __repr__(self):
        return '<ExpenseList %r>' % self.id



class ExpenseCategories(db.Model):
    __tablename__ = 'expense_categories'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    ttl_cost = db.Column(db.Numeric(10, 2))

    def __init__(self, name, ttl_cost):
        self.name = name
        self.ttl_cost = ttl_cost

    def __repr__(self):
        return '<ExpenseCategories %r>' % self.id

    

class IncomeChannel(db.Model):
    __tablename__ = 'income_channel'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    monthly_earning = db.Column(db.Numeric(10, 2))
    frequency = db.Column(db.String(255))
    date = db.Column(db.DateTime)
    acc_id = db.Column(db.Integer, db.ForeignKey('account.id'),nullable=False)

    def __init__(self, name, monthly_earning,frequency,date,acc_id):
        self.name = name
        self.monthly_earning = monthly_earning
        self.frequency = frequency
        self.date = date
        self.acc_id = acc_id

    def __repr__(self):
        return '<IncomeChannel %r>' % self.id
    
class RecommendationReport(db.Model):
    __tablename__ = 'recommendation_report'
    id = db.Column(db.Integer, primary_key=True)
    acc_id = db.Column(db.Integer, db.ForeignKey('account.id'))
    date = db.Column(db.DateTime, nullable=False)  # Assuming the date format is 'mm/yyyy'
    wants = db.Column(db.Numeric(10, 2))
    needs = db.Column(db.Numeric(10, 2))
    savings = db.Column(db.Numeric(10, 2))
    rwants = db.Column(db.Numeric(10, 2))
    rneeds = db.Column(db.Numeric(10, 2))
    rsavings = db.Column(db.Numeric(10, 2)) #create the init function
    increase_decrease = db.Column(db.Numeric(10, 2)) 
    #the current balance
    

    def __init__(self, acc_id, date, wants, needs, savings, rwants, rneeds, rsavings,increase_decrease):
        self.acc_id = acc_id
        self.date = date
        self.wants = wants
        self.needs = needs
        self.savings = savings
        self.rwants = rwants
        self.rneeds = rneeds
        self.rsavings = rsavings
        self.increase_decrease = increase_decrease

    def __repr__(self):
        return '<RecommendationReport %r>' % self.id


class AllUsersData(db.Model): #used for demo
    # __tablename__ = 'all_user_data'
    # records = db.Column(db.Integer, primary_key=True)
    # #acc_id = db.Column(db.Integer, db.ForeignKey('account.id'),nullable=False)# how it should be, but i started @30 and 30 not in "Account" thus error8
    # acc_id = db.Column(db.Integer,nullable=False)
    # start_date = db.Column(db.DateTime,nullable=False)
    # curr_date = db.Column(db.DateTime)
    # beginning_balance = db.Column(db.Numeric(15, 2))
    # monthly_income = db.Column(db.Numeric(15, 2))
    # monthly_expense = db.Column(db.Numeric(15, 2),nullable=False)
    # current_balance = db.Column(db.Numeric(15, 2))
    # wants_percent = db.Column(db.Numeric(5, 2),nullable=False)
    # needs_percent = db.Column(db.Numeric(5, 2),nullable=False)
    # savings_percent = db.Column(db.Numeric(5, 2),nullable=False)
    # min_goal = db.Column(db.Numeric(10, 2))
    # max_goal = db.Column(db.Numeric(10, 2))
    # budget_increase = db.Column(db.Numeric(10, 2))

    __tablename__ = 'all_users_data'
    records = db.Column(db.Integer, primary_key=True)
    #acc_id = db.Column(db.Integer, db.ForeignKey('account.id'),nullable=False)# how it should be, but i started @30 and 30 not in "Account" thus error8
    acc_id = db.Column(db.Integer)  
    month = db.Column(db.DateTime)
    beginning_balance = db.Column(db.Numeric(15, 2))
    monthly_income = db.Column(db.Numeric(15, 2))
    monthly_expense = db.Column(db.Numeric(15, 2))
    current_balance = db.Column(db.Numeric(15, 2))
    wants_percent = db.Column(db.Numeric(5, 2))
    needs_percent = db.Column(db.Numeric(5, 2))
    savings_percent = db.Column(db.Numeric(5, 2))
    min_goal = db.Column(db.Numeric(10, 2))
    max_goal = db.Column(db.Numeric(10, 2))
    increase_decrease = db.Column(db.Numeric(10, 2))

    def __init__(self, acc_id, month, beginning_balance, monthly_income, monthly_expense,
                current_balance, wants_percent, needs_percent, savings_percent, min_goal, max_goal, increase_decrease):
        self.acc_id = acc_id
        self.month = month
        self.beginning_balance = beginning_balance
        self.monthly_income = monthly_income
        self.monthly_expense = monthly_expense
        self.current_balance = current_balance
        self.wants_percent = wants_percent
        self.needs_percent = needs_percent
        self.savings_percent = savings_percent
        self.min_goal = min_goal
        self.max_goal = max_goal
        self.increase_decrease = increase_decrease

    def __repr__(self):
        return '<AllUserData %r>' % self.records
    


class Goals(db.Model):
    __tablename__ = 'user_goals'
    records = db.Column(db.Integer, primary_key=True)
    #acc_id = db.Column(db.Integer, db.ForeignKey('account.id')) #remove foreign key for demo
    acc_id = db.Column(db.Integer,nullable=False)
    #name = db.Column(db.String(255))
    goals = db.Column(db.Numeric(10, 2))

    def __init__(self, acc_id, goals):
        self.acc_id = acc_id
        self.goals = goals

    def __repr__(self):
        return '<ExpenseCategories %r>' % self.id

    

        

