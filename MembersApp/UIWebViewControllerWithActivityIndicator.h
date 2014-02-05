//
//  UIWebViewControllerWithActivityIndicator.h
//  iOpenPay
//
//  Created by Danie Bruwer on 2013/05/04.
//  Copyright (c) 2013 Wyobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewControllerWithActivityIndicator : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end
