//
//  WAMCGImage.m
//  WAMCamera
//
//  Created by yoshimura atsushi on 2014/03/14.
//  Copyright (c) 2014年 wow. All rights reserved.
//

#import "CGImageWrapper.h"
#import <ImageIO/ImageIO.h>

static void bufferFree(void *info, const void *data, size_t size)
{
    free((void *)data);
}
static size_t align16(size_t size)
{
    if(size == 0)
        return 0;
    
    return (((size - 1) >> 4) << 4) + 16;
}

@implementation CGImageWrapper
{
    CGImageRef _image;
}
- (instancetype)initWithData:(NSData *)data
{
    if(self = [super init])
    {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        if(imageSource == nil)
        {
            return nil;
        }
        if(CGImageSourceGetCount(imageSource) == 0)
        {
            CFRelease(imageSource);
            return nil;
        }
        
        _image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
        if(_image == nil)
        {
            CFRelease(imageSource);
            return nil;
        }
        CFRelease(imageSource);
        imageSource = NULL;
    }
    return self;
}
- (instancetype)initWithContentsOfFile:(NSString *)path
{
    if(self = [super init])
    {
        NSURL *imageURL = [NSURL fileURLWithPath:path];
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, nil);
        if(imageSource == nil)
        {
            return nil;
        }
        if(CGImageSourceGetCount(imageSource) == 0)
        {
            CFRelease(imageSource);
            return nil;
        }
        _image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
        if(_image == nil)
        {
            CFRelease(imageSource);
            return nil;
        }
        CFRelease(imageSource);
        imageSource = NULL;
    }
    return self;
}
- (id)initWithCGImage:(CGImageRef)image
{
    if(self = [super init])
    {
        NSAssert(image, @"");
        _image = CGImageRetain(image);
    }
    return self;
}
- (void)dealloc
{
    NSAssert(_image, @"");
    CGImageRelease(_image);
}
- (CGImageRef)CGImage
{
    return _image;
}

- (instancetype)rasterized
{
    CGImageRef srcImage = _image;
    size_t width = CGImageGetWidth(srcImage);
    size_t height = CGImageGetHeight(srcImage);
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = align16(4 * width);
    size_t bytesSize = bytesPerRow * height;
    uint8_t *bytes = malloc(bytesSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(bytes, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), srcImage);
    
    CGContextRelease(context);
    context = NULL;
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, bytes, bytesSize, bufferFree);
    size_t bitsPerPixel = 32;
    CGImageRef dstImage = CGImageCreate(width,
                                        height,
                                        bitsPerComponent,
                                        bitsPerPixel,
                                        bytesPerRow,
                                        colorSpace,
                                        kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst,
                                        dataProvider,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    dataProvider = NULL;
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    CGImageWrapper *rasterizedImage = [[CGImageWrapper alloc] initWithCGImage:dstImage];
    CGImageRelease(dstImage);
    return rasterizedImage;
}
@end
