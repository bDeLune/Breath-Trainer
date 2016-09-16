//
//  ViewController.m
//  Breath5
//
//  Created by barry on 16/04/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#define BIKE_SCENE_WIDTH 500
#define BIKE_SCENE_HEIGHT 500

#import <SpriteKit/SpriteKit.h>
#import "GCDObjC.h"
#import "ViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "StatsViewController.h"
#import "BikeScene.h"
#import "MidiController.h"
#import "Session.h"
#import "AddNewScoreOperation.h"
#import "Globals.h"
#import "AllGamesForDayTableVC.h"
#import "UIGlossyButton.h"
#import "AboutViewController.h"
#import "BTLEManager.h"

#define DegreesToRadians(d) ((d) * M_PI / 180.0)
typedef enum
{
    screenActivityTypeNone,
    screenActivityTypeTest,
    screenActivityTypeTraining

}screenActivityType;

@interface ViewController ()<MidiControllerProtocol,BikeSceneProtocol,SettingsProtocol,AboutVCProtocol,BTLEManagerDelegate, UserListProtoCol>
{
    gameDifficulty  currentDifficulty;
}

@property(nonatomic, weak)IIMyScene *scene;
@property(nonatomic, weak)UIView *clearContentView;

@property(nonatomic,strong)SettingsViewController  *settingsVC;
@property(nonatomic,strong)UIPopoverController  *statsPopover;
@property(nonatomic,strong)LoginViewController     *loginVC;
@property(nonatomic,strong)StatsViewController     *statsVC;
@property(nonatomic,strong)SKView  *skView;
@property(nonatomic,strong)BikeScene *bikeScene;
@property(nonatomic,strong)MidiController  *midi;

@property(nonatomic,weak)IBOutlet UIGlossyButton *toggleDirectionButton;
@property(nonatomic,weak)IBOutlet UITextView *debugTextView;
@property(nonatomic,weak)IBOutlet UILabel  *bestDistanceLabel;
@property(nonatomic,weak)IBOutlet UISlider *angleSlider;
@property(nonatomic,weak)IBOutlet UIProgressView *powerInhale;
@property(nonatomic,weak)IBOutlet UIProgressView *powerExhale;
@property(nonatomic,weak)IBOutlet UILabel  *durationLabel;
@property(nonatomic,weak)IBOutlet UILabel  *powerLabel;
@property(nonatomic,weak)IBOutlet UIImageView  *btOnOfImageView;
@property(nonatomic,weak)IBOutlet UIGlossyButton *testButton;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *trainButton;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property(nonatomic,strong)NSOperationQueue  *addGameQueue;
@property(nonatomic,weak)IBOutlet  UILabel  *currentUsersNameLabel;
@property(nonatomic,strong)Session  *currentSession;

@property(nonatomic,strong)Game  *currentGameTypeForUser;
@property(nonatomic,strong)BTLEManager  *btleManager;

@property(nonatomic,strong)UIAlertController  *repititionsAlertView;
@property(nonatomic,strong)AboutViewController  *aboutVC;
@property BOOL isInhaling;

@property int repetitionsToDo;
@property int repetitionsCompleted;
@property int currentDistance;

@property int currentBestDistance;
-(IBAction)changeAngle:(id)sender;
-(IBAction)changeAngleCommit:(id)sender;
-(IBAction)exitGameScreen:(id)sender;

-(IBAction)toggleDirection:(id)sender;
-(IBAction)showSettings:(id)sender;
-(IBAction)showStats:(id)sender;

-(IBAction)testButtonPressed:(id)sender;
-(IBAction)trainButtonPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *touchedUserButton2;
- (IBAction)touchedDownUserButton2:(id)sender;
- (IBAction)userButton2:(id)sender;
@property(nonatomic,strong)NSOperationQueue  *addUserQueue;

//@property(nonatomic,strong)NSDate *startDate;

@property(nonatomic,weak)IBOutlet UIGlossyButton  *helpButton;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *aboutButton;

-(IBAction)helpButtonPressed:(id)sender;
-(IBAction)aboutButtonPressed:(id)sender;

@property(nonatomic,weak)IBOutlet UIButton *hillTypeButton;
@property(nonatomic,weak)IBOutlet UIButton *userTypeButton;
@property(nonatomic,weak)IBOutlet UILabel  *repsLabel;
-(IBAction)hillTypeButtonPressed:(id)sender;

