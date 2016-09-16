//
//  Session.h
//  FairHammer
//
//  Created by barry on 11/07/2013.
//  Copyright (c) 2013 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject<NSCoding>
@property(nonatomic,strong)NSNumber  *sessionStrength;
@property(nonatomic,strong)NSString  *sessionDurationString;
@property(nonatomic,strong)NSNumber  *sessionDuration;
@property(nonatomic,strong)NSNumber  *sessionType;

@property(nonatomic,strong)NSDate    *sessionDate;
@property(nonatomic,strong)NSString  *username;
@property(nonatomic,strong)NSNumber  *sessionAngle;
@property(nonatomic,strong)NSNumber  *sessionWind;
@property(nonatomic,strong)NSNumber  *sessionDistance;
@property (nonatomic,strong)NSString  *cgPointString;
-(void)updateStrength:(float)pvalue;
@end
