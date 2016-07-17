//
//  PageSlideViewController.m
//  AutoLayoutPageSlideViewControllerControllerTest
//
//  Created by inock on 2016. 7. 17..
//  Copyright © 2016년 room724. All rights reserved.
//

#import "PageSlideViewController.h"

@interface PageSlideViewController ()

@property (nonatomic) NSMutableArray *cachedPageViewControllers;
@property (nonatomic) NSInteger visiblePageIndexMin;
@property (nonatomic) NSInteger visiblePageIndexMax;

@end

@implementation PageSlideViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _selectedPageIndex = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //
}

#pragma mark - Public

- (void)reloadData
{
    _visiblePageIndexMin = -1;
    _visiblePageIndexMax = -1;
    
    NSInteger sPageCount = [_dataSource pageCountInPageSlideViewController:self];
    
    [_scrollView setScrollEnabled:sPageCount > 1];
    
    [self resetCachedPageViewControllersWithPageCount:sPageCount];
    [self resetContentSizeGuideViewLeadingWithPageCount:sPageCount];
    
    if (![self updateScrollViewContentOffsetWithPageIndex:_selectedPageIndex animated:NO])
    {
        [self didScroll];
        [self didEndScroll];
    }
}

- (void)setSelectedPageIndex:(NSInteger)aPageIndex animated:(BOOL)aAnimated
{
    [self updateScrollViewContentOffsetWithPageIndex:aPageIndex animated:aAnimated];
}

- (void)setSelectedPageIndex:(NSInteger)aPageIndex
{
    [self setSelectedPageIndex:aPageIndex animated:YES];
}

- (UIViewController *)selectedPageViewController
{
    return [self pageViewControllerAtPageIndex:_selectedPageIndex];
}

- (UIViewController *)pageViewControllerAtPageIndex:(NSInteger)aPageIndex
{
    if (aPageIndex < 0 || aPageIndex >= [_cachedPageViewControllers count])
    {
        return nil;
    }
    
    id sObject = [_cachedPageViewControllers objectAtIndex:aPageIndex];
    
    return [sObject isKindOfClass:[UIViewController class]] ? sObject : nil;
}

- (CGFloat)pageIndexOffset
{
    return [_scrollView contentOffset].x / CGRectGetWidth([_scrollView bounds]);
}

- (NSInteger)pageCount
{
    return [_cachedPageViewControllers count];
}

- (void)setMarginTop:(CGFloat)aMarginTop
{
    _marginTop = aMarginTop;
    
    [self updateConstraintsOfAllPageViews];
}

- (void)setMarginBottom:(CGFloat)aMarginBottom
{
    _marginBottom = aMarginBottom;
    
    [self updateConstraintsOfAllPageViews];
}

#pragma mark - Private

- (void)resetCachedPageViewControllersWithPageCount:(NSInteger)aPageCount
{
    [self uncacheAllPageViewControllers];
    
    _cachedPageViewControllers = [NSMutableArray arrayWithCapacity:aPageCount];
    
    for (NSInteger i = 0; i < aPageCount; i ++)
    {
        [_cachedPageViewControllers addObject:[NSNull null]];
    }
}

- (void)resetContentSizeGuideViewLeadingWithPageCount:(NSInteger)aPageCount
{
    CGFloat sLeading = CGRectGetWidth([_scrollView bounds]) * aPageCount - CGRectGetWidth([_contentSizeGuideView frame]);
    
    [_contentSizeGuideViewLeadingConstraint setConstant:sLeading];
}

- (UIViewController *)cachePageViewControllerAtPageIndex:(NSInteger)aPageIndex
{
    UIViewController *sPageViewController = [self pageViewControllerAtPageIndex:aPageIndex];
    
    if (!sPageViewController)
    {
        sPageViewController = [_dataSource pageViewControllerAtPageIndex:aPageIndex];
        [[sPageViewController view] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_cachedPageViewControllers replaceObjectAtIndex:aPageIndex withObject:sPageViewController];
    }
    
    return sPageViewController;
}

- (UIViewController *)uncachePageViewControllerAtPageIndex:(NSInteger)aPageIndex
{
    UIViewController *sPageViewController = [self pageViewControllerAtPageIndex:aPageIndex];
    
    if (sPageViewController)
    {
        [[sPageViewController view] removeFromSuperview];
        [sPageViewController removeFromParentViewController];
        [_cachedPageViewControllers replaceObjectAtIndex:aPageIndex withObject:[NSNull null]];
    }
    
    return sPageViewController;
}

- (void)uncacheAllPageViewControllers
{
    for (NSInteger i = 0; i < [self pageCount]; i ++)
    {
        [self uncachePageViewControllerAtPageIndex:i];
    }
}

