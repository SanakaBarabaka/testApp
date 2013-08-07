//
//  UILabel+MultiLineAutoSize.m
//  TestApp
//
//  Created by Александр Кириченко on 07.08.13.
//
//

#import "UILabel+MultiLineAutoSize.h"

@implementation UILabel (MultiLineAutoSize)

- (void)adjustFontSizeToFit {
    UIFont *font = self.font;
    CGSize size = self.frame.size;
    
    for (CGFloat maxSize = self.font.pointSize; maxSize >= self.minimumScaleFactor * self.font.pointSize; maxSize -= 1.f) {
        font = [font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        CGSize labelSize = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
        if(labelSize.height <= size.height) {
            self.font = font;
            [self setNeedsLayout];
            break;
        }
    }
    
    // set the font to the minimum size anyway
    self.font = font;
    [self setNeedsLayout];
}

@end