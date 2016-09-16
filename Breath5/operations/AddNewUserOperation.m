//
//  AddNewUserOperation.m
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "AddNewUserOperation.h"
#import "User.h"
#import "Game.h"
#import "Globals.h"

NSString *kAddNewUserOperationUserExistsError = @"ExistsError";
NSString *kAddNewUserOperationUserError = @"GeneralError";
NSString *kAddNewUserOperationUserAdded = @"UserAdded";

@interface AddNewUserOperation ()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)NSString *username;
@end

@implementation AddNewUserOperation
- (id)initWithData:(NSString *)username sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
      
     self.sharedPSC = psc;
        self.username=username;
        
    }
    return self;

}
- (void)main {
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    [self addTheUser];
}

-(void)addTheUser
{

    User* newTask = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [newTask setUserName:self.username];
    [newTask setUserAbilityType:[NSNumber numberWithInt:0]];
    [newTask setUserHillType:[NSNumber numberWithInt:0]];
    
    bool success = [self makeTests:newTask];
    NSError  *error;
    
    
    NSLog(@"newTask, %@", newTask);

    
    if (success == true){
    
    if ([self.managedObjectContext hasChanges]) {


        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            NSLog(@"!!ABORTING!!!");
            abort();
        }else{
            NSLog(@"!!SUCCESSFULLY SAVED!!!");
        }
    }
    
    }else{
        NSLog(@"REQUESTING REGISTER REDO");
    
       // UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
       //                                              message:@"An error has occured. Please try again."
       ////                                             delegate:nil
       //                                    cancelButtonTitle:@"OK"
       //                                    otherButtonTitles:nil, nil];
        
        
      //  [[GCDQueue mainQueue]queueBlock:^{
      //      [alert show];
      //  }];
    
    }
    
    
}

/*
 @property (nonatomic, retain) NSNumber * gameType;//difficulty
 @property (nonatomic, retain) NSDate * gameDate;
 @property (nonatomic, retain) NSNumber * duration;
 @property (nonatomic, retain) NSNumber * power;
 @property (nonatomic, retain) NSNumber * bestStrength;
 @property (nonatomic, retain) NSNumber * bestDuration;
 @property (nonatomic, retain) NSString * gameDirection;
 @property(nonatomic,retain)NSNumber  *gameAngle;
 @property(nonatomic,retain)NSNumber  *gameWind;
 @property(nonatomic,retain)NSNumber  *gameDistance;
 @property (nonatomic, retain) NSNumber * gameHillType;
 @property (nonatomic, retain) NSNumber * gameAbilityType;
 @property(nonatomic,retain)NSNumber *gameTestType;
 */

