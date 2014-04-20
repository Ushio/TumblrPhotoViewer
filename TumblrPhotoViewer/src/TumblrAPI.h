//
//  TumblrAPI.h
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TumblrImageQueryResponse.h"

static const int TUMBLR_PAGING_COUNT = 20;

@interface TumblrAPI : NSObject
/**
 * @param blogname ブログ名
 */
+ (TumblrImageQueryResponse *)imageQueryWithBlogname:(NSString *)blogname offset:(int)offset;
@end
