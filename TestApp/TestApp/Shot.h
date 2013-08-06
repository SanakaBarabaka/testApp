//
//  Shot.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Shot : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *comments;
@end

@interface Shot (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
