//
//  DownloadsManager.h
//  Simple Quiz
//
//  Created by Александр Кириченко on 19.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DownloadsManagerDelegate <NSObject>

@optional
- (void)dmImageLoaded:(UIImage*)aImage data:(id)aData;

@end


@interface DownloadsManager : NSObject

// синглетон-методы
+ (DownloadsManager*)sharedDownloadsManager;
+ (void)shutdown;

// попросить иконку
- (void)downloadImageForUrl:(NSString*)aIconUrl delegate:(id<DownloadsManagerDelegate>)aDelegate data:(id)aData;

@end