-(IBAction)userTypeButtonPressed:(id)sender;


@property(nonatomic,strong)NSTimer *debugTimer;
@property gameHillType  _gameHillType;
@property gameUserType  _gameUserType;
@property screenActivityType _screenActivityType;

-(IBAction)beginbreathingdebug:(id)sender;
-(IBAction)stopBreathingdebug:(id)sender;


@end
NSString * const gameHillType_toString[] = {
    [hillTypeFlat] = @"Endurance",
    [hillTypeHill] = @"Endurance & Strength",
    [hillTypeMountain]=@"Strength"
};

NSString * const gameUserType_toString[]={
    [userTypeSignifigant]=@"Low",
    [userTypeReduced]=@"Medium",
    [userTypeLittleReduced]=@"High",
    [userTypeNotReduced]=@"Very High"
    
};

@implementation ViewController

static NSString * kViewTransformChanged = @"view transform changed";
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

   // NSLog(@"%@",scrollView);
}

-(IBAction)helpButtonPressed:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tiny.cc/c43ryx"]];
}


-(IBAction)aboutButtonPressed:(id)sender{
    
    [self.bikeScene setPaused:YES];
    if (!self.aboutVC) {
        self.aboutVC=[[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    }
    self.aboutVC.delegate=self;
    [UIView transitionFromView:self.view toView:self.aboutVC.view duration:0.3 options:UIViewAnimationOptionTransitionFlipFromBottom completion:nil];
   // [UIView transitionFromView:self.loginViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){

}
-(void)exitAboutScreen
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionFromView:self.aboutVC.view toView:self.view duration:0.3 options:UIViewAnimationOptionTransitionFlipFromTop completion:nil];
        [self.bikeScene setPaused:NO];
    });
}
-(IBAction)stopBreathingdebug:(id)sender

{
    NSLog(@"STOP!!");
    [self midiNoteStopped:nil];
}

#pragma mark -
#pragma mark - Training / Testing / Nonoe
-(void)gameAttemptEnded:(BikeScene*)bikeScene
{
    
    NSLog(@"Game attempt ended");
    NSLog(@"Game type %d", screenActivityTypeTest );
    
    if (self._screenActivityType==screenActivityTypeTest) {
       
        
        [self addDataToSession];
        [self saveCurrentSession];
        [self startSession]; //COMMENTED OUT THE ABOVE LINE AND MOVED START SESSION TO TOP
        
    }
    
    if (self._screenActivityType==screenActivityTypeTraining) {
        
         NSLog(@"Success - training! " );
        self.repetitionsCompleted++;
        if (self.repetitionsCompleted>self.repetitionsToDo) {
            
            [self enterNoneMode];
            [self.bikeScene playSuccess];
        }else
        {
            self.repsLabel.text=[NSString stringWithFormat:@"%i of %i",self.repetitionsCompleted,self.repetitionsToDo];
        }
    }
    

}
-(void)updatePoint
{   //NSLog(@"inhale or exhale == %i",self.midi.toggleIsON);
    NSManagedObjectID  *gamieID=[[Globals sharedInstance]gameIDForUser:self.gameUser breathDirection:self.midi.toggleIsON hilltype:__gameHillType];
    
    Game  *game=(Game*)[self.managedObjectContext objectWithID:gamieID];
    NSString  *pointString=game.gamePointString;
    
    if (pointString) {
        CGPoint point=CGPointFromString(pointString);
        
        [self.bikeScene setArrowDistance:point];
        switch ([self.gameUser.userHillType intValue]) {
            case hillTypeFlat:
                [self.bikeScene addArrowPct:0.5];

                break;
                
            case hillTypeHill:
                [self.bikeScene addArrowPct:0.6];

                break;
                
            case hillTypeMountain:
                [self.bikeScene addArrowPct:0.8];
                break;

                
            default:
                break;
        }
    }else
    {
        [self.bikeScene setArrowDistance:CGPointMake(0, 0)];

    }
    
}

