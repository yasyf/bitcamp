//
//  BITSettingsViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BITSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation BITSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)didClickSaveButton:(UIButton *)sender {
    
    BOOL valid = YES;
    
    self.nameField.layer.borderColor = [[UIColor blueColor] CGColor];
    self.nameField.layer.borderWidth = 1;
    
    if (self.nameField.text.length < 3) {
        self.nameField.layer.borderColor = [[UIColor redColor] CGColor];
        valid = NO;
    }
    
    if (valid == YES) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.nameField.text forKey:@"name"];
        [userDefaults synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
