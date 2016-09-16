//
//  UserListViewController.m
//  BilliardBreath
//
//  Created by barry on 11/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "UserListViewController.h"
#import "User.h"
#import "Game.h"
#import "HeaderView.h"
#import "AllGamesForDayTableVC.h"
#import "NotesTableViewController.h"
@interface UserListViewController()<UIActionSheetDelegate,HeaderViewProtocl>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIBarButtonItem *activityIndicator;

@property (nonatomic) NSMutableArray *userList;
@property(nonatomic,assign)User  *deleteUser;
@property(nonatomic,assign)User  *notesUser;
@property(nonatomic,strong)NotesTableViewController *notesViewController;

@end
@implementation UserListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(NSArray*)sortedDateArrayForUser:(User*)user
{

    NSArray *alldates=[user.game allObjects];

    
   NSArray *sortedArray = [alldates sortedArrayUsingComparator:
                   ^(id obj1, id obj2)
                   {
                       return [(NSDate*) [obj1 valueForKey:@"gameDate" ] compare: (NSDate*)[obj2 valueForKey:@"gameDate"]];
                   }
                   ];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    NSMutableArray  *datesstrings=[NSMutableArray new];

    for (int i=0; i<[sortedArray count]; i++) {
        NSDate  *date=[[sortedArray objectAtIndex:i]valueForKey:@"gameDate"];
        [datesstrings addObject:[formatter stringFromDate:date]];

    }
     return datesstrings;

}
-(int)uniquedatesForUser:(User*)user
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];

    NSMutableArray  *datesstrings=[NSMutableArray new];
    NSArray *alldates=[user.game allObjects];
    for (int i=0; i<[user.game count]; i++) {
        NSDate  *date=[[alldates objectAtIndex:i]valueForKey:@"gameDate"];
        //NSString  *datestring=[formatter]
       // NSLog(@"BEFORE DATE STRING");
        
        @try {
        
        [datesstrings addObject:[formatter stringFromDate:date]];
       // NSLog(@"AFTER DATE STRING");
        //ADDED
        }@catch (NSException *exception){
            NSLog(@"Date string not added %@",exception );

        }@finally{
        
        }
    }
    NSArray *cleanedArray = [[NSSet setWithArray:datesstrings] allObjects];
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:cleanedArray];
    [mutable sortUsingSelector:@selector(compare:)];
    
   // sortedDateKeysNoTime=[NSArray arrayWithArray:mutable];
    
    int myCount = (int)[cleanedArray count];
    
    // NSLog(@"number of unique dates per user %d", myCount);
    
    return myCount;
    //return 0;
}

-(void)getUniqueDates{

}

