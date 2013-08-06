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

@end