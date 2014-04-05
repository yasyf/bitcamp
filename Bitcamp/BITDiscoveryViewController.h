//
//  BITDiscoveryViewController.h
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BITDiscoveryViewController : UICollectionViewController <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *outgoingBeaconRegion;
@property (strong, nonatomic) CLBeaconRegion *incomingBeaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)reloadNearby;

@end