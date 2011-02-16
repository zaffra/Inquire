# Introduction

This is the Google App Engine portion of the Inquire reference application. It functions
as the API layer that the iPhone app will speak to for getting and setting the data it
requires. It's also the storage layer for keeping tabs on who owns questions and answers, 
how many karma points a particular user has, etc. For more information on what data is 
stored and the relationships between objects you should take a look at model.py. Check 
out urls.py to understand the mappings between URLs and request handlers in api.py.

# Prerequisites

* Google App Engine SDK for Python downloaded and installed. You can find this at:
  http://code.google.com/appengine/downloads.html

* A working knowledge of the Google App Engine and Django projects. We're NOT using
  the app engine supplied Django framework, but instead we're using a great project
  that has modified the latest Django to be used with app engine. For information
  on these great projects see the following links:
    http://code.google.com/appengine/docs/python/gettingstarted/
    http://www.djangoproject.com/
    http://www.allbuttonspressed.com/projects/django-nonrel

* iPhone portion of Inquire built and running in the simulator or on iOS hardware

# Project Structure

Below is a quick overview of the individual components of the GAE project.

* app.yaml - Configuration file for app engine. The main thing you'll need to change
  in this file is the application parameter that defines the name of your application
  on app engine. See http://appengine.google.com for creating an application.

* urls.py - The mapping of allowed URL endpoints to the code that handles them.

* api.py - Implements the API layer of Inquire. It handles all incoming HTTP requests
  and interfaces with the datastore.

* model.py - Defines all objects that we wish to model and persist in the app engine
  datastore. More information on each object can be found in model.py.

* settings.py - The settings module for Django projects and shouldn't need any
  modification unless you want to change things like your timezone.

* The rest (django, djangotoolbox, etc.) all contain various modules for the Django 
  web framework and shouldn't need to be modified.

# Notes

It's recommended that if you're running on iOS hardware that you run the GAE server 
on a live app engine and not locally using GoogleAppEngineLauncher. If you really want 
to run it locally you should run the app engine development server directly and have it 
bind to 0.0.0.0 instead of your machine's loopback interface or else your hardware will 
be refused a connection to your computer running the development app engine server. If
you're network requires special firewall rules to allow communication between your iOS
hardware and development app engine you'll need to configure it accordingly.

    For more information on the app engine development server see:
    http://code.google.com/appengine/docs/python/tools/devserver.html

Also, if you're using the development app engine server to run the API then anytime you
send an email it will dump to the console output or the logs window in the launcher. If
you want the development server to really send email you'll need to configure the dev
server with an SMTP server or configure a local sendmail server. If you have deployed 
your project to Google then you'll get email capabilities out of the box, but you'll need 
to set the constant SENDER_EMAIL_ADDRESS located in api.py to be a valid email address as 
defined by Google. The rules for a valid email address (taken from Google's documentation)
is as follows:
    * The address of a registered administrator for the application.
    * The address of the user for the current request signed in with a 
      Google Account
    * Any valid email receiving address for the app (such as 
      xxx@APP-ID.appspotmail.com)

For more information visit: 
http://code.google.com/appengine/docs/python/mail/sendingmail.html

Provided by: Zaffra, LLC - http://zaffra.com
