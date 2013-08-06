//
//  DownloadsManager.m
//  Simple Quiz
//
//  Created by Александр Кириченко on 19.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import "DownloadsManager.h"
#import "DownloadingItem.h"


static DownloadsManager* _instance = NULL;


@interface DownloadsManager() <NSURLConnectionDataDelegate>
{
@private
    // текущие загрузки
    CFMutableDictionaryRef downloads;    
}

@end


@implementation DownloadsManager


#pragma mark ----- Singleton -----


+ (DownloadsManager *)sharedDownloadsManager
{
    @synchronized([DownloadsManager class])
    {
        if (_instance == NULL)
        {
            _instance = [[DownloadsManager alloc] init];
        }
    }
    return _instance;
}


+ (void)shutdown
{
    if (_instance)
        [_instance release];
    _instance = NULL;
}


#pragma mark ----- Initialization -----


- (void)dealloc
{
    if (downloads)
    {
        CFRelease(downloads);
        downloads = nil;
    }
    [super dealloc];
}


- (id)init
{
    // родительская инициализация
    self = [super init];
    if (self)
    {
        //--defaults--
        // словарик соединений
        downloads = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                              0,
                                              &kCFTypeDictionaryKeyCallBacks,
                                              &kCFTypeDictionaryValueCallBacks);
    }
    // готово
    return self;
}


#pragma mark ----- Actions -----

- (void)downloadImageForUrl:(NSString *)aIconUrl delegate:(id<DownloadsManagerDelegate>)aDelegate data:(id)aData
{
    // иначе добавим ее в список загрузок
    [self newDownloadableWithType:DT_Image
                        requester:aDelegate
                        urlString:aIconUrl
                       customData:aData];
}


- (void)newDownloadableWithType:(DownloadingItemType)aType
                      requester:(id<DownloadsManagerDelegate>)aRequester
                      urlString:(NSString*)aUrlString
                     customData:(id)aCustomData
{
    // иначе добавим ее в список загрузок
    DownloadingItem* newItem = [[DownloadingItem alloc] init];
    newItem->type = aType;
    newItem->requester = [aRequester retain];
    newItem->urlString = [aUrlString retain];
    newItem->userData = [aCustomData retain];
    newItem->bytes = [[NSMutableData alloc] init];
    NSURL* requestUrl = [NSURL URLWithString:aUrlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestUrl];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    CFDictionaryAddValue(downloads,
                         connection,
                         newItem);
    [connection release];
    [newItem release];
}


#pragma mark ----- Connection Delegate -----


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // накапливаем полученную инфу
    DownloadingItem* item = CFDictionaryGetValue(downloads, connection);
    if (item)
        [item->bytes appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // загруженный элемент
    DownloadingItem* item = CFDictionaryGetValue(downloads, connection);
    // нет такого?
    if (!item)
        return;
    // все данные загружены
    UIImage* tempImage;
    switch (item->type)
    {
        case DT_Image:
            tempImage = [UIImage imageWithData:item->bytes];
            [item->requester dmImageLoaded:tempImage data:item->userData];
            break;
    }
    // освобождаем память
    CFDictionaryRemoveValue(downloads, connection);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // удалим загружаемый элемент
    CFDictionaryRemoveValue(downloads, connection);
    NSLog(@"ERROR: download error: %@", error);
}


@end