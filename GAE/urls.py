##
# urls.py
# 
# This file defines mappings of API endpoints to the methods that
# handle them. For more information on URL dispatching please
# see http://docs.djangoproject.com/en/1.2/topics/http/urls/
##

from django.conf.urls.defaults import *

urlpatterns = patterns('api',
    # POST REQUESTS
    (r'^api/register$', 'register'),
    (r'^api/auth$', 'auth'),
    (r'^api/logout$', 'logout'),
    (r'^api/ask$', 'ask'),
    (r'^api/answer$', 'answer'),
    (r'^api/accept$', 'accept'),

    # GET REQUESTS
    (r'^api/questions$', 'questions'),
    (r'^api/answers$', 'answers'),

    # Utility mapping for creating random questions
    # and should probably be removed from a "live"
    # application
    (r'^api/randomize$', 'randomize'),
)
