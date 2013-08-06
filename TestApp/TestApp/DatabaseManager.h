//
//  DatabaseManager.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <Foundation/Foundation.h>


#define NOTIFICATION_DBM_UserLoggedIn	@"dbm_user_logged_in"


@class User;
@class Shot;
@class Comment;


@interface DatabaseManager : NSObject

@property (nonatomic, readonly) User*	currentUser;

// singleton methods
+ (DatabaseManager*)sharedDatabaseManager;
+ (void)shutdown;

// логинимся с указанными параметрами
// если такой пользователь существует, то возвращаем TRUE
- (bool)loginWithUserName:(NSString*)userName password:(NSString*)password;
// добвить нового пользователя
// возвращаем успешность операции
- (bool)addNewUser:(NSString*)userName password:(NSString*)password;
// разлогиниться - забыть текущего пользователя
- (void)logoutCurrentUser;
- (NSArray*)getShotsIDOrderedByDateFavoritesOnly:(bool)favOnly titleSearch:(NSString*)titleSearch;
- (Shot*)getShotWithDribbleID:(NSNumber*)shotDribbleID;
- (void)setFavorite:(bool)favFlag forShotWithDribbleID:(NSNumber*)shotID;
- (void)setImageData:(NSData*)imgData forShotWithDribbleID:(NSNumber*)shotID favorite:(bool)favFlag;
- (void)addShotWithDribbleID:(NSNumber*)dribleID title:(NSString*)title imageUrl:(NSString*)imageUrl date:(NSDate*)date;
- (void)save;
- (NSArray*)getCommentsOrderedByDateForShot:(Shot*)shot;
- (void)removeCommentsForShot:(Shot *)shot;
- (void)addCommentForShot:shot text:text date:date;
- (void)removeComment:(Comment*)comment fromShot:(Shot*)shot;

@end