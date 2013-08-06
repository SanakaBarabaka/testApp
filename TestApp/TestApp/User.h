//
//  User.h
//  TestApp
//
//  Created by Александр Кириченко on 06.08.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shot;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSSet *shots;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addShotsObject:(Shot *)value;
- (void)removeShotsObject:(Shot *)value;
- (void)addShots:(NSSet *)values;
- (void)removeShots:(NSSet *)values;

@end
