/**
 * OverlayView.m
 *
 * See header file.
**/

#import "OverlayView.h"


@implementation OverlayView
@synthesize activityIndicator, label;

- (id)initWithFrame:(CGRect)frame label:(NSString *)aLabel {
    
    self = [super initWithFrame:frame];
    if (self) {
		
		// Create an activity indicator and center it in the view
		self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self.activityIndicator startAnimating];
		self.activityIndicator.center = CGPointMake(frame.size.width/2, frame.size.height/2);
		[self addSubview:self.activityIndicator];
		
		// Build the label with the given string. Making sure to center it and place it
		// below the activity indicator.
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
		self.label.text = aLabel;
		self.label.center = CGPointMake(frame.size.width/2, frame.size.height/2+25);
		self.label.backgroundColor = [UIColor clearColor];
		self.label.textColor = [UIColor whiteColor];
		self.label.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.label];
		
		// Set a black background with a little transparency
		[self setBackgroundColor:[UIColor blackColor]];
		[self setAlpha:0.5];
    }
    return self;
}

- (void)dealloc {
	[self.activityIndicator release];
	[self.label release];
    [super dealloc];
}


@end
