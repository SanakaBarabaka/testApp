//
//  ChooseCategoryCell.h
//  Simple Quiz
//
//  Created by Александр Кириченко on 14.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import <UIKit/UIKit.h>


#define SHOTS_CELL_HEIGHT		320


@protocol ShotsCellDelegate

- (void)changeFavoriteOfShot:(NSNumber*)shotIndex to:(bool)favFlag;
- (void)showCommentForShot:(NSNumber*)shotIndex;

@end


@interface ShotsCell : UITableViewCell
{
    IBOutlet UIImageView*				shotImage;
    IBOutlet UILabel*					titleLabel;
    IBOutlet UIActivityIndicatorView*	spinner;
    IBOutlet UIButton*					favoriteButton;
}

- (IBAction)onFavoriteButton:(id)sender;
- (IBAction)onShowCommentsButton:(id)sender;

@property (nonatomic, assign) bool	favorite;

// заполнить ячейку данными
- (void)fillWithImage:(UIImage *)aImage
                title:(NSString*)title
            shotIndex:(NSNumber*)aShotIndex
             delegate:(id<ShotsCellDelegate>)aDelegate;

@end
