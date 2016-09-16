//
//  NotesTableViewController.m
//  Breath5
//
//  Created by barry on 26/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "NotesTableViewController.h"
#import "Note.h"
#import "AddNewNoteOperation.h"
#import "CustomIOSAlertView.h"
#import "Globals.h"
#import "UpdateNoteOperation.h"
@interface NotesTableViewController ()<AddNewNoteOperationProtocol,UpdateNoteOperationProtocol>
@property(nonatomic,strong)User *user;
@property(nonatomic,strong)NSArray *notes;
@property(nonatomic,strong)UIAlertController  *addTextAlertController;
@property(nonatomic,strong)NSOperationQueue  *queue;
@property(nonatomic,strong)CustomIOSAlertView  *addNoteAlertView;
@end

@implementation NotesTableViewController
-(id)initWithUser:(User*)user
{
    if (self==[super init]) {
        _user=user;
        [self setup];
        [self refreshData];
        
    }
    
    return self;
}
-(void)addNewNoteSuccess:(AddNewNoteOperation *)noteOperation
{
    NSLog(@"Successfully added new note");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshData];

    });

}
-(void)noteUpdated:(UpdateNoteOperation *)operation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshData];
        
    });

}
-(void)refreshData
{
    self.notes=[self sortedDateArrayForUser:_user];

    [self.tableView reloadData];
}
-(NSArray*)sortedDateArrayForUser:(User*)user
{
    
    NSArray *alldates=[user.note allObjects];
    
    
    NSArray *sortedArray = [alldates sortedArrayUsingComparator:
                            ^(id obj1, id obj2)
                            {
                                return [(NSDate*) [obj1 valueForKey:@"noteDate" ] compare: (NSDate*)[obj2 valueForKey:@"noteDate"]];
                            }
                            ];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    NSMutableArray  *datesstrings=[NSMutableArray new];
    
    for (int i=0; i<[sortedArray count]; i++) {
        NSDate  *date=[[sortedArray objectAtIndex:i]valueForKey:@"noteDate"];
        [datesstrings addObject:[formatter stringFromDate:date]];
        
    }
   // return datesstrings;
    
     NSLog(@"Sorted array of note %@", sortedArray);
    
    return sortedArray;
    
}

-(void)setup
{
     NSLog(@"Setting up notes etc");
    self.queue=[[NSOperationQueue alloc]init];
   self.notes=[self sortedDateArrayForUser:_user];
    //dates=[[dates reverseObjectEnumerator]allObjects];
    
    // NSDate  *date=[sortedDateKeysNoTime objectAtIndex:indexPath.row];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Note" style:UIBarButtonItemStylePlain target:self action:@selector(addNote)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        Note  *note=[self.notes objectAtIndex:indexPath.row];
       NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = [[Globals sharedInstance]sharedPSC];
        
        [self.user.managedObjectContext deleteObject:note];
        [self.user.managedObjectContext save:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self refreshData];
        });

    }
}
-(void)addNote
{
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView] ];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
   // [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        UITextView  *tv=(UITextView*)[alertView viewWithTag:99];
        NSString  *str=tv.text;
        if (str.length>1) {
            [self gotTextFromPopup:str];
        }
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

   
}
-(void)gotTextFromPopup:(NSString*)theText
{
    AddNewNoteOperation  *op=[[AddNewNoteOperation alloc]initWithData:self.user thenote:theText sharedPSC:[Globals sharedInstance].sharedPSC];
    op.delegate=self;
    [self.queue addOperation:op];
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note  *note=self.notes[indexPath.row];
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoViewWithText:note.noteString]];
    
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        UITextView  *tv=(UITextView*)[alertView viewWithTag:99];
        NSString  *str=tv.text;
        if (str) {
            UpdateNoteOperation *op=[[UpdateNoteOperation alloc]initWithData:note thenote:str sharedPSC:[Globals sharedInstance].sharedPSC];
            op.delegate=self;
            [self.queue addOperation:op];
        }
        //[self refreshData];
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

}
- (UIView *)createDemoViewWithText:(NSString*)text
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    
    UITextView *imageView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 480, 450)];
    [demoView addSubview:imageView];
    imageView.tag=99;
    imageView.text=text;
    
    return demoView;


}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}
- (UIView *)createDemoView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    
    UITextView *imageView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 480, 450)];
    [demoView addSubview:imageView];
    imageView.tag=99;
    
    return demoView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.notes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Note  *game=[self.notes objectAtIndex:indexPath.row];
    
     NSLog(@"Setting up table view - notes are %@", self.notes);
    
    NSDate  *date=game.noteDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM y H:m:s"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
 
    cell.textLabel.text=[NSString stringWithFormat:@"%@",attemptDateString];
    // Configure the cell...
    
    NSString  *thetext=game.noteString;
    if (thetext.length>20) {
        
        thetext=[thetext substringToIndex:19];
        
        thetext=[thetext stringByAppendingString:@"..."];
    }
    cell.detailTextLabel.text=thetext;
    cell.detailTextLabel.textColor=[UIColor lightGrayColor];
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
