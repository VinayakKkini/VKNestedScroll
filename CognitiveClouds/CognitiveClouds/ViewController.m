    //
//  ViewController.m
//  VKNestedScroll
//
//  Created by Vinayak Kini on 26/09/15.
//  Copyright (c) 2015 Vinayak Kini. All rights reserved.
//

#import "ViewController.h"
#import "TitleCell.h"
#import "OrderInfoCell.h"
#import "OrdersListViewController.h"
#import "UIImage+Additions.h"

NSInteger kCollectionCellCount = 10;

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate,OrderScrollDelegate>

@property (weak, nonatomic) IBOutlet UIView *collectionViewContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *pageContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableDictionary *viewControllerDictionary;
@property (nonatomic) CGFloat previousYOffset;
@property (nonatomic) BOOL pulling;
@property (nonatomic) BOOL bounced;
@property (nonatomic) BOOL scrollFromChild;

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger nextPage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.heightConstraint.constant =CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(self.collectionView.bounds) - [self navigationBarHeight];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)navigationBarHeight
{
    return CGRectGetHeight(self.navigationController.navigationBar.frame) + 20.0f;// add statusbar height
}

- (void)setUp
{
    self.viewControllerDictionary = [NSMutableDictionary dictionary];
    [self setupCollectionView];
    [self configurePageViewController];
    [self setUpTransparentNavigationBar];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)setUpTransparentNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)setNavigationBarImageWithAlpha:(CGFloat)alpha
{
    CGFloat colorValue = 100.0f/225.0f;
    UIImage *image = [UIImage imageWithColor:[UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:alpha]];
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
}


- (void)configurePageViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.pageViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.currentPage = 0;
    
    CGRect frame = self.pageContainerView.frame;
    frame.origin = CGPointZero;
    self.pageViewController.view.frame = frame;
    
    OrdersListViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.pageContainerView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    self.pageViewController.view.backgroundColor = [UIColor redColor];

}

#pragma mark - CollectionView DataSource and Delegate Methods
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kCollectionCellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"TitleCell";
    TitleCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configureCellWithTitle:[NSString stringWithFormat:@"Page %zd",indexPath.row]];
    if (indexPath.row == self.currentPage)
        [cell selectCell];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentPage != indexPath.row)
    {
        [self performSelector:@selector(tabSelectionDidChangeToIndex:) withObject:@(indexPath.row) afterDelay:0];
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return CGSizeMake(100, 44);
}

- (void)scrollToItemAtIndex:(NSUInteger)index
{
    if(index == NSNotFound || index >= kCollectionCellCount)
        return;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}

- (void)tabSelectionDidChangeToIndex:(NSNumber*)index
{
    NSUInteger page = index.integerValue;
    
    if (page == self.currentPage)
        return;

    [self deselectPreviousTab];
    NSUInteger direction = (page < self.currentPage)? UIPageViewControllerNavigationDirectionReverse :  UIPageViewControllerNavigationDirectionForward;
    self.currentPage = page;
    
    __weak typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:page]] direction:direction animated:YES completion:^(BOOL finished) {
        [weakSelf selectCurrentTab];
    }];
    [self scrollToItemAtIndex:page];
}

- (void)deselectPreviousTab
{
   TitleCell *cell = (TitleCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    [cell deselectCell];

}

- (void)selectCurrentTab
{
    TitleCell *cell = (TitleCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    [cell selectCell];
    
}

- (OrdersListViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index > kCollectionCellCount)
        return nil;
    
    if (self.viewControllerDictionary[@(index)] != nil)
    {
        OrdersListViewController *viewController = self.viewControllerDictionary[@(index)];
        viewController.enableScroll = ([self getThresholdOffset].y == self.scrollView.contentOffset.y);

        return viewController;
    }
    
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    OrdersListViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"OrdersListViewController"];
    self.viewControllerDictionary[@(index)] = viewController;
    viewController.index = index;
    viewController.delegate = self;
    viewController.enableScroll = ([self getThresholdOffset].y == self.scrollView.contentOffset.y);

    return viewController;
}

