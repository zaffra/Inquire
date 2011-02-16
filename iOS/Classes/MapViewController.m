/**
 * MapViewController.m
 *
 * See header file.
**/
#import "Constants.h"
#import "InquireAppDelegate.h"
#import "MapViewController.h"
#import "QuestionModel.h"
#import "QuestionAnnotation.h"
#import "SignInController.h"
#import "QuestionDetailController.h"
#import "AskQuestionController.h"
#import "PayPalViewController.h"

@implementation MapViewController
@synthesize mapView;
@synthesize overlayView;

- (id)init {
	self = [super init];
	if(self != nil) {
		// Set the title for the navigation bar
		self.title = APP_NAME;
		
		// Hide the back button since this view controller is the root
		// of the navigation hierarchy
		self.navigationItem.hidesBackButton = YES;
		
		// Create a button to quickly show the user how much karma they have
		
		UserModel *user = [APP_DELEGATE currentUser];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Karma (%d)", user.karma] 
																				  style:UIBarButtonItemStyleBordered 
																				 target:self 
																				 action:@selector(handleKarmaButton:)] autorelease];
		
		// Create a button for asking new questions and place it in the
		// right side of the navigation bar
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(handleAskQuestion:)] autorelease];
	}
	return self;
}

/**
 * Creates and adds a transparent overlay to the view
**/
-(void)showOverlay {
	if(self.overlayView == nil) {
		self.overlayView = [[OverlayView alloc] initWithFrame:self.view.bounds label:@"Updating map..."];
		[self.view addSubview:self.overlayView];
	}
}

/**
 * Destroys the overlay view
**/
-(void)hideOverlay {
	if(self.overlayView != nil) {
		[self.overlayView removeFromSuperview];
		[self.overlayView release];
		self.overlayView = nil;
	}
}

/**
 * Overriding the viewWillAppear message so we can detect when we need
 * to show the sign in controller for authentication. This keeps the 
 * overall logic a bit simpler, but it would be pretty trivial to use
 * bits of the application without an authenticated user.
**/
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Show an overlay letting the user know the view is doing something
	[self showOverlay];
	
	UserModel *user = [APP_DELEGATE currentUser];
	// Check for an authenticated user and display the sign in controller if needed
	if(user == nil) {
		SignInController *signInController = [[[SignInController alloc] init] autorelease];
		[self presentModalViewController:signInController animated:NO];
		return;
	}
	
	// Update the karma button
	self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"Karma (%d)", user.karma];
	
	// Instruct the map view to track the user's location if we don't already have it.
	if(self.mapView.userLocation.location == nil) {
		self.mapView.showsUserLocation = YES;
	} 
	// If we already have the user's location update the map
	else {
		// Remove all annotations except for the "blue blip"
		for(id <MKAnnotation> a in self.mapView.annotations) {
			if(a != self.mapView.userLocation) {
				[self.mapView removeAnnotation:a];
			}
		}
		
		// Call the API method to grab the set of questions near the user's location
		InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
		[api findQuestionsNearLocation:user.location];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self.mapView release];
	self.mapView = nil;
	
	[self hideOverlay];
}