- (void)viewDidLoad
{
    self.userList=[NSMutableArray new];
    [self managedObjectContext];
    [super viewDidLoad];
    
    [self getListOfUsers];

    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(  UISwipeGestureRecognizerDirectionLeft)];
  // [[self view] addGestureRecognizer:recognizer];
    
   // UIImage *backButtonImage = [UIImage imageNamed:@"back-button"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    
   // [backButton setImage:backButtonImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 50, 40);
    
    [backButton addTarget:self
                   action:@selector(goBack)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

-(void)goBack
{
    [self.delegate userListDismissRequest:self];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getListOfUsers
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        self.userList=[NSMutableArray arrayWithArray:items];
        NSLog(@"USERLIST - %@", self.userList);
        
    }
    
    [self.tableView reloadData];
    NSLog(@"reloadData!!! ");

}
#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    User  *user=[self.userList objectAtIndex:section];
    
    NSString  *title=[user valueForKey:@"userName"];
    
    return title;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    int sections=[self.userList count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
	
   /** if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }**/
    
    User *user=[self.userList objectAtIndex:section];
    numberOfRows=[user.game count];
    return  [self uniquedatesForUser:user];
   // return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    

    
        User  *user=[self.userList objectAtIndex:indexPath.section];
    
    
    NSArray  *dates=[self sortedDateArrayForUser:user];
   // dates=[[dates reverseObjectEnumerator]allObjects];
   // NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   // [formatter setDateFormat:@"d MMM y "];

    NSString  *date=[dates objectAtIndex:indexPath.row];
  //  NSLog(@"date == %@",date);
    cell.textLabel.text=[dates objectAtIndex:indexPath.row];

    

   
  //  NSDate  gamedate=game obj
    
    return cell;
}
-(NSArray*)gamesMatchingDate:(NSString*)date user:(User*)user
{

    //ALL GAMES EVER FOUND HERE AND MATCHED TO DATE AND USER
  ///  NSLog(@"SEARCHING FOR GAMES MATCHING DATE: %@", date);
    
    NSArray *array=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];

    NSPredicate *shortNamePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        Game *game=(Game*)evaluatedObject;
        NSDate *gamedate=[game gameDate] ;
        NSString  *datestring=[formatter stringFromDate:gamedate];
        return [datestring isEqualToString:date];
        return YES;
       // return [(Game*)[evaluatedObject gameDate] ;
    }];
    
    NSArray *unfiltered=[user.game allObjects];
    
   // NSLog(@"GAMES MATCHING THIS DATE %@", unfiltered);
    
    NSArray *filtered=[unfiltered filteredArrayUsingPredicate:shortNamePredicate];
    NSMutableArray  *mut=[NSMutableArray arrayWithArray:filtered];
    
    [mut sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"gameDate" ascending:YES],nil]];
    array=mut;
    
    
    //ADDED - CHANGED ARRAY TO FILTERED
    
    return unfiltered;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User  *user=[self.userList objectAtIndex:indexPath.section];
    NSArray  *dates=[self sortedDateArrayForUser:user];
    //dates=[[dates reverseObjectEnumerator]allObjects];
    
   // NSDate  *date=[sortedDateKeysNoTime objectAtIndex:indexPath.row];
    AllGamesForDayTableVC  *detailViewController=[[AllGamesForDayTableVC alloc]initWithNibName:@"AllGamesForDayTableVC" bundle:nil];
    NSArray  *array=[self gamesMatchingDate:[dates objectAtIndex:indexPath.row] user:user];
    
    NSLog(@"MATCHING DATES %@",dates );
     NSLog(@"MATCHING DATES %ld",(long)indexPath.row );
    NSLog(@"IMPORTANT ARRAY %@",array );
    
    NSMutableArray  *durationOnly=[NSMutableArray new];
    
    for (Game *agame in array) {
            [durationOnly addObject:agame];
    }
    
    //NSLog(@"sHOWING STATS2 pre %@ ", array);
    //NSLog(@"sHOWING STATS2 %@ ", durationOnly);
    
    [detailViewController setUSerData:durationOnly];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    
}
// called after fetched results controller received a content change notification
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
}

#pragma mark - Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    if (self.sharedPSC != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];

    
    return _managedObjectContext;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   // CGFloat width = CGRectGetWidth(tableView.bounds);
  //  CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    HeaderView  *header=[[HeaderView alloc]initWithFrame:CGRectMake(0, 0, 550, 30)];
    
    header.section = section;
    header.user=[self.userList objectAtIndex:section];
    header.delegate=self;
    
    [header build];
    
    return header;
                         
                         
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
-(void)deleteMember:(HeaderView *)header
{
    self.deleteUser=[self.userList objectAtIndex:header.section];

    NSString *message=[NSString stringWithFormat:@"Delete User ' %@ '", self.deleteUser.userName];
    UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    
    [[GCDQueue mainQueue]queueBlock:^{
        [alert show];
    }];
    
    
    
}
-(void)viewNotes:(HeaderView *)header
{
    
    self.notesUser=[self.userList objectAtIndex:header.section];
    
    if (self.notesViewController) {
        self.notesViewController=nil;
    }
    
    self.notesViewController=[[NotesTableViewController alloc]initWithUser:self.notesUser];
    [self.navigationController pushViewController:self.notesViewController animated:YES];
}

-(void)viewHistoricalData:(HeaderView*)header
{
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Code for OK button
        [self.managedObjectContext deleteObject:self.deleteUser];
        
        [self.managedObjectContext save:nil];

    }
    if (buttonIndex == 1)
    {
        //Code for download button
    }
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    [self getListOfUsers];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    
    //if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
   // }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSLog(@"canEditRowAtIndexPath");
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
   /** if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.userList removeObjectAtIndex:indexPath.section];
        
        [tableView beginUpdates];
        
        // Either delete some rows within a section (leaving at least one) or the entire section.
        if ([user.game count] > 0)
        {
            // Section is not yet empty, so delete only the current row.
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            // Section is now completely empty, so delete the entire section.
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                     withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [tableView endUpdates];
    }**/
    User *user=[self.userList objectAtIndex:indexPath.section];

    [self.managedObjectContext deleteObject:user];
    
    [self.managedObjectContext save:nil];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"editingStyleForRowAtIndexPath");
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndEditingRowAtIndexPath");
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
