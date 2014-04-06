//
//  BITOtherPerson.h
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-06.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BITOtherPerson : NSObject

@property NSString *uid;
@property NSNumber *location_updated_on;
@property NSNumber *distance;
@property NSString *first_name;
@property NSString *last_name;
@property NSNumber *age;
@property NSString *gender;
@property NSString *picture;

- (id)initWithDictionary:(NSDictionary *)person;

@end