- (BOOL)updateScrollViewContentOffsetWithPageIndex:(NSInteger)aPageIndex animated:(BOOL)aAnimated
{
    CGPoint sContentOffset = CGPointMake([self pageViewLeadingWithPageIndex:aPageIndex], 0);
    
    if (CGPointEqualToPoint([_scrollView contentOffset], sContentOffset))
    {
        return NO;
    }
    
    [_scrollView setContentOffset:sContentOffset animated:aAnimated];
    
    return YES;
}

- (void)updateConstraintsOfAllPageViews
{
    for (NSInteger i = 0; i < [self pageCount]; i ++)
    {
        UIView *sPageView = [[self pageViewControllerAtPageIndex:i] view];
        
        if (![sPageView superview])
        {
            continue;
        }
        
        [self updateConstraintsOfPageView:sPageView withPageIndex:i];
    }
}

- (void)updateConstraintsOfPageView:(UIView *)aPageView withPageIndex:(NSInteger)aPageIndex
{
    BOOL sHasConstraints = NO;
    CGFloat sLeadingConstant = [self pageViewLeadingWithPageIndex:aPageIndex];
    CGFloat sTopConstant = _marginTop;
    CGFloat sHeightConstant = - _marginTop - _marginBottom;
    
    for (NSLayoutConstraint *sConstraint in [_scrollView constraints])
    {
        if ([sConstraint firstItem] == aPageView)
        {
            sHasConstraints = YES;
            
            switch ([sConstraint firstAttribute])
            {
                case NSLayoutAttributeLeading:
                    [sConstraint setConstant:sLeadingConstant];
                    break;
                    
                case NSLayoutAttributeTop:
                    [sConstraint setConstant:sTopConstant];
                    break;
                    
                case NSLayoutAttributeHeight:
                    [sConstraint setConstant:sHeightConstant];
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (!sHasConstraints)
    {
        [_scrollView addConstraints:@[ [NSLayoutConstraint constraintWithItem:aPageView
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_scrollView
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:sLeadingConstant],
                                       [NSLayoutConstraint constraintWithItem:aPageView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_scrollView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:sTopConstant],
                                       [NSLayoutConstraint constraintWithItem:aPageView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_scrollView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1
                                                                     constant:0],
                                       [NSLayoutConstraint constraintWithItem:aPageView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_scrollView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1
                                                                     constant:sHeightConstant]
                                       ]];
    }
}

- (CGFloat)pageViewLeadingWithPageIndex:(NSInteger)aPageIndex
{
    CGFloat sContentWidth = [_contentSizeGuideViewLeadingConstraint constant] + CGRectGetWidth([_contentSizeGuideView frame]);
    
    return MIN(MAX(CGRectGetWidth([_scrollView bounds]) * aPageIndex, 0), sContentWidth - CGRectGetWidth([_scrollView bounds]));
}

- (void)didScroll
{
    NSInteger sVisiblePageIndexMin = MIN(MAX(floorf([self pageIndexOffset]), 0), [self pageCount] - 1);
    NSInteger sVisiblePageIndexMax = MIN(MAX(ceilf([self pageIndexOffset]), 0), [self pageCount] - 1);
    
    if (_visiblePageIndexMin == sVisiblePageIndexMin && _visiblePageIndexMax == sVisiblePageIndexMax)
    {
        return;
    }
    
    _visiblePageIndexMin = sVisiblePageIndexMin;
    _visiblePageIndexMax = sVisiblePageIndexMax;
    
    for (NSInteger i = 0; i < [self pageCount]; i ++)
    {
        UIViewController *sPageViewController = [self pageViewControllerAtPageIndex:i];
        
        if (sVisiblePageIndexMin <= i && i <= sVisiblePageIndexMax)
        {
            if (!sPageViewController)
            {
                sPageViewController = [self cachePageViewControllerAtPageIndex:i];
            }
            
            [_scrollView addSubview:[sPageViewController view]];
            [self addChildViewController:sPageViewController];
            [self updateConstraintsOfPageView:[sPageViewController view] withPageIndex:i];
        }
        else
        {
            [[sPageViewController view] removeFromSuperview];
            [sPageViewController removeFromParentViewController];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(pageSlideViewController:didChangePageIndexOffset:)])
    {
        [_delegate pageSlideViewController:self didChangePageIndexOffset:[self pageIndexOffset]];
    }
}

- (void)didEndScroll
{
    NSInteger sSelectedPageIndex = MIN(MAX([self pageIndexOffset], -1), [self pageCount] - 1);
    
    if (_selectedPageIndex == sSelectedPageIndex)
    {
        return;
    }
    
    _selectedPageIndex = sSelectedPageIndex;
    
    if ([_delegate respondsToSelector:@selector(pageSlideViewController:didChangeSelectedPageIndex:)])
    {
        [_delegate pageSlideViewController:self didChangeSelectedPageIndex:_selectedPageIndex];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [self didScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    [self didEndScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    [self didEndScroll];
}

@end
