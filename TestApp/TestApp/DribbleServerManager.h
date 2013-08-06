//
//  ServerLocal.h
//  Simple Quiz
//
//  Created by Александр Кириченко on 11.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import <Foundation/Foundation.h>


// ошибки
#define Dribble_ERROR_DOMAIN	@"DribbleServerError"
enum DribbleServerCommunicationErrors
{
    dribbleInvalidServerResponseError = 1,
    dribbleTooManyRequests,
    dribbleServerAnswerError
};


@protocol DribbleServerManagerDelegate <NSObject>

@optional
- (void)dribbleServerConnectionError:(NSError*)error;
- (void)dribbleServerGetShotsResponse:(NSObject*)aResponse error:(NSError*)error userData:(id)userData;
- (void)dribbleServerGetCommentsResponse:(NSObject*)aResponse error:(NSError*)error userData:(id)userData;

@end


@interface DribbleServerManager : NSObject

// синглетон-методы
+ (DribbleServerManager*)sharedDribbleServerManager;
+ (void)shutdown;

// запросы к серверу
// залогиниться - получить ключ и идентификатор пользователя
- (void)getShotsForList:(NSString*)shotsList page:(int)pageNumber delegate:(id<DribbleServerManagerDelegate>)aDelegate;
- (void)getCommentsForShotWithID:(NSNumber*)shotID delegate:(id<DribbleServerManagerDelegate>)aDelegate;

@end