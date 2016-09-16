//
//  UpdateNoteOperation.m
//  Breath5
//
//  Created by barry on 26/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "UpdateNoteOperation.h"
#import "Note.h"
@interface UpdateNoteOperation ()

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,assign)Note *oldNote;
@property(nonatomic,strong)NSString *theNote;

@end
@implementation UpdateNoteOperation
- (id)initWithData:(Note *)note thenote:(NSString*)newNoteString sharedPSC:(NSPersistentStoreCoordinator *)psc
{

    self = [super init];
    if (self) {
        
        self.sharedPSC = psc;
        self.oldNote=note;
        self.theNote=newNoteString;
        
    }
    return self;

}
- (void)main {
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    __autoreleasing NSError  *error;

    Note *note=(Note*)[self.managedObjectContext objectWithID:[self.oldNote objectID]];
    
    note.noteString=self.theNote;
    
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
    [self.delegate noteUpdated:self];
}

@end
