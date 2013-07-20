//
//  GEPullTableView.h
//
//  Created by SUN YANLIANG on 13-7-16.
//
/*
 @brief 本表视图的功能有：1、无列表内容时显示无内容提示;
                       2、支持底部工具条的隐显;
                       3、下拉刷新，上拉加载下一页;
                       4、上下拉视图的更新时间的显示需要有一个持久定时器去不断发通知-NOTE_PERSISTANT_TIMER;
 @remark 用组合控件的形式做的，后期要改为控件继承，因为好多方法要转指，很烦。
 */
#import <UIKit/UIKit.h>
#import "GEPullView.h"

@protocol GEPullTableViewDelegate;


@interface GEPullTableView : UIView


@property (assign, nonatomic) id<GEPullTableViewDelegate,UITableViewDataSource,UITableViewDelegate> delegate;

@property (nonatomic, retain) UITableView* tableView;

@property (retain, nonatomic) UIView* nothingView;
@property (retain, nonatomic) UIImage* nothingImage;//if there is no nothingView,nothingImage will be used.

@property (retain, nonatomic) UIView* bottomBar;//default position should below the bottom of key screen


//setting for refresh header view.
- (void)didFinishedRefreshWithNewData:(BOOL)hasNewData;//should be excuted when loading action in delegate protocol is finished

//setting for load next page footer view.
- (void)didFinishedLoadNextPageWithNewData:(BOOL)hasNewData;//should be excuted when loading action in delegate protocol is finished

//simulate pull down refresh
- (void)scrollViewPullDownRefreshSimulation;

//used when initialization was done to show toolBar 
- (void)showToolBarAnimated;

@end


@protocol GEPullTableViewDelegate <NSObject>

//the refresh action
- (void)GEPullTableViewDidTriggerRefresh:(GEPullView*)headerView;
//the load next page action
- (void)GEPullTableViewDidTriggerLoadNextPage:(GEPullView*)footerView;

@end