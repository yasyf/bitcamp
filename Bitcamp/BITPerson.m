//
//  BITPerson.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-05.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITPerson.h"

@interface BITPerson()

@property UIImage *imageData;

@end

@implementation BITPerson

static NSMutableDictionary *_people;
static const NSString *endpoint = @"http://bitcamp.herokuapp.com";

+ (BITPerson *)personWithIdentifier:(NSString *)identifier
{
    if (_people == nil) {
        _people = [[NSMutableDictionary alloc] init];
    }
    if ([_people objectForKey:identifier] == nil) {
        NSLog(@"Fetching user %@",identifier);
        BITPerson *p = [[BITPerson alloc] initWithIdentifier:identifier];
        if (p == nil) {
            _people[identifier] = [NSNull null];
        }
        else{
            _people[identifier] = p;
        }
        
    }
    
    if ([[_people objectForKey:identifier] class] == [NSNull class]) {
        return nil;
    }
    else {
        return [_people objectForKey:identifier];
    }
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

- (NSString *)saveImage
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/photo/%@.json", endpoint, self.identifier]]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageData, 1.0);
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", self.identifier] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:nil];
    return dict[@"url"];
    
}

- (id)initWithDictionary:(NSDictionary *)person
{
    self = [super init];
    
    if(self){
        self.name = person[@"name"];
        self.identifier = person[@"_id"];
        self.image = person[@"image"];
        self.imageData = person[@"imageData"];
        self.email = person[@"email"];
        self.homepage = person[@"homepage"];
        self.facebook_id = person[@"facebook_id"];
        self.seen = NO;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    NSData *json = [NSData dataWithContentsOfURL:url];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:nil];
    if ([dict[@"status"] isEqualToString:@"error"]) {
        return nil;
    }
    return [self initWithDictionary:dict];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    return [self initWithURL:[BITPerson URLWithIdentifier:identifier method:@"GET"]];
}

- (NSString *)save
{
    if (self.identifier == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.identifier = [userDefaults stringForKey:@"identifier"];
        if (self.identifier == nil) {
            NSData *identifierData = [NSData dataWithContentsOfURL:[BITPerson URLWithIdentifier:nil method:@"CREATE"]];
            NSDictionary *newUser = [NSJSONSerialization JSONObjectWithData:identifierData options:NSJSONReadingMutableContainers error:nil];
            self.identifier = newUser[@"userid"];
        }
    }
    if (self.imageData != nil) {
        self.image = [self saveImage];
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.name, @"name", nil];
    if (self.facebook_id != nil) {
        data[@"facebook_id"] = self.facebook_id;
    }
    if (self.email != nil) {
        data[@"email"] = self.email;
    }
    if (self.homepage != nil) {
        data[@"homepage"] = self.homepage;
    }
    if (self.image != nil) {
        data[@"image"] = self.image;
    }
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString *update = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSURL *url = [BITPerson URLWithIdentifier:self.identifier method:@"SET" data:[BITPerson escapeURIComponent:update]];
    
    NSData *response = [NSData dataWithContentsOfURL:url];
    NSLog(@"%@", response);
    
    return self.identifier;
    
}

@end
