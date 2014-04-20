//
//  WAMCGImage.h
//  WAMCamera
//
//  Created by yoshimura atsushi on 2014/03/14.
//  Copyright (c) 2014年 wow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CGImageWrapper : NSObject
- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithCGImage:(CGImageRef)image;

- (CGImageRef)CGImage;

/**
 * 圧縮状態のCGImageRefを解凍状態のCGImageRefに展開して返します。
 * 元々展開状態であった場合でも処理するため、その場合はCPUリソースが無駄になります。
 */
- (instancetype)rasterized;
@end
