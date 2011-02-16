##
# model.py
# 
# This file is where we model the objects used by our web app 
# for storing in the App Engine datastore. 
#
# Note: we're taking advantage of a great project called GeoModel
# that allows us to easily query geospatial information from 
# the datastore. Our primary use of this model is to perform
# promxity searches to find nearby Questions. For more info see:
# http://code.google.com/p/geomodel/
##

# Provides standard set of app engine models and properties
from google.appengine.ext import db

# Provides proxmity and bounding box searching
from geo.geomodel import GeoModel

class User(db.Model):
    """
    The User object models an Inquire account. All fields are required.
    """

    # email address of the user
    email = db.StringProperty(required=True)

    # password of the user (NOTE: application logic is responsible for hashing the password)
    password = db.StringProperty(required=True)

    # total number of karma points the user has
    karma = db.IntegerProperty(default=0)

    # helper method to generate a JSON structure representing a User object 
    def to_json(self):
        return {
            "user_id": self.key().id(),
            "email": self.email,
            "karma": self.karma,
        }

class Question(GeoModel):
    """
    The Question object models an Inquire question. It has a relationship
    to the User object who owns the Questions. 
    """

    # owner of the question
    user = db.ReferenceProperty(User)

    # question text
    question = db.StringProperty(required=True)

    # field to easily determine if the question has been closed
    # which means a user has accepted some answer to this question
    closed = db.BooleanProperty(default=False)

    # helper method to generate a JSON structure representing a Question object 
    def to_json(self):
        return {
            "user_id": self.user.key().id(),
            "question_id": self.key().id(),
            "question": self.question,
            "latitude": self.location.lat,
            "longitude": self.location.lon,
            "closed": self.closed,
        }

class Answer(db.Model):
    """
    The Answer object models an Inquire answer. It has a relationship
    to the User object who owns the Answer and to the Question that
    the Answer is in response to.
    """

    # the user object that answered the question
    user = db.ReferenceProperty(User)

    # the question object being answered
    question = db.ReferenceProperty(Question)

    # the text of the answer
    answer = db.StringProperty(required=True)

    # indicates the accepted answer to a question
    accepted_answer = db.BooleanProperty(default=False)

    # helper method to generate a JSON structure representing an Answer object 
    def to_json(self):
        return {
            "user_id": self.user.key().id(),
            "answer_id": self.key().id(),
            "question_id": self.question.key().id(),
            "answer": self.answer,
            "accepted_answer": self.accepted_answer,
        }
