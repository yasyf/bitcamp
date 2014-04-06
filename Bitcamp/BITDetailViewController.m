//
//  BITDetailViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-06.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITDetailViewController.h"

@interface BITDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *homepageLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@end

@implementation BITDetailViewController

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
    if (self.person != nil) {
        self.nameLabel.text = self.person.name;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.person.image]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            self.imageView.frame = CGRectMake(self.view.frame.size.width/2 - self.imageView.frame.size.height/2, self.view.frame.size.height/2 + 1.2*self.imageView.frame.size.height, self.imageView.frame.size.height, self.imageView.frame.size.height);
            self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2.f;
            [self.imageView.layer setMasksToBounds:YES];
            self.imageView.image = [UIImage imageWithData:data];
            self.homepageLabel.text = self.person.homepage;
            self.emailLabel.text = self.person.email;
            if (self.person.facebook_id != nil) {
                [self.facebookButton setEnabled:YES];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneButtonDidClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)facebookButtonDidClick:(id)sender {
    if (self.facebookButton.isEnabled) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/%@",self.person.facebook_id]]];
    }
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

@end
