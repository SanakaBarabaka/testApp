//
//  DownloadingItem.m
//  Simple Quiz
//
//  Created by Александр Кириченко on 19.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import "DownloadingItem.h"


@implementation DownloadingItem


- (void)dealloc
{
    [urlString release];
    [bytes release];
    [requester release];
    [userData release];
    [super dealloc];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        //--defaults--
        type = DT_Image;
        urlString = nil;
        bytes = nil;
        requester = nil;
        userData = nil;
    }
    return self;
}


@end