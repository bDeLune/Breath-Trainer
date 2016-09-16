//
//  AddNewNoteOperation.m
//  Breath5
//
//  Created by barry on 26/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "AddNewNoteOperation.h"
#import "Note.h"
@interface AddNewNoteOperation()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,assign)User *user;
@property(nonatomic,strong)NSString *theNote;

@end
@implementation AddNewNoteOperation
- (id)initWithData:(User *)user thenote:(NSString*)note sharedPSC:(NSPersistentStoreCoordinator *)psc;
{
    self = [super init];
    if (self) {
        
        self.sharedPSC = psc;
        self.user=user;
        self.theNote=note;
        
    }
    return self;
    
}
- (void)main {
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    [self addTheNote];
}

-(void)addTheNote
{

    Note *        note=[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    
    note.noteDate=[NSDate date];
    note.noteString=self.theNote;
    __autoreleasing NSError  *error;

    if ([self.managedObjectContext hasChanges]) {
        
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }

   // [[self.user mutableSetValueForKey:@"note"] addObject:[self.user.managedObjectContext objectWithID:[note objectID]]];

   [[[self.managedObjectContext objectWithID:[self.user objectID]]mutableSetValueForKey:@"note"] addObject:[self.managedObjectContext objectWithID:[note objectID]]];

    
    
    
    if ([self.managedObjectContext hasChanges]) {
        
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.delegate addNewNoteSuccess:self];
    });

}

@end
