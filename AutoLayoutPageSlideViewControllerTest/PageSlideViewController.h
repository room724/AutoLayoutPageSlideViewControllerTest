//
//  PageSlideViewController.h
//  AutoLayoutPageSlideViewControllerTest
//
//  Created by inock on 2016. 7. 17..
//  Copyright © 2016년 room724. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageSlideViewController;

@protocol PageSlideViewControllerDataSource <NSObject>

@required

- (NSInteger)pageCountInPageSlideViewController:(PageSlideViewController *)aPageSlideViewController;

- (UIViewController *)pageViewControllerAtPageIndex:(NSInteger)aPageIndex;

@end

@protocol PageSlideViewControllerDelegate <NSObject>

@optional

- (void)pageSlideViewController:(PageSlideViewController *)aPageSlideViewController didChangeSelectedPageIndex:(NSInteger)aPageIndex;

- (void)pageSlideViewController:(PageSlideViewController *)aPageSlideViewController didChangePageIndexOffset:(CGFloat)aPageIndexOffset;

@end

@interface PageSlideViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentSizeGuideView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentSizeGuideViewLeadingConstraint;

@property (weak, nonatomic) id<PageSlideViewControllerDataSource> dataSource;
@property (weak, nonatomic) id<PageSlideViewControllerDelegate> delegate;
@property (nonatomic) NSInteger selectedPageIndex;
@property (nonatomic) CGFloat marginTop;
@property (nonatomic) CGFloat marginBottom;

- (void)reloadData;

- (void)setSelectedPageIndex:(NSInteger)aPageIndex animated:(BOOL)aAnimated;

- (UIViewController *)selectedPageViewController;

- (UIViewController *)pageViewControllerAtPageIndex:(NSInteger)aPageIndex;

- (CGFloat)pageIndexOffset;

- (NSInteger)pageCount;

@end
