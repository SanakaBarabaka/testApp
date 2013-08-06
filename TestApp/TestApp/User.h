//
//  User.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSSet *shots;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addShotsObject:(NSManagedObject *)value;
- (void)removeShotsObject:(NSManagedObject *)value;
- (void)addShots:(NSSet *)values;
- (void)removeShots:(NSSet *)values;

@end
