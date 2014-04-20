//
//  ImageQueryResponse.h
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TumblrAPIImage.h"
@interface TumblrImageQueryResponse : NSObject

/**
 * TumblrAPIImage
 */
@property (nonatomic, copy) NSArray *images;

/**
 * 全ポスト数
 */
@property (nonatomic, assign) int total_posts;

/**
 * このクエリに使われたオフセット
 */
@property (nonatomic, assign) int offset;
@end
