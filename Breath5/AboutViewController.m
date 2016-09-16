//
//  AboutViewController.m
//  Breath5
//
//  Created by barry on 28/05/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "AboutViewController.h"
#import "UIGlossyButton.h"
@interface AboutViewController ()
-(IBAction)backButtonPressed:(id)sender;
@property(nonatomic,weak)IBOutlet UIGlossyButton  *backButton;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backButton useBlackLabel:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)backButtonPressed:(id)sender
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.delegate exitAboutScreen];

    });

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
