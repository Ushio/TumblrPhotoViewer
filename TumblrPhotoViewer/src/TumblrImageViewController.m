//
//  TumblrImageViewController.m
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "TumblrImageViewController.h"

#import "MBProgressHUD.h"
#import "NSData+Download.h"

@implementation TumblrImageViewController
{
    IBOutlet UIImageView *_imageView;
    NSURL *_imageURL;
    NSOperationQueue *_helperQueue;
}
- (instancetype)initWithImageURL:(NSURL *)imageURL
{
    if(self = [super initWithNibName:@"TumblrImageViewController"
                              bundle:[NSBundle mainBundle]])
    {
        _imageURL = imageURL;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _helperQueue = [[NSOperationQueue alloc] init];
    _helperQueue.maxConcurrentOperationCount = 1;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    [_helperQueue addOperationWithBlock:^{
        NSData *imageData = [NSData dataWithDownloadURL:_imageURL progressHandler:^(double progress) {
            hud.progress = progress;
        }];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _imageView.image = [UIImage imageWithData:imageData];
            
            [hud hide:YES];
        }];
    }];
}
- (IBAction)didSelectedFinish:(id)sender
{
    [self.delegate tumblrImageViewControllerDidFinished:self];
}
@end
