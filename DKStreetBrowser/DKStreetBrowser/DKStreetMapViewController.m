//
//  DKStreetMapViewController.m
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKStreetMapViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kDKStreetMapViewNavigationBarButtonSize 24.0f
#define kDKStreetMapViewNavigationBarBackButtonImageFileName @"back"
#define kDKStreetMapViewMapImageFileName @"map"
#define kDKStreetMapLocationDelimiter @"-"
#define kDKStreetMapMultiLocationPartsCount 2
#define kDKStreetMapSingleLocationPartsCount 1

#define kDKStreetMapSingleSquareWidth 121.0f
#define kDKStreetMapSingleSquareHeight 121.0f
#define kDKStreetMapSingleSquareOffsetSize 10.0f
#define kDKStreetMapTopOffsetSize 1.5f
#define kDKStreetMapLeftOffsetSize -5.5f

#define kDKStreetMapLabelDefaultCorner 10.0f
#define kDKStreetMapLabelDefaultFontSize 60.0f

@interface DKStreetMapViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DKStreetMapViewController

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;

- (id)init {
    self = [super init];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIImage *buttonImage = [UIImage imageNamed: kDKStreetMapViewNavigationBarBackButtonImageFileName];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake (0, 0,
                                                                   kDKStreetMapViewNavigationBarButtonSize,
                                                                   kDKStreetMapViewNavigationBarButtonSize)];
    
    [button setImage: buttonImage forState: UIControlStateNormal];
    [button setImage: buttonImage forState: UIControlStateSelected];
    [button setImage: buttonImage forState: UIControlStateHighlighted];

    [button addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView: button];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame: self.view.bounds];
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.delegate = self;
    self.scrollView.contentMode = UIViewContentModeScaleToFill;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview: self.scrollView];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                          action: @selector (scrollViewDoubleTapped:)];
    
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    
    [self.scrollView addGestureRecognizer: doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector (scrollViewTwoFingerTapped:)];
    
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    
    [self.scrollView addGestureRecognizer: twoFingerTapRecognizer];
    
    UIImage *mapImage = [UIImage imageNamed:kDKStreetMapViewMapImageFileName];
    self.imageView = [[UIImageView alloc] initWithImage: mapImage];
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.frame = CGRectMake(0, 0, mapImage.size.width, mapImage.size.height);
    self.imageView.userInteractionEnabled = YES;
    
    [self.scrollView addSubview: self.imageView];
    
    self.scrollView.contentSize = mapImage.size;
}

- (void)viewWillAppear: (BOOL)animated {
    [super viewWillAppear: animated];
    
    CGRect scrollViewFrame = self.scrollView.frame;

    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN (scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)goBack {
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (UIView *)viewForZoomingInScrollView: (UIScrollView *)scrollView {

    return self.imageView;
}

- (void)scrollViewDidZoom: (UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (void)scrollViewDoubleTapped: (UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView: self.imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect: rectToZoomTo animated: YES];
}

- (void)scrollViewTwoFingerTapped: (UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    
    newZoomScale = MAX (newZoomScale, self.scrollView.minimumZoomScale);
    
    [self.scrollView setZoomScale: newZoomScale animated: YES];
}

- (NSDictionary *)indexFromAddress: (NSString *)address {
    int secondIndexPosition = 0;
    float firstIndex = 0.0;
    float secondIndex = 0.0;
    unichar firstChar = [address characterAtIndex: 0];
    
    if (([address characterAtIndex: 1] >= 'A') && ([address characterAtIndex: 1] <= 'Z')) {
        firstIndex = ((firstChar - 'A') + 1) * ('Z' - 'A' + 1) + ([address characterAtIndex: 1] - 'A');
        secondIndexPosition = 2;
    } else {
        firstIndex = firstChar - 'A';
        secondIndexPosition = 1;
    }
    
    secondIndex = [[address substringFromIndex: secondIndexPosition] intValue] - 1.0;
    
    return @{@"x": [NSNumber numberWithFloat: firstIndex], @"y": [NSNumber numberWithFloat: secondIndex]};
}

- (void)highLightRect: (CGRect)rectToHighlight withTextLabel: (NSString *)text {
    
    UIView *markerView = [[UIView alloc] initWithFrame: rectToHighlight];
    UILabel *markerLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, rectToHighlight.size.width,
                                                                      rectToHighlight.size.height)];

    markerView.backgroundColor = [UIColor whiteColor];
    markerView.alpha = 0.0f;
    markerView.layer.cornerRadius = kDKStreetMapLabelDefaultCorner;
    
    markerLabel.backgroundColor = [UIColor clearColor];
    markerLabel.textColor = [UIColor darkGrayColor];
    markerLabel.textAlignment = NSTextAlignmentCenter;
    markerLabel.text = text;
    markerLabel.font = [UIFont boldSystemFontOfSize: kDKStreetMapLabelDefaultFontSize];
    markerLabel.adjustsFontSizeToFitWidth = YES;
    
    [markerView addSubview: markerLabel];
    
    [self.imageView addSubview: markerView];
    
    [UIView animateWithDuration: 0.2
                          delay: 0.5
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         markerView.alpha = 0.9;
                     }
                     completion: ^(BOOL finished){
                         
                         if (finished) {
                             
                             [UIView animateWithDuration: 1.0
                                                   delay: 0.0
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations: ^{
                                                  markerView.alpha = 0.0;
                                              }
                                              completion: ^(BOOL finished){
                                                  [markerView removeFromSuperview];
                                              }];

                         } else {
                             [markerView removeFromSuperview];
                         }
                     }];

}

- (void)showLocations: (NSString *)location {
    NSString *originalLocation = location;
    NSArray *locations = [[location uppercaseString] componentsSeparatedByString: kDKStreetMapLocationDelimiter];
    
    location = locations [0];
    
    NSDictionary *mainAddress = [self indexFromAddress: location];
    
    switch (locations.count) {
        case 0:
            break;

        case kDKStreetMapMultiLocationPartsCount: {
                NSDictionary *endAddress = [self indexFromAddress: locations [1]];

                float x1 = [mainAddress [@"x"] floatValue];
                float y1 = [mainAddress [@"y"] floatValue];

                float x2 = [endAddress [@"x"] floatValue];
                float y2 = [endAddress [@"y"] floatValue];

                mainAddress = @{@"x": [NSNumber numberWithFloat: (x1 + x2) / 2.0f], @"y": [NSNumber numberWithFloat: (y1 + y2) / 2.0f]};
        }
            
        case kDKStreetMapSingleLocationPartsCount: {
            
            float x = [mainAddress [@"x"] floatValue];
            float y = [mainAddress [@"y"] floatValue];
            
            CGRect rectToZoomTo = CGRectMake (kDKStreetMapLeftOffsetSize + x * kDKStreetMapSingleSquareWidth - kDKStreetMapSingleSquareOffsetSize,
                                              kDKStreetMapTopOffsetSize + y * kDKStreetMapSingleSquareHeight - kDKStreetMapSingleSquareOffsetSize,
                                              kDKStreetMapSingleSquareWidth + (kDKStreetMapSingleSquareOffsetSize * 2),
                                              kDKStreetMapSingleSquareHeight + (kDKStreetMapSingleSquareOffsetSize * 2));
            
            [self.scrollView zoomToRect: rectToZoomTo animated: YES];
            
            [self highLightRect: rectToZoomTo withTextLabel: originalLocation];
        }
            break;        
            
        default:
            break;
    }
}

@end