-(void)enterTrainingMode
{
    
    NSLog(@"ENTERING TRAINING MODE");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trainButton.buttonBorderWidth=4;
        self.testButton.buttonBorderWidth=0;
        [self.testButton setNeedsDisplay];
        [self.trainButton setNeedsDisplay];
        [self updatePoint];
        [self.bikeScene hidePctArrow:NO];

    });

    self.repititionsAlertView = [UIAlertController
                                          alertControllerWithTitle:@"Number of repetitions"
                                          message:@"Please enter how many repetitions you would like to train with"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [self.repititionsAlertView addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"repetitions";
         textField.keyboardType=UIKeyboardTypeDecimalPad;
     }];
    
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                               {
                             //      NSLog(@"OK action");
                                   
                                   UITextField *txt=self.repititionsAlertView.textFields.firstObject;
                                   [self setrepetitionsFromInput:[txt.text intValue]];
                               }];
    
    [self.repititionsAlertView addAction:okAction];
    self.repsLabel.alpha=1.0;

    [self presentViewController:self.repititionsAlertView animated:YES completion:nil];
}
-(void)setrepetitionsFromInput:(int)reps
{
    self.repetitionsToDo=reps;
    self.repetitionsCompleted=1;
    self.repsLabel.text=[NSString stringWithFormat:@"%i of %i",self.repetitionsCompleted,self.repetitionsToDo];

}
-(void)enterTestMode
{
    NSLog(@"ENTERING TEST MODE");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.trainButton setStrokeType:0];
        //[self.testButton setStrokeType:kUIGlossyButtonStrokeTypeBevelUp];
        self.repsLabel.text=@"";
        
        self.trainButton.buttonBorderWidth=0;
        self.testButton.buttonBorderWidth=4;
        
        [self.testButton setNeedsDisplay];
        [self.trainButton setNeedsDisplay];
        [self.bikeScene resetDistance];
        self.repsLabel.alpha=0.0;
        [self.bikeScene hidePctArrow:YES];
    });
    
    [self startSession];
    
}
-(void)enterNoneMode
{
    
    NSLog(@"ENTERING NONE MODE");
    dispatch_async(dispatch_get_main_queue(), ^{

    __screenActivityType=screenActivityTypeNone;
        self.trainButton.buttonBorderWidth=0;
        self.testButton.buttonBorderWidth=0;
        self.repsLabel.alpha=0.0;

        [self.testButton setNeedsDisplay];
        [self.trainButton setNeedsDisplay];
        [self.bikeScene hidePctArrow:YES];

    });

    
}
-(IBAction)testButtonPressed:(id)sender{

    switch (__screenActivityType) {
        case screenActivityTypeNone:
            __screenActivityType=screenActivityTypeTest;
            [self enterTestMode];
            break;
        case screenActivityTypeTest:
            __screenActivityType=screenActivityTypeNone;
            [self enterNoneMode];

            break;
            
        case screenActivityTypeTraining:
            __screenActivityType=screenActivityTypeTest;
            [self enterTestMode];

            break;
        default:
            break;
    }
}
-(IBAction)trainButtonPressed:(id)sender{
    
    NSLog(@"TRAIN BUTTON PRESSED screenactivitytype %u", __screenActivityType);
    
    switch (__screenActivityType) {
        case screenActivityTypeNone:
            __screenActivityType=screenActivityTypeTraining;
            [self enterTrainingMode];

            break;
        case screenActivityTypeTest:
            __screenActivityType=screenActivityTypeTraining;
            [self enterTrainingMode];
            
            break;
            
        case screenActivityTypeTraining:
            __screenActivityType=screenActivityTypeNone;
            [self enterNoneMode];
            
            break;
        default:
            break;
    }

}

- (IBAction)userButton2:(id)sender {
}

#pragma mark -
#pragma mark - Options

