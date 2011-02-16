/**
 * AskQuestionController.h
 *
 * Provides a view that lets a user type a question
 * and submit it to the web app. Uses InquireAPI for
 * server communication.
 *
 * See also AskQuestionController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
**/

#import <UIKit/UIKit.h>
#import "InquireAPI.h"

@interface AskQuestionController : UIViewController <UIActionSheetDelegate, UITextViewDelegate, InquireAPIDelegate> {
	UITextView *textView;
	UILabel *remainingCharsLabel;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *remainingCharsLabel;

@end
