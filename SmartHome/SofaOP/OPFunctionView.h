//
//  OPFunctionView.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/24.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "UIButton+time.h"
#import "Config.h"
//方法代理
@protocol  FunctionDelegate <NSObject>

//复位
-(void)resertFunc;
//保存记忆
-(void)saveMemeryFunc:(NSString *)position;
//恢复记忆
-(void)recoveryMemeryFunc:(NSString *)position;

//开始旋转
-(void)startRotateFunc:(NSString *)position indexNum:(NSString *)indexNum;

//停止旋转
-(void)stopRotateFunc;

//解锁/加锁
-(void)isLockFunc:(BOOL)lock;
//灯
-(void)isLightFunc:(BOOL)isLight;


//开始Home
-(void)startResertHomeFunc;

//停止Home
-(void)stopResertHomeFunc;

//修改状态
-(void)changeStateFunc;

-(void)changeStateOKFunc;

@end


@interface OPFunctionView : UIView{
    BOOL light;
    BOOL lock;
    int posIndex;
    
   int saveTag;
}
@property(nonatomic, weak) id<FunctionDelegate> delegate;

//根据配置项目布局
-(void)opFunctionLayout:(BOOL)isLock isError:(BOOL)isError isLight:(BOOL)isLight isHome:(BOOL)isHome position:(int)position;
-(void)setSaveNum;

@end
