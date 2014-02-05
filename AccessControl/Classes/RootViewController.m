/*

 
 http://quickblox.com/developers/How_to_create_APNS_certificates
 http://arashnorouzi.wordpress.com/2011/03/31/sending-apple-push-notifications-in-asp-net-part-1/
 http://docs.urbanairship.com/build/ios.html#uploading-the-push-certificate-to-urban-airship
 
 */

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "RootViewController.h"
#import "TDBadgedCell.h"

@interface RootViewController () <EKEventEditViewDelegate>
// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;

// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;

// Array of all events happening within the next 24 hours
@property (nonatomic, strong) NSMutableArray *eventsList;

@property (nonatomic, strong) NSMutableArray *quickBookList;

// Used to add events to Calendar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property(nonatomic,retain) NSDateFormatter *dateOnlyFormatter;

@property(nonatomic,retain) NSDateFormatter *timeOnlyFormatter;

@property (nonatomic,readwrite) NSString* memberNumber;
@end
@implementation RootViewController

@synthesize dateOnlyFormatter =_dateOnlyFormatter;
@synthesize timeOnlyFormatter = _timeOnlyFormatter;
@synthesize memberNumber = _memberNumber;

-(NSString*)memberNumber
{
    if(!_memberNumber)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _memberNumber = [defaults objectForKey:@"username"];
    }
    return _memberNumber;
}

-(NSDateFormatter *)dateOnlyFormatter
{
    if(!_dateOnlyFormatter)
    {
        _dateOnlyFormatter = [[NSDateFormatter alloc] init];
        _dateOnlyFormatter.dateFormat = @"yyyy/MM/dd";
    }
    return _dateOnlyFormatter;
}

-(NSDateFormatter *)timeOnlyFormatter
{
    if(!_timeOnlyFormatter)
    {
        _timeOnlyFormatter = [[NSDateFormatter alloc] init];
        _timeOnlyFormatter.dateFormat = @"HH:mm";
    }
    return _timeOnlyFormatter;
}

- (NSDate *)deserializeJsonDateString: (NSString *)jsonDateString
{
    //NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; //get number of seconds to add or subtract according to the client default time zone
    
    NSInteger startPosition = [jsonDateString rangeOfString:@"("].location + 1; //start of the date value
    
    NSTimeInterval unixTime = [[jsonDateString substringWithRange:NSMakeRange(startPosition, 13)] doubleValue] / 1000; //WCF will send 13 digit-long value for the time interval since 1970 (millisecond precision) whereas iOS works with 10 digit-long values (second precision), hence the divide by 1000
    
    return  [NSDate dateWithTimeIntervalSince1970:unixTime]; // dateByAddingTimeInterval:offset];
}

#pragma mark -
#pragma mark View lifecycle

-(void)loadView {
    [super loadView];
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activity];
    activity.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 50);
    [activity startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Initialize the event store
	self.eventStore = [[EKEventStore alloc] init];
    // Initialize the events list
	self.eventsList = [[NSMutableArray alloc] initWithCapacity:0];
    // The Add button is initially disabled
    self.addButton.enabled = NO;
    
    self.quickBookList = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControl addTarget:self action:@selector(loadQuickBookings)
      forControlEvents:UIControlEventValueChanged];
    
    
    NSString *actionSheetTitle = @"Pre-Book"; //Action Sheet Title
    NSString *other1 = @"Quick Book";
    NSString *other2 = @"Create Event";
    NSString *cancelTitle = @"Cancel";
    addActionSheet = [[UIActionSheet alloc]
                      initWithTitle:actionSheetTitle
                      delegate:self
                      cancelButtonTitle:cancelTitle
                      destructiveButtonTitle:nil
                      otherButtonTitles:other1, other2, nil];
    
    //addActionSheet.cancelButtonIndex = [addActionSheet addButtonWithTitle: @"Cancel"];
    
    notifyByActionSheet = [[UIActionSheet alloc]
                           initWithTitle:@"Notify Via"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Message", @"Email", @"WhatsApp", nil]; //todo check if whats app installed
    
    
    quickBookRowSelectActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"Pre Approval"
                                     delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                     otherButtonTitles:@"Resend", @"Dial Number", nil];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@", NSStringFromCGPoint(activity.center));
   
    
    // Check whether we are authorized to access Calendar
    [self checkEventStoreAccessForCalendar];
    [self loadQuickBookings];
    //[self.refreshControl beginRefreshing];
    [self.tableView reloadData];
    [activity stopAnimating];
}


