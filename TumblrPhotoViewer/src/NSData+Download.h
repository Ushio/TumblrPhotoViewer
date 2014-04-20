//
//  NSData+Download.h
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Download)
/**
 * ファイルをダウンロードします。
 * この操作はメインスレッドから行うことは出来ません。
 */
+ (NSData *)dataWithDownloadURL:(NSURL *)downloadURL progressHandler:(void(^)(double))progressHandler;
@end
