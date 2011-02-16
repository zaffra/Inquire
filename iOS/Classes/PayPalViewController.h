/**
 * PayPalViewController.h
 *
 * Provides the UI for purchasing a question using the
 * PayPal library to handle the actual payment process.
 *
 * See also PayPalViewController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <UIKit/UIKit.h>
#import "PayPal.h"
#import "InquireAPI.h"

@interface PayPalViewController : UIViewController <PayPalPaymentDelegate, InquireAPIDelegate> {
	NSString *questionText;
	Boolean paymentFinished;
	Boolean libraryExited;
}

@property (nonatomic, copy) NSString *questionText;
@property (nonatomic, readwrite) Boolean paymentFinished;
@property (nonatomic, readwrite) Boolean libraryExited;

- (id)initWithQuestionText:(NSString *)someText;

@end
