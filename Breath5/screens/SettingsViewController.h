//
//  SettingsViewController.h
//  Breath5
//
//  Created by barry on 16/04/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDObjC.h"


@class SettingsViewController;

@protocol SettingsProtocol <NSObject>

-(void)settingDidFinish:(SettingsViewController*)setting;

@end

@interface SettingsViewController : UIViewController
@property(nonatomic,unsafe_unretained)id<SettingsProtocol>delegate;
@end
