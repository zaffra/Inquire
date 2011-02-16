/**
 * UserModel.h
 *
 * A simple object to encapsulate the details of a User
 * object stored on the server.
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <CoreLocation/CoreLocation.h>

@interface UserModel : NSObject {
	NSString *emailAddress;
	int karma;
	int userId;
	CLLocationCoordinate2D location;
}

@property (nonatomic, retain) NSString *emailAddress;
@property (nonatomic, readwrite) int karma;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) CLLocationCoordinate2D location;

- (id)initWithDictionary:(NSDictionary *)u;

@end