-(IBAction)hillTypeButtonPressed:(id)sender
{

    self._gameHillType++;
    if (self._gameHillType>2) {
        self._gameHillType=0;
    }
    
    NSString  *hill=gameHillType_toString[self._gameHillType];
    [self.hillTypeButton setTitle:hill forState:UIControlStateNormal];
    
    self.gameUser.userHillType=[NSNumber numberWithInt:self._gameHillType];
    
    
    @try {
        [self.clearContentView removeObserver:self forKeyPath:@"transform"];

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    [self resetGame];
    [self killGame];
    [self makeGame];
    [self updatePoint];
    //[self.bikeScene setArrowDistance:300];

}

-(void)getTheGameForThisUserBAsedOnSettings
{

}

-(IBAction)userTypeButtonPressed:(id)sender
{
    self._gameUserType++;
    if (self._gameUserType>3) {
        self._gameUserType=0;
    }
    
    NSString  *type=gameUserType_toString[self._gameUserType];

    self.userTypeButton.titleLabel.text=type;
    
    self.gameUser.userAbilityType=[NSNumber numberWithInt:self._gameUserType];
    [[Globals sharedInstance]updateUser:self.gameUser];
    [self.userTypeButton setTitle:type forState:UIControlStateNormal];
    
    [self.bikeScene updateDifficulty:self._gameUserType];

}
-(void)loadUserSettings:(User*)user
{

    self._gameUserType=[user.userAbilityType intValue];
    NSString  *type=gameUserType_toString[self._gameUserType];
    [self.userTypeButton setTitle:type forState:UIControlStateNormal];
    [self.bikeScene updateDifficulty:self._gameUserType];



}


#pragma mark -
#pragma mark - Session
-(void)setupProgress
{
    CGRect frame=self.powerInhale.frame;
    frame.size.height=40;
   // self.powerInhale.progressTintColor=[UIColor blueColor];
    self.powerInhale.frame=frame;
     self.powerInhale.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
    
    CGRect frame2=self.powerExhale.frame;
    frame2.size.height=40;
 //   self.powerExhale.tintColor=[UIColor orangeColor];
    self.powerExhale.frame=frame;


}
-(void)settingDidFinish:(SettingsViewController *)setting
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.bestDistanceLabel.text=@"";
        [self resetGame];
        [self killGame];
        [self makeGame];
    }];
    
}

-(void)gamePosX:(int)pos
{

}

-(void)gameDistance:(BikeScene *)bikeScene
{
    self.bestDistanceLabel.text=[NSString stringWithFormat:@"%i",bikeScene.bestDistance];
    self.currentDistance=bikeScene.bestDistance;
}

-(void)gameWon:(BikeScene*)bikeScene{
    self.bikeScene.paused=YES;
    [self addDataToSession];
    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame];
        [self killGame];
        [self makeGame];
    } afterDelay:1];
    
    [self saveCurrentSession];
}
-(void)gameStarted:(BikeScene*)bikeScene
{
    if (__screenActivityType!=screenActivityTypeTest) {
   return;
   }
    [self startSession];
}
-(void)addDataToSession
{
   if (__screenActivityType!=screenActivityTypeTest) {
        NSLog(@"Should have ended session adn saved!!!!!!");
        return;
    }
    
    
    //self.currentSession = [[Session alloc] init];
    
    self.currentSession.sessionAngle=[NSNumber numberWithFloat:[self.bikeScene slopeAngle]*45];
    self.currentSession.sessionDate=[NSDate date];
    self.currentSession.sessionDistance=[NSNumber numberWithInt:self.currentDistance];
    self.currentSession.sessionWind=[NSNumber numberWithInt:self.bikeScene.currentWind];
    self.currentSession.sessionStrength=[NSNumber numberWithInt:self.bikeScene.bestVelocity*127];
    self.currentSession.sessionType=[[NSUserDefaults standardUserDefaults]valueForKey:@"difficulty"];
    NSDate *now=[NSDate date];
    NSTimeInterval duration =[now timeIntervalSinceDate:self.currentSession.sessionDate];
    self.currentSession.sessionDuration=[NSNumber numberWithFloat:duration];
    self.currentSession.sessionDurationString=self.durationLabel.text;
    self.currentSession.cgPointString=NSStringFromCGPoint(self.bikeScene.lastArrowPoint);
    
    NSLog(@"sessionDate  %@", self.currentSession.sessionDate);
    NSLog(@"sessionDuration %@", self.currentSession.sessionDuration);
    NSLog(@"sessionWind %@", self.currentSession.sessionWind);
    
    [self enterNoneMode];
}
-(void)gameEnded:(BikeScene*)bikeScene

{
    NSLog(@"Game ended add to current session ");
    
    [self addDataToSession];

    self.bikeScene.paused=YES;
    
    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame];
        [self killGame];
        
    }];
    
    [self saveCurrentSession];

}
-(void)startSession
{
    
    //commenting out all screenactivitytests
    if (__screenActivityType!=screenActivityTypeTest) {
        return;
    }
    self.currentSession=[Session new];
    self.currentSession.sessionDate=[NSDate date];
}
#pragma - UIControls

