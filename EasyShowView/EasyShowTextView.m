//
//  EasyShowTextView.m
//  EasyShowViewDemo
//
//  Created by nf on 2017/12/14.
//  Copyright © 2017年 chenliangloveyou. All rights reserved.
//

#import "EasyShowTextView.h"
#import "UIView+EasyShowExt.h"

@interface EasyShowTextView()


@property (nonatomic,strong)NSString *showText ;//展示的文字
@property (nonatomic,strong)UIImage *showImage ;//展示的图片
@property (nonatomic,assign)ShowTextStatus showTextStatus ;//展示的类型
@property (nonatomic,assign)ShowType showType ;//展示的类型

@property (nonatomic,strong)NSTimer *removeTimer ;
@property (nonatomic,assign)CGFloat showTime ;
@property CGFloat timerShowTime ;//定时器走动的时间

@property (nonatomic,strong)EasyShowBgView *showBgView ;//用于放图片和文字的背景



@end

@implementation EasyShowTextView


+ (void)showToastWithText:(NSString *)text inView:(UIView *)view image:(UIImage *)image stauts:(ShowTextStatus)status
{
    if (status==ShowTextStatusPureText && ISEMPTY(text)) {//
        NSAssert(NO, @"you should set a text for showView !");
        return ;
    }
    if (nil == view) {
        NSAssert(NO, @"there shoud have a superview");
        return ;
    }
    NSAssert([NSThread isMainThread], @"needs to be accessed on the main thread.");
    
    //显示之前---->隐藏还在显示的视图
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            EasyShowView *showView = (EasyShowView *)subview ;
            [showView clearCurrentShow];
        }
    }
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
        });
    }
    
    EasyShowTextView *showView = [[EasyShowTextView alloc] initWithFrame:CGRectZero];
    showView.showText = text ;
    showView.showTextStatus = status ;
    showView.showImage = image ;
    
    showView.showTime = 1 + text.length*0.15 ;
    if (showView.showTime > [EasyShowOptions sharedEasyShowOptions].maxShowTime) {
        showView.showTime = [EasyShowOptions sharedEasyShowOptions].maxShowTime ;
    }
    if (showView.showTime < 2) {
        showView.showTime = 2 ;
    }
    
    showView.timerShowTime = 0 ;
    [showView showViewWithSuperView:view];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor =  [[UIColor lightGrayColor] colorWithAlphaComponent:0.02]; // [UIColor greenColor] ;//
    }
    return self ;
}

- (void)showViewWithSuperView:(UIView *)superView
{
    //展示视图的frame
    CGRect showFrame = CGRectZero ;
    if (self.showType == ShowTypeText) {
        showFrame = [self showTextRectWithSuperView:superView];
    }
    else if(self.showType == ShowTypeLoding){
        showFrame = [self showLodingRectWithSuperView:superView];
    }
    
    
    self.showBgView = [[EasyShowBgView alloc]initWithFrame:showFrame
                                                    status:self.showTextStatus
                                                      text:self.showText
                                                     image:self.showImage
                                                  showtype:self.showType];
    [self addSubview:self.showBgView];
    //只有展示文字的时候，才需要自动消失
    if (self.showType == ShowTypeText) {
        [self.removeTimer fire];
    }
    
    [self showSelfToSuperView:superView];
    
    if (self.options.showShadow) {
        CGFloat afterStart = self.options.showStartAnimation ? self.options.showAnimationTime :0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterStart * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showBackgrouldsubLayer];
        });
    }
}

