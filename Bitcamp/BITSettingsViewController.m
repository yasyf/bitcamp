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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *homepageField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [userDefaults stringForKey:@"identifier"];
    if (identifier != nil) {
        BITPerson *person = [BITPerson personWithIdentifier:identifier];
        self.nameField.text = person.name;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:person.image]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            self.imageView.frame = CGRectMake(self.view.frame.size.width/2 - self.imageView.frame.size.height/2, self.view.frame.size.height/2 + 1.2*self.imageView.frame.size.height, self.imageView.frame.size.height, self.imageView.frame.size.height);
            self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.f;
            [self.imageView.layer setMasksToBounds:YES];
            self.imageView.image = [UIImage imageWithData:data];
            self.homepageField.text = person.homepage;
            self.emailField.text = person.email;
        }];
    }
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email"]];
    loginView.delegate = self;
    loginView.frame = CGRectOffset(loginView.frame,  (self.view.center.x - (loginView.frame.size.width / 2)), self.view.frame.size.height/2);
    [self.view addSubview:loginView];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return wasHandled;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [userDefaults stringForKey:@"identifier"];
    
    [[FBRequest requestForMe] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error)
    {
        NSString *image = [NSString string];
        if (error) {
            image = nil;
        }
        
        else {
            image = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser username]];
        }
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:identifier, @"_id", [user objectForKey:@"name"], @"name", nil];
        if ([user objectForKey:@"link"] != nil) {
            data[@"homepage"] = [user objectForKey:@"link"];
        }
        if ([user objectForKey:@"link"] != nil) {
            data[@"email"] = [user objectForKey:@"email"];
        }
        if ([user objectForKey:@"link"] != nil) {
            data[@"facebook_id"] = [user objectForKey:@"id"];
        }
        if (image != nil) {
            data[@"image"] = image;
        }
        
        BITPerson *person = [[BITPerson alloc] initWithDictionary:data];
        NSString *identifier1 = [person save];
        
        [userDefaults setObject:identifier1 forKey:@"identifier"];
        [userDefaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDiscoveryViewController" object:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
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
    self.imageView.image = self.image;
    
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

- (IBAction)didClickSaveButton:(UIBarButtonItem *)sender {
    
    BOOL valid = YES;
    
    self.nameField.layer.borderColor = [[UIColor blueColor] CGColor];
    self.nameField.layer.borderWidth = 1;
    
    if (self.nameField.text.length < 3) {
        self.nameField.layer.borderColor = [[UIColor redColor] CGColor];
        valid = NO;
    }
    
    if (valid == YES) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *identifier1 = [userDefaults stringForKey:@"identifier"];
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:identifier1, @"_id",self.nameField.text, @"name", nil];
        if (self.homepageField.text != nil) {
            data[@"homepage"] = self.homepageField.text;
        }
        if (self.emailField.text != nil) {
            data[@"email"] = self.emailField.text;
        }
        if (self.image != nil) {
            data[@"imageData"] = self.image;
        }
        
        BITPerson *user = [[BITPerson alloc] initWithDictionary:data];
        NSString *identifier = [user save];
        
        [userDefaults setObject:identifier forKey:@"identifier"];
        [userDefaults synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDiscoveryViewController" object:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    }
}

@end