-(IBAction)exitGameScreen:(id)sender
{
   // [self gameEnded:self.bikeScene];//MAYBE - B //added

    [self.delegate gameViewExitGame];
}
-(IBAction)changeAngleCommit:(id)sender
{
[self.bikeScene setAngle:self.angleSlider.value];
}
-(IBAction)changeAngle:(id)sender
{
   // [self.bikeScene setAngle:self.angleSlider.value];
}

-(void)makeGame
{
    int x=30;
    int y=400;
    
    int factor=2;
    
    if (self._gameHillType==hillTypeFlat)
    {
        self.skView =[[SKView alloc]initWithFrame:CGRectMake(x, y, 730*factor, 500)];

    }else
    {
         self.skView =[[SKView alloc]initWithFrame:CGRectMake(x, y, 730, 500)];

    }
    
    self.skView.ignoresSiblingOrder = false;//added
   // self.skView =[[SKView alloc]initWithFrame:CGRectMake(x, y, 730, 500)];

   // self.skView.center = CGPointMake(550, 280);
    
    if (!self.skView.scene) {
        self.skView.showsFPS = NO;
        self.skView.showsNodeCount = NO;
        
        // Create and configure the scene.
        if (self._gameHillType==hillTypeFlat) {
            //CGSize frame=self.skView.bounds.size;
            //frame.width=frame.width*2;
            self.bikeScene = [BikeScene sceneWithSize:self.skView.bounds.size];

            //[self.bikeScene setContentSize:frame];
           // self.bikeScene = [BikeScene sceneWithSize:frame];
            self.bikeScene.scaleMode = SKSceneScaleModeAspectFit;
        }else
        {
            self.bikeScene = [BikeScene sceneWithSize:self.skView.bounds.size];
            self.bikeScene.scaleMode = SKSceneScaleModeAspectFit;
        }
       
        _scene = self.bikeScene;

        // Present the scene.
        [self.skView presentScene:self.bikeScene];
        [self.bikeScene setCurrentUser:self.gameUser];
        self.bikeScene.paused=NO;
        [self.view addSubview:self.skView];
    }
    //  UIButton  *but=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    //[self.view addSubview:but];
    
    [self.bikeScene gameDelegate:self];

    if (!self.midi) {
        self.midi =[[MidiController alloc]init];
        self.midi.delegate=self;
        [self.midi setup];
    }
    
    
    
    if (self._gameHillType==hillTypeFlat)
    {
        CGRect aframe=self.skView.frame;
        aframe.size.width=aframe.size.width/factor;
        
        CGSize contentSize=self.skView.bounds.size;
       // contentSize.width=contentSize.width*2;
        
        //UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:aframe];
        /*[scrollView setContentSize:contentSize];
        
        scrollView.delegate = self;
        [scrollView setMinimumZoomScale:1.0];
        [scrollView setMaximumZoomScale:1.0];
        [scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        UIView *clearContentView = [[UIView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = contentSize}];
        [clearContentView setBackgroundColor:[UIColor clearColor]];
        [scrollView addSubview:clearContentView];
        scrollView.userInteractionEnabled=NO;
        _clearContentView = clearContentView;
        
        [clearContentView addObserver:self
                           forKeyPath:@"transform"
                              options:NSKeyValueObservingOptionNew
                              context:&kViewTransformChanged];
        [self.view addSubview:scrollView];*/
        [self.bikeScene setContentSize:contentSize];
        
        [self.scene setContentOffset:CGPointMake(0, 0)];


    }
    [self.bikeScene setup];
}


