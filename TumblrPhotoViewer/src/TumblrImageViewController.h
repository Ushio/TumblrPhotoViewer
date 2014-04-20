//
//  TumblrImageViewController.h
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TumblrImageViewController;
@protocol TumblrImageViewControllerDelegate <NSObject>
- (void)tumblrImageViewControllerDidFinished:(TumblrImageViewController *)viewController;
@end

@interface TumblrImageViewController : UIViewController
- (instancetype)initWithImageURL:(NSURL *)imageURL;
@property (nonatomic, weak) id<TumblrImageViewControllerDelegate> delegate;
@end
