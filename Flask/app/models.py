from . import db
from werkzeug.security import generate_password_hash

class Account(db.Model):
    __tablename__ = 'account'
    #i kept id just incase we'll need it later on for goals. so if you dont want it feel free to delete it
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255))
    password = db.Column(db.String(255))

    def __init__(self, email, password):
        self.email = email
        self.password = generate_password_hash(password, method='pbkdf2:sha256')

    def __repr__(self):
        return '<Account %r>' % self.email


class ExpenseList(db.Model):
    __tablename__ = 'expense_list'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    cost = db.Column(db.Numeric(10, 2))
    tier = db.Column(db.Integer)
    expense_type = db.Column(db.String(255))
    frequency = db.Column(db.String(255))
    date = db.Column(db.DateTime)

    def __init__(self, name, cost, tier, expense_type, frequency, date):
        self.name = name
        self.cost = cost
        self.tier = tier
        self.expense_type = expense_type
        self.frequency = frequency
        self.date = date

    def __repr__(self):
        return '<ExpenseList %r>' % self.name



class ExpenseCategories(db.Model):
    __tablename__ = 'expense_categories'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    ttl_cost = db.Column(db.Numeric(10, 2))

    def __init__(self, name, ttl_cost):
        self.name = name
        self.ttl_cost = ttl_cost

    def __repr__(self):
        return '<ExpenseCategories %r>' % self.name

    

class IncomeChannel(db.Model):
    __tablename__ = 'income_channel'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    monthly_earning = db.Column(db.Numeric(10, 2))
    frequency = db.Column(db.String(255))
    date = db.Column(db.DateTime)

    def __init__(self, name, monthly_earning,frequency,date):
        self.name = name
        self.monthly_earning = monthly_earning
        self.frequency = frequency
        self.date = date

    def __repr__(self):
        return '<IncomeChannel %r>' % self.name
    




