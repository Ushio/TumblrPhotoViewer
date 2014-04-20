//
//  USTViewController.m
//  TumblrPhotoViewer
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "USTViewController.h"

#import "TumblrViewController.h"

@implementation USTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TumblrViewController *tumblrViewController = [[TumblrViewController alloc] initWithNibName:@"TumblrViewController"
                                                                                        bundle:[NSBundle mainBundle]];
    
    tumblrViewController.view.frame = self.view.bounds;
    [self.view addSubview:tumblrViewController.view];
    [self addChildViewController:tumblrViewController];
}


@end
