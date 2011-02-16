/**
 * SignInController.h
 *
 * Provides UI for authenticating to the web application using
 * the InquireAPI to handle the server request.
 *
 * See also SignInController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import "InquireAPI.h"

@interface SignInController : UIViewController <UITableViewDelegate, InquireAPIDelegate> {
	UITextField *emailField;
	UITextField *passwordField;
	OverlayView *overlayView;
}

@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

- (IBAction)handleSignInButton:(id)sender;
- (IBAction)handleCreateAccountButton:(id)sender;
- (void)doSignIn;
@end
