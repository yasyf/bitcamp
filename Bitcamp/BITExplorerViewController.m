//
//  BITExplorerViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-06.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITExplorerViewController.h"
#import "BITOtherPerson.h"
#import "BITOtherCollectionVewCell.h"
#import "BITStorageButton2.h"

#import <AVFoundation/AVFoundation.h>

@interface BITExplorerViewController ()

@property NSMutableDictionary *nearby;
@property NSMutableArray *order;
@property BOOL isTouching;
@property BOOL isShowing;
@property AVCaptureSession* captureSession;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@end

@implementation BITExplorerViewController

static NSString *myIdentifier;
static CLLocationManager *locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)reloadNearby
{
    
    if(self.isTouching == YES){
        return;
    }
    
    float latitude = locationManager.location.coordinate.latitude;
    float longitude = locationManager.location.coordinate.longitude;
    NSURL *source = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.socialradar.com/public/hackathon/users?lat=%f&lon=%f&format=json&radius=10000",latitude, longitude]];
    
    NSData *json = [NSData dataWithContentsOfURL:source];
    NSArray *data = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:nil];
    
    for (NSDictionary *person in data) {
        if (self.nearby[person[@"uid"]] == nil) {
            self.nearby[person[@"uid"]] = [[BITOtherPerson alloc] initWithDictionary:person];
            [self.order addObject:self.nearby[person[@"uid"]]];
        }
    }
    
    [self.collectionView reloadData];
}


- (void)toggleTouches2:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    BOOL isTouching = (BOOL) ([[userInfo objectForKey:@"isTouching"]  isEqual: @1]);
    self.isTouching = isTouching;
    BITOtherPerson *person = userInfo[@"person"];
    NSLog(@"isTouching: %@", person.first_name);
    [self showDetailsForPerson:person];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error = nil;
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.captureSession addInput:input];
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        UIView *view = self.videoView;
        [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        CALayer *viewLayer = [view layer];
        previewLayer.frame = view.bounds;
        [viewLayer setMasksToBounds:YES];
        [previewLayer setFrame:[viewLayer bounds]];
        [viewLayer addSublayer:previewLayer];
        [self.captureSession startRunning];
    });
    
    for (UIGestureRecognizer *guestureRecognizer in self.collectionView.gestureRecognizers) {
        guestureRecognizer.cancelsTouchesInView = NO;
        guestureRecognizer.delaysTouchesEnded = NO;
    }
    self.isTouching = NO;
    self.isShowing = NO;
    
    self.nearby = [NSMutableDictionary dictionary];
    self.order = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNearby) name:@"updateDiscoveryViewController" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleTouches2:) name:@"toggleTouches2" object:nil];
    
    myIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"identifier"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
    [self reloadNearby];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.order count] / 3;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat scaleFactor = pow((indexPath.section+1),-.5)*100;
    return CGSizeMake(scaleFactor,scaleFactor);
}

- (void)showDetailsForPerson:person
{
    [self performSegueWithIdentifier:@"detailSegue2" sender:person];
}

- (void)showDetailsForButton:button event:event
{
    BITOtherCollectionVewCell *viewCell = (BITOtherCollectionVewCell *)[[button superview] superview];
    [self performSegueWithIdentifier:@"detailSegue2" sender:viewCell.person];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BITOtherPerson *person = [self.order objectAtIndex:((indexPath.section)*([self.order count] / 3) + indexPath.item)];
    BITOtherCollectionVewCell *cell;
    UIImageView *imageView;
    
    CGFloat heightFactor = .5*(3-indexPath.section)*(self.view.frame.size.height - 175);
    CGFloat scaleFactor = pow((indexPath.section),-.5)*100.f;
    BITOtherCollectionVewCell *view = (BITOtherCollectionVewCell *)[cell viewWithTag:10];
    BITStorageButton2 *button = (BITStorageButton2 *)[cell viewWithTag:2];
    
    
    if (person.picture != nil) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"exploreImageCell" forIndexPath:indexPath];
        imageView = (UIImageView *)[cell viewWithTag:1];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:person.picture]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imageView.image = [UIImage imageWithData:data];
            [imageView layoutIfNeeded];
        }];
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"exploreTextCell" forIndexPath:indexPath];
    }
   
    
    

    button.frame = CGRectMake(0, 0, scaleFactor, scaleFactor);
    view.frame = CGRectMake(0, 0, scaleFactor, scaleFactor);
    view.layer.cornerRadius = scaleFactor/2.f;
    [view.layer setMasksToBounds:YES];
    view.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius] CGPath];
    if (imageView != nil) {
        imageView.frame = CGRectMake(0, 0, scaleFactor, scaleFactor);
        imageView.layer.cornerRadius = scaleFactor/2.f + 5;
        [imageView.layer setMasksToBounds:YES];
    }
    cell.center = CGPointMake((((indexPath.section % 3) + 1) * 100) - 150, MAX(heightFactor - 40, 30));

    NSMutableString *initials = [NSMutableString string];
    [[[NSString stringWithFormat:@"%@ %@", person.first_name, person.last_name] componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [initials appendString:[obj substringToIndex:1]];
    }];
    [button setTitle:initials forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showDetailsForButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    [view layoutIfNeeded];
    [cell.contentView layoutIfNeeded];
    
    cell.person = person;
    view.person = person;
    button.person = person;
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue2"]) {
        BITOtherCollectionVewCell *dest = segue.destinationViewController;
        dest.person = sender;
    }
}


@end