#pragma  mark - UIPageViewControllerDataSource & UIPageViewControllerDelegate Methods
#pragma mark -
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [(OrdersListViewController *)viewController index];
    if (index == 0 || index == NSNotFound)
    {
        return nil;
    }
    
    index --;
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(OrdersListViewController *)viewController index];
    if (index+1 == kCollectionCellCount || index == NSNotFound)
    {
        return nil;
    }
    
    index ++;
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(completed){
        
        [self deselectPreviousTab];
        self.currentPage = self.nextPage;
        OrdersListViewController *viewController = [self viewControllerAtIndex:self.currentPage];
        viewController.enableScroll = ([self getThresholdOffset].y == self.scrollView.contentOffset.y);
        [self scrollToItemAtIndex:self.currentPage];
        [self selectCurrentTab];
    }
    self.nextPage = NSNotFound;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.nextPage = [(OrdersListViewController *)pendingViewControllers.firstObject index];
}

- (CGPoint)getCurrentContentOffset
{
    return self.scrollView.contentOffset;
}


- (CGPoint)getThresholdOffset
{
    return CGPointMake(0, CGRectGetHeight(self.headerView.frame) - [self navigationBarHeight]);
}


#pragma  mark - UIScrollViewDelegate
#pragma mark -
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat navigationBarHeight = [self navigationBarHeight];
    CGFloat yOffset = CGRectGetHeight(self.headerView.frame) - navigationBarHeight;
    
    CGPoint point = scrollView.contentOffset;
    point.y += navigationBarHeight;
    
    if (scrollView.contentOffset.y > yOffset && !_pulling)
    {
        self.pulling = YES;
    }
    else
    {
        [self setNavigationBarImageWithAlpha:scrollView.contentOffset.y/yOffset];

    }
    
    if (_pulling && !_scrollFromChild)
    {
        //pass the content offset to child scroll.
        CGFloat diff = (ceilf(self.previousYOffset - scrollView.contentOffset.y));
        OrdersListViewController *childViewController = [self viewControllerAtIndex:self.currentPage];
        if (self.previousYOffset - scrollView.contentOffset.y > 0)
        {
            if ([childViewController getCurrentContentOffset].y > 0)
            {
                // scroll child view to top before scrolling parent scroll
                [self snapUpScrollView];
                [childViewController scrollWithOffset:-diff];
            }
            else
            {
                diff = (_bounced)? -diff : fabs(diff);
                [childViewController scrollWithOffset:diff];
            }
        }
        else
        {
            [childViewController scrollWithOffset:fabs(diff)];
        }
    }
    
    if (self.scrollView.contentOffset.y > self.scrollView.contentSize.height - CGRectGetHeight([UIScreen mainScreen].bounds))
    {
        // prevent bottom bouncing.
        [self snapUpScrollView];
        self.bounced = YES;
    }
    
    if (self.scrollView.contentOffset.y < 0)
    {
        // prevent top bouncing.
        self.bounced = YES;
    }
    
    self.previousYOffset = scrollView.contentOffset.y;
}

- (void)snapUpScrollView
{
    CGPoint offset = self.scrollView.contentOffset;
    offset.y = self.collectionViewContainer.frame.origin.y - [self navigationBarHeight];
    self.scrollView.contentOffset = offset;
}

- (void)scrollEnded
{
    _pulling = NO;
    self.previousYOffset = 0;
    self.bounced = NO;
    CGFloat navigationBarHeight = [self navigationBarHeight];
    CGPoint point = self.collectionViewContainer.frame.origin;
    point.y -= navigationBarHeight;
    self.scrollView.scrollEnabled = !(self.scrollView.contentOffset.y ==  point.y);
    OrdersListViewController *vc = [self viewControllerAtIndex:self.currentPage];
    vc.enableScroll = (self.scrollView.contentOffset.y ==  point.y);
    [vc parentScrollDidEnd];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollEnded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self scrollEnded];
    }

}

#pragma mark - OrderScrollDelegate
#pragma mark -

- (void)scrollViewDidBeginScrolling
{
    self.scrollView.scrollEnabled = NO;
    self.scrollFromChild = YES;
}

- (void)scrollWithOffset:(CGFloat)yOffset
{
    CGPoint point = self.scrollView.contentOffset;
    point.y = MAX(0, (point.y - yOffset));
    self.scrollView.contentOffset = point;
}

- (void)scrollViewDidEndScrolling
{
    self.scrollView.scrollEnabled = YES;
    self.scrollFromChild = NO;

}

@end
