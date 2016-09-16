//
//  ViewController.h
//  Breath5
//
//  Created by barry on 16/04/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserListViewController.h"



@protocol GameViewProtocol <NSObject>

-(void)gameViewExitGame;

@end
@interface ViewController : UIViewController<UIScrollViewDelegate>

@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)User  *gameUser;
@property(nonatomic,unsafe_unretained)id<GameViewProtocol>delegate;

//added by me
@property(nonatomic,strong)UserListViewController  *userList;
@property(nonatomic,strong)UINavigationController  *navcontroller;

-(void)setLabels;
-(void)resetGame;
-(void)killGame;
-(void)loadUserSettings:(User*)user;
@end

