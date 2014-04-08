//
//  BITDiscoveryViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITDiscoveryViewController.h"
#import "BITPerson.h"
#import "BITNullPerson.h"
#import "BITCollectionCell.h"

#import <AVFoundation/AVFoundation.h>

@interface BITDiscoveryViewController ()

    @property NSMutableDictionary *nearby;
    @property NSMutableDictionary *order;
    @property BITPerson *me;
    @property BOOL isTouching;
    @property BOOL isShowing;
    @property AVCaptureSession* captureSession;
    @property (weak, nonatomic) IBOutlet UIView *videoView;

@end
    
@implementation BITDiscoveryViewController

static NSString *UUIDString = @"432B078C-3E31-4B80-849D-177EA587C10E";
static NSString *UUIDIdentifier = @"com.yasyf.bitcampBeaconRegion";
static NSString *myIdentifier;

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
    
    if (myIdentifier != nil && self.nearby[myIdentifier] == nil) {
        if (self.me == nil) {
            self.me = [BITPerson personWithIdentifier:myIdentifier];
            self.me.proximity = 3;
        }
        self.nearby[myIdentifier] = self.me;
        self.order = [self baseArrayWithWidth:3];
        self.order[@3][0] = myIdentifier;
    }
    
    if (self.nearby[@"-1"] == nil) {
        self.nearby[@"-1"] = [[BITNullPerson alloc] init];
    }
    
    [self.collectionView reloadData];
    
    if ([self.order[@3] count] > 1) {
        BITPerson *person = (BITPerson *)self.nearby[self.order[@3][1]];
        if (person.proximity == 1 && person.seen == NO) {
            //[self showDetailsForPerson:person];
        }
    }
}

- (void)initBeacon
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:UUIDString];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.outgoingBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[[numberFormatter numberFromString:self.me.identifier] unsignedShortValue] identifier:UUIDIdentifier];
}

- (void)turnOnBeacon
{
    self.beaconPeripheralData = [self.outgoingBeaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Beacon Now On");
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        NSLog(@"Beacon Now Off");
        [self.peripheralManager stopAdvertising];
    }
}

- (void)initReceiver
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:UUIDString];
    self.incomingBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:UUIDIdentifier];
    [self.locationManager startMonitoringForRegion:self.incomingBeaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.incomingBeaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.incomingBeaconRegion];
}

- (NSMutableDictionary *)baseArrayWithWidth:(NSInteger)width
{
    NSMutableDictionary *baseArray = [NSMutableDictionary dictionaryWithDictionary:@{@3: [NSMutableArray array], @2: [NSMutableArray array], @1: [NSMutableArray array]}];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < width; j++) {
            baseArray[[NSNumber numberWithInt:i+1]][j] = @"-1";
        }
    }
    return baseArray;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (myIdentifier == nil) {
        return;
    }
    NSMutableDictionary *newTempOrder = [NSMutableDictionary dictionaryWithDictionary:@{@3: [NSMutableArray array], @2: [NSMutableArray array], @1: [NSMutableArray array]}];
    newTempOrder[@3][0] = [NSMutableArray arrayWithArray:@[myIdentifier, @-800]];
    
    NSMutableDictionary *newOrder = [self baseArrayWithWidth:3];
    newOrder[@3][0] = myIdentifier;
    BOOL changed = NO;
    for (CLBeacon *beacon in beacons) {
        
        if (beacon.proximity == 0) {
            continue;
        }
        
        NSString *identifier = [NSString stringWithFormat:@"%@", beacon.major];
        
        BITPerson *person;
        
        if (self.nearby[identifier] == nil) {
            person = [BITPerson personWithIdentifier:identifier];
            if (person == nil) {
                continue;
            }
        }
        
        else {
            person = self.nearby[identifier];
        }
        
        if (person.proximity != (4-beacon.proximity)) {
            person.proximity = (4-beacon.proximity);
            changed = YES;
        }
        
        self.nearby[identifier] = person;
        
        NSArray *node = @[identifier, [NSNumber numberWithLong:beacon.rssi]];
        NSUInteger index = [newTempOrder[[NSNumber numberWithInteger:person.proximity]] indexOfObject:node inSortedRange:(NSRange){0, [newTempOrder[[NSNumber numberWithInteger:person.proximity]] count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSArray* a, NSArray* b){
            NSNumber *one = a[1];
            NSNumber *two = b[1];
            return [one compare:two];
        }];
        [newTempOrder[[NSNumber numberWithInteger:person.proximity]] insertObject:node atIndex:index];
        [newOrder[[NSNumber numberWithInteger:person.proximity]] insertObject:identifier atIndex:index];
        
        
        
        NSLog(@"Logged Person %@ (P=%lu)", identifier, person.proximity);
        //NSLog(@"%@", beacon);
        
    }
    if (changed == YES || ![newOrder isEqualToDictionary:self.order]) {
        self.order = newOrder;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != '-1'"];
        NSUInteger count = [[self.order[@0] filteredArrayUsingPredicate:predicate] count] + [[self.order[@1] filteredArrayUsingPredicate:predicate] count] + [[self.order[@2] filteredArrayUsingPredicate:predicate] count];
        [[[[[self tabBarController] tabBar] items]
          objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%lu",count]];
        if (count > 0) {
            NSLog(@"Reloading (%lu People)", (unsigned long)count);
            [self reloadNearby];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.incomingBeaconRegion];
}

- (void)toggleTouches:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    BOOL isTouching = (BOOL) ([[userInfo objectForKey:@"isTouching"]  isEqual: @1]);
    self.isTouching = isTouching;
    BITPerson *person = userInfo[@"person"];
    NSLog(@"isTouching: %@", person.name);
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
    self.order = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNearby) name:@"updateDiscoveryViewController" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleTouches:) name:@"toggleTouches" object:nil];
    
    myIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"identifier"];
    
    [self initBeacon];
    [self turnOnBeacon];
    
    [self initReceiver];
    
    [self reloadNearby];
        
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.incomingBeaconRegion];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}


- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return [self.order[[NSNumber numberWithInteger:section]] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}


//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSNumber *identifier = self.order[[NSNumber numberWithInteger:indexPath.section]][indexPath.item];
//    BITPerson *person = self.nearby[identifier];
//    CGFloat scaleFactor = pow((4-person.proximity),-.5)*100;
//    return CGSizeMake(scaleFactor,scaleFactor);
//}


- (void)showDetailsForPerson:person
{
    [self performSegueWithIdentifier:@"detailSegue" sender:person];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *identifier = self.order[[NSNumber numberWithInteger:indexPath.section]][indexPath.item];
    BITPerson *person = self.nearby[identifier];
    BITCollectionCell *cell;
    UIImageView *imageView;
    
    CGFloat scaleFactor = pow(4-indexPath.section,-.5)*100.f;
    
    if ([person.identifier isEqual: @"-1"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryTextCell" forIndexPath:indexPath];
        UIButton *button = cell.button;
        [button setTitle:@"JEDGIG" forState:UIControlStateNormal];
    }
    
    else {
        if (person.image != nil) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryImageCell" forIndexPath:indexPath];
            UIButton *button = cell.button;
            imageView = (UIImageView *)[cell viewWithTag:1];
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:person.image]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                imageView.image = [UIImage imageWithData:data];
                [imageView layoutIfNeeded];
            }];
        }
        else{
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryTextCell" forIndexPath:indexPath];
        }
        
     
        
        
//        if ([person.identifier isEqualToString:self.me.identifier]) {
//            view.layer.borderWidth = 1;
//            view.layer.borderColor = [[UIColor colorWithRed:0 green:0.475 blue:1 alpha:1] CGColor]; /*#0079ff*/
//            view.layer.cornerRadius = (80)/2.f + 8;
//            [view.layer setMasksToBounds:YES];
//            view.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius] CGPath];
//            if (imageView != nil) {
//                imageView.layer.cornerRadius = (80)/2.f + 8;
//                [imageView.layer setMasksToBounds:YES];
//            }
//        }
//        else {
//            view.layer.cornerRadius = scaleFactor/2.f;
//            [view.layer setMasksToBounds:YES];
//            view.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius] CGPath];
//            if (imageView != nil) {
//                imageView.layer.cornerRadius = scaleFactor/2.f + 5;
//                [imageView.layer setMasksToBounds:YES];
//            }
//        }
        

        
        [cell.contentView layoutIfNeeded];
        
        cell.person = person;
        
        //NSLog(@"%@ at (%lu, %lu)", person.name, indexPath.section, indexPath.item);
    }
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        BITCollectionCell *dest = segue.destinationViewController;
        dest.person = sender;
    }
}


@end