// This method is called when the user selects an event in the table view. It configures the destination
// event view controller with this event.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEventViewController"])
    {
        // Configure the destination event view controller
        EKEventViewController* eventViewController = (EKEventViewController *)[segue destinationViewController];
        // Fetch the index path associated with the selected event
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        // Set the view controller to display the selected event
        eventViewController.event = [self.eventsList objectAtIndex:indexPath.row];
        
        // Allow event editing
        eventViewController.allowsEditing = YES;
    }
}


#pragma mark -
#pragma mark Table View

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCaseID = nil;
    abid = nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        NSDictionary * obj = [self.quickBookList objectAtIndex:indexPath.row];
        selectedPersonName = [obj objectForKey:@"Comments"];
        selectedPhoneNumber = [obj objectForKey:@"Cellphone"];
        selectedCaseID = [obj objectForKey:@"CaseID"];
        abid = [[obj objectForKey:@"abid"] integerValue];
        [quickBookRowSelectActionSheet showInView:[[UIApplication sharedApplication].delegate window]];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Events";
    else
        return  @"Quick Bookings";
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return self.eventsList.count;
    else
        return self.quickBookList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    
    if(indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
        // Get the event at the row selected and display its title
        cell.textLabel.text = [[self.eventsList objectAtIndex:indexPath.row] title];
        NSDate* date =[[self.eventsList objectAtIndex:indexPath.row] startDate];
        cell.detailTextLabel.text = [self.dateOnlyFormatter stringFromDate:date];
        return cell;
    }
    else
    {
        TDBadgedCell *cell = (TDBadgedCell*)[tableView dequeueReusableCellWithIdentifier:@"quickBook" forIndexPath:indexPath];
        NSDictionary * obj = [self.quickBookList objectAtIndex:indexPath.row];
        cell.textLabel.text = [obj objectForKey:@"Comments"];
        id creationDateField = [obj objectForKey:@"CreationDate"];
        NSDate* creationDate = [self deserializeJsonDateString:creationDateField];
        cell.detailTextLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@ %@ %@ %@ ", [NSString fontAwesomeIconStringForEnum:FAClockO], [self.timeOnlyFormatter stringFromDate:creationDate], [NSString fontAwesomeIconStringForEnum:FAPhone] , [obj objectForKey:@"Cellphone"]];
        NSString *myString = [obj objectForKey:@"CaseID"];
        NSArray *myWords = [myString componentsSeparatedByCharactersInSet:
                            [NSCharacterSet characterSetWithCharactersInString:@"-"]
                            ];
        cell.badgeString = [myWords lastObject];
        return cell;
    }
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 1)
    {
        [self deleteRowAIndexPath:indexPath];
    }
}
-(void) deleteRowAIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * obj = [self.quickBookList objectAtIndex:indexPath.row];
    NSString* caseID = [obj objectForKey:@"CaseID"];
    [self.quickBookList removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self performSelectorInBackground:@selector(deleteCase:) withObject:caseID];
}
-(void) deleteCase:(NSString*) caseID
{
    NSString* urlAsString =  [NSString stringWithFormat: @"http://reports.accesscontrol.wyobi.net/Cases/Delete/%@",
                             caseID];
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
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData
                                                       options:0 error:&jsonParsingError];
    id returnCode = [data objectForKey:@"ReturnCode"];
    if([returnCode integerValue] != 200)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[data objectForKey:@"Message"]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];

    }
}

#pragma mark -
#pragma mark Access Calendar

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             RootViewController * __weak weakSelf = self;
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [weakSelf accessGrantedForCalendar];
             });
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
    // Enable the Add button
    self.addButton.enabled = YES;
    // Fetch all events happening in the next 24 hours and put them into eventsList
    self.eventsList = [self fetchEvents];
    // Update the UI with the above events
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Fetch events
- (void)loadQuickBookings
{
    self.quickBookList = [self fetchQuickBookings];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSMutableArray*)fetchQuickBookings
{
    NSString* urlAsString =  [NSString stringWithFormat: @"http://reports.accesscontrol.wyobi.net/Cases/ListJSON?membershipNumber=%@&symptom=pre-book",
                               self.memberNumber];
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
    
    NSError *jsonParsingError = nil;
    NSArray *arrData = [NSJSONSerialization JSONObjectWithData:urlData
                                                       options:0 error:&jsonParsingError];
    
    return [arrData mutableCopy];
}
// Fetch all events happening in the next 24 hours
- (NSMutableArray *)fetchEvents
{
    NSDate *startDate = [NSDate date];
    
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 100;
	
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
	// We will only search the default calendar for our events
	NSArray *calendarArray = [NSArray arrayWithObject:self.defaultCalendar];
    
    // Create the predicate
	NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:calendarArray];
	
	// Fetch all events that match the predicate
	NSMutableArray *events = [NSMutableArray arrayWithArray:[self.eventStore eventsMatchingPredicate:predicate]];
    
	return events;
}


