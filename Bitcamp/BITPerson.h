//
//  BITPerson.h
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-05.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BITPerson : NSObject

@property NSString *identifier;
@property NSInteger proximity;
@property NSString *name;
@property NSString *image;
@property NSString *homepage;
@property NSString *email;
@property NSString *facebook_id;

+ (BITPerson *)personWithIdentifier:(NSString *)identifier;

- (id)initWithDictionary:(NSDictionary *)person;

- (NSString *)save;

@end
