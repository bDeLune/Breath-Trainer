//
//  AboutViewController.h
//  Breath5
//
//  Created by barry on 28/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AboutVCProtocol
-(void)exitAboutScreen;
@end
@interface AboutViewController : UIViewController
@property(nonatomic,unsafe_unretained)id<AboutVCProtocol>delegate;
@end
