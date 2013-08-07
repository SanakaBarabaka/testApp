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
    // изменим отношение сторон отображения, чтобы картинка уменьшалась одинаково по обоим осям
    if (aImage != nil)
    {
        float scaledWidth = shotImage.frame.size.width;
        float scaledHeight = shotImage.frame.size.height;
        if (aImage.size.height < aImage.size.width)
            scaledHeight = shotImage.frame.size.height * aImage.size.height / aImage.size.width;
        else
            scaledWidth = shotImage.frame.size.width * aImage.size.height / aImage.size.width;
        shotImage.frame = CGRectMake((self.frame.size.width - scaledWidth) / 2.0f,
                                     (self.frame.size.height - scaledHeight) / 2.0f,
                                     scaledWidth,
                                     scaledHeight);
        commentsButton.frame = shotImage.frame;
        // картинка
        shotImage.hidden = false;
        shotImage.image = aImage;
        // крутилка
        [spinner stopAnimating];
    }
    else
        [spinner startAnimating];
    // заполним ячейку
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