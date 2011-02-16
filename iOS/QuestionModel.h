/**
 * QuestionModel.h
 *
 * A simple object to encapsulate the details of a Question
 * object stored on the server.
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface QuestionModel : NSObject {
	int userId;
	int questionId;
	BOOL isOwner;
	NSString *questionText;
	CLLocationCoordinate2D location;
}
@property (nonatomic, readonly) int userId;
@property (nonatomic, readonly) int questionId;
@property (nonatomic, readonly) BOOL isOwner;
@property (nonatomic, readonly) NSString *questionText; 
@property (nonatomic, readonly) CLLocationCoordinate2D location;

- (id)initWithDictionary:(NSDictionary *)q ownerId:(int)ownerId;

@end
