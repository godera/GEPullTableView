//
//  based on EGORefreshTableHeaderView.h
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//


#import "GEPullView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define ARROW_IMAGE_NAME @"GEPullViewArrow.png"

typedef enum{
	GEPullStatus_Crisis = 0,
	GEPullStatus_Loading,
	GEPullStatus_Normal,
}GEPullStatus;


@interface GEPullView ()

@property (assign, nonatomic) GEPullStatus state;
@property (retain, nonatomic) UILabel* lastUpdatedLabel;
@property (retain, nonatomic) UILabel* statusLabel;
@property (retain, nonatomic) CALayer* arrowImageLayer;
@property (retain, nonatomic) UIActivityIndicatorView* activityView;

- (void)setState:(GEPullStatus)aState;
- (NSString*)intervalStringFromEarlyDate:(NSDate*)earlyDate;

@end

@implementation GEPullView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTE_PERSISTANT_TIMER object:nil];
    [_lastUpdatedDate release];
    [_arrowImageName release];
    [_textColor release];
    
    
	[_lastUpdatedLabel release];
    [_statusLabel release];
    [_arrowImageLayer release];
    [_activityView release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)configViaArrowImageName:(NSString *)arrowImageName textColor:(UIColor *)textColor
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    if (self.position == ViewPositon_Top) {
        UILabel *lastUpdatedLabel = [[UILabel new] autorelease];
        lastUpdatedLabel.frame = CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 20.0f);
        lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
        lastUpdatedLabel.textColor = textColor;
        lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:lastUpdatedLabel];
        self.lastUpdatedLabel = lastUpdatedLabel;
    }
    
    
    UILabel* statusLabel = [[UILabel new]autorelease];
    if (self.position == ViewPositon_Bottom) {
        statusLabel.frame = CGRectMake(0.0f, 17.0f, self.frame.size.width, 20.0f);
    }else{
        statusLabel.frame = CGRectMake(0.0f, self.frame.size.height - 48.0f, self.frame.size.width, 20.0f);
    }
    statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusLabel.font = [UIFont systemFontOfSize:12.0f];
    statusLabel.textColor = textColor;
    statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    
    CALayer *arrowImageLayer = [CALayer layer];
    if (self.position == ViewPositon_Bottom) {
        arrowImageLayer.frame = CGRectMake(85.0f, 10.0f, 15.0f, 28.0f);
    }else{
        arrowImageLayer.frame = CGRectMake(85.0f, self.frame.size.height - 42.0f, 15.0f, 28.0f);
    }
    arrowImageLayer.contentsGravity = kCAGravityResizeAspect;
    arrowImageLayer.contents = (id)[UIImage imageNamed:arrowImageName].CGImage;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        arrowImageLayer.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    
    [[self layer] addSublayer:arrowImageLayer];
    self.arrowImageLayer = arrowImageLayer;
    
    
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    if (self.position == ViewPositon_Bottom) {
        activityView.frame = CGRectMake(85.0f, 17.0f , 20.0f, 20.0f);
    }else{
        activityView.frame = CGRectMake(85.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
    }
    [self addSubview:activityView];
    self.activityView = activityView;
    
    
    [self setState:GEPullStatus_Normal];
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview == nil) {
        
        if (self.arrowImageName && self.textColor) {
            [self configViaArrowImageName:self.arrowImageName textColor:self.textColor];
        }else{
            [self configViaArrowImageName:ARROW_IMAGE_NAME textColor:TEXT_COLOR];
        };
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastUpdatedDate) name:NOTE_PERSISTANT_TIMER object:nil];
        
    }
}

#pragma mark - Setters
- (void)refreshLastUpdatedDate{

    if (self.position == ViewPositon_Top) {
        if (self.lastUpdatedDate) {
            
            _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", [self intervalStringFromEarlyDate:self.lastUpdatedDate]];
            
        } else {
            
            _lastUpdatedLabel.text = @"上次更新: 没更新过";
            
        }
    }else{
        _lastUpdatedLabel.text = @"";
    }
	

}

- (NSString*)intervalStringFromEarlyDate:(NSDate*)earlyDate
{
    NSDate* now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:earlyDate];
    
    if (interval < 60) {
        return [NSString stringWithFormat:@"几秒前"];
    }
    if (interval < 60 * 60) {
        return [NSString stringWithFormat:@"%.0f分钟前",interval/60];
    }
    if (interval < 60 * 60 * 60) {
        return [NSString stringWithFormat:@"%.0f小时前",interval/60/60];
    }
    if (interval < 60 * 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%.0f天前",interval/60/60/24];
    }
    return @"";
}

