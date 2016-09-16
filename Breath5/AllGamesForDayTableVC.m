//
//  AllGamesForDayTableVC.m
//  BilliardBreath
//
//  Created by barry on 27/02/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "AllGamesForDayTableVC.h"
#import "Game.h"

NSMutableArray * validTableEntries;
int noOfEntries;

@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
}

@end

@implementation AllGamesForDayTableVC


-(void)setUSerData:(NSArray*)games
{
   // NSLog(@"RESETTING TABLE INFO ARRAY ");
    
    data=games;
    
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    validTableEntries = [[NSMutableArray alloc] init];
    
  //  NSLog(@"data count %lu", (unsigned long)[data count]);
    
    for (int i = 0; i < [data count]-1; i++){
        NSArray* thisEntry = [data objectAtIndex:i];
        Game* dICT = [data objectAtIndex:i];
        NSString *thisGameDuration = [dICT valueForKey:@"durationString"];
       /// NSLog(@"thisGameDuration %@", thisGameDuration);
        
        if (!(thisGameDuration == (id)[NSNull null] || thisGameDuration  == NULL || [thisGameDuration isEqual: @"(null)"])){
            
         ///   NSLog(@"ADDING AS NOT NIL");
            [validTableEntries addObject:thisEntry];
        }
    }
    
    
    noOfEntries = (int)[validTableEntries count];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections

   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noOfEntries;
}
    
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Game  *game=[validTableEntries objectAtIndex:indexPath.row];
    //Game  *game=[data objectAtIndex:indexPath.row];
    
    
   // NSLog(@"TABLE VIEW Index no :%ld", (long)indexPath.item);
    
    NSDate  *date=game.gameDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM y H:m:s"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
   // int gameType=[game.gameType intValue];
    
    //game.gameTestType;
    
    NSString  *testTypeString=@"";
    
    switch ([game.gameTestType intValue]) {
            
        case gameTestTypeFlatExhale:
            testTypeString=@"Endurance Exhale";
            break;
        case gameTestTypeFlatInhale:
            testTypeString=@"Endurance Inhale";

            break;
        case gameTestTypeHillExhale:
            testTypeString=@"Endurance & Strength Exhale";

            break;
        case gameTestTypeHillInhale:
            testTypeString=@"Endurance & Strength Inhale";

            break;
            
        case gameTestTypeMountainExhale:
            testTypeString=@"Strength Exhale";

            break;
            
        case gameTestTypeMountainInhale:
            testTypeString=@"Strength Inhale";

            break;
            
        default:
            break;
    }
    
//NSLog(@"testTypeString :%@", testTypeString);

   // if (game.durationString != NULL){
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
   // NSString *formattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[game.duration floatValue]]];
    // NSString  *duration=[NSString stringWithFormat:@"%0.2f",[game.duration floatValue]];
     NSString  *strength=[NSString stringWithFormat:@"%i",[game.power intValue]];
     cell.textLabel.text=[NSString stringWithFormat:@"%@  %@ ",testTypeString,attemptDateString];
     cell.detailTextLabel.text=[NSString stringWithFormat:@"Duration :%@ Power %@ Distance:%@",game.durationString,strength,game.gameDistance];
    // Configure the cell...
    
//NSLog(@"Duration :%@ Power %@ Distance:%@",game.durationString,strength,game.gameDistance);
   // }else{
   //     NSLog(@"Duration is null for this cell, not adding");
//}
        
    return cell;
}

@end
