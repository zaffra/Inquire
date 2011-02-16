/**
 * QuestionAnnotation.m
 *
 * See header file.
**/

#import "QuestionAnnotation.h"


@implementation QuestionAnnotation
@synthesize question;

+ (NSString *)identifier {
	return @"__QuestionAnnotation__";
}

- (id)initWithQuestion:(QuestionModel *)aQuestion {
	self = [super init];
	if(self != nil) {
		self.question = aQuestion;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	return question.location;
}

- (NSString *)title {
	if(self.question.isOwner) {
		return @"My Question";
	}
	else {
		return @"Question";
	}
}

- (NSString *)subtitle {
	return [NSString stringWithFormat:@"%@", self.question.questionText];
}

@end
