//
//  ViewController.m
//  AutoLayoutPageSlideViewControllerTest
//
//  Created by inock on 2016. 7. 17..
//  Copyright © 2016년 room724. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) PageSlideViewController *pageSlideViewController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_pageSlideViewController reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //
}

- (void)prepareForSegue:(UIStoryboardSegue *)aSegue sender:(id)aSender
{
    if ([[aSegue identifier] isEqualToString:@"PAGE"])
    {
        _pageSlideViewController = [aSegue destinationViewController];
        [_pageSlideViewController setMarginTop:100];
        [_pageSlideViewController setMarginBottom:50];
        [_pageSlideViewController setDataSource:self];
    }
}

#pragma mark - PageSlideViewControllerDataSource

- (NSInteger)pageCountInPageSlideViewController:(PageSlideViewController *)aPageSlideViewController
{
    return 3;
}

- (UIViewController *)pageViewControllerAtPageIndex:(NSInteger)aPageIndex
{
    UIViewController *sPageViewController = [[UIViewController alloc] init];
    
    if (aPageIndex == 0)
    {
        [[sPageViewController view] setBackgroundColor:[UIColor redColor]];
    }
    else if (aPageIndex == 1)
    {
        [[sPageViewController view] setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        [[sPageViewController view] setBackgroundColor:[UIColor blueColor]];
    }
    
    return sPageViewController;
}

@end
