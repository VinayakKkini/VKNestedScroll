//
//  TitleCell.m
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//

#import "TitleCell.h"

@interface TitleCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectionIndicatorView;

@end

@implementation TitleCell


- (void)prepareForReuse
{
    [self setBackgroundColor: [UIColor whiteColor]];
    [self.selectionIndicatorView setBackgroundColor: [UIColor clearColor]];
}

- (void)configureCellWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
}


- (CGSize)getSizeForTitle:(NSString *)title
{
    return CGSizeZero;
#warning set height.
    
}

- (void)selectCell
{
    [self.selectionIndicatorView setBackgroundColor:[UIColor grayColor]];
}

- (void)deselectCell
{
    [self.selectionIndicatorView setBackgroundColor:[UIColor clearColor]];
}

@end
