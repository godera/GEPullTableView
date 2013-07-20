//
//  GEPullTableView.h
//
//  Created by SUN YANLIANG on 13-7-16.
//

#import "GEPullTableView.h"

@interface GEPullTableView ()<GEPullViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) GEPullView* refreshHeaderView;
@property (nonatomic, assign) GEPullView* nextPageFooterView;

@property (nonatomic, assign) float originY;
@property (nonatomic, assign) BOOL noGoods;

@property (nonatomic, assign) BOOL needShowHideToolBar;//should be set yes when next page loading was done ever ok or faild

@end


@implementation GEPullTableView

- (void)dealloc
{
    [_nothingImage release];
    [_bottomBar release];
    
    [_tableView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.originY = 0.0f;
        self.needShowHideToolBar = YES;
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    UITableView* table = [[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain] autorelease];
    table.dataSource = self;
    table.delegate = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:table];
    self.tableView = table;

    ////header
    GEPullView *refreshHeaderView = [[[GEPullView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)]autorelease];
    refreshHeaderView.delegate = self;
    refreshHeaderView.position = ViewPositon_Top;
    [self.tableView addSubview:refreshHeaderView];
    self.refreshHeaderView = refreshHeaderView;
    
    ////footer
    GEPullView *nextPageFooterView = [[[GEPullView alloc] initWithFrame:CGRectZero]autorelease];
    nextPageFooterView.delegate = self;
    nextPageFooterView.position = ViewPositon_Bottom;
    [self.tableView addSubview:nextPageFooterView];
    self.nextPageFooterView = nextPageFooterView;
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];    
}

#pragma mark - KVO for self.tableView.contentSize
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.nextPageFooterView footerFrameReset];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (scrollView.contentOffset.y + scrollView.bounds.size.height < scrollView.contentSize.height) {
        [self bottomBarHideShowJudgement:scrollView];
    }

    [self.refreshHeaderView statusJudgementFromScrollView:scrollView];
    [self.nextPageFooterView statusJudgementFromScrollView:scrollView];

    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    [self.refreshHeaderView triggerJudgementFromScrollView:scrollView];
    [self.nextPageFooterView triggerJudgementFromScrollView:scrollView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

//在begin方法里初始化，包括手势的begin和触摸的begin，以及scrollView的dragging的begin
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.originY = self.tableView.contentOffset.y;
}

-(void)bottomBarHideShowJudgement:(UIScrollView*)scrollView
{
    CGFloat deltaY = self.originY - scrollView.contentOffset.y;
    
    if (deltaY < -50) {
        [self hideView:self.bottomBar Animated:YES];
    }else if (deltaY > 1) {
        [self showView:self.bottomBar Animated:YES];
    }
}

- (void)scrollViewPullDownRefreshSimulation
{
    [self.tableView setContentOffset:CGPointMake(0, -THRESHOLD) animated:NO];
    [self scrollViewDidEndDragging:self.tableView willDecelerate:YES];
}

#pragma mark - GEPullViewDelegate
-(void)GEPullViewDidTriggerRefresh:(GEPullView *)headerView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(GEPullTableViewDidTriggerRefresh:)]) {
        [self.delegate GEPullTableViewDidTriggerRefresh:headerView];
    }
}

-(void)GEPullViewDidTriggerLoadNextPage:(GEPullView *)footerView
{
    [self hideView:self.bottomBar Animated:YES];
//    self.needShowHideToolBar = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(GEPullTableViewDidTriggerLoadNextPage:)]) {
        [self.delegate GEPullTableViewDidTriggerLoadNextPage:footerView];
    }
}

- (void)hideView:(UIView*)view Animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.center = CGPointMake(view.superview.frame.size.width / 2.0, view.superview.frame.size.height + view.frame.size.height / 2.0);
        } completion:^(BOOL finished) {

        }];
    }else{
        view.center = CGPointMake(view.superview.frame.size.width / 2.0, view.superview.frame.size.height + view.frame.size.height / 2.0);
    }
}

- (void)showView:(UIView*)view Animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.center = CGPointMake(view.superview.frame.size.width / 2.0, view.superview.frame.size.height - view.frame.size.height / 2.0);
        } completion:^(BOOL finished) {

        }];
    }else{
        view.center = CGPointMake(view.superview.frame.size.width / 2.0, view.superview.frame.size.height - view.frame.size.height / 2.0);
    };
}

- (void)showToolBarAnimated
{
    [self showView:self.bottomBar Animated:YES];
}

//just support one section now
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        n = [self.delegate tableView:tableView numberOfRowsInSection:section];
    }
    if (n == 0) {
        self.noGoods = YES;
        return 1;
    }else if(n < 0){//delegate return any value less than zero means shouldn't display noGoods View
        return 0;
    }else{
        self.noGoods = NO;
        return n;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.noGoods) {
        
        UITableViewCell* cell = [[[UITableViewCell alloc] init] autorelease];
        cell.frame = tableView.bounds;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.nothingView) {
            self.nothingView.center = CGPointMake(cell.bounds.size.width / 2.0, (cell.bounds.size.height - self.bottomBar.bounds.size.height) / 2.0 );
            [cell.contentView addSubview:self.nothingView];
        }else{
            UIImageView* noGoodsIV = [[[UIImageView alloc] initWithImage:self.nothingImage] autorelease];
            noGoodsIV.frame = cell.bounds;
            noGoodsIV.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:noGoodsIV];
        }
        
        return cell;
        
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
            return [[[self.delegate tableView:tableView cellForRowAtIndexPath:indexPath]retain]autorelease];
        }else{
            
            static NSString* cellID = @"no Cell return id";
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
                cell.textLabel.text = @"no Cell return";
            }
            return cell;
            
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.noGoods) {
        return self.tableView.bounds.size.height;
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
            return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
        }else{
            return 44;
        }
    }
    
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    
//}
//
//#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
//        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
//        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
//        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
//        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
//        [self.delegate tableView:tableView heightForHeaderInSection:section];
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
//        [self.delegate tableView:tableView heightForFooterInSection:section];
//    }
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
//        [self.delegate tableView:tableView viewForHeaderInSection:section];
//    }
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
//        [self.delegate tableView:tableView viewForFooterInSection:section];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
//        [self.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//    }
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
//    }
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
//    }
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
//    }
//}
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
//
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
//    }
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
//    }
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
//    }
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
//    }
//}
//
//- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
//    }
//}
//
//- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)]) {
//        [self.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
//    }
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
//        [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
//    }
//}
//
//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)]) {
//        return [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
//    }
//    return 0;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]) {
//        return [self.delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
//    }
//    return YES;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]) {
//        return [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
//    }
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
//        [self.delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
//    }
//}

#pragma mark - Manual Controlled Methods
- (void)didFinishedRefreshWithNewData:(BOOL)hasNewData
{
    if (hasNewData) {
        [self.tableView reloadData];
    }
    
    self.refreshHeaderView.lastUpdatedDate = [NSDate date];
    [self.refreshHeaderView scrollViewDidFinishedLoading:self.tableView];
}

- (void)didFinishedLoadNextPageWithNewData:(BOOL)hasNewData
{
    if (hasNewData) {
        [self.tableView reloadData];
    }

    [self.nextPageFooterView scrollViewDidFinishedLoading:self.tableView];
}

@end








