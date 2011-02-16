/**
 * AnswerModel.m
 *
 * See header file.
**/

#import "AnswerModel.h"


@implementation AnswerModel
@synthesize userId;
@synthesize answerId;
@synthesize answerText;
@synthesize isOwner;
@synthesize isAcceptedAnswer;
@synthesize question;

- (id)initWithDictionary:(NSDictionary *)q ownerId:(int)ownerId {
	self = [super init];
	if(self != nil) {
		// Owner of the answer
		self->userId = [(NSNumber *)[q objectForKey:@"user_id"] intValue];
		
		// The answer id
		self->answerId = [(NSNumber*)[q objectForKey:@"answer_id"] intValue];
		
		// Text of the answer
		answerText = [(NSString *)[q objectForKey:@"answer"] copy];;
						
		// Quickly determine if the current user is the owner of this answer
		self->isOwner = (ownerId == self.userId);
	}
	return self;
}

- (void)dealloc {
	[answerText release];
	[super dealloc];
}

@end
