# Introduction

This is the iPhone and user-interface portion of the Inquire reference application. The primary
use of this application is to allow users to ask questions that other users may answer. Each
question requires a payment via PayPal's iPhone library. To answer a question, a user must be 
within 50 miles of an existing question and use the application's map view to select a question 
and provide an answer. When an answer is received for a given question, the owner of the question 
will receive an email notification and can accept that answer in the application. When an answer 
is accepted the owner of the answer will be given one karma point.
 
# Prerequisites

* Latest Xcode (i.e., 3.2.5+)
* iOS hardware with GPS support running iOS 4.0 or higher (for testing on a device)
* PayPal iOS SDK downloaded from x.com
* GoogleAppEngine portion of Inquire configured and running locally or on app engine.

# Libraries Used

* PayPal iPhone Library - provides mobile payments through PayPal
* TouchJSON - Objective-C library for easily encoding and decoding JSON objects
* ASIHttp - quick and simple library for handling HTTP operations

# Configuration and Quick Setup

1) Open the Xcode project (Inquire.xcodeproj) to load the project in Xcode
2) Download the PayPal iPhone Library from https://www.x.com/community/ppx/sdks
3) Extract the zip file to a location on your computer and drag the Library directory
   into your Xcode project. When prompted, select the checkbox labeled "Copy items into
   destination group's folder". Note that this operation creates a folder and group in 
   your project named "Library". If you would rather have it named something else, like
   "PayPal", copy the original Library directory to a new PayPal directory, and drag
   that directory into your Xcode project.
4) Double-check that the libPayPalMEP library is linked to your project by looking under 
   Project->Edit Active Target "Inquire". If it is not, you should manually add the library
   to your target's linked libraries list by clicking the plus button, clicking "Add Other",
   and finding the libPayPalMEP.a binary in the PayPal SDK you've downloaded.
5) Build and run your application in the simulator to confirm it builds without errors.

# Signing In / Create Account

The first screen you're presented with is the Sign In screen [SignInController] where you 
may sign in with your email address and password, or you can create a new account if
needed [CreateAccountController]. Once you have successfully authenticated, the view will
close and the [MapViewController] will be presented to show available questions in your
area.

# Viewing Question Details

The [MapViewController] presents pins representing questions in your area. Green pins
represent questions you have asked and not accepted answers to, and purple pins are those
questions from other users. Touching a pin will present an annotation pop up with a summary
of the question and a disclousure button to view the question's detail view. The details
of a question [QuestionDetailController] will show the full text of the question and any
answers that have been given for the question. 

# Answering a Question

If you aren't the owner of a question you'll be allowed to provide an answer to a question
while viewing the details of a question. By touching the "Answer" button, a new view 
[AnswerQuestionController] will appear that allows you to type up to 160 characters and
submit the answer. NOTE: The 160 character limit is an arbitrary limit and can be adjusted
to fit your needs.

# Accept an Answer

If you are the owner of a question, you'll be allowed to swipe an answer in the detail
view of a question to present an "Accept" button. Touching that button will effectively
close the question and the owner of the accepted answer will be notified via email and
be given one karma point (handled on the server.) The question will no longer show up 
in the map view or allow new answers.

# Asking a Question

To ask a question, simply touch the right navigation button in the map view (the button's
style is that of a UIBarButtonSystemItemCompose) to be presented with a view for 
asking a question [AskQuestionController]. Like answering a question, you'll be allowed
up to 160 characters for your question text. Once the question is finished, clicking the
Send button will present new view to complete the payment process for asking the question.

# Notes

1) If you're running into build issues, be sure that you have all the required libraries
in your target's list of linked libraries. The required libraries are:

    *  Foundation
    *  UIKit
    *  CoreGraphics
    *  CFNetwork
    *  MobileCoreServices
    *  SystemConfiguration
    *  CoreLocation
    *  MapKit
    *  libz.1.2.3.dylib
    *  libxml2.dylib
    *  libPayPalMEP.a

2) User authentication is only checked when the application is first loaded via the Sign
In screen. If the session on the server expires for whatever reason you may get an 
alert from the ASIHttp library

3) Using the simulator causes your current location to always be Apple's headquarters at
1 Infinite Loop, Cupertino, CA. The best way to use this application is to run it on
actual hardware so the GPS can kick in and find your actual location, but it will be
just fine in the simulator if you don't mind always being stuck in California.

4) We're intentionally initializing th PayPal library in demo mode (ENV_NONE) that will
allow you to use the PayPal transaction without an Internet connection. If you flip this
to sandbox mode (ENV_SANDBOX) you'll need to have a PayPal developer account with
business and personal test accounts created _AND_ be logged in to your dev account before
PayPal will accept your email/password during the payment process.

5) Currently, the application will not know about any new questions or answers when they
occur. To get realtime notifications the application could be modified to use Apple's
Push Notification. For more information see http://bit.ly/92lkGV

6) Be aware the API method /ask currently receives the PayKey from the PayPal transaction
when the user purchased the question. There is no server-side check to make sure the user
actually paid, but you could verify the given PayKey against PayPal's API to ensure it's
legit.

7) Another approach to #6 would be to use PayPal's Instant Payment Notification service.
This would allow PayPal to notify your backend server via a URL after a payment was
processed. You can add the appropriate URL via the ipnUrl property of a PayPalPayment
object. For more information on PayPal's IPN see https://www.paypal.com/ipn

Provided by: Zaffra, LLC - http://zaffra.com
