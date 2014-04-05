//
//  BITDiscoveryViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITDiscoveryViewController.h"
#import "BITPerson.h"

@interface BITDiscoveryViewController ()

    @property NSMutableDictionary *nearby;
    @property NSMutableArray *order;
    @property BITPerson *me;

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
    
    if (myIdentifier != nil && self.nearby[myIdentifier] == nil) {
        if (self.me == nil) {
            self.me = [BITPerson personWithIdentifier:myIdentifier];
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
    NSMutableArray *newTempOrder = [NSMutableArray arrayWithArray:@[@[myIdentifier, @-1000]]];
    NSMutableArray *newOrder = [NSMutableArray arrayWithArray:@[myIdentifier]];
    for (CLBeacon *beacon in beacons) {
        
        if (beacon.proximity == 0) {
            continue;
        }
        
        NSString *identifier = [NSString stringWithFormat:@"%@", beacon.major];
        
        if (self.nearby[identifier] == nil) {
            BITPerson *person = [BITPerson personWithIdentifier:identifier];
            if (person == nil) {
                continue;
            }
            self.nearby[identifier] = person;
        }
        
        NSArray *node = @[identifier, [NSNumber numberWithLong:beacon.rssi]];
        NSUInteger index = [newTempOrder indexOfObject:node inSortedRange:(NSRange){0, [newTempOrder count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSArray* a, NSArray* b){
            NSNumber *one = a[1];
            NSNumber *two = b[1];
            return [one compare:two];
        }];
        [newTempOrder insertObject:node atIndex:index];
        [newOrder insertObject:identifier atIndex:index];
        
        NSLog(@"Logged Person %@", identifier);
        
    }
    if (![newOrder isEqualToArray:self.order]) {
        self.order = newOrder;
        NSUInteger count = [self.order count];
        if (count > 0) {
            NSLog(@"Reloading (%lu People)", (unsigned long)count);
            [self reloadNearby];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nearby = [NSMutableDictionary dictionary];
    self.order = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNearby) name:@"updateDiscoveryViewController" object:nil];
    
    myIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"identifier"];
    
    [self initBeacon];
    [self turnOnBeacon];
    
    [self initReceiver];
    
    [self reloadNearby];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.order count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *identifier = [self.order objectAtIndex:indexPath.item];
    BITPerson *person = self.nearby[identifier];
    UICollectionViewCell *cell;
    if (person.image != nil) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryImageCell" forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:person.image]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imageView.image = [UIImage imageWithData:data];
        }];
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryTextCell" forIndexPath:indexPath];
    }
    
    UIButton *button = (UIButton *)[cell viewWithTag:2];
    NSMutableString *initials = [NSMutableString string];
    [[person.name componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [initials appendString:[obj substringToIndex:1]];
    }];
    [button setTitle:initials forState:UIControlStateNormal];
    
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