#pragma mark -
#pragma mark Add a new event

// Display an event edit view controller when the user taps the "+" button.
// A new event is added to Calendar when the user taps the "Done" button in the above view controller.
- (IBAction)addEvent:(id)sender
{
    selectedCaseID = nil;
    abid = nil;
    [addActionSheet showInView:self.tabBarController.view];
}
//-(void) dismissActionSheet:(id)sender {
//    UIActionSheet *actionSheet =  (UIActionSheet *)[(UIView *)sender superview];
//    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
//}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [actionSheet cancelButtonIndex])
    {
        //Do nothing
        if(actionSheet == quickBookRowSelectActionSheet)
        {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
    }
    else
    {
        if(actionSheet == addActionSheet)
        {
            
            if(buttonIndex == 0)
            {
                ABPeoplePickerNavigationController *picker =
                [[ABPeoplePickerNavigationController alloc] init];
                picker.peoplePickerDelegate = self;
                
                [self presentViewController:picker animated:YES completion:^{
                    NSLog(@"ABPeoplePickerNavigationController");
                }];
            }
            else if(buttonIndex == 1)
            {
                [self addComplexEvent];
            }
            else if(buttonIndex == 2)
            {
                
            }
        }
        else if(actionSheet == notifyByActionSheet)
        {
            selectedPhoneNumber = [self parsePhoneNumber:selectedPhoneNumber];
            NSString* msg = selectedCaseID ? [self getPINMessage: selectedCaseID] : [self sendCase:selectedPhoneNumber];
            if(buttonIndex == 0)
            {
                [self sendAsMessage:selectedPhoneNumber andMessage:msg];
            }
            else if(buttonIndex == 1)
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Not Implemented"
                                                                  message:@"Coming soon"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
            }
            else if(buttonIndex == 2)
            {
                [self sendAsWhatsApp:selectedPhoneNumber andMessage:msg];
            }
        }
        else if(actionSheet == quickBookRowSelectActionSheet)
        {
            if(buttonIndex == [actionSheet destructiveButtonIndex])
            {
                [self deleteRowAIndexPath:[self.tableView indexPathForSelectedRow]];
            }
            else if(buttonIndex == 1)
            {//resend
                 [notifyByActionSheet showInView:[[UIApplication sharedApplication].delegate window]];
            }
              else if(buttonIndex == 2)
              {
                NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", selectedPhoneNumber];
                NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
                [[UIApplication sharedApplication] openURL:phoneURL];
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            }
        }
        else
        {//Number Select
            selectedPhoneNumber =[actionSheet buttonTitleAtIndex:buttonIndex];
            [self sendMessage];
        }
    }
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
 
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Not Implemented"
                                                      message:@"Coming soon"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
     return NO;
}
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    abid = ABRecordGetRecordID(person);
    
    CFTypeRef firstName = ABRecordCopyValue(person,kABPersonFirstNameProperty);
    CFTypeRef lastName = ABRecordCopyValue(person,kABPersonLastNameProperty);
    
    NSString *firstNameString = (__bridge NSString*)firstName; // fetch contact first name from address book
    
    NSString *lastNameString = (__bridge NSString*)lastName; // fetch contact last name from address book
    
    selectedPersonName = [NSString stringWithFormat:@"%@ %@", firstNameString, lastNameString];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    int numberOfNumbers = ABMultiValueGetCount(phoneNumbers);
    if (numberOfNumbers > 0)
    {
        NSString* phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
        if(numberOfNumbers > 1)
        {
            
            NSString *actionSheetTitle = @"Multipe Numbers - Select"; //Action Sheet Title
            NSString *other1 =  (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            NSString *other2 =  (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 1);
            NSString *cancelTitle = @"Cancel";
            UIActionSheet* numberSheet = [[UIActionSheet alloc]
                                          initWithTitle:actionSheetTitle
                                          delegate:self
                                          cancelButtonTitle:cancelTitle
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:other1, other2, nil];
            
            UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
            if ([numberSheet.subviews containsObject:self.view]) {
                [numberSheet showInView:self.view];
            } else {
                [numberSheet showInView:window];
            }
        }
        else
        {
            selectedPhoneNumber = phoneNumber;
            [self sendMessage];
        }
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Phone Number!"
                                                          message:@"The contact you selected is not valid as they don't have phone number."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    
    CFRelease(phoneNumbers);
    CFRelease(firstName);
    CFRelease(lastName);
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"peoplePicker dismissed");
    }];
    return NO;
}
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) addComplexEvent
{
    // Create an instance of EKEventEditViewController
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    EKEvent *event  = [EKEvent eventWithEventStore:self.eventStore];
    event.location = @"138 Olympus Country Estate";
    event.notes= @"Temporary pin for Entrance : 58175";
    
	// Set addController's event store to the current event store
	addController.eventStore = self.eventStore;
    addController.event=event;
    addController.editViewDelegate = self;
    //addController.title = @"Danie's Party";
    
    [self presentViewController:addController animated:YES completion:nil];
    
}
-(NSString*) parsePhoneNumber:(NSString*) phoneNumber
{
    NSCharacterSet *charactersToRemove =
    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
    
    NSString *trimmedReplacement =
    [[ phoneNumber componentsSeparatedByCharactersInSet:charactersToRemove ]
     componentsJoinedByString:@"" ];
    return  trimmedReplacement;
}


