//
//  AuthenticationController.m
//  iOpenPay
//
//  Created by Danie Bruwer on 2012/03/24.
//  Copyright (c) 2012 Wyobi. All rights reserved.
//

#import "AuthenticationController.h"

@implementation AuthenticationController

@synthesize footerText = _footerText;
@synthesize txtUsername;
@synthesize txtPassword;

- (IBAction)loginPressed:(id)sender 
{
    NSLog(@"LoginPressed");
    [self performSegueWithIdentifier: @"tabControllerSegue" sender : self];
    NSLog(@"Should have shown tabs!");
    
}
- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //NSLog( [ @"ok - performSegueWithIdentifier" s   identifier  );
    
    NSLog(@" %@ ", [ @"ok - performSegueWithIdentifier : " stringByAppendingString:identifier]);
    
    [super performSegueWithIdentifier : identifier  sender : self];
    
    NSLog(@"OK should have segued");
}
//UIViewController performSegueWithIdentifier:sender:
- (IBAction)userNameNext:(id)sender 
{
    NSLog(@"userNameNext");
}
- (IBAction)usernameDidEndonExit 
{
    NSLog(@"usernameDidEndonExit");
    [self.txtPassword setSelected: YES];
    [self.txtPassword becomeFirstResponder];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(self.footerText)
    {
        return self.footerText;
    }
    return @"Please enter your username and password.";
}
- (IBAction)passwordDidEndOnExit 
{
    NSLog(@"passwordDidEndOnExit");
    
    if([ self.txtPassword.text isEqualToString : @"1"])
    {
        [self performSegueWithIdentifier: @"tabControllerSegue" sender : self];
    }
    else
    {
        //self.tableView tableFooterView set
        //[self.tableView.tableFooterView setHidden: YES];
        //[self.tableView.tableFooterView         //[self.tableView view 
        // [(UITableView *)tableView titleForFooterInSection:(NSInteger)sectio
        //[self.tableView titleForFooterInSection : 1];
        //[self.tableView.sectionFooterHeight :0];
        //[self.tableView.tableFooterView setHidden: YES];
        self.footerText = @"Incorrect password.";
        [self.tableView.tableFooterView setNeedsDisplay];
    }
}

- (void)viewDidUnload {
    [self setTxtUsername:nil];
    [self setTxtPassword:nil];
    [super viewDidUnload];
}


@end
