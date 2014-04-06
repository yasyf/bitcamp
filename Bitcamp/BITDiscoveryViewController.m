//
//  BITDiscoveryViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITDiscoveryViewController.h"
#import "BITPerson.h"
#import "BITCollectionViewCell.h"

@interface BITDiscoveryViewController ()

    @property NSMutableDictionary *nearby;
    @property NSMutableArray *order;
    @property BITPerson *me;
    @property BOOL isTouching;
    @property BOOL isShowing;

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
            self.me.proximity = 1;
        }
        self.nearby[myIdentifier] = self.me;
        self.order = [NSMutableArray arrayWithArray:@[myIdentifier]];
    }
    
    [self.collectionView reloadData];
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

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (myIdentifier == nil) {
        return;
    }
    NSMutableArray *newTempOrder = [NSMutableArray arrayWithArray:@[@[myIdentifier, @-800]]];
    NSMutableArray *newOrder = [NSMutableArray arrayWithArray:@[myIdentifier]];
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
        else
        {
            person = self.nearby[identifier];
        }
        
        if (person.proximity != beacon.proximity) {
            person.proximity = beacon.proximity;
            changed = YES;
        }
        
        self.nearby[identifier] = person;
        
        NSArray *node = @[identifier, [NSNumber numberWithLong:beacon.rssi]];
        NSUInteger index = [newTempOrder indexOfObject:node inSortedRange:(NSRange){0, [newTempOrder count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSArray* a, NSArray* b){
            NSNumber *one = a[1];
            NSNumber *two = b[1];
            return [one compare:two];
        }];
        [newTempOrder insertObject:node atIndex:index];
        [newOrder insertObject:identifier atIndex:index];
        
        
        
        //NSLog(@"Logged Person %@ (P=%lu)", identifier, person.proximity);
        //NSLog(@"%@", beacon);
        
    }
    if (![newOrder isEqualToArray:self.order] || changed == YES) {
        self.order = newOrder;
        NSUInteger count = [self.order count];
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
    NSLog(@"isTouching: %d", isTouching);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIGestureRecognizer *guestureRecognizer in self.collectionView.gestureRecognizers) {
        guestureRecognizer.cancelsTouchesInView = NO;
        guestureRecognizer.delaysTouchesEnded = NO;
    }
    self.isTouching = NO;
    self.isShowing = NO;
    
    self.nearby = [NSMutableDictionary dictionary];
    self.order = [NSMutableArray array];
    
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
    return 3;
}

- (NSInteger)numberOfItemsBelowSection:(NSInteger)section
{
    NSInteger count = 0;
    
    for (NSString *identifier in self.order) {
        BITPerson *person = self.nearby[identifier];
        if (person.proximity < section + 1) {
            count += 1;
        }
    }
    
    return count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    for (NSString *identifier in self.order) {
        BITPerson *person = self.nearby[identifier];
        if (person.proximity == section + 1) {
            count += 1;
        }
    }
    
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *identifier = [self.order objectAtIndex:([self numberOfItemsBelowSection:indexPath.section] + indexPath.item)];
    BITPerson *person = self.nearby[identifier];
    CGFloat scaleFactor = pow((person.proximity),-.5)*100;
    return CGSizeMake(scaleFactor,scaleFactor);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *identifier = [self.order objectAtIndex:([self numberOfItemsBelowSection:indexPath.section] + indexPath.item)];
    BITPerson *person = self.nearby[identifier];
    BITCollectionViewCell *cell;
    UIImageView *imageView;
    
    if (person.image != nil) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryImageCell" forIndexPath:indexPath];
        imageView = (UIImageView *)[cell viewWithTag:1];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:person.image]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imageView.image = [UIImage imageWithData:data];
            [imageView layoutIfNeeded];
        }];
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryTextCell" forIndexPath:indexPath];
    }
    
    CGFloat heightFactor = .5*(3-person.proximity)*(self.view.frame.size.height - 175);
    CGFloat scaleFactor = pow((person.proximity),-.5)*100.f;
    UIView *view = (UIView *)[cell viewWithTag:10];
    UIButton *button = (UIButton *)[cell viewWithTag:2];
    
    
    if ([person.identifier isEqualToString:self.me.identifier]) {
        button.frame = CGRectMake(0, 0, 80, 80);
        view.layer.borderWidth = 1;
        view.layer.borderColor = [[UIColor colorWithRed:0 green:0.475 blue:1 alpha:1] CGColor]; /*#0079ff*/
        view.frame = CGRectMake(0, 0, 80, 80);
        view.layer.cornerRadius = (80)/2.f + 8;
        [view.layer setMasksToBounds:YES];
        view.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:view.layer.cornerRadius] CGPath];
        if (imageView != nil) {
            imageView.frame = CGRectMake(0, 0, 80, 80);
            imageView.layer.cornerRadius = (80)/2.f + 8;
            [imageView.layer setMasksToBounds:YES];
        }
        cell.center = CGPointMake(self.view.frame.size.width/2.f, self.view.frame.size.height - (80 + 20));
    }
    else {
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
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        cell.center = CGPointMake(((([[numberFormatter numberFromString:person.identifier] intValue] % 3) + 1) * 100) - 150, MAX(heightFactor - 40, 30));
    }
    
    NSMutableString *initials = [NSMutableString string];
    [[person.name componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [initials appendString:[obj substringToIndex:1]];
    }];
    [button setTitle:initials forState:UIControlStateNormal];
    
    [view layoutIfNeeded];
    [cell.contentView layoutIfNeeded];
    
    cell.person = person;
    
    return cell;
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
