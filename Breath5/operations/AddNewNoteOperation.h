//
//  AddNewNoteOperation.h
//  Breath5
//
//  Created by barry on 26/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<CoreData/CoreData.h>
#import "User.h"
@class AddNewNoteOperation;

@protocol AddNewNoteOperationProtocol <NSObject>

-(void)addNewNoteSuccess:(AddNewNoteOperation*)noteOperation;

@end
@interface AddNewNoteOperation : NSOperation
- (id)initWithData:(User *)user thenote:(NSString*)note sharedPSC:(NSPersistentStoreCoordinator *)psc;
@property(nonatomic,unsafe_unretained)id<AddNewNoteOperationProtocol>delegate;
@end