- (void)setState:(GEPullStatus)aState{

	switch (aState) {
		case GEPullStatus_Crisis:
			
            if (self.position == ViewPositon_Top) {
                _statusLabel.text = NSLocalizedString(@"松开即可更新...", @"松开即可更新...");
            }else{
                _statusLabel.text = NSLocalizedString(@"松开加载更多...", @"松开加载更多...");
            }
			[CATransaction begin];
			[CATransaction setAnimationDuration:0.25];
			self.arrowImageLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case GEPullStatus_Normal:
			
			if (_state == GEPullStatus_Crisis) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:0.25];
				self.arrowImageLayer.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
            if (self.position == ViewPositon_Bottom) {
                _statusLabel.text = NSLocalizedString(@"上拉加载更多...", @"上拉加载更多...");
            }else{
                _statusLabel.text = NSLocalizedString(@"下拉即可更新...", @"下拉即可更新...");
            }
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			self.arrowImageLayer.hidden = NO;
			self.arrowImageLayer.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case GEPullStatus_Loading:
			
			_statusLabel.text = NSLocalizedString(@"加载中...", @"加载中...");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			self.arrowImageLayer.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
    _state = aState;

}


#pragma mark - ScrollView Embeded Methods
- (void)statusJudgementFromScrollView:(UIScrollView *)scrollView
{
    if (self.state == GEPullStatus_Loading) {//底下的判断都没有正在加载中，所以一旦是在加载中，就不需要判断
        return;
    }
    
    if (scrollView.isDragging) {
        
        if (self.position == ViewPositon_Bottom) {
            
            if (_state == GEPullStatus_Crisis && scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height + THRESHOLD && scrollView.contentOffset.y > 0.0f) {
                [self setState:GEPullStatus_Normal];
            } else if (_state == GEPullStatus_Normal && scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + THRESHOLD) {
                [self setState:GEPullStatus_Crisis];
            }
            
        }else{
            
            if (_state == GEPullStatus_Crisis && scrollView.contentOffset.y > -THRESHOLD && scrollView.contentOffset.y < 0.0f) {
                [self setState:GEPullStatus_Normal];
            } else if (_state == GEPullStatus_Normal && scrollView.contentOffset.y < -THRESHOLD) {
                [self setState:GEPullStatus_Crisis];
            }
            
        }
    }
	
}

- (void)triggerJudgementFromScrollView:(UIScrollView *)scrollView
{
    if (self.state == GEPullStatus_Loading) {//如果正在加载中，就不需要再次触发
        return;
    }
    
    if (self.position == ViewPositon_Bottom) {
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + THRESHOLD && _state != GEPullStatus_Loading) {
            
            [self setState:GEPullStatus_Loading];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, THRESHOLD, 0.0f);
            [UIView commitAnimations];
            
            if ([_delegate respondsToSelector:@selector(GEPullViewDidTriggerLoadNextPage:)]) {
                [_delegate GEPullViewDidTriggerLoadNextPage:self];
            }
            
            

        }
        
    }else{//ViewPositon_Top
        
        if (scrollView.contentOffset.y <= -THRESHOLD && _state != GEPullStatus_Loading) {
            
            [self setState:GEPullStatus_Loading];

            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            scrollView.contentInset = UIEdgeInsetsMake(THRESHOLD, 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
            
            if ([self.delegate respondsToSelector:@selector(GEPullViewDidTriggerRefresh:)]) {
                [self.delegate GEPullViewDidTriggerRefresh:self];
            }
            
            
        }
        
    }
	
}

- (void)scrollViewDidFinishedLoading:(UIScrollView *)scrollView
{
    self.state = GEPullStatus_Normal;

    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	[UIView commitAnimations];
	
}

-(void)footerFrameReset
{
    if (self.superview) {
        UIScrollView* table = (UIScrollView*)self.superview;
        CGFloat contentHeight = table.contentSize.height;
        CGFloat tableHeight = table.bounds.size.height;
        CGFloat Y = MAX(contentHeight , tableHeight);
        self.frame = CGRectMake(0.0f, Y, table.frame.size.width, table.bounds.size.height);
    }
}

@end












