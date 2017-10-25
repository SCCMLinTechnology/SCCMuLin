//
//  LayoutSofaView.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/23.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "DotView.h"
#import "BFDragGestureRecognizer.h"  //拖动事件

//方法代理
@protocol  RefreshLayoutDelegate <NSObject>

-(void)RefreshLayoutData:(NSArray *)data position:(int)position;

@end


typedef void (^finishRecvData)(NSDictionary *data,int currentIndex,int position);

@interface LayoutSofaView : UIView{
    NSArray *opArr;//用来存储传递过来的数组
    int index;//0或者1
    int currentIndex;//当前数组的位置
    
    CGPoint _startCenter;
    
    BOOL isLayoutTest;
    BOOL isLayoutBack;
    BOOL isLayoutMove;
    
    BFDragGestureRecognizer *holdDragRecognizer;
}
@property (nonatomic,copy) finishRecvData finishData;
@property(nonatomic, weak) id<RefreshLayoutDelegate> delegate;
//将沙发放置到网格中
//-(void)layoutSetDataToBox:(NSArray *)sofaArr finishCallBack:(finishRecvData)block;
-(void)layoutSetDataToBox:(NSArray *)sofaArr isMove:(BOOL)isMove isBack:(BOOL)isBack isTest:(BOOL)isTest finishCallBack:(finishRecvData)block;
//将沙发刷新到网格中
-(void)layoutRefreshDataToBox:(NSArray *)sofaArr;
//刷新数据
//-(void)layoutRefreshData:(refreshData)block;

@end
