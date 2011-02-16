/**
 * QuestionAnnotation.h
 *
 * Implements the MKAnnotation protocol for displaying
 * pins on the map for a Question. Uses QuestionModel
 * objects for providing title, subtitle, coordinates,
 * etc.
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#include <MapKit/MapKit.h>
#include "QuestionModel.h"

@interface QuestionAnnotation : NSObject <MKAnnotation> {
	QuestionModel *question;
}

@property (nonatomic, retain) QuestionModel *question;

+ (NSString *)identifier;
- (id)initWithQuestion:(QuestionModel *)question;

@end
