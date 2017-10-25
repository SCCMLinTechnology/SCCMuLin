//
//  OPHeaderView.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/24.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "Config.h"

//方法代理
@protocol  FunctionHeaderDelegate <NSObject>

-(void)clickLayoutFunc:(BOOL)isFirst;
-(void)saveHandleDataFunc:(NSDictionary *)data position:(int)position;

@end


@interface OPHeaderView : UIView{
    NSDictionary *tempData;
    BOOL lock;
    BOOL error;
}

@property(nonatomic, weak) id<FunctionHeaderDelegate> delegate;

//头部布局
-(void)opHeaderViewLayout:(NSDictionary *)data isLock:(BOOL)isLock isError:(BOOL)isError;
@end
