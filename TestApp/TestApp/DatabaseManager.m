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
#import "Shot.h"
#import "Comment.h"


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


- (NSArray*)getShotsIDOrderedByDateFavoritesOnly:(bool)favOnly titleSearch:(NSString *)titleSearch
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot"
                                              inManagedObjectContext:dbContext];
    
    [fetchRequest setEntity:entity];
    
    NSString* predicateFormat = @"user == %@";
    if (favOnly)
        predicateFormat = [predicateFormat stringByAppendingString:@" && favorite == %@"];
    if (titleSearch != nil && ![titleSearch isEqualToString:@""])
        predicateFormat = [predicateFormat stringByAppendingString:@" && title CONTAINS %@"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat,
                              [dbContext objectWithID:self.currentUser.objectID],
                              [NSNumber numberWithBool:true],
                              titleSearch];
    [fetchRequest setPredicate:predicate];
    
    // Add an NSSortDescriptor to sort the labels alphabetically
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSError *error = nil;
    NSArray* shots = [dbContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray* shotsIDs = [[NSMutableArray alloc] initWithCapacity:shots.count];
    for (Shot* shot in shots)
    {
        [shotsIDs addObject:shot.dribble_id];
    }
    return [shotsIDs autorelease];
}


- (Shot*)getShotWithDribbleID:(NSNumber*)shotDribbleID
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // что ищем - пользователя
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot"
                                              inManagedObjectContext:dbContext];
    [fetchRequest setEntity:entity];
    // ограничение
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dribble_id == %@", shotDribbleID];
    [fetchRequest setPredicate:predicate];
    
    // сделаем запрос
    NSError *error = nil;
    NSArray* shotsFound = [dbContext executeFetchRequest:fetchRequest error:&error];
    // успех?
    if (shotsFound.count >= 1)
        return [shotsFound objectAtIndex:0];
    return nil;
}


- (void)setFavorite:(bool)favFlag forShotWithDribbleID:(NSNumber *)shotID
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // что ищем - пользователя
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot"
                                              inManagedObjectContext:dbContext];
    [fetchRequest setEntity:entity];
    // ограничение
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dribble_id == %@", shotID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray* shotsFound = [dbContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil && shotsFound.count >= 1)
    {
        Shot* shot = [shotsFound objectAtIndex:0];
        shot.favorite = [NSNumber numberWithBool:favFlag];
        
        if ([dbContext save:&error])
        {
            NSLog(@"changed favorite");
        }
        else
        {
            NSLog(@"The save wasn't successful: %@", [error localizedDescription]);
        }
    }
}


- (void)setImageData:(NSData *)imgData forShotWithDribbleID:(NSNumber *)shotID favorite:(bool)favFlag
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // что ищем - пользователя
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot"
                                              inManagedObjectContext:dbContext];
    [fetchRequest setEntity:entity];
    // ограничение
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dribble_id == %@", shotID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray* shotsFound = [dbContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil && shotsFound.count >= 1)
    {
        Shot* shot = [shotsFound objectAtIndex:0];
        shot.favorite = [NSNumber numberWithBool:favFlag];
        shot.data = imgData;
        
        if ([dbContext save:&error])
        {
            NSLog(@"changed favorite");
        }
        else
        {
            NSLog(@"The save wasn't successful: %@", [error localizedDescription]);
        }
    }
}


- (void)addShotWithDribbleID:(NSNumber *)dribleID title:(NSString *)title imageUrl:(NSString *)imageUrl date:(NSDate *)date
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // найдем старое
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // что ищем - пользователя
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot"
                                              inManagedObjectContext:dbContext];
    [fetchRequest setEntity:entity];
    // ограничение
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dribble_id == %@", dribleID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray* shotsFound = [dbContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil)
    {
        if (shotsFound.count >= 1)
        {
            Shot* shot = [shotsFound objectAtIndex:0];
            shot.title = title;
            shot.image_url = imageUrl;
            shot.date = date;
        }
        else
        {
            // создадим новое
            Shot *newShot = [NSEntityDescription insertNewObjectForEntityForName:@"Shot" inManagedObjectContext:dbContext];
            newShot.favorite = false;
            newShot.dribble_id = dribleID;
            newShot.title = title;
            newShot.image_url = imageUrl;
            newShot.date = date;
            
            [currentUser addShotsObject:newShot];
        }
    }
}


- (void)save
{
    // просто схороняемся
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    NSError *error = nil;
    if ([dbContext save:&error])
    {
        NSLog(@"save successful!");
    }
    else
    {
        NSLog(@"The save wasn't successful: %@", [error localizedDescription]);
    }
}


- (NSArray*)getCommentsOrderedByDateForShot:(Shot*)shot
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment"
                                              inManagedObjectContext:dbContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shot == %@", shot];
    [fetchRequest setPredicate:predicate];
    
    // Add an NSSortDescriptor to sort the labels alphabetically
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSError *error = nil;
    NSArray* comments = [dbContext executeFetchRequest:fetchRequest error:&error];
    return comments;
}


- (void)removeCommentsForShot:(Shot *)shot
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    [shot removeComments:shot.comments];
    
    NSError* error = nil;
    if ([dbContext save:&error])
    {
        NSLog(@"deleted successfully");
    }
    else
    {
        NSLog(@"delete was not successful");
    }
}


- (void)addCommentForShot:(id)shot text:(id)text date:(id)date
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    // сразу добавляем новый комент
    Comment *newComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:dbContext];
    newComment.text = text;
    newComment.date = date;
    
    [shot addCommentsObject:newComment];
    
    // не сохраняемся
}


- (void)removeComment:(Comment *)comment fromShot:(Shot *)shot
{
    NSManagedObjectContext* dbContext = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    
    [shot removeCommentsObject:comment];
    
    NSError* error = nil;
    if ([dbContext save:&error])
    {
        NSLog(@"comment deleted successfully");
    }
    else
    {
        NSLog(@"delete was not successful");
    }
}


@end