//
//  BITNullPerson.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-08.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITNullPerson.h"

@implementation BITNullPerson

- (BITNullPerson *)init
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"-1", @"_id", @"", @"name", nil];
    self = [super initWithDictionary:data];
    return self;
}

@end
