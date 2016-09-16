//
//  HeaderView.h
//  BilliardBreath
//
//  Created by barry on 11/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@class HeaderView;

@protocol HeaderViewProtocl<NSObject>
-(void)deleteMember:(HeaderView*)header;
-(void)viewHistoricalData:(HeaderView*)header;
-(void)viewNotes:(HeaderView*)header;

@end
@interface HeaderView : UIView
@property NSManagedObjectID  *mmoid;
@property int section;
@property(nonatomic,unsafe_unretained)id<HeaderViewProtocl>delegate;
@property(nonatomic,weak)User  *user;
-(void)build;
@end
