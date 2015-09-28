//
//  OrdersListViewController.m
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//
#import "OrderInfoCell.h"
#import "OrdersListViewController.h"
#import "ViewController.h"

@interface OrdersListViewController ()<UITableViewDataSource,UITabBarDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CGFloat previousYOffset;
@property (nonatomic) BOOL scrollFromParent;
@property (nonatomic) BOOL didPull;
@property (nonatomic) BOOL bounces;

@end

@implementation OrdersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollFromParent = NO;
    self.previousYOffset = 0.0f;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEnableScroll:(BOOL)enableScroll
{
    _enableScroll = enableScroll;
    self.tableView.scrollEnabled = enableScroll;
}

#pragma mark - UITableViewDelegate & DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OrderCell";
    OrderInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCellWithInfo:[NSString stringWithFormat:@"%zd",indexPath.row]];
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.0f;
}


- (CGPoint)getParentScrollOffset
{
    return [(ViewController *)self.parentViewController.parentViewController getCurrentContentOffset];
}

- (CGPoint)getParentThresholdOffset
{
    return [(ViewController *)self.parentViewController.parentViewController getThresholdOffset];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (_scrollFromParent)
        return;
    
    if (scrollView.contentOffset.y <= 0 &&!_didPull)
    {
        _didPull = YES;
        [self.delegate scrollViewDidBeginScrolling];
    }
    
    if (_didPull)
    {
        CGFloat diff =  (ceilf(self.previousYOffset - scrollView.contentOffset.y)); //abs value to prevent bouncing effect

        if (self.tableView.contentOffset.y >= 0 )
        {
            if ([self getParentScrollOffset].y < [self getParentThresholdOffset].y)
            {
                // parent has not scrolled to threshold point keep child scroll to zero offset.
                [self setContentOffsetToZero];
            }
            
            [self.delegate scrollWithOffset:diff];
        }
        else if (_bounces)
        {
            [self.delegate scrollWithOffset: fabs(diff)];
            [self setContentOffsetToZero];
        }

        if (self.tableView.contentOffset.y < 0)
        {
            self.bounces = YES;
        }
    }
    self.previousYOffset = scrollView.contentOffset.y;

}


- (void)setContentOffsetToZero
{
    CGPoint offset = self.tableView.contentOffset;
    offset.y = 0;
    self.tableView.contentOffset = offset;
}

- (void)scrollEnded
{
    self.tableView.scrollEnabled = !(self.tableView.contentOffset.y == 0);
    [self.delegate scrollViewDidEndScrolling];
    _didPull = NO;
    self.previousYOffset = 0;
    self.bounces = NO;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollEnded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollEnded];
    }
}

#pragma  mark - Method used by Parent
- (void)scrollWithOffset:(CGFloat)scrollOffset
{
    if (self.tableView.contentSize.height < self.tableView.bounds.size.height || [self getParentScrollOffset].y < [self getParentThresholdOffset].y)
    {
        // content is less than the screen size
        // if parent has nor reached threshold
        return;
    }
    self.scrollFromParent = YES;
    CGPoint offset = self.tableView.contentOffset;
    offset.y = MIN(self.tableView.contentSize.height- self.tableView.bounds.size.height, MAX(0,offset.y + scrollOffset));
    self.tableView.contentOffset = offset;
}

- (CGPoint)getCurrentContentOffset
{
    return self.tableView.contentOffset;
}


- (void)parentScrollDidEnd
{
    self.scrollFromParent = NO;
}



@end
