//
//  OrderInfoCell.m
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//

#import "OrderInfoCell.h"

@interface OrderInfoCell ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation OrderInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configureCellWithInfo:(NSString *)info
{
    self.infoLabel.text = info;
}

- (CGFloat)heightForCell
{
    return 90.0f;
}

@end
