//
//  DownloadingItem.h
//  Simple Quiz
//
//  Created by Александр Кириченко on 19.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
    DT_Image,	// картинка
} DownloadingItemType;


@interface DownloadingItem : NSObject
{
@public
    DownloadingItemType	type;
    NSString*			urlString;
    NSMutableData*		bytes;
    id					requester;
    id					userData;
}

@end