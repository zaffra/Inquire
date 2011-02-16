/**
 * AnswerQuestionController.h
 *
 * Provides a view that lets a user type an answer to
 * a question and submit it to the web app. Uses InquireAPI 
 * for server communication.
 *
 * See also AnswerQuestionController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <UIKit/UIKit.h>
#import "InquireAPI.h"
#import "QuestionModel.h"

@interface AnswerQuestionController : UIViewController <InquireAPIDelegate, UIActionSheetDelegate> {
	QuestionModel *question;
	UITextView *textView;
	UILabel *remainingCharsLabel;
}
@property (nonatomic, assign) QuestionModel *question;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *remainingCharsLabel;

- (id)initWithQuestion:(QuestionModel *)aQuestion;

@end