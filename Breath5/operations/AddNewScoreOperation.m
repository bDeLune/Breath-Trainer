//
//  AddNewScoreOperation.m
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "AddNewScoreOperation.h"
#import "Globals.h"
@interface AddNewScoreOperation ()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)User  *user;
@property(nonatomic,strong)Session  *session;
@end
@implementation AddNewScoreOperation
- (id)initWithData:(User *)auser  session:(Session*)asession sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
        
        self.sharedPSC = psc;
        self.user=auser;
        self.session=asession;
    }
    return self;
    
}
- (void)main {
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addTheSession];

    });
}

-(void)addTheSession
{
    NSLog(@"New Score operation");
   // Game  *game=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    Game  *game;

    NSString *direction=[[NSUserDefaults standardUserDefaults]objectForKey:@"direction"];
    int directionInt;
    if ([direction isEqualToString:@"inhale"]) {
        directionInt=1;
    }else if ([direction isEqualToString:@"exhale"])
    {
        directionInt=0;
    }
   // game=[[Globals sharedInstance]gameForUser:self.user breathDirection:directionInt hilltype:[self.user.userHillType intValue]];
    NSManagedObjectID  *objID=[[Globals sharedInstance]gameIDForUser:self.user breathDirection:directionInt hilltype:[self.user.userHillType intValue]];
   // [game setUser:self.user];
    game=(Game*)[self.managedObjectContext objectWithID:objID];
  //  NSLog(@"duration %f",[self.session.sessionDuration floatValue]);
    if ([self.session.sessionDuration floatValue]<=0.0) {
        return;
    }
    [game setDuration:self.session.sessionDuration];
    [game setGameDate:self.session.sessionDate];
    [game setGameType:self.session.sessionType];
    [game setGameAngle:self.session.sessionAngle];
    [game setGameDistance:self.session.sessionDistance];
    [game setGameWind:self.session.sessionWind];
    [game setPower:self.session.sessionStrength];
    [game setGameAbilityType:self.user.userAbilityType];
    [game setGameHillType:self.user.userHillType];
    [game setGameDirection:direction];
    [game setDurationString:self.session.sessionDurationString];
    [game setGamePointString:self.session.cgPointString];

    NSString   *name=[self.user valueForKey:@"userName"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    ///NSUInteger count = [moc countForFetchRequest:fetchRequest error:&err];
    //NSMutableArray *gamesArray = [NSEntityDescription
    //                      insertNewObjectForEntityForName:@"GamesArray"
    //                      inManagedObjectContext:context];

    //User *auser=[items objectAtIndex:0];
    //NSMutableArray *thisArray = [[NSMutableArray alloc] init];
    ///[thisArray addObject: auser.game];
    //[thisArray addObject: game];
    //[auser setValue:thisArray forKey:@"gamesArray"];
    //NSLog(@"AFTER AUSER %@ COUNT %lu", auser.game, (unsigned long)[auser.game count]);
    
    if ([items count]>0) {
        User *auser=[items objectAtIndex:0];
        NSLog(@"GAME: %@", auser.game);
        [[auser mutableSetValueForKey:@"game"]
         addObject:game];
    }
    
    NSLog(@"AFTER AUSER ");
    if ([self.managedObjectContext hasChanges]) {
         NSLog(@"Changes saved");
        if (![self.managedObjectContext save:&error]) {         //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }else{
        NSLog(@"No changes saved");
    }
}

@end
