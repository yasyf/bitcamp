//
//  BITCollectionCell.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-08.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITCollectionCell.h"

@implementation BITCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@1, @"isTouching", self.person, @"person", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleTouches" object:self userInfo:userInfo];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@0, @"isTouching", self.person, @"person", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleTouches" object:self userInfo:userInfo];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
