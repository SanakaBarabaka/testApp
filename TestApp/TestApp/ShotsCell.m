//
//  ChooseCategoryCell.m
//  Simple Quiz
//
//  Created by Александр Кириченко on 14.02.13.
//  Copyright (c) 2013 alliance5. All rights reserved.
//

#import "ShotsCell.h"


@interface ShotsCell()
{
    NSNumber*		shotIndex;
    id<ShotsCellDelegate> delegate;
}

@end


@implementation ShotsCell


- (void)dealloc
{
    [shotIndex release];
    [shotImage release];
    [titleLabel release];
    [spinner release];
    [favoriteButton release];
    [super dealloc];
}


- (void)fillWithImage:(UIImage *)aImage
                title:(NSString *)title
            shotIndex:(NSNumber*)aShotIndex
             delegate:(id<ShotsCellDelegate>)aDelegate
{
    shotImage.image = aImage;
    shotImage.hidden = aImage == nil;
    spinner.hidden = aImage != nil;
    titleLabel.text = title;
    shotIndex = [aShotIndex retain];
    delegate = aDelegate;
}


- (void)setFavorite:(bool)aFavorite
{
    favoriteButton.selected = aFavorite;
}


- (bool)favorite
{
    return favoriteButton.selected;
}


- (void)onFavoriteButton:(id)sender
{
    self.favorite = !self.favorite;
    
    [delegate changeFavoriteOfShot:shotIndex to:self.favorite];
}


- (void)onShowCommentsButton:(id)sender
{
    [delegate showCommentForShot:shotIndex];
}


@end