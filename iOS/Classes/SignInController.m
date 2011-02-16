/**
 * SignInController.m
 *
 * See header file.
**/

#import "Constants.h"
#import "CJSONDeserializer.h"
#import "SignInController.h"
#import "CreateAccountController.h"
#import "InquireAppDelegate.h"

@implementation SignInController
@synthesize emailField, passwordField;

- (id) init {
	return [super init];
}

/**
 * Reset our input fields when the view is about to be shown.
**/
- (void)viewWillAppear:(BOOL)animated {
	[emailField setText:@""];
	[passwordField setText:@""];
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
	[overlayView release];
    [super dealloc];
}

/**
 * Create an overlay to mask input fields.
**/
-(void)showOverlay {
	overlayView = [[OverlayView alloc] initWithFrame:[[self view] bounds] label:@"Signing in..."];
	[[self view] addSubview:overlayView];
}

/**
 * Destroy the overlay that was masking inputs and re-enable the
 * right nav button.
**/
-(void)hideOverlay {
	[overlayView removeFromSuperview];
	[overlayView release];
	overlayView = nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate Messages

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	// The return key for the email field should set the password
	// field as the first responder
	if(textField == emailField) {
		[passwordField becomeFirstResponder];
	} 
	// For the password field we execute the doSignIn method
	else {
		[textField resignFirstResponder];
		[self doSignIn];
	}
	
	return YES;
}

#pragma mark -
#pragma mark InquireAPIDelegate Messages

- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse {
	NSLog(@"%@", jsonResponse);
	// Authentication succeeded
	if([(NSNumber *)[jsonResponse objectForKey:@"success"] boolValue] == YES) {
		// Resign any first responders
		[emailField resignFirstResponder];
		[passwordField resignFirstResponder];
		
		// Clear our overlay
		[self hideOverlay];
		
		// Tell the application delegate to store the user object so other views
		// can easily get to it.
		[APP_DELEGATE setCurrentUser:[[[UserModel alloc] initWithDictionary:[jsonResponse objectForKey:@"user"]] autorelease]];
		
		// Dismiss ourself from the modal view
		[self dismissModalViewControllerAnimated:YES];
	} 
	// Authentication failed. Show an alert using our shortcut method and remove 
	// the overlay mask.
	else {
		[APP_DELEGATE showAlertWithTitle:@"" message:[jsonResponse objectForKey:@"msg"]];
		[self hideOverlay];
	}	
}

- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
	[self hideOverlay];
}

#pragma mark -
#pragma mark UI Actions

- (void) doSignIn {	
	// Validate the input fields before trying to authenticate. Both the email and
	// passwords fields must have data before we can proceed.
	if([emailField.text length] == 0) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Please enter your email address."];
		return;
	}
	
	if([passwordField.text length] == 0) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Please enter your password."];
		return;
	}
		
	// Call the helper method to create the overlay and disable user input
	[self showOverlay];
	
	// Rather than making your controllers aware of the ASIHttpRequest objects required
	// to do hit the web application we've encapsulated the logic for the API into the
	// InquireAPI object to make things easier to follow.
	InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
	[api authenticateWithEmail:self.emailField.text andPassword:self.passwordField.text];
}

/**
 * Call our doSignIn method when the Sign In button is touched.
**/
- (IBAction)handleSignInButton:(id)sender {
	[self doSignIn];
}

/**
 * Instantiates a CreateAccountController and displays it modally for account creation.
 **/
- (IBAction)handleCreateAccountButton:(id)sender {
	CreateAccountController *cac = [[[CreateAccountController alloc] init] autorelease];
	[cac setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentModalViewController:cac animated:YES];
}

@end
