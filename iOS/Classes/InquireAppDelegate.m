/**
 * InquireAppDelegate.m
 *
 * See header file.
**/

#import "Constants.h"
#import "InquireAppDelegate.h"
#import "MapViewController.h"
#import "PayPal.h"

@implementation InquireAppDelegate
@synthesize window;
@synthesize navController;
@synthesize currentUser;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {	
	// The fun part - initialize PayPal. When you initialize the PayPal library you
	// must supply a couple of things: your application ID and the environment mode to
	// operate in. The application ID is your PayPal application ID and for testing
	// you can use "APP-80W284485P519543T" which we are using below. The environment mode
	// is an enum and can be one of ENV_SANDBOX, ENV_LIVE, and ENV_NONE. The first two
	// should be pretty self explanatory, but the last one allows you to work in what
	// PayPal calls "demonstration mode". In a nuthsell it lets you use the library
	// without actually connecting to any servers.

	// PayPal highly recommends that you initialize the library via a background thread
	// for performance reasons. Basically, initializing on a background thread will allow
	// the library to load transparently (in the background!) and not cause in noticeable
	// delays when loading your iOS application. If you intend to show a "Pay with PayPal"
	// button immediately you might consider refactoring your so you don't have to
	// show it immediately or show a loading screen while things are initialized so the
	// user doesn't spend a few seconds looking at a blank screen.
	
	// Here we initialize with the test app id and the demo environment in a background
	// thread
	[NSThread detachNewThreadSelector:@selector(initPayPalOnThread) toTarget:self withObject:nil];
	
	// Add our MapViewController as the root view controller
	MapViewController *mvc = [[[MapViewController alloc] init] autorelease];
	[self.navController pushViewController:mvc animated:NO];
	
	// Add the navigation controller to the main window
	[self.window addSubview:[navController view]];
	
	// Show the window
    [self.window makeKeyAndVisible];

    return YES;
}

-(void)initPayPalOnThread {
	// Using ENV_NONE for demo environment. If you want to use a sandbox or live
	// environment you'll need to create and setup the appropriate paypal account
	// Take a look at Constants.h for providing the required information for these
	// types of environments.
	[PayPal initializeWithAppID:PAYPAL_APPLICATION_ID forEnvironment:ENV_NONE];	
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
	[[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[currentUser release];
	[navController release];
    [window release];
    [super dealloc];
}


@end