- (CGRect)showLodingRectWithSuperView:(UIView *)superView
{
    
    //显示图片的高度。
    CGFloat imageH = self.showTextStatus==ShowTextStatusPureText ?:(EasyDrawImageWH + EasyDrawImageEdge) ;
    
    //显示区域的宽高
    CGFloat backGroundH = 0 ;
    CGFloat backGroundW = SCREEN_WIDTH ;
    
    CGSize textSize = CGSizeZero ;
    if (!ISEMPTY(self.showText)) {
        textSize = [EasyShowUtils textWidthWithStirng:self.showText
                                                 font:self.options.textFount
                                             maxWidth:self.options.maxWidthScale*SCREEN_WIDTH];
    }
    backGroundH = (textSize.height?(textSize.height+30):0) ;
    backGroundW = textSize.width?(textSize.width+40):0  ;
    
    if (self.options.showLodingType > ShowLodingTypeImage) {//左右形式
        backGroundW = backGroundW + imageH ;
    }
    else{//上下形式
        backGroundH = backGroundH + imageH ;
    }
    
    if (backGroundW < EasyShowViewMinWidth) {
        backGroundW = EasyShowViewMinWidth  ;
    }
    if (backGroundH < EasyShowViewMinWidth) {
        backGroundH = EasyShowViewMinWidth  ;
    }
    CGFloat showFrameY = (SCREEN_HEIGHT-backGroundH)/2  ;//默认显示在中间
    //显示区域的frame
    CGRect showFrame = CGRectMake(0, 0, backGroundW, backGroundH);
    if (self.options.superViewReceiveEvent) {
        //父视图能接受事件--> self的大小为显示区域的大小
        self.frame =  CGRectMake((SCREEN_WIDTH-backGroundW)/2, showFrameY, backGroundW, backGroundH);
    }
    else{
        
        //父视图不能接收-->self的大小应该为superview的大小。来遮盖
        self.frame = CGRectMake(0, 0, superView.width, superView.height) ;
        
        showFrame.origin = CGPointMake((self.width-backGroundW)/2, showFrameY) ;
    }
    return showFrame ;
}
//获取需要展示框的大小
- (CGRect)showTextRectWithSuperView:(UIView *)superView
{
    //显示图片的高度。
    CGFloat imageH = self.showTextStatus==ShowTextStatusPureText ?:(EasyDrawImageWH + EasyDrawImageEdge) ;
    
    //显示区域的宽高
    CGFloat backGroundH = 0 ;
    CGFloat backGroundW = SCREEN_WIDTH ;
    switch (self.options.textStatusType) {
        case ShowTextStatusTypeStatusBar://如果是在statusbar上，则高固定，不需要计算
            backGroundH = STATUSBAR_HEIGHT ;
            break;
        case ShowTextStatusTypeNavigation:
            backGroundH = NAVIGATION_HEIGHT ;
            break ;
        default:{
            CGSize textSize = CGSizeZero ;
            if (!ISEMPTY(self.showText)) {
                textSize = [EasyShowUtils textWidthWithStirng:self.showText
                                                         font:self.options.textFount
                                                     maxWidth:self.options.maxWidthScale*SCREEN_WIDTH];
            }
            backGroundH = (textSize.height?(textSize.height+30):0) + imageH ;
            backGroundW = textSize.width?(textSize.width+40):0  ;
            
            if (backGroundW < EasyShowViewMinWidth) {
                backGroundW = EasyShowViewMinWidth  ;
            }
        } break;
    }
    
    //显示区域的y值
    CGFloat showFrameY = (SCREEN_HEIGHT-backGroundH)/2  ;//默认显示在中间
    //    if (self.showTextStatus != ShowStatusLoding) {
    switch (self.options.textStatusType ) {
        case ShowTextStatusTypeNavigation:
        case ShowTextStatusTypeStatusBar:
            showFrameY = 0 ;
            break ;
        case ShowTextStatusTypeTop:
            showFrameY = NAVIGATION_HEIGHT + EasyTextShowEdge ;
            break;
        case ShowTextStatusTypeBottom:
            showFrameY = SCREEN_HEIGHT - backGroundH - EasyTextShowEdge ;
            break ;
        default: break;
    }
    //    }
    
    
    //显示区域的frame
    CGRect showFrame = CGRectMake(0, 0, backGroundW, backGroundH);
    
    if (self.options.superViewReceiveEvent) {
        
        //父视图能接受事件--> self的大小为显示区域的大小
        self.frame =  CGRectMake((SCREEN_WIDTH-backGroundW)/2, showFrameY, backGroundW, backGroundH);
    }
    else{
        
        //父视图不能接收-->self的大小应该为superview的大小。来遮盖
        self.frame = CGRectMake(0, 0, superView.width, superView.height) ;
        
        showFrame.origin = CGPointMake((self.width-backGroundW)/2, showFrameY) ;
    }
    
    return showFrame ;
}

- (void)timerAction
{
    if (_timerShowTime >= _showTime ) {
        
        //移除定时器
        _timerShowTime = 0 ;
        if (_removeTimer) {
            [_removeTimer invalidate];
            _removeTimer = nil ;
        }
        
        //移除阴影
        if (self.options.showShadow) {
            [self hiddenBackgrouldsubLayer];
        }
        
        //移除自己
        [self removeSelfFromSuperView];
    }
    _timerShowTime++ ;
    
}

