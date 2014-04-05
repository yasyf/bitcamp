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
static const NSString *endpoint = @"http://0.0.0.0:5000";

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

+ (NSURL *)URLWithIdentifier:(NSString *)identifier method:(NSString *)method
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/%@.json?method=%@", endpoint, identifier, method]];
    NSLog(@"%@", url);
    return url;
}

+ (NSURL *)URLWithIdentifier:(NSString *)identifier method:(NSString *)method data:(NSString *)data
{
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@.json?method=%@&data=%@", endpoint, identifier, method, data];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"%@", url);
    return url;
}

+ (NSString *)escapeURIComponent:(NSString *)component
{
    return [component stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (id)initWithDictionary:(NSDictionary *)person
{
    self = [super init];
    
    if(self){
        self.name = person[@"name"];
        self.identifier = person[@"_id"];
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
    return [self initWithURL:[BITPerson URLWithIdentifier:identifier method:@"GET"]];
}

- (NSString *)save
{
    if (self.identifier == nil) {
        NSData *identifierData = [NSData dataWithContentsOfURL:[BITPerson URLWithIdentifier:nil method:@"CREATE"]];
        NSDictionary *newUser = [NSJSONSerialization JSONObjectWithData:identifierData options:NSJSONReadingMutableContainers error:nil];
        self.identifier = newUser[@"userid"];
        
    }
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:self.name, @"name", nil];
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString *update = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSURL *url = [BITPerson URLWithIdentifier:self.identifier method:@"SET" data:[BITPerson escapeURIComponent:update]];
    
    NSData *response = [NSData dataWithContentsOfURL:url];
    NSLog(@"%@", response);
    
    return self.identifier;
    
}

@end
