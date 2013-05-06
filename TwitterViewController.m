//
//  TwitterViewController.m
//  iOpenPay
//
//  Created by Danie Bruwer on 2013/05/04.
//  Copyright (c) 2013 Wyobi. All rights reserved.
//

#import "TwitterViewController.h"

@interface TwitterViewController ()

@end

@implementation TwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.webview.delegate = self;
    [self.webview loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://twitter.com/AASouthAfrica"]]
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
