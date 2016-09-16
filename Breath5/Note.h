//
//  Note.h
//  Breath5
//
//  Created by barry on 26/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import <CoreData/CoreData.h>
@class User;
@interface Note : NSManagedObject
@property(nonatomic,retain)NSDate *noteDate;
@property(nonatomic,retain)NSString *noteString;
@property (nonatomic, retain) User *user;

@end
