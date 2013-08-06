//
//  Shot.h
//  TestApp
//
//  Created by Александр Кириченко on 06.08.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, User;

@interface Shot : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * dribble_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *user;
@end

@interface Shot (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
