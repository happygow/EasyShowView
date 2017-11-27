//
//  EasyShowOptions.h
//  EasyShowViewDemo
//
//  Created by Mr_Chen on 2017/11/24.
//  Copyright © 2017年 chenliangloveyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , ShowStatusTextType) {
    ShowStatusTextTypeTop ,
    ShowStatusTextTypeMidden ,
    ShowStatusTextTypeBottom,
};

@interface EasyShowOptions : NSObject


@property (nonatomic,strong)UIFont *textFount ;
@property (nonatomic,assign)CGFloat maxWidthScale ;
@property (nonatomic,assign)BOOL superViewReceiveEvent ;//在显示的期间，superview是否能接接收事件
@property (nonatomic,assign)ShowStatusTextType showStatusTextTpye ;//显示文字的时候，显示在哪个地方
@property (nonatomic,assign)BOOL showStartAnimation ;//是否弹出加载时的动画
@property (nonatomic,assign)BOOL showEndAnimation ;//是否弹出移除掉的动画
@property (nonatomic,assign)CGFloat showAnimationDuration;//展示动画的时间
+ (instancetype)shareInstance ;
@end