//
//  PanicButtonViewController.h
//  WillowAcres
//
//  Created by Danie Bruwer on 2014/02/01.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PanicButtonViewController : UIViewController<CLLocationManagerDelegate>
{
    UIActivityIndicatorView* activity;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@end