-(bool)makeTests:(User*)user
{

   Game  *game1;
    Game  *game2;
    Game  *game3;
    Game  *game4;
    Game  *game5;
    Game  *game6;
    
   /// Game  *game1 = [[Game alloc] init];
   // Game  *game2 = [[Game alloc] init];
   // Game  *game3 = [[Game alloc] init];
   // Game  *game4 = [[Game alloc] init];
   // Game  *game5 = [[Game alloc] init];
   // Game  *game6 = [[Game alloc] init];
    
    NSLog(@"game1 %@", game1);
    NSLog(@"game2 %@", game2);
    NSLog(@"game3 %@", game3);
    NSLog(@"game4 %@", game4);
    NSLog(@"game5 %@", game5);
    NSLog(@"game6 %@", game6);
    

    
    //gameTestTypeFlatExhale

    //NSLog(@"MAKE TESTS");
    
        game1=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
        game1.gameTestType=[NSNumber numberWithInt:gameTestTypeFlatExhale];
        game1.gameHillType=[NSNumber numberWithInt:hillTypeFlat];
        game1.gameAbilityType=[NSNumber numberWithInt:0];

        game1.gameType=[NSNumber numberWithInt:0];
        game1.gameDate=[NSDate date];
        game1.duration=[NSNumber numberWithInt:0];
        game1.power=[NSNumber numberWithInt:0];
        game1.bestStrength=[NSNumber numberWithInt:0];
        game1.bestDuration=[NSNumber numberWithInt:0];
        game1.gameAngle=[NSNumber numberWithInt:0];
        game1.gameWind=[NSNumber numberWithInt:0];
        game1.gameDistance=[NSNumber numberWithInt:0];
       game1.gameDirectionInt=[NSNumber numberWithInt:0];
       game1.gameDirection=@"Exhale";
    
    //gameTestTypeFlatInhale
 
 //    NSLog(@"MAKE TESTS2");
    
    game2=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    game2.gameTestType=[NSNumber numberWithInt:gameTestTypeFlatInhale];
    game2.gameHillType=[NSNumber numberWithInt:hillTypeFlat];
    game2.gameAbilityType=[NSNumber numberWithInt:0];
    
    game2.gameType=[NSNumber numberWithInt:0];
    game2.gameDate=[NSDate date];
    game2.duration=[NSNumber numberWithInt:0];
    game2.power=[NSNumber numberWithInt:0];
    game2.bestStrength=[NSNumber numberWithInt:0];
    game2.bestDuration=[NSNumber numberWithInt:0];
    game2.gameAngle=[NSNumber numberWithInt:0];
    game2.gameWind=[NSNumber numberWithInt:0];
    game2.gameDistance=[NSNumber numberWithInt:0];
    game2.gameDirectionInt=[NSNumber numberWithInt:1];
    game2.gameDirection=@"Inhale";
    
    //gameTestTypeHillExhale
 //NSLog(@"MAKE TESTS3");
    game3=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    game3.gameTestType=[NSNumber numberWithInt:gameTestTypeHillExhale];
    game3.gameHillType=[NSNumber numberWithInt:hillTypeHill];
    game3.gameAbilityType=[NSNumber numberWithInt:0];
    
    game3.gameType=[NSNumber numberWithInt:0];
    game3.gameDate=[NSDate date];
    game3.duration=[NSNumber numberWithInt:0];
    game3.power=[NSNumber numberWithInt:0];
    game3.bestStrength=[NSNumber numberWithInt:0];
    game3.bestDuration=[NSNumber numberWithInt:0];
    game3.gameAngle=[NSNumber numberWithInt:0];
    game3.gameWind=[NSNumber numberWithInt:0];
    game3.gameDistance=[NSNumber numberWithInt:0];
    game3.gameDirectionInt=[NSNumber numberWithInt:0];
    game3.gameDirection=@"Exhale";
    //gameTestTypeHillInhale
    
    
// NSLog(@"MAKE TESTS4");
    
    NSLog(@"self.managedObjectContext %@", self.managedObjectContext);
   // NSArray *entityNames = [[self.managedObjectContext ] valueForKey:@"Game"];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
   NSLog(@"self.managedObjectContext %@", entityDescription);
    
    game4=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    game4.gameTestType=[NSNumber numberWithInt:gameTestTypeHillInhale];
    game4.gameHillType=[NSNumber numberWithInt:hillTypeHill];
    game4.gameAbilityType=[NSNumber numberWithInt:0];
    
    game4.gameType=[NSNumber numberWithInt:0];
    game4.gameDate=[NSDate date];
    game4.duration=[NSNumber numberWithInt:0];
    game4.power=[NSNumber numberWithInt:0];
    game4.bestStrength=[NSNumber numberWithInt:0];
    game4.bestDuration=[NSNumber numberWithInt:0];
    game4.gameAngle=[NSNumber numberWithInt:0];
    game4.gameWind=[NSNumber numberWithInt:0];
    game4.gameDistance=[NSNumber numberWithInt:0];
    game4.gameDirectionInt=[NSNumber numberWithInt:1];
    game4.gameDirection=@"Inhale";
    //gameTestTypeMountainExhale
    
    game5=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    game5.gameTestType=[NSNumber numberWithInt:gameTestTypeMountainExhale];
    game5.gameHillType=[NSNumber numberWithInt:hillTypeMountain];
    game5.gameAbilityType=[NSNumber numberWithInt:0];
    
    game5.gameType=[NSNumber numberWithInt:0];
    game5.gameDate=[NSDate date];
    game5.duration=[NSNumber numberWithInt:0];
    game5.power=[NSNumber numberWithInt:0];
    game5.bestStrength=[NSNumber numberWithInt:0];
    game5.bestDuration=[NSNumber numberWithInt:0];
    game5.gameAngle=[NSNumber numberWithInt:0];
    game5.gameWind=[NSNumber numberWithInt:0];
    game5.gameDistance=[NSNumber numberWithInt:0];
    game5.gameDirectionInt=[NSNumber numberWithInt:0];
    game5.gameDirection=@"Exhale";
    //gameTestTypeMountainInhale
    
    //if (game6 == nil){
        
    //    NSLog(@"ERROR IN CREATING USER - a game object was not instantiated properly. Might be to do with loading");
    //    return false;
    ///}
    
    
    game6=[NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    game6.gameTestType=[NSNumber numberWithInt:gameTestTypeMountainInhale];
    game6.gameHillType=[NSNumber numberWithInt:hillTypeMountain];
    game6.gameAbilityType=[NSNumber numberWithInt:0];
    
    game6.gameType=[NSNumber numberWithInt:0];
    game6.gameDate=[NSDate date];
    game6.duration=[NSNumber numberWithInt:0];
    game6.power=[NSNumber numberWithInt:0];
    game6.bestStrength=[NSNumber numberWithInt:0];
    game6.bestDuration=[NSNumber numberWithInt:0];
    game6.gameAngle=[NSNumber numberWithInt:0];
    game6.gameWind=[NSNumber numberWithInt:0];
    game6.gameDistance=[NSNumber numberWithInt:0];
    
    game6.gameDirectionInt=[NSNumber numberWithInt:1];
    game6.gameDirection=@"Inhale";
    
  //   NSLog(@"MAKE TESTS6");
   // NSLog(@"game1 %@", game1);
   // NSLog(@"game2 %@", game2);
   // NSLog(@"game3 %@", game3);
   // NSLog(@"game4 %@", game4);
   // NSLog(@"game5 %@", game5);
   // NSLog(@"game6 %@", game6);
    
    
    [[user mutableSetValueForKey:@"game"]addObject:game1];
    [[user mutableSetValueForKey:@"game"]addObject:game2];
    [[user mutableSetValueForKey:@"game"]addObject:game3];
    [[user mutableSetValueForKey:@"game"]addObject:game4];
    [[user mutableSetValueForKey:@"game"]addObject:game5];
    [[user mutableSetValueForKey:@"game"]addObject:game6];

 //NSLog(@"MAKE TESTSEND");
    
    return true;
    
}
@end
