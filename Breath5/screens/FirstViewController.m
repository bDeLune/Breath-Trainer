//
//  FirstViewController.m
//  Breath5
//
//  Created by barry on 21/04/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "FirstViewController.h"
#import "LoginViewController.h"
//#import "GameViewController.h"
#import "Globals.h"
#import "ViewController.h"
@interface FirstViewController ()<LoginProtocol,GameViewProtocol>
@property(nonatomic,strong)LoginViewController  *loginViewController;
@property(nonatomic,strong)ViewController  *gameViewController;

@property(nonatomic,strong)User  *currentUser;
@property(nonatomic,strong)Game  *currentGame;
@property(nonatomic,strong)NSTimer  *splashRemoveTimer;
@property(nonatomic,strong)UIImageView *spashImageView;

@end

@implementation FirstViewController
-(void)addUserLoginViewController
{
    if (!self.loginViewController) {
        self.loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    self.loginViewController.sharedPSC=[Globals sharedInstance].sharedPSC;
    self.loginViewController.delegate=self;
    [self.view addSubview:self.loginViewController.view];    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addUserLoginViewController];
    [self createSplash];
    // Do any additional setup after loading the view.
}
-(void)createSplash
{
    UIImage *image=[UIImage imageNamed:@"BreathTrainer-Splash_new"];
    self.spashImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.spashImageView setImage:image];
    [self.view addSubview:self.spashImageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self.spashImageView removeFromSuperview];
        self.spashImageView=nil;
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark - Login Delegate


-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user
{
    // assert([NSThread isMainThread]);
    
    self.currentUser=user;
    
    if (!self.gameViewController) {
        UIStoryboard  *main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.gameViewController=[main instantiateViewControllerWithIdentifier:@"ViewController"];
        self.gameViewController.delegate=self;
    }else
    {
        [self.gameViewController resetGame];
        [self.gameViewController.view removeFromSuperview];
        self.gameViewController=nil;
        
        UIStoryboard  *main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.gameViewController=[main instantiateViewControllerWithIdentifier:@"ViewController"];
        self.gameViewController.delegate=self;

    }
    
    [UIView transitionFromView:self.loginViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){
        self.gameViewController.gameUser=user;
        [self.gameViewController setLabels];
        self.gameViewController.sharedPSC=[Globals sharedInstance].sharedPSC;
        [self.gameViewController loadUserSettings:user];

       // [self.gameViewController resetGame];
        
    }];
}

-(void)gameViewExitGame
{
    [UIView transitionFromView:self.gameViewController.view toView:self.loginViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
