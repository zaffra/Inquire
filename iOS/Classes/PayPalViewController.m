/**
 * PayPalViewController.m
 *
 * See header file.
**/

#import "Constants.h"
#import "PayPalViewController.h"
#import "InquireAppDelegate.h"
#import "PayPalPayment.h"
#import "PayPalInvoiceData.h"
#import "PayPalInvoiceItem.h"
#import "MapViewController.h"

@implementation PayPalViewController
@synthesize questionText;
@synthesize paymentFinished;
@synthesize libraryExited;

- (id)initWithQuestionText:(NSString *)someText {
	self = [super init];
	if(self != nil) {
		self.questionText = someText;
		self.paymentFinished = NO;
		self.libraryExited = NO;
	}
	return self;
}

/**
 * Creates the "Pay with PayPal" button and places it in the view
**/
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Place the PayPal button in the view. There are several button types to choose from and
	// they only change the size of the button. You can set the buttonTextType to be one of
	// BUTTON_TEXT_DONATE or BUTTON_TEXT_PAY to control whether the button's label reads
	// Pay or Donate with PayPal
	UIButton *button = [[PayPal getInstance] getPayButtonWithTarget:self andAction:@selector(handlePayPalButton:) andButtonType:BUTTON_194x37];

	// Center the button in the view and place it slightly below the label
	CGRect frame = button.frame;
	frame.origin.x = (self.view.frame.size.width - button.frame.size.width) / 2.0;
	frame.origin.y = 220;
	button.frame = frame;
	
	// Add the button to the view
	[self.view addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}

- (void)popToMapView {
	UIViewController *uivc;
	for(uivc in self.navigationController.viewControllers) {
		if([uivc isKindOfClass:[MapViewController class]]) {
			break;
		}
	}
	[self.navigationController popToViewController:uivc animated:YES];
}

#pragma mark -
#pragma mark PayPalPaymentDelegate Messages

/**
 * PayPal Delegate for handling a successful payment! First, we need to check the payment
 * status to make sure it was completed. Then, we need to finish the question asking by
 * sending the question via the API. We are sending along the payKey from PayPal so the
 * server may further validate the transacation, save any metadata, etc.
 *
 * Sending the data back to the server from our mobile app is only one way to accomplish
 * letting the server know a succesful payment was received. We can also set up Instant
 * Payment Notifications through our PayPalPayment we created in the handlePayPalButton
 * message. Defining an IPN URL would instruct PayPal to hit that URL when a payment
 * processed. For more infomation on IPN check out the developer guide.
 *
 * In our case we're taking the simpler route and just sending back to the server. We are
 * sending the payKey along with the question details. The reason we send the payKey is so
 * the server can use a PayPal API to check that the payKey is valid. We won't be handling
 * that on the server, but for security reasons you should (or use the IPN gateway.)
 **/
-(void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
	// Check that the payment was completed. The other options are CREATED and OTHER, but
	// since we're using simple payments we don't need to check for them.
	if(paymentStatus == STATUS_COMPLETED) {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Thanks for your payment!"];
		
		// Build an API request to send the question to the server
		InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
				
		// User
		UserModel *user = [APP_DELEGATE currentUser];
		
		// Start the API request to ask the question
		[api askQuestion:self.questionText atLocation:user.location withPayKey:payKey];
	}
	else {
		[APP_DELEGATE showAlertWithTitle:@"" message:@"Payment status other than completed received!!!"];
	}
}

/**
 * PayPal Delegate for handling a user canceling a payment. In our we do nothing except
 * let the user know that they've canceled.
**/
-(void)paymentCanceled {
	[APP_DELEGATE showAlertWithTitle:@"" message:@"Your payment has been canceled."];
}

-(void)paymentFailedWithCorrelationID:(NSString *)correlationID andErrorCode:(NSString *)errorCode andErrorMessage:(NSString *)errorMessage {
	[APP_DELEGATE showAlertWithTitle:[NSString stringWithFormat:@"PayPal Error - %@", errorCode] message:errorMessage];
}

/**
 * Called when the PayPal library has finished.
**/
-(void)paymentLibraryExit {
	// Check to see if the payment has completed and if so pop back to
	// the map view.
	if(self.paymentFinished) {
		[self popToMapView];
	}
}

#pragma mark -
#pragma mark InquireAPIDelegate Messages

/**
 * InquireAPI delegate message for handling a response
**/
- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse {
	NSLog(@"%@", jsonResponse);
	// As always check that the success parameter validates to YES
	if([(NSNumber *)[jsonResponse objectForKey:@"success"] boolValue] == YES) {
		
		// If the PayPal library has already exited we can go ahead and pop back to the map view
		// or else we wait until the PayPal library exits.
		self.paymentFinished = YES;
		
		if(self.libraryExited) {
			[self popToMapView];
		}

	} else {
		// Failure alert from API
		[APP_DELEGATE showAlertWithTitle:@"" message:[jsonResponse objectForKey:@"msg"]];
		[api release];
	}
}

/**
 * InquireAPI delegate message for handling a failed request
 **/
- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
}

#pragma mark -
#pragma mark UI Actions

/**
 * Performs the logic for setting up a simple payment using the PayPal library.
 * If you need to execute a different payment type you should consult the
 * "PayPal Mobile Payments Library Developer Guide and Reference - iOS Edition"
 * that comes with the PayPal iPhone Library.
 * @see https://www.x.com/community/ppx/sdks#MPL
**/
-(void)handlePayPalButton:(id)sender {
	// We don't need shipping enabled since this is a digital purchase
	// and we aren't shipping items to the user
	[PayPal getInstance].shippingEnabled = NO;
	
	// Since we aren't handling shipping we also don't need dynamic account
	// updates to calculate said shipping so disable that as well
	[PayPal getInstance].dynamicAmountUpdateEnabled = TRUE;
	
	// This is optional, and we're deliberately setting the default
	// value for who pays for the fees of the transaction to show that
	// you can choose different fee payers. Check out the docs if you
	// need more information.
	[PayPal getInstance].feePayer = FEEPAYER_EACHRECEIVER;
	
	// We are sending a payment to one recipient ("simple payment") so
	// we only need to create a PayPalPayment object. For other payment 
	// types and how to set them up, see the user guide referenced above
	PayPalPayment *payment = [[[PayPalPayment alloc] init] autorelease];
	payment.recipient = PAYPAL_RECEIVER_EMAIL;
	payment.paymentCurrency = @"USD";
	payment.description = @"Inquire Question";
	payment.merchantName = @"Inquire iPhone App";
	
	// Set the total amount of the purchase
	payment.subTotal = [NSDecimalNumber decimalNumberWithString:@"0.99"];
	
	// Build a PayPalInvoiceData object that lets us set tax, shipping, and
	// individual invoice items. We're not using the tax or shipping, but
	// we'll use it to build out the invoice item
	payment.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
	payment.invoiceData.invoiceItems = [NSMutableArray array];
	
	PayPalInvoiceItem *item = [[[PayPalInvoiceItem alloc] init] autorelease];
	item.name = @"Inquire Question";
	item.totalPrice = payment.subTotal;
	
	// Add our invoice item to the list of invoice items in the PayPalInvoiceData
	// object
	[payment.invoiceData.invoiceItems addObject:item];

	// Our PayPalPayment has been created and configured, so now all that's left
	// is to send the checkout request and let PayPal do the rest. Of course,
	// we'll need to respond to any delegate messages it calls, but that's
	// pretty simple too.
	[[PayPal getInstance] checkoutWithPayment:payment];
}


@end