- (void)dealloc {
	[self hideOverlay];
	[mapView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Utility Messages

/**
 * Iterates over the annotations our map view has and calculates the
 * appropriate MKCoordinateRegion that encapsulates all annotation 
 * objects.
 *
 * Borrowed from http://bit.ly/hw1TLb
**/
-(void)zoomToFitMapAnnotations {
    if([self.mapView.annotations count] == 0)
        return;
	
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
	
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
	
    for(id<MKAnnotation> annotation in self.mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
		
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
	
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
	
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

/**
 * Given a list of Question JSON objects from the server, we build a new list of
 * QuestionAnnotation objects and add them to the map view to show as pins.
**/
-(void)buildQuestionAnnotations:(NSArray *)rawQuestions {	
	int userId = [[APP_DELEGATE currentUser] userId];
	
	// Build a list of QuestionAnnotation objects using QuestionModel objects
	NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:[rawQuestions count]];
	for(NSDictionary *rawQuestion in rawQuestions) {
		QuestionModel *question = [[[QuestionModel alloc] initWithDictionary:rawQuestion ownerId:userId] autorelease];
		[list addObject:[[QuestionAnnotation alloc] initWithQuestion:question]];
	}
	
	NSLog(@"Built %d QuestionAnnotation objects.", [list count]);
	
	// Add the list of QuestionAnnotation objects to the map view
	[self.mapView addAnnotations:list];
	
	// Release the list since the map will retain it
	[list release];
	
	// Update the map zoom to show all annotation objects
	[self zoomToFitMapAnnotations];
	
	// Hide the overlay
	[self hideOverlay];
}

#pragma mark -
#pragma mark MKMapViewDelegate Messages

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	// Store the current location globally through the app delegate
	// so other views can get to it.
	UserModel *user = [APP_DELEGATE currentUser];
	user.location = [userLocation coordinate];
	
	// Using the API, load questions in the vicinity of the user's location
	InquireAPI *api = [[InquireAPI alloc] initWithBaseURL:BASE_API_URL andDelegate:self];
	[api findQuestionsNearLocation:[userLocation coordinate]];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	// For the current user's location we use the default "blue blip" annotation by returning nil
	if(annotation == self.mapView.userLocation) {
		return nil;
	}
	
	MKPinAnnotationView *pin = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"questionAnnotation"];
	if(pin == nil) {
		pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"questionAnnotation"];
		pin.animatesDrop = NO;
		pin.canShowCallout = YES;
		
		// Distinguish between the user's questions and others by the pin color
		if(((QuestionAnnotation *)annotation).question.isOwner) {
			pin.pinColor = MKPinAnnotationColorGreen;
		} else {
			pin.pinColor = MKPinAnnotationColorPurple;
		}
		
		// Set the right callout view to be a disclosure button that indicates more
		// information is available for the question. In particular, this will let us
		// load the detail view for a question and accept answers.
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		//[rightButton addTarget:self action:@selector(handleQuestionDetailsButton) forControlEvents:UIControlEventTouchUpInside];
		pin.rightCalloutAccessoryView = rightButton;
	}
		
	return pin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	NSLog(@"%@", [view.annotation title]);
	NSLog(@"%@", [view.annotation subtitle]);
}

/**
 * Convenience message of the MKMapViewDelegate that is called when a callout
 * accessory view is tapped. In this case we only have one callout (right)
 * and we should build and present a QuestionDetailController
**/
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	QuestionModel *question = ((QuestionAnnotation *)view.annotation).question;
	QuestionDetailController *qdc = [[[QuestionDetailController alloc] initWithQuestionModel:question] autorelease];
	[self.navigationController pushViewController:qdc animated:YES];
}

- (void)mapView:(MKMapView *)aMapView didFailToLocateUserWithError:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"MKMapView Error" message:[error localizedDescription]];
}

#pragma mark -
#pragma mark InquireAPIDelegate Messages

- (void)apiRequestFinished:(InquireAPI *)api response:(NSDictionary *)jsonResponse {
	if([(NSNumber *)[jsonResponse objectForKey:@"success"] boolValue] == YES) {
		NSArray *keys = [jsonResponse allKeys];
		if([keys containsObject:@"questions"]) {
			[self buildQuestionAnnotations:(NSArray *)[jsonResponse objectForKey:@"questions"]];
		}
	} else {
		[APP_DELEGATE showAlertWithTitle:@"" message:[jsonResponse objectForKey:@"msg"]];
	}
	
	// Release the API object
	[api release];
}

- (void)apiRequestFailed:(InquireAPI *)api error:(NSError *)error {
	[APP_DELEGATE showAlertWithTitle:@"" message:[error localizedDescription]];
}


#pragma mark -
#pragma mark UI Actions

/**
 * Called when the karma button is touched. This simply displays an alert with
 * the number of karma points the user has. It could display new view controller
 * that shows the user's global rank and the users with the top 25 karma.
**/
- (void)handleKarmaButton:(id)sender {
	UserModel *user = [APP_DELEGATE currentUser];
	[APP_DELEGATE showAlertWithTitle:@"" message:[NSString stringWithFormat:@"You have %d karma point%@!!", user.karma, (user.karma == 1 ? @"" : @"s")]];
}

/**
 * When touched, present the AskQuestionController via navigation controller.
 **/
- (void)handleAskQuestion:(id)sender {
	// Build and push an AskQuestionController on the navigation controller's stack
	AskQuestionController *aqc = [[[AskQuestionController alloc] init] autorelease];
	[self.navigationController pushViewController:aqc animated:YES];
}

@end
