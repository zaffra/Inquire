/**
 * OverlayView.h
 *
 * Utility view for providing a semi-transparent overlay where 
 * needed. Mainly used for masking inputs while some asynch
 * process is executing.
 *
 * Created by Zaffra, LLC - http://zaffra.com
 **/

#import <UIKit/UIKit.h>


@interface OverlayView : UIView {
	UIActivityIndicatorView *activityIndicator;
	UILabel *label;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *label;

- (id)initWithFrame:(CGRect)frame label:(NSString *)aLabel;

@end
