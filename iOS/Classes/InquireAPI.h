/**
 * InquireAPI.h
 *
 * A utility class for executing various API methods on the Inquire
 * web application. It uses the ASIHttp library for performing all
 * HTTP operations.
 * 
 * NOTE: User's of the public methods are required to release any
 * instances of the class after use -- usually done in the delegate
 * methods for handling the API response.
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "QuestionModel.h"
#import "AnswerModel.h"

typedef enum {
	API_METHOD_AUTH = 0,
	API_METHOD_REGISTER,
	API_METHOD_ASK,
	API_METHOD_ANSWER,
	API_METHOD_ACCEPT,
	API_METHOD_QUESTIONS,
	API_METHOD_ANSWERS
} API_METHOD;

/**
 * The InquireAPIDelegate protocol defines the messages sent to the InquireAPI delegate
 * as part of the responses from an ASIHttpRequest object. One message for a successful
 * response and one for a failure are both defined. Both methods are optional.
**/
@class InquireAPI;
@protocol InquireAPIDelegate <NSObject>

@optional

/**
 * Called when an ASIHttpRequest responded successfully. It's signature is modeled after
 * the ASIHttpReqeustDelegate, however, instead of sending a reference to the request
 * we decode the response's JSON string into a NSDictionary for convenience. If an
 * error occurrs during the JSON decoding the requestFailed:error message is called.
**/
- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse;

/**
 * Called when some error occurred during an ASIHttpRequest request.
**/
- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error;
	
@end

@interface InquireAPI : NSObject <ASIHTTPRequestDelegate> {
	int apiMethod;
	id<InquireAPIDelegate> delegate;
	NSString *baseURL;
}
@property (nonatomic, readonly) int apiMethod;
@property (nonatomic, retain) id<InquireAPIDelegate> delegate;
@property (nonatomic, retain) NSString *baseURL;

- (id)initWithBaseURL:(NSString*) _baseURL andDelegate:(id<InquireAPIDelegate>) _delegate;

/**
 * POST: /auth - Authenticates to the web application. Sessions on the server
 * will keep track of the user.
 *
 * @param email - User's email address
 * @param password - User's password (WARNING: plain-text!)
 **/
- (void)authenticateWithEmail:(NSString *)email andPassword:(NSString *)password;

/**
 * POST: /register - Registers a user with the given email and password.
 *
 * @param email - User's email address
 * @param password - User's password (WARNING: plain-text!)
 **/
- (void)registerWithEmail:(NSString *)email andPassword:(NSString *)password;

/**
 * POST: /ask - Submits a question with a location and PayPal payKey
 * 
 * @param question - User's question
 * @param location - User's current location
 * @param payKey - The payKey received from a successful PayPal transaction
 **/
- (void)askQuestion:(NSString *)question atLocation:(CLLocationCoordinate2D)location withPayKey:(NSString *)payKey;

/**
 * POST: /answer - Submits an answer for the given question
 * 
 * @param question - QuestionModel instance (for question_id)
 * @param answer - String representing the user's answer
 **/
- (void)answerQuestion:(QuestionModel *)question withAnswer:(NSString *)answer;

/**
 * POST: /accept - Accepts an answer for the given question
 * 
 * @param answer   - AnswerModel representing the accepted answer (for answer_id)
 **/
- (void)acceptAnswer:(AnswerModel *)answer;

/**
 * GET: /questions - Returns a list of questions near the location.
 * 
 * @param location - User's current location
 **/
- (void)findQuestionsNearLocation:(CLLocationCoordinate2D)location;

/**
 * GET: /answers - Returns a list of answers for a given question
 * 
 * @param question - QuestionModel instance (for question_id)
 **/
- (void)getAnswersForQuestion:(QuestionModel *)question;

@end
