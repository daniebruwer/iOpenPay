//
//  RecoveryController.h
//  iOpenPay
//
//  Created by Danie Bruwer on 2013/05/03.
//  Copyright (c) 2013 Wyobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecoveryController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *uiTextFieldProblem;
@property (weak, nonatomic) IBOutlet UITextField *uiTextFieldComments;
@property (weak, nonatomic) IBOutlet UIPickerView *uiPickerFieldProblem;



@end
