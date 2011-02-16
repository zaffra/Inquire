/**
 * CreateAccountController.m
 *
 * See header file.
**/

#import "Constants.h"
#import "CreateAccountController.h"
#import "InquireAppDelegate.h"

@implementation CreateAccountController
@synthesize emailField, passwordField, confirmPasswordField;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}

-(void)showOverlay {
	overlayView = [[OverlayView alloc] initWithFrame:[[self view] bounds] label:@"Creating account..."];
	[[self view] addSubview:overlayView];
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)hideOverlay {
	[overlayView removeFromSuperview];
	[overlayView release];
	overlayView = nil;
}


/**
 * Called when the create account button is touched. This will
 * validate the fields and then submit the information to the 
 * web server using a InquireAPI object.
**/
- (void)doCreateAccount {
	// Validate
	if([emailField.text length] == 0) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Please enter your email address."];
		return;
	}
	
	if([passwordField.text length] == 0) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Please enter a password."];
		return;
	}
	
	if([confirmPasswordField.text length] == 0) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Please confirm your password."];
		return;
	}
	
	if(![passwordField.text isEqualToString:confirmPasswordField.text]) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Passwords must match."];
		return;
	}
	
	// Create an overlay to mask input fields and disable the 
	[self showOverlay];
	
	InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
	[api registerWithEmail:self.emailField.text andPassword:self.passwordField.text];
}

#pragma mark -
#pragma mark InquireAPIDelegate Messages

- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse {
	NSLog(@"%@", jsonResponse);
	// Registration succeeded

	if([(NSNumber *)[jsonResponse objectForKey:@"success"] boolValue] == YES) {
		// Resign any first responders
		[emailField resignFirstResponder];
		[passwordField resignFirstResponder];
		
		// Clear our overlay
		[self hideOverlay];
		
		// Dismiss ourself from the modal view
		[self dismissModalViewControllerAnimated:YES];
	} 
	// Authentication failed. Show an alert using our shortcut method and remove 
	// the overlay mask.
	else {
		[APP_DELEGATE showAlertWithTitle:@"" message:[jsonResponse objectForKey:@"msg"]];
		[self hideOverlay];
	}	
	
	// Release the API
	[api release];
}

- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	// The API request failed. Show an alert.
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
	[self hideOverlay];
}


#pragma mark -
#pragma mark UITextFieldDelegate Messages

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	// The return key for the email field should set the password
	// field as the first responder
	if(textField == emailField) {
		[passwordField becomeFirstResponder];
	} 
	else if(textField == passwordField) {
		[confirmPasswordField becomeFirstResponder];
	}
	// For the password field we execute the doSignIn method
	else {
		[textField resignFirstResponder];
		[self doCreateAccount];
	}
	
	return YES;
}

#pragma mark -
#pragma mark UI Actions

-(IBAction)handleCancelButton {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)handleCreateAccountButton {
	[self doCreateAccount];
}

@end
