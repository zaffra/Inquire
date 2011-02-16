##
# api.py
# 
# This file is the workhorse for the the entire web application.
# It implements and provides the API required for the iOS portion
# of the project as well as interacting with Google's datastore
# for persistent storage of our models.
##

# for sending mail
from google.appengine.api import mail

# Used in conjunction with the geomodel library for doing
# proximity based searches
from google.appengine.ext.db import GeoPt
from geo import geotypes

# HttpResponse is what all Django-based views must return
# to render the output. In our web application the
# _json* methods build and return HttpResponse objects
# for rendering JSON dat
from django.http import HttpResponse 

# For encoding Python objects into JSON strings
from django.utils import simplejson

# Our datastore models
from model import *

# For handling user sessions
from appengine_utilities.sessions import Session

# Provides the sha1 module we use for hashing passwords
import hashlib

# The Python loggin module. We use the basicConfig method
# to setup to log to the console (or GoogleAppEngineLauncher
# logs screen)
import logging
logging.basicConfig(level=logging.DEBUG)

##
# CONSTANTS
##

"""
The email address to send from. See the Notes section of the README
for more information on what to set this to.
"""

SENDER_EMAIL_ADDRESS = "VALID@APPENGINE_ADDRESS.COM"

##
# UTILITY METHODS
##

def _hash_password(password):
    """
    Returns a sha1-hashed version of the given plaintext password.
    """
    return hashlib.sha1(password).hexdigest()

def _json_response(success=True, msg="OK", **kwargs):
    """
    Helper method to build an HTTPResponse with a stock
    JSON object. 

    @param success=True: indicates success or failure of the API method
    @param msg: string with details on success or failure
    @kwargs: any number of key/value pairs to be sent with the JSON object
    """

    # build up the response data and convert it to a string using the
    # simplejson module
    response_data = dict(success=success, msg=msg)
    response_data.update(kwargs)
    response_string = simplejson.dumps(response_data)

    # All views must return a valid HttpResponse object so build it and
    # set the JSON string and mimetype indicating that the result is
    # JSON
    return HttpResponse(response_string, mimetype="application/json")

def _json_unauthorized_response(**kwargs):
    """
    Helper method to build an HTTPResponse with a stock JSON object
    that represents unauthorized access to an API method.

    NOTE: Always returns success=false and msg="Unauthorized"

    @kwargs: any number of key/value pairs to be sent with the JSON object
    """

    # Same process as _json_response method, accept always return false and
    # an Unauthorized message with a status code of 401
    response_data = dict(success=False, msg="Unauthorized")
    response_data.update(kwargs)
    response_string = simplejson.dumps(response_data)

    return HttpResponse(response_string, status=401, mimetype="application/json")

##
# DECORATORS
#
# For more information about decorators in Python see:
#
# http://www.python.org/dev/peps/pep-0318/
# http://wiki.python.org/moin/PythonDecorators
# http://www.ibm.com/developerworks/linux/library/l-cpdecor.html
# Google...
##

# Usage: @validate_request(method, p1, p2, ...)
def validate_request(method, *params):
    """
    Decorator for validating the required request method for an API call as
    well as enforcing any required parameters in the request. If either the
    method or parameter checks fail a stock failure JSON object is returned
    with the exact issue in the msg field. If all checks pass then the
    API call proceeds.
    """
    def _dec(view_func):
        def _view(request, *args, **kwargs):

            # check the required method
            if request.method == method:
                # check that each parameter exists and has a value
                for param in params:
                    value = request.REQUEST.get(param, "")
                    if not value:
                        # failed parameter check
                        return _json_response(success=False,
                                             msg="'%s' is required." % param)

                # return the original API call through 
                return view_func(request, *args, **kwargs)
            else:
                # failed method check
                return _json_response(success=False,
                                     msg="%s requests are not allowed." % request.method)
        return _view
    return _dec

# Usage: @validate_session()
def validate_session():
    """
    Decorator for validating that a user is authenticated by checking the 
    session for a user object. If this fails the stock json_unauthorized_response
    is returned or else the API call is allowed to proceed.
    """
    def _dec(view_func):
        def _view(request, *args, **kwargs):
            # get the session and check for a user, fail if it doesn't exist
            if Session().get("user") is None:
                # failed request
                return _json_unauthorized_response()
            # return the original API call through 
            return view_func(request, *args, **kwargs)
        return _view
    return _dec

##
# API METHODS
##

