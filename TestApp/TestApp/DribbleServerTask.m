//
//  A5ServerTask.m
//  Simple Quiz
//
//  Created by Александр Кириченко on 25.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import "DribbleServerTask.h"


@implementation DribbleServerTask

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
        urlString = nil;
        bytes = nil;
        requester = nil;
        responseSelector = nil;
        userData = nil;
    }
    return self;
}

@end