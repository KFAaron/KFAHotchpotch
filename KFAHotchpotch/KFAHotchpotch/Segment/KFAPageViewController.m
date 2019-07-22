//
//  KFAPageViewController.m
//  KFAHotchpotch
//
//  Created by KFAaron on 2019/7/22.
//  Copyright © 2019 KFAaron. All rights reserved.
//

#import "KFAPageViewController.h"
#import "KFAPageViewControllerItem.h"
#import "UIView+KFASement.h"

@interface KFAPageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation KFAPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self prepareDatasource];
    [self initDataSource];
    [self initContainerView];
    [self initSegmentedControl];
    
    KFAPageViewControllerItem *item = self.controllerItems.firstObject;
    UIViewController *vc = item.viewController;
    [self moveToViewController:vc];
}

#pragma mark - Init Methods

- (void)prepareDatasource {
    UIViewController *vc1 = [[UIViewController alloc] init];
    vc1.view.backgroundColor = [UIColor redColor];
    KFAPageViewControllerItem *item1 = [[KFAPageViewControllerItem alloc] init];
    item1.viewController = vc1;
    item1.segmentTitle = @"111";
    
    UIViewController *vc2 = [[UIViewController alloc] init];
    vc2.view.backgroundColor = [UIColor orangeColor];
    KFAPageViewControllerItem *item2 = [[KFAPageViewControllerItem alloc] init];
    item2.viewController = vc2;
    item2.segmentTitle = @"222";
    
    UIViewController *vc3 = [[UIViewController alloc] init];
    vc3.view.backgroundColor = [UIColor yellowColor];
    KFAPageViewControllerItem *item3 = [[KFAPageViewControllerItem alloc] init];
    item3.viewController = vc3;
    item3.segmentTitle = @"333";
    
    UIViewController *vc4 = [[UIViewController alloc] init];
    vc4.view.backgroundColor = [UIColor greenColor];
    KFAPageViewControllerItem *item4 = [[KFAPageViewControllerItem alloc] init];
    item4.viewController = vc4;
    item4.segmentTitle = @"444";
    
    UIViewController *vc5 = [[UIViewController alloc] init];
    vc5.view.backgroundColor = [UIColor cyanColor];
    KFAPageViewControllerItem *item5 = [[KFAPageViewControllerItem alloc] init];
    item5.viewController = vc5;
    item5.segmentTitle = @"555";
    
    UIViewController *vc6 = [[UIViewController alloc] init];
    vc6.view.backgroundColor = [UIColor blueColor];
    KFAPageViewControllerItem *item6 = [[KFAPageViewControllerItem alloc] init];
    item6.viewController = vc6;
    item6.segmentTitle = @"666";
    
    UIViewController *vc7 = [[UIViewController alloc] init];
    vc7.view.backgroundColor = [UIColor purpleColor];
    KFAPageViewControllerItem *item7 = [[KFAPageViewControllerItem alloc] init];
    item7.viewController = vc7;
    item7.segmentTitle = @"777";
    
    self.controllerItems = @[item1,item2,item3,item4,item5,item6,item7];
}

// 初始化数据
- (void)initDataSource {
    
    self.titleArray = [NSMutableArray arrayWithCapacity:0];
    self.viewControllers = [NSMutableArray arrayWithCapacity:0];
    for (KFAPageViewControllerItem *item in self.controllerItems) {
        [_titleArray addObject:item.segmentTitle];
        [_viewControllers addObject:item.viewController];
    }
    
    self.selectedIndex = NSNotFound;
}

// 初始化试图
- (void)initContainerView {
    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _containerView.pagingEnabled = YES;
    _containerView.showsVerticalScrollIndicator = NO;
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.delegate = self;
    [_containerView setContentSize:CGSizeMake(_containerView.width * [self.controllerItems count],_containerView.height)];
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        _containerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else
#endif
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:_containerView];
}

