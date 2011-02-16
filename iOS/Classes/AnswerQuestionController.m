/**
 * AnswerQuestionController.m
 *
 * See header file.
**/

#import "AnswerQuestionController.h"
#import "InquireAppDelegate.h"
#import "Constants.h"

@implementation AnswerQuestionController
@synthesize question;
@synthesize textView;
@synthesize remainingCharsLabel;

/**
 * Initialize the controller with the QuestionModel object that will
 * receive the answer.
**/
- (id)initWithQuestion:(QuestionModel *)aQuestion {
	self = [super init];
	if(self != nil) {
		self.question = aQuestion;
		
		// Set the title for the navigation controller
		self.title = @"Ask Question";
		
		// Hide the default back button and replace it with a new
		// button for canceling the question
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																							   target:self 
																							   action:@selector(handleCancelButton:)] autorelease];
		
		// Create and set a button for sending the question to
		// the server. When touched it will call the handleSendButton
		// method.
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Send" 
																				   style:UIBarButtonItemStyleBordered target:self 
																				  action:@selector(handleSendButton:)] autorelease];
	}
	return self;
}

/**
 * Set view defaults
**/
- (void)viewWillAppear:(BOOL)animated {
	self.textView.text = @"";
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.remainingCharsLabel.text = [NSString stringWithFormat:@"Remaining: %d", MAX_ANSWER_LENGTH];
	[self.textView becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self.remainingCharsLabel release];
	[self.textView release];
}

- (void)dealloc {
	[self.remainingCharsLabel release];
	[self.textView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITextViewDelegate Messages

/**
 * Calculate the remaining characters left and update the remainingCharsLabel
**/
- (void)textViewDidChange:(UITextView *)textView {
	self.navigationItem.rightBarButtonItem.enabled = ([self.textView.text length] > 0);
	
	// Calculate the remaining characters and update the label
	int remainingChars = MAX_ANSWER_LENGTH - [self.textView.text length];
	self.remainingCharsLabel.text = [NSString stringWithFormat:@"Remaining: %d", remainingChars];
	
	if(remainingChars < 0) {
		self.remainingCharsLabel.textColor = [UIColor redColor];
	} else {
		self.remainingCharsLabel.textColor = [UIColor blackColor];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate Messages

/**
 * The user decided to cancel asking a question so we remove this view
 * from the navigation controller.
 **/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Confirmed cancel (0 index == cancel button)
	if(buttonIndex == 0) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark InquireAPIDelegate Messages

/**
 * InquireAPI success delegate message
 **/
- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse {
	NSLog(@"%@", jsonResponse);
	
	// Check the "success" parameter in the JSON response object
	if([(NSNumber *)[jsonResponse objectForKey:@"success"] boolValue] == YES) {
		// The answer went through fine. Release our API and pop the view from
		// the navigation controller
		[api release];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		// The JSON response from the server indicated an unsuccessful request.
		// Show an alert with the details.
		[APP_DELEGATE showAlertWithTitle:@"" message:(NSString*)[jsonResponse objectForKey:@"msg"]];
	}
}

/**
 * InquireAPI failure delegate message
 **/
- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
}

#pragma mark -
#pragma mark UI Actions

/**
 * Show a UIActionSheet asking for cancel confirmation.
**/
- (void)handleCancelButton:(id)sender {
	[[[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to cancel?" 
								  delegate:self 
						 cancelButtonTitle:@"No" 
					destructiveButtonTitle:@"Yes, Cancel" 
						 otherButtonTitles:nil] autorelease] showInView:self.view];
}

/**
 * Validate the answer text and fire off the answer to the server via InquireAPI.
 * When the response is received we can pop our view off the navigation stack.
**/
- (void)handleSendButton:(id)sender {
	// Validate the text length
	if([self.textView.text length] > MAX_ANSWER_LENGTH) {
		[APP_DELEGATE showAlertWithTitle:@"" message:[NSString stringWithFormat:@"Maximum answer length is %d", MAX_ANSWER_LENGTH]];	
		return;
	}
	
	// Use the answerQuestion method from the InquireAPI to send the user's answer
	// to the given question.
	InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
	[api answerQuestion:self.question withAnswer:self.textView.text];
}

@end
