//
//  BITDiscoveryViewController.m
//  Bitcamp
//
//  Created by Yasyf Mohamedali on 2014-04-04.
//  Copyright (c) 2014 Yasyf Mohamedali. All rights reserved.
//

#import "BITDiscoveryViewController.h"
#import "BITPerson.h"

@interface BITDiscoveryViewController ()
  @property NSMutableDictionary *nearby;

@end

@implementation BITDiscoveryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)reloadNearby
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"identifier"];
    if (identifier != nil && self.nearby[identifier] == nil) {
        BITPerson *me = [BITPerson personWithIdentifier:identifier];
        self.nearby[identifier] = me;
    }
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nearby = [NSMutableDictionary dictionary];
    
    [self reloadNearby];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNearby) name:@"updateDiscoveryViewController" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.nearby count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BITPerson *person = [[self.nearby allValues] objectAtIndex:indexPath.row];
    UICollectionViewCell *cell;
    if (person.image != nil) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryImageCell" forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:person.image]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imageView.image = [UIImage imageWithData:data];
        }];
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"discoveryTextCell" forIndexPath:indexPath];
    }
    
    UIButton *button = (UIButton *)[cell viewWithTag:2];
    NSMutableString *initials = [NSMutableString string];
    [[person.name componentsSeparatedByString:@" "] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [initials appendString:[obj substringToIndex:1]];
    }];
    [button setTitle:initials forState:UIControlStateNormal];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
