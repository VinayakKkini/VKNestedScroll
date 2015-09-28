//
//  OrderInfoCell.h
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderInfoCell : UITableViewCell

- (void)configureCellWithInfo:(NSString *)info;
- (CGFloat)heightForCell;

@end
