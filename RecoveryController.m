//
//  RecoveryController.m
//  iOpenPay
//
//  Created by Danie Bruwer on 2013/05/03.
//  Copyright (c) 2013 Wyobi. All rights reserved.
//

#import "RecoveryController.h"

@interface RecoveryController ()

@end

@implementation RecoveryController

//NSArray *arrayGroupNames;
//NSArray *arrayGroupItems;
NSMutableDictionary *values;

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
    values = [[NSMutableDictionary alloc] init];
    
    [values setValue: [NSArray arrayWithObjects: @"Battery Service",@"Jump Start",@"Battery Test",@"Battery Sold",nil] forKey:@"Battery"];
    [values setValue: [NSArray arrayWithObjects: @"Free Fuel",@"Carburetor",nil] forKey:@"Fuel"];
    
	// Do any additional setup after loading the view.
    self.uiPickerFieldProblem.delegate = self;
    self.uiTextFieldProblem.delegate = self;
    self.uiTextFieldComments.delegate= self;
    self.uiPickerFieldProblem.hidden = NO;

    
    //[[NSMutableArray alloc] init];
//    [arrayGroupNames addObject:@"Battery"];
//    [arrayGroupNames addObject:@"Electrical"];
//    [arrayGroupNames addObject:@"Fuel"];
//    [arrayGroupNames addObject:@"Other"];
    
    [self.uiPickerFieldProblem selectRow:0 inComponent:0 animated:NO];
    //mlabel.text= [arrayNo objectAtIndex:[self.uiPickerFieldProblem selectedRowInComponent:0]];
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect pickerFrame = self.uiPickerFieldProblem.frame;
    //TODO: Align bottom
    self.uiPickerFieldProblem.frame = CGRectMake(0, bounds.size.height - pickerFrame.size.height, pickerFrame.size.width, pickerFrame.size.height);
    //self.uiPickerFieldProblem.frame.origin set
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:(BOOL)animated];
//    
//    //self.uiPickerFieldProblem.frame.origin.y+=50;
//    self.uiPickerFieldProblem.center = self.view.center;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Delegate function
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == self.uiTextFieldProblem)
    {
            // Close the keypad if it is showing
        //[self.superclass endEditing:YES];
       [self.view endEditing:YES];
        
        self.uiPickerFieldProblem.hidden = NO;
        
        // Return NO so that there won't be a cursor in the box
        return  NO;
    }
    else
    {
        self.uiPickerFieldProblem.hidden = YES;
    }
    return YES;
}
- (IBAction)SendRecovery:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sent"
                                                      message:@"Your request has been sent."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}
//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//    self.uiPickerFieldProblem.hidden = YES;
//}
//- (IBAction)uiProblemEndEdit:(id)sender {
//    self.uiPickerFieldProblem.hidden = YES;
//}

- (void)viewDidUnload {
    [self setUiTextFieldProblem:nil];
    [self setUiTextFieldComments:nil];
    [self setUiPickerFieldProblem:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 2;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    self.uiTextFieldProblem.text = @"Danie";
    if(component==0)
        [self.uiPickerFieldProblem reloadComponent:1];
    
    NSInteger *selectedGroup = [self.uiPickerFieldProblem selectedRowInComponent:0];
    NSArray *keys = [values allKeys];
    NSString *key = [keys objectAtIndex:selectedGroup];
    NSArray *childArray = [values objectForKey:key];
    self.uiTextFieldProblem.text = [childArray objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if(component == 0)
        return [[values allKeys] count];
    
    NSInteger *selectedGroup = [self.uiPickerFieldProblem selectedRowInComponent:0];
    NSArray *keys = [values allKeys];
    NSString *key = [keys objectAtIndex:selectedGroup];
    NSArray *childArray = [values objectForKey:key];
    
    return [childArray count];
    //else if ([self.uiPickerFieldProblem.selectedRowInComponent:0] == 1) // how would I tell it to change component 1?
     //   return 1;
    //return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    NSArray *keys = [values allKeys];
    if(component == 0)
    {   
        return [keys objectAtIndex:row];
    }

    NSInteger *selectedGroup = [self.uiPickerFieldProblem selectedRowInComponent:0];
    NSString *key = [keys objectAtIndex:selectedGroup];
    NSArray *childArray = [values objectForKey:key];
    return [childArray objectAtIndex:row];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    switch (component){
        case 0:
            return 100.0f;
        case 1:
            return bounds.size.width - 100.f;
    }
    return 0;
}
@end