- (void)clearCurrentShow
{
    _timerShowTime = [EasyShowOptions sharedEasyShowOptions].maxShowTime + 1 ;
    [self timerAction];
}
- (void)showSelfToSuperView:(UIView *)superView
{
    if (self.options.showStartAnimation) {
        
        if (self.showType==ShowTypeText && (self.isShowedStatusBar || self.isShowedNavigation)) {
            self.y = - self.height ;
            [UIView animateWithDuration:self.options.showAnimationTime animations:^{
                self.y = 0 ;
                [self.showBgView showWindowYToPoint:0];
            }] ;
        }
        else{
            [self.showBgView showStartAnimationWithDuration:self.options.showAnimationTime];
        }
        
        [superView addSubview:self];
        
    }
    else{
        if (self.showType==ShowTypeText && (self.isShowedStatusBar || self.isShowedNavigation)) {
            self.y = 0 ;
        }
        else{
            self.alpha = 0.1 ;
            [UIView animateWithDuration:self.options.showAnimationTime animations:^{
                self.alpha = 1.0 ;
            } completion:^(BOOL finished) {
                [superView addSubview:self];
            }];
        }
    }
}
- (void)removeSelfFromSuperView
{
    if (self.options.showEndAnimation) {
        
        if (self.showType==ShowTypeText && (self.isShowedStatusBar || self.isShowedNavigation)) {
            
            [UIView animateWithDuration:self.options.showAnimationTime animations:^{
                self.y = -self.height ;
                [self.showBgView showWindowYToPoint:-self.height ];
                NSLog(@"========= %.2f",self.y);
            }completion:^(BOOL finished) {
                [self removeFromSuperview];
            }] ;
        }
        else{
            [self.showBgView showEndAnimationWithDuration:self.options.showAnimationTime];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.options.showAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }
    }
    else{
        [UIView animateWithDuration:self.options.showAnimationTime animations:^{
            self.alpha = 0.1 ;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }] ;
    }
}
- (void)showBackgrouldsubLayer
{
    CALayer *addSubLayer=[CALayer layer];
    addSubLayer.frame= self.showBgView.frame;
    addSubLayer.cornerRadius=8;
    addSubLayer.backgroundColor=self.options.backGroundColor.CGColor;
    addSubLayer.masksToBounds=NO;
    addSubLayer.name = @"backgrouldsubLayer";
    addSubLayer.shadowColor = self.options.shadowColor.CGColor;
    addSubLayer.shadowOffset = CGSizeMake(0.5, 2);
    addSubLayer.shadowOpacity = 0.6;
    addSubLayer.shadowRadius = 4;
    [self.layer insertSublayer:addSubLayer below:self.showBgView.layer];
    
}
- (void)hiddenBackgrouldsubLayer
{
    for (CALayer *subLayer in self.layer.sublayers) {
        if ([subLayer.name isEqualToString:@"backgrouldsubLayer"]) {
            [subLayer removeFromSuperlayer];
            break ;
        }
    }
}

#pragma mark - getter
//是否显示在statusbar上
- (BOOL)isShowedStatusBar
{
    return self.options.textStatusType==ShowTextStatusTypeStatusBar ;
}
//是否正在显示在navigation上
- (BOOL)isShowedNavigation
{
    return self.options.textStatusType==ShowTextStatusTypeNavigation ;
}

- (NSTimer *)removeTimer
{
    if (nil == _removeTimer) {
        _removeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_removeTimer forMode:NSRunLoopCommonModes];
    }
    return _removeTimer ;
}









+ (void)showText:(NSString *)text
{
    UIView *showView = [UIApplication sharedApplication].keyWindow ;
    [self showText:text inView:showView];
}

+ (void)showText:(NSString *)text inView:(UIView *)view
{
    [self showToastWithText:text inView:view image:nil stauts:ShowTextStatusPureText];
}

+ (void)showSuccessText:(NSString *)text
{
    UIView *showView = [UIApplication sharedApplication].keyWindow ;
    [self showSuccessText:text inView:showView];
}
+ (void)showSuccessText:(NSString *)text inView:(UIView *)superView
{
    [self showToastWithText:text inView:superView image:nil stauts:ShowTextStatusSuccess];
}

+ (void)showErrorText:(NSString *)text
{
    UIView *showView = [UIApplication sharedApplication].keyWindow ;
    [self showErrorText:text inView:showView];
}
+ (void)showErrorText:(NSString *)text inView:(UIView *)superView
{
    [self showToastWithText:text inView:superView image:nil stauts:ShowTextStatusError];
}

+ (void)showInfoText:(NSString *)text
{
    UIView *showView = [UIApplication sharedApplication].keyWindow ;
    [self showInfoText:text inView:showView];
}
+ (void)showInfoText:(NSString *)text inView:(UIView *)superView
{
    [self showToastWithText:text inView:superView image:nil stauts:ShowTextStatusInfo];
}

+ (void)showImageText:(NSString *)text image:(UIImage *)image
{
    UIView *showView = [UIApplication sharedApplication].keyWindow ;
    [self showImageText:text image:image inView:showView] ;
}
+ (void)showImageText:(NSString *)text image:(UIImage *)image inView:(UIView *)superView
{
    [self showToastWithText:text inView:superView image:image stauts:ShowTextStatusImage] ;
}

@end