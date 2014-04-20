//
//  TumblrImageViewCell.h
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TumblrAPIImage.h"
@interface TumblrImageViewCell : UICollectionViewCell
@property (nonatomic, strong) TumblrAPIImage *tumblrAPIImage;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@end
