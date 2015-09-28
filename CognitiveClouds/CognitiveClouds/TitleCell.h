//
//  TitleCell.h
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleCell : UICollectionViewCell

- (void)configureCellWithTitle:(NSString *)title;
- (CGSize)getSizeForTitle:(NSString *)title;
- (void)selectCell;
- (void)deselectCell;

@end
