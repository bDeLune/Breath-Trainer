//
//  Session.m
//  FairHammer
//
//  Created by barry on 11/07/2013.
//  Copyright (c) 2013 barry. All rights reserved.
//

#import "Session.h"

@implementation Session

-(id)init
{
    self=[super init];
    
    if (self) {
        _sessionDate=[NSDate date];
        _sessionStrength=[NSNumber numberWithFloat:0.0];
        _sessionDuration=[NSNumber numberWithFloat:0.0];
        _sessionType=[NSNumber numberWithInt:0];
        _sessionAngle=[NSNumber numberWithFloat:0.0];
        _sessionDistance=[NSNumber numberWithFloat:0.0];
        _sessionWind=[NSNumber numberWithFloat:0.0];
    }
    
    return self;
}

-(void)updateStrength:(float)pvalue
{

    if (pvalue>[_sessionStrength floatValue]) {
        _sessionStrength=[NSNumber numberWithFloat:pvalue];
    }
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_sessionDate forKey:@"sessionDate"];
    [encoder encodeObject:_sessionDuration forKey:@"sessionDuration"];
    [encoder encodeObject:_sessionStrength forKey:@"sessionStrength"];

    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_sessionType forKey:@"sessionType"];
    
    [encoder encodeObject:_sessionDistance forKey:@"sessionDistance"];
    [encoder encodeObject:_sessionWind forKey:@"sessionWind"];
    [encoder encodeObject:_sessionAngle forKey:@"sessionAngle"];


}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.sessionDate = [decoder decodeObjectForKey:@"sessionDate"];
    self.sessionStrength = [decoder decodeObjectForKey:@"sessionStrength"];
    self.username = [decoder decodeObjectForKey:@"username"];
    self.sessionDuration = [decoder decodeObjectForKey:@"sessionDuration"];
    
    self.sessionAngle=[decoder decodeObjectForKey:@"sessionAngle"];
    self.sessionDistance=[decoder decodeObjectForKey:@"sessionDistance"];
    self.sessionWind=[decoder decodeObjectForKey:@"sessionWind"];
    return self;
}

@end