@validate_session()
@validate_request("POST", "question", "latitude", "longitude", "pay_key")
def ask(request):
    """
    API Method - /ask
    Creates a new Question and adds it to the datastore

    @method POST
    @param question: the text of the question
    @param latitude: latitude of the location
    @param longitude: longitude of the location
    @param pay_key: the pay key from a successful PayPal purchase
    
    @returns stock success or failure JSON response along with
    the question and user objects.
    """

    # authenticated user
    user = Session().get("user")

    # required parameters
    question = request.REQUEST.get("question")
    latitude = float(request.REQUEST.get("latitude"))
    longitude = float(request.REQUEST.get("longitude"))
    pay_key = request.REQUEST.get("pay_key")

    # Using the PayKey you could validate it using PayPal APIs
    # to confirm that a user paid and the transaction is complete.
    # This is left up to the curious coder to implement :)

    # Create the question with the required fields and tie it
    # to the authenticated user
    q = Question(question=question, 
                 location=GeoPt(latitude, longitude),
                 user=user)
    q.update_location()
    q.put()

    # return stock JSON with the Question object details
    return _json_response(question=q.to_json(), user=user.to_json())

@validate_session()
@validate_request("POST", "question_id", "answer")
def answer(request):
    """
    API Method - /answer
    Creates a new Answer object and adds it to the datastore. Validates
    that the question exists and does not have an accepted answer before
    accepting the answer.

    This method also takes care of sending the owner of the question
    an email saying a new answer has been given with the answer in the
    body of the message.

    @method POST
    @param question_id: id of an existing question
    @param answer: the text for the answer to a question
    
    @returns one answer object 
    """

    # session and authenticated user
    user = Session().get("user")

    # required parameters
    question_id = int(request.REQUEST.get("question_id"))
    answer = request.REQUEST.get("answer")

    # find the question associated with the question_id parameter
    question = Question.get_by_id(question_id)

    # no question with the given id
    if question is None:
        return _json_response(success=False, msg="Question does not exist.")

    # question has already been answered
    if question.closed:
        return _json_response(success=False, msg="Question has an accepted answer and is now closed.")

    # create a new answer and save it to the datastore
    a = Answer(user=user,
               question=question,
               answer=answer)
    a.put()

    # send an email to the owner of the question
    question_owner_email = question.user.email

    mail.send_mail(sender=SENDER_EMAIL_ADDRESS,
                   to=question_owner_email,
                   subject="Your question has a new answer!",
                   body="""
This is to inform you that one of your questions has 
received a new answer.

Your question: 
%s

The answer: 
%s

Regards,

Inquire Application
""" % (question.question, answer))

    # return stock JSON with details of the answer object
    return _json_response(answer=a.to_json())

@validate_session()
@validate_request("POST", "answer_id")
def accept(request):
    """
    API Method - /accept
    Accepts an answer for a question. The question must be owned by the
    current authenticated user accepting the question and not already
    have an accepted answer.

    This method also takes care of sending the owner of the answer 
    an email saying their answer was accepted. The accepted answer 
    owner will also be given one karma point. 

    @method POST
    @param answer_id: id of the answer being accepted
    
    @returns stock JSON object
    """

    # session and authenticated user
    user = Session().get("user")

    # required parameters
    answer_id = int(request.REQUEST.get("answer_id"))

    # find the answer associated with the answer_id 
    answer = Answer.get_by_id(answer_id)

    # no answer with the given id
    if answer is None:
        return _json_response(success=False, msg="Answer does not exist.")

    # associated question
    question = answer.question

    # make sure the question for this answer is owned by this user
    question = answer.question
    if question.user.key().id() != user.key().id():
        return _json_response(success=False, msg="You must be the owner of the question to accept an answer.")

    # also make sure the question is not already answered
    if question.closed:
        return _json_response(success=False, msg="Question already has an accepted answer.")

    # change the accepted flag of the answer and save it. 
    answer.accepted_answer = True
    answer.put()

    # close the question and save it
    question.closed = True
    question.put()

    # update the answer owner's karma points 
    answer.user.karma += 1
    answer.user.put()

    # send an email to the address assigned to the answer
    answer_owner_email = answer.user.email
    mail.send_mail(sender=SENDER_EMAIL_ADDRESS,
                   to=answer_owner_email,
                   subject="Your answer was accepted!",
                   body="""
This is to inform you that one of your answers has
been accepted! You have been given one karma point.

The question you answered: 
%s

Your answer: 
%s

Regards,

Inquire Application
""" % (question.question, answer.answer))


    # return stock success JSON 
    return _json_response()

@validate_session()
@validate_request("GET", "question_id")
def answers(request):
    """
    API Method - /answers
    Returns a list of answers for a given question id.

    @method GET
    @param question_id: The question id to retrieve answers for

    @returns list of answer objects
    """
    # required parameters
    question_id = int(request.GET.get("question_id"))

    # retrieve the matching question
    question = Question.get_by_id(question_id)

    if question is None:
        return _json_response(success=False,
                              msg="Question does not exist!")

    return _json_response(answers=[a.to_json() for a in question.answer_set])
         