-(void) sendMessage
{
    //[notifyByActionSheet showInView: self.view];
    [notifyByActionSheet showInView:[[UIApplication sharedApplication].delegate window]];
}
-(void) sendAsMessage:(NSString*) phoneNumber andMessage:(NSString*) msg
{
    MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
    viewController.recipients = [[NSArray alloc] initWithObjects:phoneNumber, nil];
    viewController.body = msg;
    viewController.messageComposeDelegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
-(void) sendAsWhatsApp:(NSString*) phoneNumber andMessage:(NSString*) msg
{
    NSString* url = [NSString stringWithFormat:@"whatsapp://send?abid=%d&text=%@", abid, [msg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *whatsappURL = [NSURL URLWithString:url];
    if([self canSendWithWhatsApp :whatsappURL])
    {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    else
    {
        [self sendAsMessage:phoneNumber andMessage:msg];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
-(BOOL) canSendWithWhatsApp:(NSURL *) whatsappURL
{
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])
    {
        return YES;
    }
    return NO;
}

- (NSString*)sendCase:(NSString*) phoneNumber
{
    [activity startAnimating];
    NSString* urlAsString =  [NSString stringWithFormat: @"http://reports.accesscontrol.wyobi.net/Cases/CreateJSON?membershipNumber=%@&cellphone=%@&symptom=pre-book&comments=%@&abid=%d&random=%@"
                              , self.memberNumber
                              , phoneNumber
                              , [selectedPersonName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                              , abid
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
   [activity stopAnimating];
    return [self getPINMessage:caseID];
}
-(NSString*) getPINMessage:(NSString*) caseID
{
    NSString* qrcodeUrl = @"http://reports.accesscontrol.wyobi.net/AZTEC/Index/";
    NSArray *strings = [caseID componentsSeparatedByString:@"-"];
    return [NSString stringWithFormat:@"Temporary pin to visit 138 Olympus Country Estate valid for %@ : %@.\nPresent link to security \n %@%@",
       [strings objectAtIndex:0],
      [strings objectAtIndex:1],
     qrcodeUrl,
     [strings objectAtIndex:1]
     ];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSString* resultString = @"";
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = @"Cancelled";
            break;
        case MessageComposeResultSent:
            resultString = @"Sucessful";
            break;
        case MessageComposeResultFailed:
            resultString = @"Failed";
            break;
        default:
            break;
    }
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Pre-Book"
                                                      message:resultString
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}


#pragma  mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    RootViewController * __weak weakSelf = self;
	// Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (action != EKEventEditViewActionCanceled)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 // Re-fetch all events happening in the next 24 hours
                 weakSelf.eventsList = [self fetchEvents];
                 // Update the UI with the above events
                 [weakSelf.tableView reloadData];
             });
         }
     }];
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
	return self.defaultCalendar;
}



@end