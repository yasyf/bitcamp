//
//  BITPerson.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-05.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITPerson.h"

@implementation BITPerson

static NSMutableDictionary *_people;

+ (BITPerson *)personWithIdentifier:(NSString *)identifier
{
    if (_people == nil) {
        _people = [[NSMutableDictionary alloc] init];
    }
    if ([_people objectForKey:identifier] == nil) {
        NSLog(@"Fetching user %@",identifier);
        BITPerson *p = [[BITPerson alloc] initWithIdentifier:identifier];
        _people[identifier] = p;
    }
    return [_people objectForKey:identifier];
}

- (id)initWithDictionary:(NSDictionary *)person
{
    self = [super init];
    
    if(self){
        self.name = person[@"name"];
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    NSData *json = [NSData dataWithContentsOfURL:url];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:nil];
    return [self initWithDictionary:dict];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    return [self initWithURL:];
}

@end
