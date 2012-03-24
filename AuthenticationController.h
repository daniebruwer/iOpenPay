//
//  AuthenicationController.h
//  iOpenPay
//
//  Created by Danie Bruwer on 2012/03/24.
//  Copyright (c) 2012 Wyobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthenticationController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak) NSString* footerText;

@end
