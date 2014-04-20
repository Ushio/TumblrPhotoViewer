//
//  TumblrViewController.m
//  DownloadIndicator
//
//  Created by ushiostarfish on 2014/04/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "TumblrViewController.h"

#import "MBProgressHUD.h"

#import "TumblrImageViewCell.h"
#import "TumblrAPI.h"
#import "TumblrImageQueryResponse.h"
#import "CGImageWrapper.h"

static NSString *const kReuseIdentifier = @"kReuseIdentifier";

@implementation TumblrViewController
{
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UICollectionView *_collectionView;
    
    NSArray *_images;
    NSOperationQueue *_queryQueue;
    NSOperationQueue *_downloadQueue;
    NSOperationQueue *_processingQueue;
    
    NSCache *_imageCache;
    
    NSString *_currentBlogname;
    TumblrImageQueryResponse *_lastTumblrImageQueryResponse;
    BOOL _querying;
}
- (void)viewDidLoad
{
    _searchBar.delegate = self;
    _searchBar.text = @"terrysdiary";
    [_searchBar becomeFirstResponder];
    
    UINib *nib = [UINib nibWithNibName:@"TumblrImageViewCell" bundle:[NSBundle mainBundle]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:kReuseIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    _queryQueue = [[NSOperationQueue alloc] init];
    _queryQueue.maxConcurrentOperationCount = 1;
    
    _downloadQueue = [[NSOperationQueue alloc] init];
    _downloadQueue.maxConcurrentOperationCount = 2;
    
    _processingQueue = [[NSOperationQueue alloc] init];
    _processingQueue.maxConcurrentOperationCount = 2;
    
    _imageCache = [[NSCache alloc] init];
    _imageCache.totalCostLimit = 1024 * 1024 * 20;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    
    _currentBlogname = searchBar.text;
    _lastTumblrImageQueryResponse = nil;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_queryQueue addOperationWithBlock:^{
        TumblrImageQueryResponse *tmblrImageQueryResponse = [TumblrAPI imageQueryWithBlogname:_currentBlogname offset:0];
        if(tmblrImageQueryResponse)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _lastTumblrImageQueryResponse = tmblrImageQueryResponse;
                _images = tmblrImageQueryResponse.images;
                [_collectionView reloadData];
            }];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [hud hide:YES];
        }];
    }];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TumblrAPIImage *tumblrAPIImage = _images[indexPath.row];
    
    TumblrImageViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    cell.tumblrAPIImage = tumblrAPIImage;
    [cell.indicatorView startAnimating];
    cell.contentView.layer.contentsGravity = kCAGravityResizeAspectFill;
    cell.contentView.layer.contents = nil;
    cell.contentView.layer.masksToBounds = YES;
    
    // まずはキャッシュを見に行く
    NSData *cacheImageData = [_imageCache objectForKey:tumblrAPIImage.thumbnailURL.path];
    
    if(cacheImageData)
    {
        // 画像をラスター展開して表示
        [_processingQueue addOperationWithBlock:^{
            // 第一チェック
            // スクロール等で必要なくなった場合のキャンセル処理
            __block BOOL isSkip = NO;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(cell.tumblrAPIImage != tumblrAPIImage)
                {
                    isSkip = YES;
                }
            });
            if(isSkip)
            {
                return;
            }
            
            CGImageWrapper *image = [[CGImageWrapper alloc] initWithData:cacheImageData];
            CGImageWrapper *rasterizedImage = [image rasterized];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // 第二チェック
                // スクロール等で必要なくなった場合に,
                // セルの再利用によりずれたセルに対して処理を行ってしまうのを防ぐ
                if(cell.tumblrAPIImage == tumblrAPIImage)
                {
                    [cell.indicatorView stopAnimating];
                    
                    CATransition* transition = [CATransition animation];
                    transition.type = kCATransitionFade;
                    transition.duration = 0.2f;
                    [cell.contentView.layer addAnimation:transition forKey:nil];
                    
                    cell.contentView.layer.contents = (id)[rasterizedImage CGImage];
                }
            }];
        }];
    }
    else
    {
        // 画像をダウンロード後ラスター展開して表示
        [_downloadQueue addOperationWithBlock:^{
            // 第一チェック
            // スクロール等で必要なくなった場合のキャンセル処理
            __block BOOL isSkip = NO;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(cell.tumblrAPIImage != tumblrAPIImage)
                {
                    isSkip = YES;
                }
            });
            if(isSkip)
            {
                return;
            }
            
            NSData *downloadedImageData = [NSData dataWithContentsOfURL:tumblrAPIImage.thumbnailURL];
            if(downloadedImageData)
            {
                [_imageCache setObject:downloadedImageData forKey:tumblrAPIImage.thumbnailURL.path cost:downloadedImageData.length];
            }
            else
            {
                // エラー
                return;
            }
            
            [_processingQueue addOperationWithBlock:^{
                CGImageWrapper *image = [[CGImageWrapper alloc] initWithData:downloadedImageData];
                CGImageWrapper *rasterizedImage = [image rasterized];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // 第二チェック
                    // スクロール等で必要なくなった場合に,
                    // セルの再利用によりずれたセルに対して処理を行ってしまうのを防ぐ
                    if(cell.tumblrAPIImage == tumblrAPIImage)
                    {
                        [cell.indicatorView stopAnimating];
                        
                        CATransition* transition = [CATransition animation];
                        transition.type = kCATransitionFade;
                        transition.duration = 0.2f;
                        [cell.contentView.layer addAnimation:transition forKey:nil];
                        
                        cell.contentView.layer.contents = (id)[rasterizedImage CGImage];
                    }
                }];
            }];
        }];
    }

    
    // 追加クエリ
    // 最後の画像が表示されたら追加のクエリを送る
    ^{
        if(indexPath.row != _images.count - 1)
        {
            // 最後の画像が表示されていない
            return;
        }
        
        if(_querying)
        {
            // 現在処理中である
            return;
        }
        
        if(_lastTumblrImageQueryResponse)
        {
            if(_lastTumblrImageQueryResponse.offset + TUMBLR_PAGING_COUNT >= _lastTumblrImageQueryResponse.total_posts)
            {
                // 最後のページまで到達している
                return;
            }
        }
        
        // 追加クエリ送信
        _querying = YES;
        int offset = _lastTumblrImageQueryResponse.offset + TUMBLR_PAGING_COUNT;
        [_queryQueue addOperationWithBlock:^{
            TumblrImageQueryResponse *tmblrImageQueryResponse = [TumblrAPI imageQueryWithBlogname:_currentBlogname
                                                                                           offset:offset];
            if(tmblrImageQueryResponse)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:tmblrImageQueryResponse.images.count];
                    for(int i = 0 ; i < tmblrImageQueryResponse.images.count ; ++i)
                    {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_images.count + i inSection:0];
                        [insertIndexPaths addObject:indexPath];
                    }
                    _images = [_images arrayByAddingObjectsFromArray:tmblrImageQueryResponse.images];
                    _lastTumblrImageQueryResponse = tmblrImageQueryResponse;
                    
                    [_collectionView insertItemsAtIndexPaths:insertIndexPaths];
                }];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _querying = NO;
            }];
        }];
    }();
    
    return cell;
}

// 選択されたものを表示する
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TumblrAPIImage *tumblrAPIImage = _images[indexPath.row];
    
    TumblrImageViewController *tumblrImageViewController = [[TumblrImageViewController alloc] initWithImageURL:tumblrAPIImage.originalURL];
    tumblrImageViewController.delegate = self;
    tumblrImageViewController.view.frame = self.view.bounds;
    tumblrImageViewController.view.transform = CGAffineTransformMakeTranslation(0, tumblrImageViewController.view.bounds.size.height);
    [self.view addSubview:tumblrImageViewController.view];
    [self addChildViewController:tumblrImageViewController];
    
    [UIView animateWithDuration:0.5 animations:^{
        tumblrImageViewController.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)tumblrImageViewControllerDidFinished:(TumblrImageViewController *)viewController
{
    [UIView animateWithDuration:0.5 animations:^{
        viewController.view.transform = CGAffineTransformMakeTranslation(0, viewController.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }];
}
@end