- (void)viewDidLoad {
    [super viewDidLoad];
        NSLog(@"New view loaded");
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:NULL];
    for (NSString *fileName in files) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
     //   NSLog(@"BUNDLE FILE: %@", url);
    }
    
    
    self.view.backgroundColor=[UIColor blackColor];
    self.addGameQueue=[[NSOperationQueue alloc]init];
    [self setupProgress];
    [BTLEManager sharedInstance].delegate=self;
    [[BTLEManager sharedInstance]startWithDeviceName:@"GroovTube" andPollInterval:0.1];
    [[BTLEManager sharedInstance]setTreshold:80];
    [[BTLEManager sharedInstance]setRangeReduction:2];
    
    self.userList=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    self.userList.sharedPSC=self.sharedPSC;
    
    self.navcontroller=[[UINavigationController alloc]initWithRootViewController:self.userList];
    
    CGRect  frame=self.view.frame;
    [self.navcontroller.view setFrame:frame];
    // Do any additional setup after loading the view from its
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    @try {
       // [self.clearContentView removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException *exception) {    }
    @finally {    }

    if (!self.bikeScene) {
        [self resetGame];
        [self killGame];
        [self makeGame];
    }
   
}

-(void)viewDidAppear:(BOOL)animated
{
    [self enterNoneMode];
    
    [self.hillTypeButton useBlackLabel:YES];
    [self.userTypeButton useBlackLabel:YES];
    [self.testButton useBlackLabel:YES];
    [self.trainButton useBlackLabel:YES];
    [self.helpButton useBlackLabel:YES];
    [self.aboutButton useBlackLabel:YES];
    
    /*self.testButton.invertGraidentOnSelected=YES;
    self.trainButton.invertGraidentOnSelected=YES;*/
    
    self.trainButton.borderColor=[UIColor orangeColor];
    self.trainButton.buttonBorderWidth=4;
    
    self.testButton.borderColor=[UIColor orangeColor];
    self.testButton.buttonBorderWidth=4;
    
    [self.testButton setStrokeType:kUIGlossyButtonStrokeTypeBevelUp];
    [self.trainButton setStrokeType:kUIGlossyButtonStrokeTypeBevelUp];
    
    BOOL isconnected=[[BTLEManager sharedInstance]isConnected];
    
    if (isconnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];
            
        });
    }
}

-(void)gameDuration:(BikeScene *)bikeScene
{
    NSDate *now=[NSDate date];
    
    NSTimeInterval  intervale=[now timeIntervalSinceDate:self.currentSession.sessionDate];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *formattedDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:intervale]];
 
    
    self.durationLabel.text=formattedDate;
}

#pragma mark -
#pragma mark - MidiDelegate
-(void)btleManagerBreathBegan:(BTLEManager*)manager
{
   // [self midiNoteBegan:nil];

}
-(void)btleManagerBreathBeganWithInhale:(BTLEManager*)manager
{
    if (!self.midi.toggleIsON)
    {
        return;
    }
    [self midiNoteBegan:nil];


}
-(void)btleManagerBreathBeganWithExhale:(BTLEManager*)manager
{
    if (self.midi.toggleIsON)
    {
        return;
    }
    [self midiNoteBegan:nil];


}

-(void)btleManagerBreathStopped:(BTLEManager*)manager
{
    self.bikeScene.isBlowing=NO;
    [self midiNoteStopped:nil];


}

-(void)btleManagerConnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];
        
    });
    
}

-(void)btleManagerDisconnected:(BTLEManager *)manager

{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
    });
    
}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{

    self.isInhaling=YES;
    if (!self.midi.toggleIsON)
    {
        return;
    }
    [self midiNoteContinuingFloat:percentOfmax*127.0];


}
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    self.isInhaling=NO;
    if (self.midi.toggleIsON)
    {
        return;
    }
    
   // NSLog(@"value == %f",percentOfmax*127.0);
    
    [self midiNoteContinuingFloat:percentOfmax*127.0];

}
-(void)midiNoteBegan:(MidiController *)midi
{
    
    [self.bikeScene setPaused:NO];

}

