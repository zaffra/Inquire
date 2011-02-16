/**
 * AnswerModel.h
 *
 * A simple object to encapsulate the details of an Answer
 * object stored on the server.
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import "QuestionModel.h"

@interface AnswerModel : NSObject {
	int userId;
	int answerId;
	NSString *answerText;
	BOOL isOwner;
	BOOL isAcceptedAnswer;
	QuestionModel *question;
}

@property (nonatomic, readonly) int userId;
@property (nonatomic, readonly) int answerId;
@property (nonatomic, readonly) NSString *answerText;
@property (nonatomic, readonly) BOOL isOwner;
@property (nonatomic, readonly) BOOL isAcceptedAnswer;
@property (nonatomic, readonly) QuestionModel *question;

- (id)initWithDictionary:(NSDictionary *)a ownerId:(int)ownerId;

@end
