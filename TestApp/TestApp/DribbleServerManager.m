//
//  ServerLocal.m
//  Simple Quiz
//
//  Created by Александр Кириченко on 11.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import "DribbleServerManager.h"
#import "DribbleServerTask.h"


#define SERVER_URL	@"http://api.dribbble.com"


static DribbleServerManager*	_instance = NULL;


@interface DribbleServerManager() <NSURLConnectionDataDelegate>
{    
    // текущие соединения
    CFMutableDictionaryRef			tasks;    
}

- (void)newTaskWithRequester:(id<DribbleServerManagerDelegate>)aRequester
            responseSelector:(SEL)aResponseSelector
                   urlString:(NSString*)aUrlString
                    userData:(id)userData;
- (void)respondToRequester:(id)requester response:(SEL)responseSelector jsonData:(NSObject*)jsonData error:(NSError*)customError;

@end


@implementation DribbleServerManager


#pragma mark ----- Singleton -----


+ (DribbleServerManager *)sharedDribbleServerManager
{
    @synchronized(self)
    {
        if (_instance == NULL)
        {
            _instance = [[self alloc] init];
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
    if (tasks)
    {
        CFDictionaryRemoveAllValues(tasks);
        CFRelease(tasks);
        tasks = nil;
    }
    [super dealloc];
}


- (id)init
{
    // родительская инициализация
    self = [super init];
    if (self)
    {
        // начальные значения
        // словарик соединений
        tasks = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                          0,
                                          &kCFTypeDictionaryKeyCallBacks,
                                          &kCFTypeDictionaryValueCallBacks);
    }
    // готово
    return self;
}


#pragma mark ----- Supplemental -----


- (void)newTaskWithRequester:(id<DribbleServerManagerDelegate>)aRequester
            responseSelector:(SEL)aResponseSelector
                   urlString:(NSString *)aUrlString
                    userData:(id)userData
{
    // иначе добавим ее в список загрузок
    DribbleServerTask* newTask = [[DribbleServerTask alloc] init];
    newTask->requester = [aRequester retain];
    newTask->responseSelector = aResponseSelector;
    newTask->urlString = [aUrlString retain];
    newTask->bytes = [[NSMutableData alloc] init];
    newTask->userData = [userData retain];
    NSURL* requestUrl = [NSURL URLWithString:aUrlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0f];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    CFDictionaryAddValue(tasks, connection, newTask);
    [connection release];
    [newTask release];
}


- (void)respondToRequester:(id)requester response:(SEL)responseSelector jsonData:(NSObject*)jsonData error:(NSError*)customError
{
    if ([requester respondsToSelector:responseSelector])
        [requester performSelector:responseSelector withObject:jsonData withObject:customError];
}


- (void)respondToRequester:(DribbleServerTask*)task jsonData:(NSObject*)jsonData error:(NSError*)customError
{
    if ([task->requester respondsToSelector:task->responseSelector])
    {
        NSMethodSignature * mySignature = [[task->requester class] instanceMethodSignatureForSelector:task->responseSelector];
        NSInvocation * myInvocation = [NSInvocation invocationWithMethodSignature:mySignature];
        [myInvocation setTarget:task->requester];
        [myInvocation setSelector:task->responseSelector];
        if (jsonData != nil)
            [myInvocation setArgument:&jsonData atIndex:2];
        if (customError != nil)
            [myInvocation setArgument:&customError atIndex:3];
        if (task->userData != nil)
            [myInvocation setArgument:&(task->userData) atIndex:4];
        
        [myInvocation retainArguments];
        [myInvocation invoke];
    }
}


#pragma mark ----- Actions -----


- (void)getShotsForList:(NSString*)shotsList page:(int)pageNumber delegate:(id<DribbleServerManagerDelegate>)aDelegate
{
    // сформируем урл запроса
    NSString *urlString = [NSString stringWithFormat:@"%@/shots/%@?page=%i&per_page=30",
                           SERVER_URL,
                           shotsList,
                           pageNumber];
    NSLog(@"INFO: get shots for list: %@", urlString);
    // добавим новую задачу
    [self newTaskWithRequester:aDelegate
              responseSelector:@selector(dribbleServerGetShotsResponse:error:userData:)
                     urlString:urlString
                      userData:nil];
}


- (void)getCommentsForShotWithID:(NSNumber *)shotID delegate:(id<DribbleServerManagerDelegate>)aDelegate
{
    // сформируем урл запроса
    NSString *urlString = [NSString stringWithFormat:@"%@/shots/%@/comments?page=1&per_page=30",
                           SERVER_URL,
                           shotID];
    NSLog(@"INFO: get comments for shot: %@", urlString);
    // добавим новую задачу
    [self newTaskWithRequester:aDelegate
              responseSelector:@selector(dribbleServerGetCommentsResponse:error:userData:)
                     urlString:urlString
                      userData:shotID];
}


#pragma mark ----- Connection Delegate -----


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    DLog(@"receive response: %@", response.URL);
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // накапливаем полученную инфу
    DribbleServerTask* item = CFDictionaryGetValue(tasks, connection);
    if (item)
        [item->bytes appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // обрабатываемая задача
    DribbleServerTask* task = CFDictionaryGetValue(tasks, connection);
    // нет такой?
    if (!task)
        return;
    // ответ должен быть в формате JSON
    // разберем ответ
//    DLog(@"receive data: %@", [[[NSString alloc] initWithData:task->bytes encoding:NSUTF8StringEncoding] autorelease]);
    NSError* jsonError = nil;
    NSError* customError = nil;
    NSDictionary* jsonData = [[NSJSONSerialization JSONObjectWithData:task->bytes options:NSJSONReadingMutableLeaves error:&jsonError] retain];
    // ошибка?
    if (jsonError != nil)
    {
        NSLog(@"ERROR: json error: %@\n\nresponse text:%@", jsonError, [[[NSString alloc] initWithData:task->bytes encoding:NSUTF8StringEncoding] autorelease]);
        [jsonData release];
        jsonData = nil;
        jsonError = nil;
        // сформируем собственную ошибку для ответа делегату
        customError = [[NSError alloc] initWithDomain:Dribble_ERROR_DOMAIN
                                                 code:dribbleInvalidServerResponseError
                                             userInfo:nil];
    }
    else
    {
        // проверим на наличие ошибки, о которой нам мог сообщить сам сервер
        if ([jsonData respondsToSelector:@selector(objectForKey:)])
        {
            // запись об ошибке есть?
            NSString* errorData = [[jsonData objectForKey:@"message"] retain];
            if (errorData)
            {
                    NSLog(@"ERROR - Dibble server error:\n message: %@", errorData);
                    customError = [[NSError alloc] initWithDomain:Dribble_ERROR_DOMAIN
                                                             code:dribbleServerAnswerError
                                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"(ERROR) %@", errorData]
                                                                                              forKey:NSLocalizedDescriptionKey]];
            }
            [errorData release];
        }
        // иначе все ок, сервер выдал условно правильные данные
    }
    [self respondToRequester:task jsonData:jsonData error:customError];
    
    [customError release];
    [jsonData release];
    jsonData = nil;

    // освобождаем память
    CFDictionaryRemoveValue(tasks, connection);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DribbleServerTask* task = CFDictionaryGetValue(tasks, connection);
    if (task)
    {
        // ошибка
        // сообщим о ней
        NSLog(@"ERROR: Dribble server connection fail: %@", error);
        [self respondToRequester:task->requester response:task->responseSelector jsonData:nil error:error];
        // удалим задачу
        CFDictionaryRemoveValue(tasks, connection);
    }
}


- (NSURLRequest*)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    //    DLog(@"!redirect request: %@", request);
    //    DLog(@"!redirect response: %@", response);
    return request;
}


@end