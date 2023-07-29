
from flask import Flask
from .config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_jwt_extended import JWTManager #test


app = Flask(__name__)
app.config.from_object(Config)

#from app import models

db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Flask-Login login manager
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Configure JWT settings
app.config['JWT_SECRET_KEY'] = 'secretPP'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 3600 #change
jwt = JWTManager(app)

from app import views



