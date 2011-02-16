/**
 * Constants.m
 *
 * See header file.
**/ 
#import "Constants.h"


@implementation Constants

NSString * const APP_NAME		= @"Inquire";

// This is set to point to your local machine. Modify it with
// an app engine URL if you have deployed to Google
NSString * const BASE_API_URL	= @"http://localhost:8080/api";

int const MAX_QUESTION_LENGTH = 160;
int const MAX_ANSWER_LENGTH = 160;

// The application ID of your PayPal account. The ID to use for testing 
// is APP-80W284485P519543T
NSString* const PAYPAL_APPLICATION_ID = @"APP-80W284485P519543T";

// The email address of the payment's receiver. If you're using a sandbox
// or live PayPal account this will most likely be your account's email
// address
NSString* const PAYPAL_RECEIVER_EMAIL = @"your_account@example.com";

@end
