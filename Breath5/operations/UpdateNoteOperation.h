//
//  UpdateNoteOperation.h
//  Breath5
//
//  Created by barry on 26/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//
#import<CoreData/CoreData.h>

#import <Foundation/Foundation.h>
@class Note;
@class UpdateNoteOperation;

@protocol UpdateNoteOperationProtocol <NSObject>

-(void)noteUpdated:(UpdateNoteOperation*)operation;

@end

@interface UpdateNoteOperation : NSOperation
- (id)initWithData:(Note *)note thenote:(NSString*)note sharedPSC:(NSPersistentStoreCoordinator *)psc;
@property(nonatomic,unsafe_unretained)id<UpdateNoteOperationProtocol>delegate;
@end
