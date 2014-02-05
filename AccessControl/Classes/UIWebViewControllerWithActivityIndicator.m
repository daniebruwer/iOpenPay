//
//  UIWebViewControllerWithActivityIndicator.m
//  iOpenPay
//
//  Created by Danie Bruwer on 2013/05/04.
//  Copyright (c) 2013 Wyobi. All rights reserved.
//

#import "UIWebViewControllerWithActivityIndicator.h"

@interface UIWebViewControllerWithActivityIndicator ()

@end

@implementation UIWebViewControllerWithActivityIndicator

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    [self.activityIndicator startAnimating];
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [self.activityIndicator startAnimating];
    
}
- (void)webViewDidFinishLoading:(UIWebView *)wv
{
    [self.activityIndicator stopAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}
- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.webview)
    {
       
        //self.webview = [[UIWebView alloc] initWithFrame: self.view.frame];//init and       create the UIWebView
        self.webview =  [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        self.webview .autoresizesSubviews = YES;
        self.webview .autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [[self view] addSubview:self.webview];
    }
    self.webview.delegate = self;
    if(!self.activityIndicator)
    {
        UIActivityIndicatorView *actInd=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        actInd.hidesWhenStopped = true;
        //Change the color of the indicator, this override the color set by UIActivityIndicatorViewStyleWhiteLarge
        actInd.color=[UIColor blackColor];
        
        //Put the indicator on the center of the webview
        [actInd setCenter:self.view.center];
        
        //Assign it to the property
        self.activityIndicator=actInd;
        
        //Add the indicator to the webView to make it visible
        [self.webview addSubview:self.activityIndicator];
    }
    [self.navigationController setNavigationBarHidden:YES];
    
//    [self.webview loadRequest:
//     [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com/AASouthAfrica"]]
//     ];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