-(void)midiNoteStopped:(MidiController *)midi
{
  // end turn / rep
    
    
    NSLog(@"Attempt Ended!!");
    
    
    //[self startSession]; //START SESSION MOVED TO TO BEFORE NEXT TWO
    //[self addDataToSession];
    //[self saveCurrentSession];
    
    
    //these were commented out, returns were not + dispatch
    
    
    if (self.isInhaling) {
     
        if (!self.midi.toggleIsON) {
   //         return;
        }
    }
    if (!self.isInhaling) {
        
        if (self.midi.toggleIsON) {
  //          return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bikeScene setStopVector];

        [self gameAttemptEnded:nil];

    });
}
-(void)midiNoteContinuingFloat:(float)velocity
{
    if (velocity==127) {
        return;
    }
    self.bikeScene.isBlowing=YES;
    [[GCDQueue backgroundPriorityGlobalQueue]queueBlock:^{
        [self.bikeScene setVelocity:(velocity/127.0f)];
        
        [[GCDQueue mainQueue]queueBlock:^{
            /// [self sendLogToOutput:[NSString stringWithFormat:@"%f",_midi.velocity]];
            self.powerLabel.text=[NSString stringWithFormat:@"%i",(int)velocity];
            
            if (self.midi.toggleIsON) {
                //inhale
                [self.powerInhale setProgress:velocity/127.0f];
                [self.powerExhale setProgress:0.0];
            }else
            {
                //Exhale
                [self.powerExhale setProgress:velocity/127.0f];
                [self.powerInhale setProgress:0.0];
            }
        }];
        
        
        
    }];
    
}

-(void)midiNoteContinuing:(MidiController*)midi
{
    if (midi.velocity==127) {
        return;
    }
    self.bikeScene.isBlowing=YES;

    [[GCDQueue backgroundPriorityGlobalQueue]queueBlock:^{
        [self.bikeScene setVelocity:(midi.velocity/127.0f)];
        
        [[GCDQueue mainQueue]queueBlock:^{
            // [self sendLogToOutput:[NSString stringWithFormat:@"%f",midi.velocity]];
            self.powerLabel.text=[NSString stringWithFormat:@"%i",(int)midi.velocity];
            
            if (self.midi.toggleIsON) {
                //inhale
                [self.powerInhale setProgress:self.midi.velocity/127.0f];
                [self.powerExhale setProgress:0.0];
            }else
            {
              //Exhale
                [self.powerExhale setProgress:self.midi.velocity/127.0f];
                [self.powerInhale setProgress:0.0];
            }
        }];
        
        

    }];

}

-(IBAction)toggleDirection:(id)sender
{
    
    switch (self.midi.toggleIsON) {
        case 0:
            self.midi.toggleIsON=YES;
            //  midiController.currentdirection=midiinhale;
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"INHALEButton.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
            
            break;
        case 1:
            self.midi.toggleIsON=NO;
            
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"EXHALEButton.png"] forState:UIControlStateNormal];
            //  midiController.currentdirection=midiexhale;
            
            [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
            
            break;
            
        default:
            break;
    }
    
    
    [self updatePoint];
    
}
-(IBAction)showSettings:(id)sender
{
    if (!self.settingsVC) {
        
        UIStoryboard  *main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.settingsVC=[main instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    }
    self.settingsVC.delegate=self;
      
    [self presentViewController:self.settingsVC animated:YES completion:nil];
}
-(void)setLabels{
    
    [self managedObjectContext];
    [[GCDQueue mainQueue]queueBlock:^{
        self.currentUsersNameLabel.text=[self.gameUser valueForKey:@"userName"];
        // [self setTargetScore];
        
    }];

}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    if (self.sharedPSC != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    
    
    
    return _managedObjectContext;
}

-(void)resetGame{
    self.bikeScene.paused=YES;
   

}
-(void)killGame
{
    self.bikeScene.paused=YES;
    [self.bikeScene removeFromParent];
    self.bikeScene=nil;
    [self.skView removeFromSuperview];
   // self.skView=nil;

}
-(void)saveCurrentSession
{
    NSLog(@"Saving Current Session");
    
    if (__screenActivityType!=screenActivityTypeTest) {
        return;
   }
    
    
  //  NSLog(@"SESSION %@", self.currentSession);
  //  NSLog(@"sessionStrength %@", self.currentSession.sessionStrength);
    
  //  NSLog(@"self.gameUser %@", self.gameUser);
   
   // NSLog(@"self.sharedPSC %@", self.sharedPSC.name);
    
    
    AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:self.currentSession sharedPSC:self.sharedPSC];
    
    [self.addGameQueue addOperation:operation];
    
    [self enterNoneMode];
}

