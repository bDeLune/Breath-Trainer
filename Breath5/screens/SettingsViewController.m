//
//  SettingsViewController.m
//  Breath5
//
//  Created by barry on 16/04/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,weak)IBOutlet UILabel  *windValueLabel;
@property(nonatomic,weak)IBOutlet UISlider  *windSlider;
@property(nonatomic,weak)IBOutlet UIButton  *backButton;



-(IBAction)backButtonHit:(id)sender;
-(IBAction)changeWind:(id)sender;
@end

@implementation SettingsViewController

-(IBAction)backButtonHit:(id)sender
{
   // [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate settingDidFinish:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    float gravity=[[[NSUserDefaults standardUserDefaults]valueForKey:@"gravity"]floatValue];
    //float angle=[[[NSUserDefaults standardUserDefaults]valueForKey:@"angle"]floatValue];
    
    //int difficulty=[[[NSUserDefaults standardUserDefaults]valueForKey:@"difficulty"]intValue];
    
    self.windSlider.value=gravity;
    [self changeWind:nil];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction)changeAngle:(id)sender
{
    /*self.angleValueLabel.text=[NSString stringWithFormat:@"%0.1f",self.angleSlider.value*45];
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithFloat:self.angleSlider.value] forKey:@"angle"];
    [[NSUserDefaults standardUserDefaults]synchronize];*/

}
-(IBAction)changeWind:(id)sender
{
    self.windValueLabel.text=[NSString stringWithFormat:@"%0.1f",self.windSlider.value];
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithFloat:self.windSlider.value] forKey:@"gravity"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}
-(IBAction)changeDifficulty:(id)sender
{}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    int selectrow=(int)row;
    selectrow++;//to match enum
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:selectrow] forKey:@"difficulty"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 3;
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    
    switch (row) {
        case 0:
            title=@"Easy";
            break;
        case 1:
            title=@"Medium";

            break;
        case 2:
            title=@"Hard";

            break;
            
        default:
            break;
    }
    
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}
@end
