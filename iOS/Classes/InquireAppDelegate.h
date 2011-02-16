/**
 * InquireAppDelegate.h
 *
 * The starting point of the Inquire application. Uses a UINavigationController
 * for managing our view hierarchy throughout the application. We also use this
 * object to initialize the PayPal library in a background thread so that it's
 * loaded transparently and ready to use when we need it. The root controller
 * of our UINavigationController is MapViewController.
 * 
 * See also MainWindow.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UserModel.h"

#define APP_DELEGATE (InquireAppDelegate *)[[UIApplication sharedApplication] delegate]
#define CURRENT_USER (UserModel *)[[APP_DELEGATE] currentUser]

@interface InquireAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navController;
	UserModel *currentUser;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) UserModel *currentUser;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

