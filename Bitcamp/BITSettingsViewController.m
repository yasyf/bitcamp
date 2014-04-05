//
//  BITSettingsViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITSettingsViewController.h"
#import "BITPerson.h"
#import "BITMainViewController.h"
#import "BITDiscoveryViewController.h"

@interface BITSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property UIImage *image;

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

#pragma mark - UIImagePickerController Delegate

- (IBAction)didClickImageButton:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didClickSaveButton:nil];
    return YES;
}

- (IBAction)didClickSaveButton:(UIButton *)sender {
    
    BOOL valid = YES;
    
    self.nameField.layer.borderColor = [[UIColor blueColor] CGColor];
    self.nameField.layer.borderWidth = 1;
    
    if (self.nameField.text.length < 3) {
        self.nameField.layer.borderColor = [[UIColor redColor] CGColor];
        valid = NO;
    }
    
    if (valid == YES) {
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:self.nameField.text, @"name", self.image, @"imageData", nil];
        BITPerson *user = [[BITPerson alloc] initWithDictionary:data];
        NSString *identifier = [user save];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:identifier forKey:@"identifier"];
        [userDefaults synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDiscoveryViewController" object:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
