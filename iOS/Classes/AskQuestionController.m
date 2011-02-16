/**
 * AskQuestionController.m
 *
 * See header file.
**/ 

#import "Constants.h"
#import "AskQuestionController.h"
#import "InquireAppDelegate.h"
#import "CJSONDeserializer.h"
#import "UserModel.h"
#import "PayPalViewController.h"

@implementation AskQuestionController
@synthesize textView;
@synthesize remainingCharsLabel;

- (id)init {
	self = [super init];
	if(self != nil) {
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	self.textView.text = @"";
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.remainingCharsLabel.text = [NSString stringWithFormat:@"Remaining: %d", MAX_QUESTION_LENGTH];
	[self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self.remainingCharsLabel release];
	[self.textView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITextViewDelegate Messages

- (void)textViewDidChange:(UITextView *)textView {
	self.navigationItem.rightBarButtonItem.enabled = ([self.textView.text length] > 0);
	
	// Calculate the remaining characters and update the label
	int remainingChars = MAX_QUESTION_LENGTH - [self.textView.text length];
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
		// The question went through fine. Pop the view from the navigation controller
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		// The JSON response from the server indicated an unsuccessful request.
		// Show an alert with the details.
		[APP_DELEGATE showAlertWithTitle:@"" message:(NSString*)[jsonResponse objectForKey:@"msg"]];
	}
	
	// release the API
	[api release];
}

/**
 * InquireAPI failure delegate message
**/
- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
	
	// release the API
	[api release];
}

#pragma mark -
#pragma mark UI Actions

- (void)handleCancelButton:(id)sender {
	// Show a UIActionSheet asking for cancel confirmation
	[[[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to cancel?" 
								  delegate:self 
						 cancelButtonTitle:@"No" 
					destructiveButtonTitle:@"Yes, Cancel" 
						 otherButtonTitles:nil] autorelease] showInView:self.view];
}

- (void)handleSendButton:(id)sender {
	// Validate the text length
	if([self.textView.text length] > MAX_QUESTION_LENGTH) {
		[APP_DELEGATE showAlertWithTitle:@"" message:[NSString stringWithFormat:@"Maximum question length is %d", MAX_QUESTION_LENGTH]];	
		return;
	}
	
	// Kick start the PayPal process by showing the PayPalViewController
	PayPalViewController *pvc = [[[PayPalViewController alloc] initWithQuestionText:self.textView.text] autorelease];
	[self.navigationController pushViewController:pvc animated:YES];	
}


@end
