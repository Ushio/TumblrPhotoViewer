//
//  NSString+application_x_www_form_urlencoded.m
//  TwitterVideo
//
//  Created by yoshimura atsushi on 2014/01/28.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncodeRFC3986)
- (NSString *)stringByURLEncode
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8);
}
@end
