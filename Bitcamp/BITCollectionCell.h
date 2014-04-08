//
//  BITCollectionCell.h
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-08.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BITPerson.h"

@interface BITCollectionCell : UICollectionViewCell

@property BITPerson *person;
@property (weak, nonatomic) IBOutlet UIButton *button;


@end
