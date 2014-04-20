//
//  TumblrAPIImage.h
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 画像のURL情報をまとめる
 */
@interface TumblrAPIImage : NSObject
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic, strong) NSURL *thumbnailURL;
@end
