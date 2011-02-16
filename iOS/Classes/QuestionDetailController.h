/**
 * QuestionDetailController.h
 *
 * Provides a UI view for showing the full text of
 * a question and a list of the answers. The UI
 * is a subclass of UIViewController and displays
 * a grouped table view with two sections. One for
 * the question and another for the answers.
 *
 * It also provides the owner of a question the ability
 * to "accept" an answer by swiping an item in the 
 * answer section and clicking the resulting Accept
 * button.
 *
 * Users who are just viewing the question may use
 * the right navigation item ("Ask") to compose and
 * submit a new answer to the question.
 *
 * See also QuestionDetailController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <UIKit/UIKit.h>
#import "InquireAPI.h"
#import "QuestionModel.h"

@interface QuestionDetailController : UIViewController <InquireAPIDelegate, UITableViewDelegate, UITableViewDataSource> {
	QuestionModel *question;
	UITableView *tableView;
	NSMutableArray *answers;
}

@property (nonatomic, assign) QuestionModel *question;
@property (nonatomic, retain) NSMutableArray *answers;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id)initWithQuestionModel:(QuestionModel *)aQuestion;

@end
