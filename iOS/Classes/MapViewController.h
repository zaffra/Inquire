/**
 * MapViewController.h
 *
 * Provides a MKMapView for showing the current user's location and
 * a list of questions near that location. Each question is represented
 * by either a green (user's question) or a purple (not user's question)
 * map pin. Touching a pin shows a quick description of the question and
 * a disclosure button to show the question's detail view provided by
 * QuestionDetailController. Touching the left navigation bar item will
 * present a simple alert with the number of karam points available, and
 * touching the right navigation item will show a AskQuestionController
 * for asking and purchasing a new question.
 *
 * See also MapViewController.xib
 *
 * Created by Zaffra, LLC - http://zaffra.com
**/

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "InquireAPI.h"
#import "OverlayView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, InquireAPIDelegate> {
	MKMapView *mapView;
	OverlayView *overlayView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) OverlayView *overlayView;

@end
