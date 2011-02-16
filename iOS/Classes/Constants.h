/**
 * Constants.h
 *
 * Defines a set of constant variables used throughout the application.
 *
 * Created by Zaffra, LLC - http://zaffra.com
**/

#import <Foundation/Foundation.h>

// The application name
extern NSString* const APP_NAME;

// The root URL to the web application's API
extern NSString* const BASE_API_URL;

// Maximum question and answer body length
extern int const MAX_QUESTION_LENGTH;
extern int const MAX_ANSWER_LENGTH;

// Your PayPal application ID and account email address
extern NSString* const PAYPAL_APPLICATION_ID;
extern NSString* const PAYPAL_RECEIVER_EMAIL;

@interface Constants : NSObject {
	
}

@end
