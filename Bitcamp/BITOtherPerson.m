//
//  BITOtherPerson.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-06.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITOtherPerson.h"

@implementation BITOtherPerson

- (id)initWithDictionary:(NSDictionary *)person
{
    self = [super init];
    
    if(self){
        self.uid = person[@"uid"];
        self.location_updated_on = person[@"location_updated_on"];
        self.distance = person[@"distance"];
        self.first_name = person[@"first_name"];
        self.last_name = person[@"last_name"];
        self.age = person[@"age"];
        self.gender = person[@"gender"];
        self.picture = person[@"picture"];
    }
    
    return self;
}



@end
