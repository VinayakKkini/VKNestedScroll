//
//  OrdersListViewController.h
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderScrollDelegate<NSObject>

- (void)scrollViewDidBeginScrolling;
- (void)scrollWithOffset:(CGFloat)offset;
- (void)scrollViewDidEndScrolling;

@end

@interface OrdersListViewController : UIViewController

@property (nonatomic) NSUInteger index;
@property (nonatomic) BOOL enableScroll;
@property (nonatomic, weak) id<OrderScrollDelegate> delegate;

- (void)scrollWithOffset:(CGFloat)offset;
- (CGPoint)getCurrentContentOffset;
- (void)parentScrollDidEnd;

@end