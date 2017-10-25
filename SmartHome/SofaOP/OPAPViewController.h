//
//  OPAPViewController.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/5/15.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "BaseViewController.h"
#import "ProfileViewController.h"
#import "UIButton+time.h"

#import "OPHeaderView.h"//操作头部视图
#import "OPFunctionView.h"//功能性视图

#import "LYTBackView.h"
#import "LayoutSofaView.h"
#import "LightViewController.h"//灯

typedef void (^finishRecvBoolean)(BOOL locked);

@interface OPAPViewController : BaseViewController{
    
    OPHeaderView *headerView;
    OPFunctionView *functionView;
    
}



@property(nonatomic,retain)NSArray *opArr;
@property(nonatomic,retain)NSArray *sofaArr;
@property (nonatomic,copy) finishRecvBoolean finishData;

@end


