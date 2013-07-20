//
//  based on EGORefreshTableHeaderView.h
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//

/*usage:
 ////header
 GEPullView *refreshHeaderView = [[[GEPullView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)]autorelease];
 refreshHeaderView.delegate = self;
 refreshHeaderView.position = ViewPositon_Top;
 [self.tableView addSubview:refreshHeaderView];
 self.refreshHeaderView = refreshHeaderView;
 
 ////footer
 GEPullView *nextPageFooterView = [[[GEPullView alloc] initWithFrame:CGRectMake(0.0f, self.tableView.contentSize.height, self.tableView.frame.size.width, 60)]autorelease];
 nextPageFooterView.delegate = self;
 nextPageFooterView.position = ViewPositon_Bottom;
 [self.tableView addSubview:nextPageFooterView];
 self.nextPageFooterView = nextPageFooterView;
 
 */
#define THRESHOLD 56.0f
#define NOTE_PERSISTANT_TIMER @"NOTE_PERSISTANT_TIMER"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
    ViewPositon_Top = 0,
    ViewPositon_Bottom,
}ViewPositon;

@protocol GEPullViewDelegate;


@interface GEPullView : UIView

@property(nonatomic,assign) id <GEPullViewDelegate> delegate;
@property(nonatomic,retain) NSDate* lastUpdatedDate;//when finished loading,u should reset it.
@property(nonatomic,copy) NSString* arrowImageName;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,assign) ViewPositon position;//to identify header or footer.default is top(header).

- (void)statusJudgementFromScrollView:(UIScrollView *)scrollView;//should be excuted in super view's delegate method - (void)scrollViewDidScroll:(UIScrollView *)scrollView
- (void)triggerJudgementFromScrollView:(UIScrollView *)scrollView;//should be excuted in super view's delegate method- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

//should be excuted when loading action in delegate protocol is finished
- (void)scrollViewDidFinishedLoading:(UIScrollView *)scrollView;
//when next page is finished loading,u should reset the frame of footer view. just for footer.
-(void)footerFrameReset;

@end

#pragma mark - GEPullViewDelegate
@protocol GEPullViewDelegate<NSObject>
//the refresh action
- (void)GEPullViewDidTriggerRefresh:(GEPullView*)headerView;
//the load next page action
- (void)GEPullViewDidTriggerLoadNextPage:(GEPullView*)footerView;
@end







