//
//  TumblrAPI.m
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "TumblrAPI.h"
#import "TumblrAPIImage.h"
#import "NSString+URLEncode.h"

static NSString *const kAPIKey = @"Enter your API key";

@implementation TumblrAPI
+ (TumblrImageQueryResponse *)imageQueryWithBlogname:(NSString *)blogname
                                              offset:(int)offset
{
    NSString *URLString = [NSString stringWithFormat:@"https://api.tumblr.com/v2/blog/%@.tumblr.com/posts/photo?api_key=%@&offset=%d", [blogname stringByURLEncode], kAPIKey, offset];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data == nil)
    {
        return nil;
    }
    
    if([response isKindOfClass:[NSHTTPURLResponse class]] == NO)
    {
        return nil;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse.statusCode != 200)
    {
        return nil;
    }
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(jsonObject == nil)
    {
        return nil;
    }
    if([jsonObject isKindOfClass:[NSDictionary class]] == NO)
    {
        return nil;
    }
    
    NSMutableArray *images = [NSMutableArray array];
    NSArray *posts = [jsonObject valueForKeyPath:@"response.posts"];
    for(NSDictionary *post in posts)
    {
        NSArray *photos = post[@"photos"];
        for(NSDictionary *photo in photos)
        {
            TumblrAPIImage *tumblrAPIImage = [[TumblrAPIImage alloc] init];
            NSString *originalURLString = [photo valueForKeyPath:@"original_size.url"];
            
            NSArray *alt_sizes = photo[@"alt_sizes"];
            NSDictionary *last = alt_sizes.lastObject;
            NSString *thumbnailURLString = last[@"url"];
            
            tumblrAPIImage.originalURL = [NSURL URLWithString:originalURLString];
            tumblrAPIImage.thumbnailURL = [NSURL URLWithString:thumbnailURLString];
            
            [images addObject:tumblrAPIImage];
        }
    }
    
    NSNumber *total_posts = [jsonObject valueForKeyPath:@"response.total_posts"];
    
    TumblrImageQueryResponse *tumblrImageQueryResponse = [[TumblrImageQueryResponse alloc] init];
    tumblrImageQueryResponse.images = images;
    tumblrImageQueryResponse.total_posts = total_posts.intValue;
    tumblrImageQueryResponse.offset = offset;
    return tumblrImageQueryResponse;
}

@end
