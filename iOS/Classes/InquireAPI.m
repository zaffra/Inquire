/**
 * InquireAPI.m
 * 
 * See header file.
**/
#import "InquireAPI.h"
#import "CJSONDeserializer.h"

@implementation InquireAPI
@synthesize apiMethod;
@synthesize delegate;
@synthesize baseURL;

- (id)initWithBaseURL:(NSString*) _baseURL andDelegate:(id<InquireAPIDelegate>) _delegate {
	self = [super init];
	if(self != nil) {
		self.delegate = _delegate;
		self.baseURL = _baseURL;
	}
	return self;
}

/**
 * All API calls need an ASIHttpRequest and each request is essentially the
 * same. Construct a new one using the baseURL+apiEndPoint as a URL and return
 * it to the calling method which will fill in the parameters it needs
**/
- (ASIFormDataRequest *)newFormRequest:(NSString *)apiEndPoint {
	// Build the URL to use for our request
	NSString *urlString = [self.baseURL stringByAppendingString:apiEndPoint];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Build the actual request using the URL. We are assigning ourself as
	// the delegate so we can get the response from the server.
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
		
	return request;
}

#pragma mark -
#pragma mark InquireAPI Messages

- (void)authenticateWithEmail:(NSString *)email andPassword:(NSString *)password {
	self->apiMethod = API_METHOD_AUTH;
	ASIFormDataRequest *request = [self newFormRequest:@"/auth"];
		
	// Assign required POST values for email and password
	[request setPostValue:email forKey:@"email"];
	[request setPostValue:password forKey:@"password"];
	
	// Start the request
	[request startAsynchronous];
}

- (void)registerWithEmail:(NSString *)email andPassword:(NSString *)password {
	self->apiMethod = API_METHOD_REGISTER;
	ASIFormDataRequest *request = [self newFormRequest:@"/register"];
	
	// Assign required POST values for email and password
	[request setPostValue:email forKey:@"email"];
	[request setPostValue:password forKey:@"password"];
	
	// Start the request
	[request startAsynchronous];
}

- (void)askQuestion:(NSString *)question atLocation:(CLLocationCoordinate2D)location withPayKey:(NSString *)payKey {
	self->apiMethod = API_METHOD_ASK;
	ASIFormDataRequest *request = [self newFormRequest:@"/ask"];
	
	// Assign required POST values for question, latitude, and longitude
	[request setPostValue:question forKey:@"question"];
	[request setPostValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
	[request setPostValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
	[request setPostValue:[NSString stringWithString:payKey] forKey:@"pay_key"];
	
	// Start the request
	[request startAsynchronous];
}

- (void)answerQuestion:(QuestionModel *)question withAnswer:(NSString *)answer {
	self->apiMethod = API_METHOD_ANSWER;
	ASIFormDataRequest *request = [self newFormRequest:@"/answer"];
	
	// Assign required POST values for question_id and answer
	[request setPostValue:[NSString stringWithFormat:@"%d", question.questionId] forKey:@"question_id"];
	[request setPostValue:answer forKey:@"answer"];
	
	// Start the request
	[request startAsynchronous];
}

- (void)acceptAnswer:(AnswerModel *)answer {
	self->apiMethod = API_METHOD_ACCEPT;
	ASIFormDataRequest *request = [self newFormRequest:@"/accept"];
	
	// Assign required POST values for question_id and answer
	[request setPostValue:[NSString stringWithFormat:@"%d", answer.answerId] forKey:@"answer_id"];
	
	// Start the request
	[request startAsynchronous];
}

- (void)getAnswersForQuestion:(QuestionModel *)question {
	self->apiMethod = API_METHOD_ANSWERS;
	// The answers API requires a GET request with the question_id passed in the
	// query string
	NSString *url = [NSString stringWithFormat:@"/answers?question_id=%d", question.questionId];
	ASIFormDataRequest *request = [self newFormRequest:url];
	
	// Set the method to be GET
	request.requestMethod = @"GET";
	
	// Start the request
	[request startAsynchronous];
}

- (void)findQuestionsNearLocation:(CLLocationCoordinate2D)location {
	self->apiMethod = API_METHOD_QUESTIONS;
	// The questions API requires a GET request with the latitude and longitude
	// of the location passed in the query string.
	NSString *url = [NSString stringWithFormat:@"/questions?latitude=%f&longitude=%f", location.latitude, location.longitude];
	ASIFormDataRequest *request = [self newFormRequest:url];
	
	// Set the method to be GET
	request.requestMethod = @"GET";
	
	// Start the request
	[request startAsynchronous];
}

#pragma mark -
#pragma mark ASIHTTPRequest Messages

/**
 * An ASIHttpRequest finished. All server calls should return JSON objects
 * so we try to decode it and send off a delegate method with the result
 * or error if decoding failed.
**/
- (void)requestFinished:(ASIHTTPRequest *)request {	
	NSError *error;
	NSDictionary *result = [[CJSONDeserializer deserializer] deserializeAsDictionary:[[request responseString] dataUsingEncoding:NSUTF32BigEndianStringEncoding] error:&error];
	if(result == nil) {
		// Call the requestFailed delegate method with the error
		[self.delegate apiRequestFailed:self error:error];
		return;
	}
	
	// Decoding was successful. Call the requestFinished delegate method
	// with the decoded result
	[self.delegate apiRequestFinished:self response:result];
}

/**
 * The asynchronous request to the server failed. Send the error in the delegate
 * message.
 **/
- (void)requestFailed:(ASIHTTPRequest *)request {
	// Call the delegate method
	[self.delegate apiRequestFailed:self error:request.error];
}

@end