- (void)initSegmentedControl {
    _segmentedControl = [[KFASegmentControl alloc] initWithTitles:[_titleArray copy]];
    [self.segmentedControl setFrame:CGRectMake(0, 0, kScreenWidth, 52)];
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 10, 20);
    self.segmentedControl.horizontalPadding = 30;
    self.segmentedControl.showsIndicator = YES;
    self.segmentedControl.showBottomShadow = NO;
    self.segmentedControl.indicatorWidthStyle = KFASegmentedControlIndicatorWidthStyleBackground;
    self.segmentedControl.indicatorBackgroundColor = [UIColor redColor];
    [_segmentedControl addTarget:self action:@selector(selectedTabIndex:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [_segmentedControl segmentControlDidScroll:scrollView];
    
    // 根据当前的x坐标和页宽度计算出当前页数
    NSUInteger index = roundf(scrollView.contentOffset.x/scrollView.width);
    if (_selectedIndex != index) {
        [self moveToChildViewControllerAtIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_segmentedControl segmentControlDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [_segmentedControl segmentControlDidEndScrollingAnimation:scrollView];
}

#pragma mark - BPPageViewControllerMoveEvent

///即将移动到某个VC
- (void)willMoveFrom:(UIViewController *)selectedViewController to:(UIViewController *)viewController {
    
    if ([selectedViewController respondsToSelector:@selector(willMoveToViewController:)]) {
        [selectedViewController willMoveToViewController:viewController];
    }
    if ([viewController respondsToSelector:@selector(willEnterFromViewController:)]) {
        [viewController willEnterFromViewController:selectedViewController];
    }
}

///已经移动到某个VC
- (void)didMoveFrom:(UIViewController *)selectedViewController to:(UIViewController *)viewController {
    if ([selectedViewController respondsToSelector:@selector(didMoveToViewController:)]) {
        [selectedViewController didMoveToViewController:viewController];
    }
    if ([viewController respondsToSelector:@selector(didEnterFromViewController:)]) {
        [viewController didEnterFromViewController:selectedViewController];
    }
}

#pragma mark - Public Methods

///插入一个VC
- (void)insertViewControllerItem:(KFAPageViewControllerItem *)viewControllerItem atIndex:(NSUInteger)index {
    
    [_viewControllers insertObject:viewControllerItem.viewController atIndex:index];
    NSUInteger selectedIndex = _segmentedControl.selectedSegmentIndex;
    _segmentedControl.selectedSegmentIndex = selectedIndex;
    NSUInteger viewControllerCount = [_viewControllers count];
    for (NSUInteger i = index + 1; i < viewControllerCount; i++) {
        UIViewController *viewController = [_viewControllers objectAtIndex:i];
        if ([self.childViewControllers containsObject:viewController]) {
            viewController.view.x += _containerView.width;
        }
    }
    
    [self.containerView setContentSize:CGSizeMake(self.containerView.contentSize.width + self.containerView.width, self.containerView.contentSize.height)];
}

///删除一个VC
- (void)removeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [_viewControllers indexOfObject:viewController];
    if (index != NSNotFound) {
        if (self.selectedIndex == index) {
            _segmentedControl.selectedSegmentIndex = 0;
        }
        
        [_viewControllers removeObjectAtIndex:index];
        NSUInteger selectedIndex = _segmentedControl.selectedSegmentIndex;
        _segmentedControl.selectedSegmentIndex = selectedIndex;
        
        if ([self.childViewControllers containsObject:viewController]) {
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
        
        NSUInteger viewControllerCount = [_viewControllers count];
        for (NSUInteger i = index; i < viewControllerCount; i++) {
            UIViewController *viewController = [_viewControllers objectAtIndex:i];
            if ([self.childViewControllers containsObject:viewController]) {
                viewController.view.x -= _containerView.width;
            }
        }
        
        [self.containerView setContentSize:CGSizeMake(self.containerView.contentSize.width - self.containerView.width, self.containerView.contentSize.height)];
    }
}

///移动到某个VC
- (void)moveToViewController:(UIViewController *)viewController {
    NSUInteger index = [_viewControllers indexOfObject:viewController];
    
    if (index != NSNotFound) {
        if (_selectedIndex == NSNotFound && index == 0) {
            [self moveToChildViewControllerAtIndex:index];
        }else if(_selectedIndex != index) {
            [_containerView setContentOffset:CGPointMake(_containerView.width * index, _containerView.contentOffset.y)];
        }
        [_segmentedControl setSelectedSegmentIndex:index ignoreAction:YES];
    }
}


//查询某个VC的index
- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    return [_viewControllers indexOfObject:viewController];
}

//移动到某个VC
- (void)didGoToViewController:(UIViewController *)viewController{
    return;
}

- (NSUInteger)selectedViewIndex {
    return self.selectedIndex;
}

#pragma mark - Methods

- (void)moveToChildViewControllerAtIndex:(NSUInteger)index {
    
    UIViewController *viewController = [_viewControllers objectAtIndex:index];
    UIViewController *selectedViewController = nil;
    if (_selectedIndex < _viewControllers.count) {
        selectedViewController = [_viewControllers objectAtIndex:_selectedIndex];
    }
    [self willMoveFrom:selectedViewController to:viewController];
    if (![self.childViewControllers containsObject:viewController]) {
        [self addChildViewController:viewController];
        [viewController.view setFrame:CGRectMake(self.view.width * index, _segmentedControl.height, self.view.width, kScreenHeight - [[UIApplication sharedApplication] statusBarFrame].size.height - 44.0f - _segmentedControl.height)];
        [self.containerView addSubview:viewController.view];
    }
    [self didMoveFrom:selectedViewController to:viewController];
    
    _selectedIndex = index;
    
    if ([self respondsToSelector:@selector(didGoToViewController:)]) {
        [self didGoToViewController:viewController];
    }
}

#pragma mark - Actions

- (void)selectedTabIndex:(KFASegmentControl *)segmentedControl {
    
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    if (_selectedIndex != index) {
        [_containerView setContentOffset:CGPointMake(_containerView.width * index, _containerView.contentOffset.y)];
    }
    
    NSString *title = [self.titleArray objectAtIndex:index];
    [self statisticsTitle:title];
}

// 点击segment埋点用
- (void)statisticsTitle:(NSString *)title {
    // 子类实现
}

#pragma mark - Setters

- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;
    _containerView.scrollEnabled = scrollEnable;
}

@end
