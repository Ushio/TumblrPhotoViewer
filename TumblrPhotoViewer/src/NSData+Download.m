//
//  NSData+Download.m
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "NSData+Download.h"

@interface DownloadHandler : NSObject<NSURLConnectionDelegate>
@property (nonatomic, copy) void (^progressHandler)(double);
@property (nonatomic, copy) void (^errorHandler)();
@property (nonatomic, copy) void (^completionHandler)(NSData *);
- (NSData *)data;
@end
@implementation DownloadHandler
{
    int _expect;
    NSMutableData *_data;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _expect = (int)[response expectedContentLength];
	_data = [[NSMutableData alloc] initWithCapacity:_expect];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    self.progressHandler((double)_data.length / (double)_expect);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.completionHandler(_data);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.errorHandler();
}
- (NSData *)data
{
    return _data;
}
@end

@implementation NSData (Download)
+ (NSData *)dataWithDownloadURL:(NSURL *)downloadURL progressHandler:(void(^)(double))progressHandler
{
    NSAssert(![NSThread isMainThread], @"Required other than main thread");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    DownloadHandler *handler = [[DownloadHandler alloc] init];
    handler.progressHandler = progressHandler;
    handler.errorHandler = ^{
        dispatch_semaphore_signal(semaphore);
    };
    handler.completionHandler = ^(NSData *data){
        dispatch_semaphore_signal(semaphore);
    };
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:handler];
        NSOperationQueue *handlerQueue = [[NSOperationQueue alloc] init];
        handlerQueue.name = @"com.nsdata.download";
        handlerQueue.maxConcurrentOperationCount = 1;
        [connection setDelegateQueue:handlerQueue];
        [connection start];
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return [handler data];
}
@end