-(void)setTargetScore
{
    NSLog(@"Set target score");
    NSString   *name=self.gameUser.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *user=[items objectAtIndex:0];
        NSSet  *game=user.game;
        NSArray  *games=[game allObjects];
        
        float highestNumber=0;
        for (Game *game in games)
        {
            if ([game.power floatValue] > highestNumber) {
                highestNumber = [game.power floatValue];
            }
        }
        
        
        //float value=highestNumber;
        [[GCDQueue mainQueue]queueBlock:^{
           // [self.targetLabel setText:[NSString stringWithFormat:@"%0.0f",value]];
            
        }];
        
    }
    
}

-(IBAction)showStats:(id)sender
{
    // NSArray  *dates=[self sortedDateArrayForUser:self.gameUser];
    //dates=[[dates reverseObjectEnumerator]allObjects];
    // NSDate  *date=[sortedDateKeysNoTime objectAtIndex:indexPath.row];
    AllGamesForDayTableVC  *detailViewController=[[AllGamesForDayTableVC alloc]initWithNibName:@"AllGamesForDayTableVC" bundle:nil];
    NSArray *array=[NSArray arrayWithArray:[self.gameUser.game allObjects]];
    
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Game*)a gameDate];
        NSDate *second = [(Game*)b gameDate];
        return [first compare:second];
    }];
    
    
    //NSLog(@"sHOWING STATS %@ ", sortedArray);
    
    [detailViewController setUSerData:sortedArray];
    
    if (!self.statsPopover) {
        self.statsPopover=[[UIPopoverController alloc]initWithContentViewController:detailViewController];
    }
    detailViewController.preferredContentSize=CGSizeMake(500, 500);
    [self.statsPopover presentPopoverFromRect:CGRectZero inView:self.view permittedArrowDirections:0 animated:NO];
}

-(NSArray*)sortedDateArrayForUser:(User*)user
{
    
    NSArray *alldates=[user.game allObjects];
    NSArray *sortedArray = [alldates sortedArrayUsingComparator:
                            ^(id obj1, id obj2)
                            {
                                return [(NSDate*) [obj1 valueForKey:@"gameDate" ] compare: (NSDate*)[obj2 valueForKey:@"gameDate"]];
                            }
                            ];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    NSMutableArray  *datesstrings=[NSMutableArray new];
    
    for (int i=0; i<[sortedArray count]; i++) {
        NSDate  *date=[[sortedArray objectAtIndex:i]valueForKey:@"gameDate"];
        [datesstrings addObject:[formatter stringFromDate:date]];
        
    }
    
    NSLog(@"Returning date String %@", datesstrings);
    
    return datesstrings;

}

#pragma mark -
#pragma mark - weird scroll stuff

-(void)adjustContent:(UIScrollView *)scrollView
{
    CGFloat zoomScale = [scrollView zoomScale];
    [self.scene setContentScale:zoomScale];
    CGPoint contentOffset = [scrollView contentOffset];
    [self.scene setContentOffset:contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.clearContentView;
}

-(void)scrollViewDidTransform:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations
{
    [self adjustContent:scrollView];
}
#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (context == &kViewTransformChanged)
    {
        [self scrollViewDidTransform:(id)[(UIView *)object superview]];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/*-(void)dealloc
{
    @try {
        [self.clearContentView removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException *exception) {    }
    @finally {    }
}*/


#pragma mark -
#pragma mark - Core Data Searching

-(Game*)gameForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype
{
    return [[Globals sharedInstance]gameForUser:user breathDirection:direction hilltype:hilltype];
}
- (IBAction)touchedUserButton2:(id)sender {

    NSLog(@"Touched new user button");
    self.userList.sharedPSC=self.sharedPSC ;
    [self.userList getListOfUsers];
    [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
        
        self.userList.sharedPSC=self.sharedPSC;
        self.userList.delegate=self;
        
    }];



}
- (IBAction)touchedDownUserButton2:(id)sender {

    NSLog(@"Touchedm down new user button");
    self.userList.sharedPSC=self.sharedPSC ;

    [self.userList getListOfUsers];

    [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){

        self.userList.sharedPSC=self.sharedPSC;
        self.userList.delegate=self;
        
    }];


}

-(void)userListDismissRequest:(UserListViewController *)caller
{
    [[GCDQueue mainQueue]queueBlock:^{
        
        
        [UIView transitionFromView:self.navcontroller.view toView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
            
            self.userList.sharedPSC=self.sharedPSC;
            self.userList.delegate=self;
            
        }];
        
    }];
    
}

@end
