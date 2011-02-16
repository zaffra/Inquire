/**
 * UserModel.m
 *
 * See header file.
 **/

#import "UserModel.h"

@implementation UserModel
@synthesize emailAddress;
@synthesize karma;
@synthesize userId;
@synthesize location;

- (id)initWithDictionary:(NSDictionary *)u {
	self = [super init];
	if(self != nil) {
		self.userId = [(NSNumber *)[u objectForKey:@"user_id"] intValue];
		self.karma = [(NSNumber *)[u objectForKey:@"karma"] intValue];
		self.emailAddress = (NSString *)[u objectForKey:@"email"];
	}
	return self;
}

@end
