//
//  PanicButtonViewController.m
//  WillowAcres
//
//  Created by Danie Bruwer on 2014/02/01.
//
//

#import "PanicButtonViewController.h"

@interface PanicButtonViewController ()

@end

@implementation PanicButtonViewController

-(void)loadView {
    [super loadView];
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.hidesWhenStopped = YES;
    [self.view addSubview:activity];
    activity.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 50);
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (IBAction)panicButtonClicked:(id)sender
{
     [activity startAnimating];
    
    NSString* urlAsString =  [NSString stringWithFormat: @"http://reports.accesscontrol.wyobi.net/Cases/CreateJSON?membershipNumber=0721328231&Latitude=%g&Longitude=%g&symptom=panic&random=%@"
                              , self.locationManager.location.coordinate.latitude
                              , self.locationManager.location.coordinate.longitude
                              , [[NSUUID UUID] UUIDString]];
    NSLog(@"url : %@",urlAsString);
    NSURL* url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod: @"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
    
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:&response
                                                error:&error];
    
    NSString* caseID = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    caseID = [caseID stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString* msg = [@"Security notified. Your reference Number " stringByAppendingString: [caseID stringByReplacingOccurrencesOfString:@"-" withString:@" : "]];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Panic Button"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
    [activity stopAnimating];
}

-(CLLocationManager*) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self; // send loc updates to myself
    }
    return _locationManager;
}

@end
