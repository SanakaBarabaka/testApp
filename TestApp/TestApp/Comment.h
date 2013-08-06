//
//  Comment.h
//  TestApp
//
//  Created by Александр Кириченко on 06.08.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shot;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Shot *shot;

@end
