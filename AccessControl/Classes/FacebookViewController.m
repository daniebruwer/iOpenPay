//
//  FacebookViewController.m
//  iOpenPay
//
//  Created by Danie Bruwer on 2013/05/04.
//  Copyright (c) 2013 Wyobi. All rights reserved.
//

#import "FacebookViewController.h"

@interface FacebookViewController ()

@end

@implementation FacebookViewController


//- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
//{
//    [self.activityIndicator startAnimating];
//    return YES;
//}
//
//- (void)webViewDidFinishLoading:(UIWebView *)wv
//{
//    [self.activityIndicator stopAnimating];
//}
//-(void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [self.activityIndicator stopAnimating];
//}
//- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
//{
//    [self.activityIndicator stop/Animating];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//       [self.webview loadRequest:
//        [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Silver-Lakes-Golf-Estates/266839433352381"]]
//     ];
    
    [self.webview loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.willowacres.co.za/"]]
     ];

	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebview:nil];
    //[self activityIndicator:nil];
    [super viewDidUnload];
}
@end
