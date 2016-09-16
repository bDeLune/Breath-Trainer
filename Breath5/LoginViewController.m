//
//  LoginViewController.m
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "LoginViewController.h"
#import "AddNewUserOperation.h"

@interface LoginViewController ()<UserListProtoCol>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSManagedObject  *loggedInUser;
@property(nonatomic,strong)NSOperationQueue  *addUserQueue;
//@property(nonatomic,strong)UINavigationController  *navcontroller;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.addUserQueue = [NSOperationQueue new];
        
        // observe the keypath change to get notified of the end of the parser operation to hide the activity indicator
        [self.addUserQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
           }
    return self;
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

- (void)viewDidLoad
{
    if ([self.usernameTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightGrayColor];
        self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter a username" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    [super viewDidLoad];
    
    
   // self.userList=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
   // self.userList.sharedPSC=self.sharedPSC;
    
 //   self.navcontroller=[[UINavigationController alloc]initWithRootViewController:self.userList];

    CGRect  frame=self.view.frame;
  ///  [self.navcontroller.view setFrame:frame];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark -
#pragma mark - KVO
// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.addUserQueue && [keyPath isEqualToString:@"operationCount"]) {
        
        if (self.addUserQueue.operationCount == 0) {
            // [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
            NSLog(@"Done!!!");
            
            [[GCDQueue mainQueue]queueBlock:^{
                [self.delegate LoginSucceeded:self user:[self user:self.usernameTextField.text]];

            }];
        }else
        {
           
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(User*)user:(NSString*)username
{

    NSString   *name=self.usernameTextField.text;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        User *user=[items objectAtIndex:0];
        return user;
    }
    
    return nil;
}
-(void)login:(id)sender
{
    NSString   *name=self.usernameTextField.text;
    if (name.length<1) {
        return;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    if ([items count]==0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"That user does not exist. Try signing up instead"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
        
        
        [[GCDQueue mainQueue]queueBlock:^{
            [alert show];
        }];
        
        return;
    }
    
    self.loggedInUser=[items objectAtIndex:0];
    
    [self.delegate LoginSucceeded:self user:[self user:self.usernameTextField.text]];
  
}

-(void)signup:(id)sender
{
    NSString   *name=self.usernameTextField.text;
    
    if (name.length==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Field has been left blank"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
        
        
        [[GCDQueue mainQueue]queueBlock:^{
            [alert show];
        }];
        
        return;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Sorry, that user already exists"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
        
        
        [[GCDQueue mainQueue]queueBlock:^{
            [alert show];
        }];
        
        return;
    }else
    {
        AddNewUserOperation *addUserOperation =[[AddNewUserOperation alloc]initWithData:self.usernameTextField.text sharedPSC:self.sharedPSC];
        
        [self.addUserQueue addOperation:addUserOperation];
    }
    
    
}

-(IBAction)goToUsersScreen:(id)sender

{
   // self.userList.sharedPSC=self.sharedPSC ;
   // [self.userList getListOfUsers];
  //  [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){

   //     self.userList.sharedPSC=self.sharedPSC;
  //      self.userList.delegate=self;
        
  //  }];


}

-(void)userListDismissRequest:(UserListViewController *)caller
{
    [[GCDQueue mainQueue]queueBlock:^{
    
    
//        [UIView transitionFromView:self.navcontroller.view toView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
            
  //          self.userList.sharedPSC=self.sharedPSC;
  //          self.userList.delegate=self;
            
        }];
    
  ////  }];

}

@end
