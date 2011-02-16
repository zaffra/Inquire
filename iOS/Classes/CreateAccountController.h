/**
 * CreateAccountController.h
 *
 * Provides UI and logic for registering a new user. Submitting
 * the "form" will make use of InquireAPI to register the user
 * in the web application.
 *
 * See also CreateAccountController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
**/

#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import "InquireAPI.h"

@interface CreateAccountController : UIViewController <InquireAPIDelegate, UITextFieldDelegate> {
	UITextField *emailField;
	UITextField *passwordField;
	UITextField *confirmPasswordField;
	
	OverlayView *overlayView;
}

@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPasswordField;

-(IBAction)handleCancelButton;
-(IBAction)handleCreateAccountButton;

- (void)doCreateAccount;

@end
