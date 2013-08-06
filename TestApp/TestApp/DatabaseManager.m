//
//  DatabaseManager.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "DatabaseManager.h"
#import "AppDelegate.h"
#import "User.h"


static	DatabaseManager* _instance = NULL;


@implementation DatabaseManager

@synthesize currentUser;

#pragma mark ----- Singleton -----


+ (DatabaseManager*)sharedDatabaseManager
{
    @synchronized([DatabaseManager class])
    {
        if (_instance == NULL)
        {
            _instance = [[DatabaseManager alloc] init];
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


- (id)init
{
    self = [super init];
    if (self)
    {
        //--defaults--
        currentUser = nil;
    }
    return self;
}


#pragma mark ----- Actions -----


- (bool)loginWithUserName:(NSString *)userName password:(NSString *)password
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // что ищем - пользователя
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:dbContext];
    [fetchRequest setEntity:entity];
    // ограничение
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"login == %@ && password == %@", userName, password];
    [fetchRequest setPredicate:predicate];
    
    // сделаем запрос
    NSError *error = nil;
    NSArray* usersFound = [dbContext executeFetchRequest:fetchRequest error:&error];
    // успех?
    if (usersFound.count >= 1)
    {
        [currentUser release];
        currentUser = [[usersFound objectAtIndex:0] retain];
        // сообщим кому надо
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DBM_UserLoggedIn object:nil];
    }
    return currentUser != nil;
}


- (bool)addNewUser:(NSString *)userName password:(NSString *)password
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Grab the Label entity
    User* newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                  inManagedObjectContext:dbContext];
    // set fields
    newUser.login = userName;
    newUser.password = password;
    
    // Save to DB
    NSError *error = nil;
    if ([dbContext save:&error])
        NSLog(@"user added successfully");
    else
        NSLog(@"ERROR: adding user error: %@", [error userInfo]);
    return error != nil;
}


- (void)logoutCurrentUser
{
    [currentUser release];
    currentUser = nil;
}


@end