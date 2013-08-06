//
//  DataModel.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <Foundation/Foundation.h>


#define NOTIFICATION_DM_ImageDownloaded	@"img_downloaded"
#define NOTIFICATION_DM_ShotsUpdated	@"shots_updated"
#define NOTIFICATION_DM_CommentsUpdated	@"comments_updated"


@class Shot;
@class Comment;


@interface DataModel : NSObject

// singleton methods
+ (DataModel*)sharedDataModel;
+ (void)shutdown;

// actions
- (void)clearCache;
- (NSArray*)getShotsFavoritesOnly:(bool)favOnly titleSearch:(NSString*)titleSearch;
- (void)refreshUserShots;
- (Shot*)getShot:(NSNumber*)shotDribbleID;
- (UIImage*)getImageForShot:(Shot*)aShot;
- (void)setFavorite:(bool)favFlag forShot:(NSNumber*)shotID;
- (NSArray*)getCommentsorderedByDateForShotWithID:(NSNumber*)shotID;
- (void)updateCommentsForShotWithID:(NSNumber*)shotID;
- (void)removeComment:(Comment*)comment fromShotWithID:(NSNumber*)shotID;

@end