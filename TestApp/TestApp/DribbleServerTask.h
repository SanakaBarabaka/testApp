//
//  A5ServerTask.h
//  Simple Quiz
//
//  Created by Александр Кириченко on 25.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DribbleServerManager.h"


@protocol DribbleServerManagerDelegate;


@interface DribbleServerTask : NSObject
{
@public
    NSString*							urlString;
    NSMutableData*						bytes;
    id<DribbleServerManagerDelegate>	requester;
    SEL									responseSelector;
    id									userData;
}

@end