@validate_session()
@validate_request("GET", "latitude", "longitude")
def questions(request):
    """
    API Method - /questions
    Returns a list of questions that are within geographical proximity
    to the passed in latitude/longitude.

    @method GET
    @param latitude: latitude of the location
    @param longitude longitude of the location

    @optional max_results: max number of questions to return, default=25
    @optional max_distance: max distance to search in miles
    
    @returns list of question objects
    """
    # required parameters
    latitude = float(request.GET.get("latitude"))
    longitude = float(request.GET.get("longitude"))

    # defines the center of our proximity search
    # geotypes.Point provided by geomodel project
    center = geotypes.Point(latitude, longitude)

    # default 
    max_results = int(request.GET.get("max_results", 25))     # 25 results default
    max_distance = int(request.GET.get("max_distance", 50))   # 50 mile default

    # convert miles to kilometers
    max_distance = 1000*max_distance/0.621371192

    # Get all unclosed questions within the proximity max_distance and
    # limit to max_results 
    base_query = Question.all().filter("closed =", False)
    questions = Question.proximity_fetch(base_query,
                                         center,
                                         max_results=max_results,
                                         max_distance=max_distance)

    return _json_response(questions=[q.to_json() for q in questions])

@validate_request("POST", "email", "password")
def register(request):
    """
    API Method - /register
    Creates a new user and adds it to the datastore. If a user already
    exists with the given email address the request fails and an
    appropriate JSON response is returned.

    @method POST
    @param email: email address for the user
    @param password: password for the user
    
    @returns newly created user object or failure JSON
    """

    # required parameters
    email = request.POST.get("email")
    password = request.POST.get("password")

    #
    users = User.all()
    users.filter("email =", email)

    if users.count() != 0:
        return _json_response(success=False,
                             msg="Email address already exists.", users=users.count())

    password = _hash_password(password)
    new_user = User(email=email, password=password)
    new_user.put()

    return _json_response()

def logout(request):
    """
    API Method - /logout
    Destroys the active user's session object. Any further use of
    protected API methods will require a new session via the auth
    API.

    @method GET
    @returns stock JSON response
    """

    # delete session and return stock JSON response with a msg
    # indicating the user has logged out
    session = Session()
    session.delete()
    return _json_response(msg="User has been logged out.")

@validate_request("POST", "email", "password")
def auth(request):
    """
    API Method - /auth
    If credentials are correct a new session is created for this
    user which authorizes them to use protected API methods.

    @method POST
    @param email: user's email address
    @param password: user's password

    @returns stock JSON response
    """

    # required parameters
    email = request.POST.get("email")
    password = request.POST.get("password")

    # hash the password
    password = _hash_password(password)

    # Look up a User object that matches the email/password 
    users = User.all()
    users \
        .filter("email =", email) \
        .filter("password =", password)

    # No user found, return a failure message
    if users.count() == 0:
        return _json_response(success=False,
                             msg="Email or password is invalid.")

    # Somehow more than one client with the same user/password have
    # been created, which should never happen. Error out here.
    if users.count() > 1:
        return _json_response(details=None,
                             success=False,
                             msg="Internal security error. Contact an administrator")

    # Pull the User from the datastore
    user = users.get()

    # Build a new session object and store the user
    session = Session()
    session["user"] = user

    # return stock JSON with user details
    return _json_response(user=user.to_json())


# Utility method for generating random questions around a
# given point. The point is currently Apple's headquarters
# so this works well with testing with the simulator.
def randomize(request):
    import random

    # location to generate questions around
    near_lat, near_lon = 37.331693, -122.030457

    # ~50 miles
    dx = 50.0/69.0

    # Number of questions to generate
    num_questions = 10

    # Possible users to assign questions to. These
    # users will be looked up by the email addresses
    # supply in this list and they must exist
    email_accounts = ["email1@example.com", "email2@example.com"]

    # no more editing

    # look up the user objects associated with the 
    # given email addresses
    users = []
    for email in email_accounts:
        user = User.all().filter("email =", email).get()
        if user is not None:
            users.append(user)

    # return false if there were no user objects found
    if not users:
        return _json_response(success=False, msg="No users found")

    # generate num_questions random questions around the given
    # point (near_lat, near_lon) within some distance dx and
    # assigning a random user to the question
    for i in range(num_questions):
        lat = random.uniform(near_lat-dx, near_lat+dx)
        lon = random.uniform(near_lon-dx, near_lon+dx)
        user = random.sample(users, 1)[0]

        q = Question(user=user, 
                     question="Question %d" % i, 
                     location=db.GeoPt(lat, lon))
        q.update_location()
        q.put()
    
    # return true
    return _json_response()
