/**
 * QuestionModel.m
 *
 * See header file.
 **/

#import "QuestionModel.h"

@implementation QuestionModel
@synthesize userId;
@synthesize questionId;
@synthesize isOwner;
@synthesize questionText;
@synthesize location;

- (id)initWithDictionary:(NSDictionary *)q ownerId:(int)ownerId {
	self = [super init];
	if(self != nil) {
		// Owner of the question
		self->userId = [(NSNumber *)[q objectForKey:@"user_id"] intValue];
		
		// The question id
		self->questionId = [(NSNumber*)[q objectForKey:@"question_id"] intValue];
		
		// Text of the question
		questionText = [(NSString *)[q objectForKey:@"question"] copy];
				
		// Latitude and longitude of the question
		float lat = [(NSString *)[q objectForKey:@"latitude"] floatValue];
		float lon = [(NSString *)[q objectForKey:@"longitude"] floatValue];
		self->location = CLLocationCoordinate2DMake(lat, lon);
		
		// Quickly determine if the current user is the owner of this question
		// This is mainly used when deciding annotation colors to distinguish
		// between owned questions and other people's questions.
		self->isOwner = (ownerId == self.userId);
	}
	return self;
}

- (void)dealloc {
	[questionText release];
	[super dealloc];
}

@end
