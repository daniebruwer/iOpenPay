//
//  ProductListController.m
//  iOpenPay
//
//  Created by Danie Bruwer on 2012/03/24.
//  Copyright (c) 2012 Wyobi. All rights reserved.
//

#import "ProductListController.h"

@interface ProductListController () 

@property (strong) NSMutableArray * cells;
//- (NSMutableArray *) cells;

@end

@implementation ProductListController

@synthesize cells = _cells;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue -  ProductListController");
}
- (IBAction)editClicked:(id)sender 
{
    NSLog(@"ProductListController - Now Editing");

    [self.tableView setEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"productcell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText: @"Danie"]; 
    [cell.detailTextLabel setText:@"R299.00"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    /*
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        //NSLog(@"Awesome its a checkbox");
        //[((UIButton *)cell.accessoryView) ];
        //[((UIButton *)cell.accessoryView) set: NO ];
        [self.tableView deselectRowAtIndexPath:indexPath animated                                           : NO ];
        [self.tableView setNeedsDisplay];
        
    }
     */
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Here we deselect ourselve so we can be selected again
    [self.tableView deselectRowAtIndexPath:indexPath animated : NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) 
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (cell.accessoryType == UITableViewCellAccessoryNone) 
    {
        cell.accessoryType =   UITableViewCellAccessoryCheckmark;  
    }
    
    [self calculateTotal];
    
    
    [self.tableView setNeedsDisplay];
    
    
    //NSLog( [@" accessoryType : @" stringByAppendingFormat: cell.accessoryType.description ]);
}
//- (NSMutableArray) 
- (NSMutableArray *) cells
{
    /* */
    if(_cells == Nil)
    {
        _cells = [[NSMutableArray alloc] init];
        /* */
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
            {
                UITableViewCell *cell  = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if(cell != Nil)
                    [_cells addObject: cell];
            }
        }
    }
    return _cells;
}


- (void) calculateTotal
{
    NSInteger count = 0;
    /* */
    for (UITableViewCell *cell in self.cells)
    {
       if(cell != Nil && cell.accessoryType == UITableViewCellAccessoryCheckmark)
           count++;
    }
    
    NSString *inStr = [NSString stringWithFormat:@"Total : %d", count];

    [self.parentViewController setTitle: inStr];  
}

@end
