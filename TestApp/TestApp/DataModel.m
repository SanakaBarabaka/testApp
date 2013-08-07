//
//  DataModel.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "DataModel.h"
#import "DownloadsManager.h"
#import "DatabaseManager.h"
#import "User.h"
#import "Shot.h"
#import "Comment.h"
#import "DribbleServerManager.h"


static	DataModel* _instance = NULL;


@interface DataModel() <DribbleServerManagerDelegate, DownloadsManagerDelegate>
{
    DatabaseManager*		sharedDatabaseManager;
    DribbleServerManager*	sharedDribbleManager;
    NSMutableDictionary*	imagesCache;
}

@end


@implementation DataModel


#pragma mark ----- Singleton -----


+ (DataModel*)sharedDataModel
{
    @synchronized([DataModel class])
    {
        if (_instance == NULL)
        {
            _instance = [[DataModel alloc] init];
        }
    }
    return _instance;
}


+ (void)shutdown
{
    if (_instance)
    {
        // завершимся
        [_instance release];
    }
    _instance = NULL;
}


#pragma mark ----- Initialization -----


- (void)dealloc
{
    [imagesCache release];
    [super dealloc];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        imagesCache = [[NSMutableDictionary alloc] init];
        sharedDatabaseManager = [DatabaseManager sharedDatabaseManager];
        sharedDribbleManager = [DribbleServerManager sharedDribbleServerManager];
    }
    return self;
}


#pragma mark ----- Actions -----


- (void)clearCache
{
    [imagesCache removeAllObjects];
}


- (NSArray*)getShotsFavoritesOnly:(bool)favOnly titleSearch:(NSString *)titleSearch
{
    if (sharedDatabaseManager.currentUser == nil)
        return nil;
    else
        return [sharedDatabaseManager getShotsIDOrderedByDateFavoritesOnly:favOnly titleSearch:titleSearch];
}


- (NSArray*)getCommentsorderedByDateForShotWithID:(NSNumber *)shotID
{
    if (sharedDatabaseManager.currentUser == nil)
        return nil;
    else
    {
        Shot* shot = [self getShot:shotID];
        if (shot!= nil)
            return [sharedDatabaseManager getCommentsOrderedByDateForShot:shot];
        else
            return nil;
    }
}


- (Shot*)getShot:(NSNumber*)shotDribbleID
{
    return [sharedDatabaseManager getShotWithDribbleID:shotDribbleID];
}


- (UIImage *)getImageForShot:(Shot *)aShot
{
    // сохранена ли картинка в базе?
    if (aShot.data != nil)
        return [UIImage imageWithData:aShot.data];
    else
    {
        // может в кеше?
        UIImage* cachedImage = [imagesCache objectForKey:aShot.dribble_id];
        if (cachedImage == nil)
        {
            // нет - загрузим из интернетов (с сервера дрибла)
            [[DownloadsManager sharedDownloadsManager] downloadImageForUrl:aShot.image_url
                                                                  delegate:self
                                                                      data:aShot.dribble_id];
            // а пока вернем пусто
            return nil;
        }
        else
            return cachedImage;
    }
}


- (void)setFavorite:(bool)favFlag forShot:(NSNumber*)shotID
{
    UIImage* img = [imagesCache objectForKey:shotID];
    if (favFlag && img != nil)
        [sharedDatabaseManager setImageData:UIImagePNGRepresentation(img) forShotWithDribbleID:shotID favorite:favFlag];
    else
        [sharedDatabaseManager setFavorite:favFlag forShotWithDribbleID:shotID];
    
    // сообщим, что кодичество любимых изменилось
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DM_FavoritesChanged object:nil];
}


- (void)refreshUserShots
{
    if (sharedDatabaseManager.currentUser != nil)
    {
        [sharedDribbleManager getShotsForList:@"popular"
                                         page:1
                                     delegate:self];
    }
}


- (void)updateCommentsForShotWithID:(NSNumber *)shotID
{
    if (sharedDatabaseManager.currentUser != nil && shotID != nil)
    {
        [sharedDribbleManager getCommentsForShotWithID:shotID delegate:self];
    }
}


- (void)removeComment:(Comment *)comment fromShotWithID:(NSNumber *)shotID
{
    Shot* shot = [self getShot:shotID];
    [sharedDatabaseManager removeComment:comment fromShot:shot];
}


#pragma mark ----- DownloadsManagerDelegate -----


- (void)dmImageLoaded:(UIImage *)aImage data:(id)aData
{
    NSNumber* shotID = (NSNumber*)aData;
    [imagesCache setObject:aImage forKey:shotID];
    
    // если эта картинка любимая (наверное пользовтаель тыкнул на кнопку любимости слмшком рано) то сохраним саму картинку внутрь базы
    Shot* shot = [sharedDatabaseManager getShotWithDribbleID:shotID];
    if (shot.favorite)
        [sharedDatabaseManager setImageData:UIImagePNGRepresentation(aImage)
                       forShotWithDribbleID:shotID
                                   favorite:shot.favorite];
    
    // сообщим кому надо
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DM_ImageDownloaded
                                                        object:aData];
}


#pragma mark ----- DribbleServerManagerDelegate -----


- (void)dribbleServerConnectionError:(NSError *)error
{
    // ну ошибка - нарисуем ее пользователю
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert autorelease];
}


- (void)dribbleServerGetShotsResponse:(NSObject *)aResponse error:(NSError *)error userData:(id)unused
{
    if (error)
    {
        [self showError:error];
        return;
    }
    // распарсиваем ответ и добавляем картинки в базу
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss Z"];
    
    NSArray* shotsData = [[(NSDictionary*)aResponse objectForKey:@"shots"] retain];
    
    for (NSDictionary* shotData in shotsData)
    {
        NSNumber* dribleID = [shotData objectForKey:@"id"];
        NSString* title = [shotData objectForKey:@"title"];
        NSString* imageUrl = [shotData objectForKey:@"image_url"];
        NSDate* date = [formatter dateFromString:[shotData objectForKey:@"created_at"]];
        
        [sharedDatabaseManager addShotWithDribbleID:dribleID title:title imageUrl:imageUrl date:date];
    }
    // не забываем схраниться, потому что вешиспользуемый запрос не сохраняет изменения
    [sharedDatabaseManager save];

    // ресурсики
    [formatter release];
    [shotsData release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DM_ShotsUpdated object:nil];
}


- (void)dribbleServerGetCommentsResponse:(NSObject *)aResponse error:(NSError *)error userData:(id)userData
{
    if (error)
    {
        [self showError:error];
    }
    
    NSNumber* shotID = (NSNumber*)userData;
    // remove previous comments on this shot
    Shot* shot = [self getShot:shotID];
    [sharedDatabaseManager removeCommentsForShot:shot];
    
    // parse comments
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss Z"];
    NSArray* commentsData = [[(NSDictionary*)aResponse objectForKey:@"comments"] retain];
    
    for (NSDictionary* commentData in commentsData)
    {
        NSString* text = [commentData objectForKey:@"body"];
        NSDate* date = [formatter dateFromString:[commentData objectForKey:@"created_at"]];
        
        // add to DB
        [sharedDatabaseManager addCommentForShot:shot text:text date:date];
    }
    // не забываем схраниться, потому что вешиспользуемый запрос не сохраняет изменения
    [sharedDatabaseManager save];
    
    [formatter release];
    [commentsData release];
    // сообщим
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DM_CommentsUpdated object:shotID];
}


- (void)showError:(NSError*)error
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert autorelease];
}


@end