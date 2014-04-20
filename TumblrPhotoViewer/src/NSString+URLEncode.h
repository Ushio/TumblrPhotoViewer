//
//  NSString+application_x_www_form_urlencoded.h
//  TwitterVideo
//
//  Created by yoshimura atsushi on 2014/01/28.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncodeRFC3986)
- (NSString *)stringByURLEncode;
@end
