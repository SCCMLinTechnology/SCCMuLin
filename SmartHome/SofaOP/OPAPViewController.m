//
//  OPAPViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/5/15.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "OPAPViewController.h"

@interface OPAPViewController ()<FunctionDelegate,FunctionHeaderDelegate,RefreshLayoutDelegate>{

    BOOL isClick;//判断是否点击沙发
    NSString *lightStr;//灯字符
    NSString *pos;//判断沙发的左边还是右边
    NSString *seatPosition;
    
    int faileTimes;//失败次数
    
    int power;//点击的个数
    int powerIndex;//点击的个数
    NSMutableDictionary *savePowerPosition;
    NSString *memeryIdent;
    NSString *identifier;//唯一标识码
    
    
    int timeoutIndex;//超时次数
    
    BOOL isHome;//是home键
    LayoutSofaView *layoutsofa;
    
    
    BOOL isLock;
    BOOL isError;
    
    NSMutableDictionary *currentDic;
    int currentPos;
    int currentIndexPos;
    
    BOOL light;
    
    
    NSMutableArray *sofa_arr;
    
    BOOL isCurrentBle;
    
    BOOL isEnterNext;
    
    BOOL isOffElectriclight;//是否断电
    
    BOOL bleCurrentConnectState;

    int bleIndex;
    
    NSString *maxMacid;
    
    NSString *directPosition;
    
    BOOL isLightBack;
    
    BOOL isTouchDown;//判断是否按下过
}

@property(nonatomic,retain)UIView *coverView;

@end

@implementation OPAPViewController
@synthesize opArr;
@synthesize sofaArr;

//个人中心
-(void)profile{
    
//    [self buttonOK];
    if (isEnterNext) {
        [AppDelegate shareGlobal].globalSofaArr = sofa_arr;
        [AppDelegate shareGlobal].globalSofaDic = currentDic;
        
        ProfileViewController *pro =[[ProfileViewController alloc] init];
        pro.sofaArr = sofaArr;
        [self.navigationController pushViewController:pro animated:YES];
    }
   
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"op_bg"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    //增加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnexpectedInterruptionNotice) name:@"UnexpectedInterruptionNotice" object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UnexpectedInterruptionNotice" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"op_bg"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
   
    isEnterNext = YES;
    isLightBack = NO;
    //配置按钮
    UIView *customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,80,50)];
    customView.backgroundColor=[UIColor clearColor];
    UIImageView *img = nil;
    if (ipad) {
        img=[[UIImageView alloc] initWithFrame:CGRectMake(80-50, (50-50)/2, 50,50)];
    }
    else{
        img=[[UIImageView alloc] initWithFrame:CGRectMake(80-36, (50-36)/2, 36,36)];
    }
    
    img.image=[UIImage imageNamed:@"setting"];
    [customView addSubview:img];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=customView.bounds;
    [btn addTarget:self action:@selector(profile) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.rightBarButtonItem = backItem;
    
    //背景
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"op_bg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    sofa_arr =[[NSMutableArray alloc] initWithArray:sofaArr];
    
    //默认第一个沙发显示
    int i = 0;
    NSDictionary *temp = [sofaArr objectAtIndex:i];
    
    //头部界面
    headerView = [[OPHeaderView alloc] initWithFrame:CGRectMake(15, 15+(iPhone5?-10:0), sWIDTH-15*2, 70+(iPhone5 ?-20 : 0))];
    if (ipad) {
        headerView.frame = CGRectMake(20, 30, sWIDTH-20*2, 90);
    }
    
    headerView.delegate = self;
    [self.view addSubview:headerView];
    
    [headerView opHeaderViewLayout:temp isLock:NO isError:NO];
    
    
    //操作界面
    functionView = [[OPFunctionView alloc] initWithFrame:CGRectMake(15, 100-(iPhone5?40:0), sWIDTH-15*2, 450)];
    if (ipad) {
        functionView.frame = CGRectMake(20, 150, sWIDTH-20*2, 800);
    }
    functionView.delegate = self;
    [self.view addSubview:functionView];
    
    power = [[temp objectForKey:@"powerNum"] intValue];//沙发的个数

    lightStr = [temp objectForKey:@"light"];
    light = NO;
    if ([lightStr isEqualToString:@"NO"]) {
        light = NO;
    }
    else{
        light = YES;
    }
    
    NSString *Home = [temp objectForKey:@"controlLayout"];//判断布局
    
    if ([Home isEqualToString:@"Home"]) {
        isHome = true;
    }
    else{
        isHome = false;
    }
    
    //布局
    [functionView opFunctionLayout:NO isError:NO isLight:light isHome:isHome position:power];
    
    //弹出框布局
    [self clickLayoutFunc:YES];//第一次弹出遮罩
    
    
    [self bleAllState];
    
    bleIndex = 0;
    [self connectAllBLE];//连接所有蓝牙
    
}



-(void)connectAllBLE{
    
    if (bleIndex < [AppDelegate shareGlobal].bleListArr.count) {
        //连接
        NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:bleIndex];
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
        
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
//            NSLog(@"准备完成状态=测试=%@",state);
            if ([state intValue] == 1) {
                
                ++bleIndex;
                [self connectAllBLE];
            }
        };
        
    }
}



-(void)bleAllState{
    
    //判断蓝牙是打开/关闭
    [[AppDelegate shareGlobal] manager].linkBlcok = ^(NSString *state){
        
//        NSLog(@"蓝牙打开/关闭==%@",state);
        [AppDelegate shareGlobal].link = state;
        if ([state isEqualToString:kCONNECTED_POWERD_ON]) {
            
            [self buttonOK];
            [self dataAnalysisProcessing:NO isErr:NO];
            
            isCurrentBle = YES;
            if (currentDic) {
                //搜索到蓝牙设备之后,并直接连接
                [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[currentDic objectForKey:@"serviceUUIDs"] identifier:[currentDic objectForKey:@"identifier"]];
            }
        }
        else{
            
            [self updateLog:@"Please open Bluetooth"];
            //判断如果蓝牙是自己锁的话，需要解锁
            [self dataAnalysisProcessing:YES isErr:NO];
            [self disConnectBleOpenSelfLock];//断开蓝牙时，所有自己锁的设备恢复正常
            [self buttonFailue];
        }
    };
    
    /*
    //获取搜索蓝牙设备列表
    [[AppDelegate shareGlobal] manager].listBlock = ^(NSMutableArray *array) {
//        NSLog(@"蓝牙列表==%@",array);
        if (currentDic && isCurrentBle) {
            for (int i=0; i<array.count; i++) {
                if ([[currentDic objectForKey:@"identifier"] isEqualToString: [[array objectAtIndex:i] objectForKey:@"identifier"] ]) {
                    
                    isCurrentBle = NO;
                    //搜索到蓝牙设备之后,并直接连接
                    [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[currentDic objectForKey:@"serviceUUIDs"] identifier:[currentDic objectForKey:@"identifier"]];
                    
                    break;
                }
            }
        }
        
    };
     */
    
    //判断蓝牙是连接成功/失败
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number,NSString *idFlag,int errCode) {
         NSLog(@"状态==%d===%d",number,errCode);
        //判断是断开蓝牙还是断开连接
        if (errCode != 0) {//断电的情况
            //判断当前断电的沙发
            if ([idFlag isEqualToString:[currentDic objectForKey:@"identifier"]]) {
                isOffElectriclight = YES;//断电
                if (number != 0) {
                    [self dataAnalysisProcessing:YES isErr:YES];
                    
                }
                else{
                    [self dataAnalysisProcessing:NO isErr:NO];
                }
            }
            else{
                [self checkStatePowerOff:1 mac:idFlag];
            }
        }
        else{
            //判断当前断电的沙发
            if ([idFlag isEqualToString:[currentDic objectForKey:@"identifier"]]) {
                isOffElectriclight = NO;//通电
                if (number == 0) {
                    [self dataAnalysisProcessing:NO isErr:NO];
                }
            }
            else{
                if (number == 0) {
                    [self checkStatePowerOff:0 mac:idFlag];
                }
            }
        }
    };
    
    //无匹配蓝牙
    [[AppDelegate shareGlobal] manager].noPeripheralBlock = ^(NSString *state) {
//        NSLog(@"无匹配蓝牙状态状态==%@",state);
        if ([state intValue] == 1) {
            
            [self dataAnalysisProcessing:YES isErr:YES];
        }
    };

    
    //2.判断状态
    [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
//        NSLog(@"准备完成状态22==%@",state);
        if ([state isEqualToString:@"1"]) {
            if (currentDic) {
                bleCurrentConnectState = YES;
                [self clickSofaLayout:currentDic position:currentIndexPos];
            }
        }
        else{
            bleCurrentConnectState = NO;
            //连接超时
            [self dataAnalysisProcessing:YES isErr:YES];
            
            [self buttonFailue];
        }
    };
    
}


//时时检测下拉的断电情况
-(void)checkStatePowerOff:(int)isPower mac:(NSString *)mac{
    
    for (int i = 0; i<sofa_arr.count; i++) {
        if ([[[sofa_arr objectAtIndex:i] objectForKey:@"identifier"] isEqualToString:mac]) {
            
            NSMutableDictionary *partOfDic = [[NSMutableDictionary alloc] initWithDictionary:[sofa_arr objectAtIndex:i]];
            
            NSMutableArray *tempDataArr = [[NSMutableArray alloc] initWithArray:[partOfDic objectForKey:@"sofadata"]];
            for (int j=0; j<[tempDataArr count]; j++) {
                //将sofadata中的
                NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[tempDataArr objectAtIndex:j]];
                
                [temp_dic setObject:[NSNumber numberWithInt:isPower] forKey:@"isError"];
                
                if ([[temp_dic objectForKey:@"isSelfLock"] intValue] == 1) {
                    [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
                }
                [tempDataArr removeObjectAtIndex:j];
                [tempDataArr insertObject:temp_dic atIndex:j];
                
            }
            [partOfDic setObject:tempDataArr forKey:@"sofadata"];
            //    NSLog(@"currentDic==%@",currentDic);
            
            [sofa_arr removeObjectAtIndex:i];
            [sofa_arr insertObject:partOfDic atIndex:i];
            
            [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
            
            break;
        }
    }
    
}


//当蓝牙断开时,解锁所有自己锁定的沙发
-(void)disConnectBleOpenSelfLock{
    for (int i = 0; i<sofa_arr.count; i++) {
        NSMutableDictionary *partOfDic = [[NSMutableDictionary alloc] initWithDictionary:[sofa_arr objectAtIndex:i]];
        
        NSMutableArray *tempDataArr = [[NSMutableArray alloc] initWithArray:[partOfDic objectForKey:@"sofadata"]];
        for (int j=0; j<[tempDataArr count]; j++) {
            //将sofadata中的
            NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[tempDataArr objectAtIndex:j]];
            
            if ([[temp_dic objectForKey:@"isSelfLock"] intValue] == 1) {
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
            }
            [tempDataArr removeObjectAtIndex:j];
            [tempDataArr insertObject:temp_dic atIndex:j];
            
        }
        [partOfDic setObject:tempDataArr forKey:@"sofadata"];
        //    NSLog(@"currentDic==%@",currentDic);
        
        [sofa_arr removeObjectAtIndex:i];
        [sofa_arr insertObject:partOfDic atIndex:i];
        
        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self bleAllState];
    
    //如果断电或者断开蓝牙过
    if ([AppDelegate shareGlobal].globalBleDis || [AppDelegate shareGlobal].globalPowerOff) {
        //自己锁置为0
        NSLog(@"进入到这里");
        [self dataAnalysisProcessing:YES isErr:NO];
        [self disConnectBleOpenSelfLock];//解锁
        
        [AppDelegate shareGlobal].globalBleDis = NO;
        [AppDelegate shareGlobal].globalPowerOff = NO;
    }
    
    //进行判断,1.是否蓝牙断开,2.是否当前设备断电
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        //如果有currentDic值
        if (currentDic) {
            
            //sofa_arr =[[NSMutableArray alloc] initWithArray:[AppDelegate shareGlobal].globalSofaArr];
            
            //直接连接蓝牙
            [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[currentDic objectForKey:@"serviceUUIDs"] identifier:[currentDic objectForKey:@"identifier"]];
        }
    }
    else{
        //蓝牙断开
        bleCurrentConnectState = NO;
        isEnterNext = YES;
        //连接超时
        [self dataAnalysisProcessing:NO isErr:NO];
        [self buttonFailue];
    }
  
   
}

-(void)dataAnalysisProcessing:(BOOL)isSelfLock isErr:(BOOL)isErr{
    
    if (!currentDic) {
        return ;
    }
    //首先判断当前操作是否时当前选中的图标
    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
    power = [[currentDic objectForKey:@"powerNum"] intValue];//沙发的个数
//    NSLog(@"temp_arr==%@",temp_arr);
    
//    power = [[currentDic objectForKey:@"powerNum"] intValue];//沙发的个数
    //判断是Home键还是R键
    NSString *Home = [currentDic objectForKey:@"controlLayout"];//判断布局
    if ([Home isEqualToString:@"Home"]) {
        isHome = true;
    }
    else{
        isHome = false;
    }
    
    //是否需要进入灯控界面
    lightStr = [currentDic objectForKey:@"light"];
    light = NO;
    if ([lightStr isEqualToString:@"NO"]) {
        light = NO;
    }
    else{
        light = YES;
    }
    
    for (int i=0; i<temp_arr.count; i++) {
        //将sofadata中的
        NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[temp_arr objectAtIndex:i]];
        
        if (isSelfLock) {
            if ([[temp_dic objectForKey:@"isSelfLock"] intValue] == 1) {
                //解锁
                isLock = NO;
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];//断电之后将0也
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
            }
            else{
                isLock = NO;
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];//断电之后将0也
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
            }
        }
        else{
            if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON])
            {
                
            }
            else{
                if ([[temp_dic objectForKey:@"isSelfLock"] intValue] == 1 || isOffElectriclight) {
                    //解锁
                    isLock = NO;
                    [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];//断电之后将0也
                    [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
                }
            }
            
        }
//        else{
//            isLock = NO;
//            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];//断电之后将0也
//            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
//        }
        
        if (isErr) {
            isError = YES;
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
        }
        else{
            isError = NO;
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
        }
        
        [temp_arr removeObjectAtIndex:i];
        [temp_arr insertObject:temp_dic atIndex:i];
    }
    
    [currentDic setObject:temp_arr forKey:@"sofadata"];
//    NSLog(@"currentDic==%@",currentDic);
    
    [sofa_arr removeObjectAtIndex:currentPos];
    [sofa_arr insertObject:currentDic atIndex:currentPos];
    
//    NSLog(@"sofa_arr==%@",sofa_arr);
    
    [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
    
    [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
    
    //操作布局
    [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];

}

//从头部点击沙发
-(void)saveHandleDataFunc:(NSDictionary *)data position:(int)position{
    
    NSLog(@"data==%@===position==%d",data,position);
    currentDic = [[NSMutableDictionary alloc] initWithDictionary:data];
    currentIndexPos = position;
    
    if (position == 0) {
        pos = @"01";
    }
    else{
        pos = @"02";
    }
    
    if ([[data objectForKey:@"identifier"] isEqualToString:maxMacid]) {
        //        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
        [self maxConnectState:NO];
    }
    
    [self clickSofaLayout:data position:position];
    
   
}



//刷新界面数据
-(void)RefreshLayoutData:(NSArray *)data position:(int)position{
    sofa_arr = nil;
    sofa_arr =[[NSMutableArray alloc] initWithArray:data];
    currentIndexPos = position;
    
    
    [headerView opHeaderViewLayout:[data objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
}

//进入弹出框布局
-(void)clickLayoutFunc:(BOOL)isFirst{
//    NSLog(@"layout");
    
    //布局界面
    layoutsofa = [[LayoutSofaView alloc] initWithFrame:CGRectMake(spaceWidth, (sHEIGHT-boxWidth *heng_box)/2, boxWidth *shu_box, boxWidth *heng_box)];
    
    [layoutsofa setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    /*
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"bg"];
    [layoutsofa addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    */
    
    layoutsofa.delegate = self;
//    layoutsofa.backgroundColor = [UIColor blackColor];
//    layoutsofa.alpha = 0.7;
    [LYTBackView showWithView:layoutsofa isFirst:isFirst];//弹出视图
//    [self updateLog:[NSString stringWithFormat:@"==%d",isFirst]];
    
    isClick = NO;
//    NSLog(@"sofa_arrsofa_arrsofa_arr==%@",sofa_arr);
//    [[NSUserDefaults standardUserDefaults] setObject:sofa_arr forKey:[NSString stringWithFormat:@"%@_%@", SMARTMULIN,@"sofa"]];
    
    NSLog(@"sofa_arr==%@",sofa_arr);
    //布局
    [layoutsofa layoutSetDataToBox:sofa_arr isMove:NO isBack:YES isTest:NO  finishCallBack:^(NSDictionary *data, int currentIndex, int position) {
        
        NSLog(@"这里的循序：：%@===positon==%d",data,position);
        isClick = YES;
        
        currentDic = [[NSMutableDictionary alloc] initWithDictionary:data];
        currentPos = currentIndex;//数组中的序号
        currentIndexPos = position;//左右沙发的位置

        [LYTBackView dissMiss];//遮罩消失
        
         identifier = [data objectForKey:@"identifier"];//唯一标识码
        //蓝牙切换连接
        //1.连接蓝牙
        if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
            
            [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:identifier];
            
            //2.判断状态
            [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
//                NSLog(@"准备完成状态==%@",state);
                
                if ([state isEqualToString:@"1"]) {
                    bleCurrentConnectState = YES;
                    maxMacid = @"";
                    [self clickSofaLayout:currentDic position:currentIndexPos];
                }
                else{
                    bleCurrentConnectState = NO;
                    //连接超时
                    [self dataAnalysisProcessing:YES isErr:YES];
                    
                    [self buttonFailue];
                }
            };

        }
        else{
            //蓝牙关闭提示
          
            power = [[data objectForKey:@"powerNum"] intValue];//沙发的个数
            
            //判断是Home键还是R键
            NSString *Home = [data objectForKey:@"controlLayout"];//判断布局
            if ([Home isEqualToString:@"Home"]) {
                isHome = true;
            }
            else{
                isHome = false;
            }
            
            //是否需要进入灯控界面
            lightStr = [data objectForKey:@"light"];
            light = NO;
            if ([lightStr isEqualToString:@"NO"]) {
                light = NO;
            }
            else{
                light = YES;
            }
            
            isLock = NO;
            isError = NO;
            [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
            [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
            //操作布局
            [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];
            
            [self updateLog:@"Please open Bluetooth"];
            [self dataAnalysisProcessing:NO isErr:NO];
            [self buttonFailue];
        }
    }];
    
    
}

//最大连接数量
-(void)maxConnectState:(BOOL)state{
    
    if (!state) {
        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
        [self buttonFailue];
        
        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
        
    }
    else{
//        [self buttonOK];
    }
}

-(void)clickSofaLayout:(NSDictionary *)data position:(int)position{
    
    //判断沙发是左边还是右边座位
    if (position == 0) {
        pos = @"01";
    }
    else{
        pos = @"02";
    }
    
    power = [[data objectForKey:@"powerNum"] intValue];//沙发的个数
   
    
    //判断是Home键还是R键
    NSString *Home = [data objectForKey:@"controlLayout"];//判断布局
    if ([Home isEqualToString:@"Home"]) {
        isHome = true;
    }
    else{
        isHome = false;
    }
    
    //是否需要进入灯控界面
    lightStr = [data objectForKey:@"light"];
    light = NO;
    if ([lightStr isEqualToString:@"NO"]) {
        light = NO;
    }
    else{
        light = YES;
    }
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON] && !isOffElectriclight) {
        //打开蓝牙
        if (!bleCurrentConnectState) {
            [sofa_arr removeObjectAtIndex:currentPos];
            [sofa_arr insertObject:currentDic atIndex:currentPos];
            
            [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
            [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
            
            return;
        }
    }
    else{
        
        [sofa_arr removeObjectAtIndex:currentPos];
        [sofa_arr insertObject:currentDic atIndex:currentPos];
        
        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
        [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
        
        if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
            
        }
        else{
            [self updateLog:@"Please open Bluetooth"];
        }
        
        return ;
    }
    
    //注册命令
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"03",[NSString stringWithFormat:@"%@000000",pos],msgCRC16]];
    //数据返回
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"注册==%@",array);
        
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [self maxConnectState:NO];
            maxMacid = identifier;//最大连接数的id
            return ;
        }
        else{
//            [self maxConnectState:YES];
            maxMacid = @"";
        }
        
        isLock = NO;
        isError = NO;
        
        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
        
        //将sofadata中的isSelfLock置为1
        NSMutableDictionary *temp_dic = [temp_arr objectAtIndex:currentIndexPos];
        
//        NSLog(@"[self responseData:array]==%@",[self responseData:array]);
        if ([[self responseData:array] intValue] == 0) {
            //正常
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
        }
        else if([[self responseData:array] intValue] == 1){
            //锁定,他人锁定
            isLock = YES;
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
        }
        else if([[self responseData:array] intValue] == 2 || [[self responseData:array] intValue] == 3) {
            //错误,通讯故障、控制器故障
            isError = YES;
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
        }
        
        
        [temp_arr removeObjectAtIndex:currentIndexPos];
        [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
        
        [currentDic setObject:temp_arr forKey:@"sofadata"];
//        NSLog(@"currentDic==%@",currentDic);
        
        [sofa_arr removeObjectAtIndex:currentPos];
        [sofa_arr insertObject:currentDic atIndex:currentPos];
        
//        NSLog(@"=======sofa_arr======%@",sofa_arr);
        
        if (isLock == NO) {
            //判断本地自己是否锁定
            NSArray *sofadata = [data objectForKey:@"sofadata"];
            if ([[[sofadata objectAtIndex:position] objectForKey:@"isSelfLock"] intValue] == 1) {
                
                isLock = YES;
            }
        }
        
        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
        
        [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
        
        if (!isLightBack) {
            //操作布局
            [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];
        }
        else{
            isLightBack = NO;
        }
        
    };
}


//判断当前锁的状态
-(void)isLockState:(finishRecvBoolean)block{
    
    self.finishData = block;
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
   
        [self buttonFailue];
        [self updateLog:@"Please open Bluetooth"];
       
        return;
    }
    
    //注册命令
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"03",[NSString stringWithFormat:@"%@000000",pos],msgCRC16]];
    //数据返回
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"判断当前状态array==%@",array);
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [self maxConnectState:NO];
            return ;
        }
        else{
//            [self maxConnectState:YES];
        }
        
        isLock = NO;
        isError = NO;
        
        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
        
        //将sofadata中的isSelfLock置为1
        NSMutableDictionary *temp_dic = [temp_arr objectAtIndex:currentIndexPos];
        
        NSDictionary *storeTemp = [[NSDictionary alloc] initWithDictionary:temp_dic];
        //        NSLog(@"[self responseData:array]==%@",[self responseData:array]);
        if ([[self responseData:array] intValue] == 0) {
            /*
            //正常
            if ([[temp_dic objectForKey:@"isLock"] intValue] == 1) {
                //解锁
                
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
                
                
                [temp_arr removeObjectAtIndex:currentIndexPos];
                [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
                
                [currentDic setObject:temp_arr forKey:@"sofadata"];
                //        NSLog(@"currentDic==%@",currentDic);
                
                [sofa_arr removeObjectAtIndex:currentPos];
                [sofa_arr insertObject:currentDic atIndex:currentPos];
                
                [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
                [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
                //操作布局
                [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];
            }
            */
            
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
        }
        else if([[self responseData:array] intValue] == 1){
            //锁定,他人锁定
            isLock = YES;
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
        }
        else{
            //错误
            isError = YES;
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
            if ([[self responseData:array] intValue] == 2 || [[self responseData:array] intValue] == 3){
                [self buttonFailue];
            }
        }
        
        
        [temp_arr removeObjectAtIndex:currentIndexPos];
        [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
        
        [currentDic setObject:temp_arr forKey:@"sofadata"];
        //        NSLog(@"currentDic==%@",currentDic);
        
        [sofa_arr removeObjectAtIndex:currentPos];
        [sofa_arr insertObject:currentDic atIndex:currentPos];
        
        //        NSLog(@"=======sofa_arr======%@",sofa_arr);
        
        
        if ([[self responseData:array] intValue] == 0) {
            if ([[storeTemp objectForKey:@"isLock"] intValue] == 1) {
                
                [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
                [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
                //操作布局
                [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];
            }
        }
        
        if (isLock == NO) {
            //判断本地自己是否锁定
            NSArray *sofadata = [currentDic objectForKey:@"sofadata"];
            if ([[[sofadata objectAtIndex:([pos intValue]-1)] objectForKey:@"isSelfLock"] intValue] == 1) {
                
                isLock = YES;
            }
        }
        
        if (isLock) {
            
            [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
            
            [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
            
            //操作布局
            [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];
        }
        
        if (self.finishData) {
            self.finishData(isLock);
            self.finishData = nil;
        }
    };
}

//解锁/加锁
-(void)isLockFunc:(BOOL)lock{

    //当为他人锁时
    [self isLockState:^(BOOL locked) {
        
        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
        //将sofadata中的isSelfLock置为1
        NSMutableDictionary *temp_dic = [temp_arr objectAtIndex:currentIndexPos];
        
        NSString *lockStr = @"";
        if (lock) {
            //解锁
            if ([[temp_dic objectForKey:@"isLock"] intValue] == 1) {
                [self updateLog:@"You have no right to unlock"];
                return;
            }
            
            lockStr = @"00";
        }
        else{
            //锁定
            lockStr = @"01";
        }
        
        isEnterNext = NO;
        //复位发送后退控制码0x23，电机编号传送00ffff
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"23",[NSString stringWithFormat:@"%@%@FFFF",pos,lockStr ],msgCRC16]];
        
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
            //        NSLog(@"数据返回：read==%@",array);
            if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                [self maxConnectState:NO];
                return ;
            }
            
            if ([[self responseData:array] intValue] == 0) {
                
                if ([lockStr isEqualToString:@"00"]) {
                    //                [self updateLog:@"解锁成功"];
                    isLock = NO;
                    [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
                }
                else if ([lockStr isEqualToString:@"01"]){
                    isLock = YES;
                    [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isSelfLock"];
                }
                
            }
            
            [temp_arr removeObjectAtIndex:currentIndexPos];
            [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
            
            [currentDic setObject:temp_arr forKey:@"sofadata"];
            //        NSLog(@"currentDic==%@",currentDic);
            
            [sofa_arr removeObjectAtIndex:currentPos];
            [sofa_arr insertObject:currentDic atIndex:currentPos];
            
            [headerView opHeaderViewLayout:[sofa_arr objectAtIndex:currentPos] isLock:isLock isError:isError];//进入头部
            
            //操作布局
            [functionView opFunctionLayout:isLock isError:isError isLight:light isHome:isHome position:power];
            
            isEnterNext = YES;
            
        };
    }];
    
   
}


//灯
-(void)isLightFunc:(BOOL)isLight
{
//    [self buttonOK];
    
    [self isLockState:^(BOOL locked) {
        
        if (isEnterNext) {
            isLightBack = YES;
            LightViewController *lightController = [[LightViewController alloc] init];
            lightController.lightStr = lightStr;
            lightController.data = currentDic;
            [self.navigationController pushViewController:lightController animated:true];
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -
#pragma - 复位
//复位
-(void)resertFunc{
    
//    NSLog(@"复位:");
    [self isLockState:^(BOOL locked) {
        if (!locked) {
            //复位的时候，点击不需要停止
            //复位发送后退控制码0x12，电机编号传送00ffff
            isEnterNext = NO;
            [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@%@",msgHead,msgLength,@"12",pos,@"000000",msgCRC16]];
            [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                //NSLog(@"数据返回：read==%@",array);
                if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                    [self maxConnectState:NO];
                    return ;
                }
                
                [self buttonOK];
                isEnterNext = YES;
            };
        }
    }];
}


//开始Home
-(void)startResertHomeFunc{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startResertHomeFunc_temp) object:nil];
    [self performSelector:@selector(startResertHomeFunc_temp) withObject:nil afterDelay:0.1];

}


-(void)startResertHomeFunc_temp{
    
    [self isLockState:^(BOOL locked) {
        if (!locked) {
            //点击home键的时候，松开写入停止命令
            isEnterNext = NO;
            [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@%@",msgHead,msgLength,@"12",pos,@"000000",msgCRC16]];
            [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                //                NSLog(@"数据返回：read==%@",array);
                if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                    [self maxConnectState:NO];
                    return ;
                }
                
                [self buttonFailue];
            };
        }
    }];

}

//停止Home
-(void)stopResertHomeFunc{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopResertHomeFunc_temp) object:nil];
    [self performSelector:@selector(stopResertHomeFunc_temp) withObject:nil afterDelay:0.1];
}

-(void)stopResertHomeFunc_temp{
    
    [self isLockState:^(BOOL locked) {
        //停止0x13-左
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"13",[NSString stringWithFormat:@"%@000000",pos],msgCRC16]];
        
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
            //        NSLog(@"停止命令==%@",array);
            if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                [self maxConnectState:NO];
                return ;
            }
            
            [self buttonOK];
            isEnterNext = YES;
            
            [self isLockState:^(BOOL locked) {
            }];
        };
    }];

}

//按钮恢复
-(void)buttonOK{
    
    for (UIView *sub in functionView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn =(UIButton *)sub;
            [btn setEnabled:YES];
        }
    }
    
    isEnterNext = YES;
}

//按钮禁止
-(void)buttonFailue{
    
    for (UIView *sub in functionView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn =(UIButton *)sub;
            [btn setEnabled:NO];
        }
    }
}

//意外中断通知
-(void)UnexpectedInterruptionNotice{
    NSLog(@"意外中断");
    [self buttonOK];
//    [self stopRotateFunc];
    if (currentDic) {
         [self stopResertHomeFunc];
    }
   
}

#pragma -
#pragma - 点击用于恢复
//恢复记忆
-(void)recoveryMemeryFunc:(NSString *)position{
    [self isLockState:^(BOOL locked) {
        if (!locked) {
            
            NSString *namePos = [NSString stringWithFormat:@"%@%@%@",identifier,pos,position];
//            NSLog(@"namePos::%@",namePos);
            NSDictionary *mPosition = [[NSUserDefaults standardUserDefaults] objectForKey:namePos];
//            NSLog(@"mPosition::%@",mPosition);
            if (mPosition) {
                
                powerIndex=1;
                timeoutIndex = 0;
                
                [self read:power opstr:@"22" mPos:mPosition];
                
            }
            else{
                [self updateLog:@"No memory settings yet"];//[NSString stringWithFormat:@"暂无设置%@",position]
                [self buttonOK];
            }

        }
    }];
    
}


//读取位置
-(void)read:(int)num opstr:(NSString *)opstr mPos:(NSDictionary *)mPos{
    
  
    //0x22
    timeoutIndex++;
    if (powerIndex <= num) {
        
        NSString *positionName = [NSString stringWithFormat:@"%@%02d",pos,powerIndex];
//        NSLog(@"positionName==%@",positionName);
        
        NSString *temp =[mPos objectForKey:positionName];
        isEnterNext = NO;
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,opstr,[[temp substringFromIndex:temp.length - 14] substringToIndex:8],msgCRC16]];
        
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//            NSLog(@"数据返回：read==%@",array);
            if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                [self maxConnectState:NO];
                return ;
            }
            
            if ([[self responseData:array] intValue] == 0) {
                
                powerIndex++;
                timeoutIndex = 0;
                [NSThread sleepForTimeInterval:delayTime/1000.0];//暂停
                [self read:num opstr:opstr mPos:mPos];
            }
            else if ([[self responseData:array] intValue] == 4){
                
                //如果无线忙碌
                [NSThread sleepForTimeInterval:delayTime/1000.0];//暂停
                if (timeoutIndex < repeatTime) {
                    [self read:num opstr:opstr mPos:mPos];
                }
                else{
//                    [self updateLog:@"超过了10次"];
                    [self buttonOK];
                    isEnterNext = YES;
                }
            }
            else{
                [self buttonOK];
                isEnterNext = YES;
            }
        };
    }
    else{
        [self buttonOK];
        isEnterNext = YES;
    }
}

//修改状态
-(void)changeStateFunc{
    
    isEnterNext = NO;
}


//修改状态
-(void)changeStateOKFunc{
    
    isEnterNext = YES;
}

#pragma -
#pragma - 长按用于记忆
//保存记忆
-(void)saveMemeryFunc:(NSString *)position{

    //position为1的时候，记忆左边，当2时记忆右
    [self isLockState:^(BOOL locked) {
        if (!locked) {
          
            //读取当前的位置
            memeryIdent = position;
            powerIndex=1;
            savePowerPosition = [NSMutableDictionary new];//位置保存
            
            [self setting:power opstr:@"21"];
        }
    }];
    
    
}

 
//设置长按按钮
-(void)setting:(int)num opstr:(NSString *)opstr{
    
    //0x21--读取
    if (powerIndex <= num) {
      
        isEnterNext = NO;
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,opstr,[NSString stringWithFormat:@"%@%02d0000",pos,powerIndex],msgCRC16]];
        
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//             NSLog(@"数据返回：read==%@",array);
            if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                [self maxConnectState:NO];
                return ;
            }
            
            if ([[self responseData:array] intValue] == 0) {
                
                [savePowerPosition setObject:[array componentsJoinedByString:@""] forKey:[NSString stringWithFormat:@"%@%02d",pos,powerIndex]];
                
                powerIndex++;
                [self setting:num opstr:opstr];
            }
            else{
                 [self buttonOK];
                isEnterNext = YES;
            }
        };
    }
    else{
//        NSLog(@"这里呢");
        [self buttonOK];
        isEnterNext = YES;
        [self updateLog:@"Memory position set successfully"];
        [[NSUserDefaults standardUserDefaults] setObject:savePowerPosition forKey:[NSString stringWithFormat:@"%@%@%@", identifier,pos,memeryIdent]];
        
        [functionView setSaveNum];//设置变量为0
//        NSLog(@"savePowerPosition==%@",savePowerPosition);
    }
}



//开始旋转
-(void)startRotateFunc:(NSString *)position indexNum:(NSString *)indexNum
{
    seatPosition = indexNum;
    directPosition = position;
    isTouchDown = NO;
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRotateFunc_temp) object:nil];
    [self performSelector:@selector(startRotateFunc_temp) withObject:nil afterDelay:0.1];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopRotateFunc_temp) object:nil];

}


-(void)startRotateFunc_temp{
    
    [self isLockState:^(BOOL locked) {
        if (!locked) {
            
            faileTimes = 0;
            //首先判断是哪一个沙发位置
            if ([directPosition isEqualToString:@"L"]) {
                //前进
                [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"11",[NSString stringWithFormat:@"%@%@0000",pos,seatPosition],msgCRC16]];
                
            }
            else if ([directPosition isEqualToString:@"R"]){
                //后退
                [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"12",[NSString stringWithFormat:@"%@%@0000",pos,seatPosition],msgCRC16]];
            }
            isEnterNext = NO;
            [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                
                NSLog(@"数据返回：read0x12==%@",array);
                isTouchDown = YES;
                if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                    [self maxConnectState:NO];
                    return ;
                }
                
                if ([[self responseData:array] intValue] == 4) {
                    //设备忙碌
                    if (faileTimes < repeatTime) {
                        //隔50ms发送指令
                        faileTimes++;
                        [self performSelector:@selector(stopRotateFunc) withObject:nil afterDelay:delayTime/1000.0];
                    }
                    else{
                        
                        //[self updateLog:@"通讯忙碌"];
                    }
                }
                else{
                    faileTimes=0;
                }
                
            };
            
        }
    }];

}

//停止旋转
-(void)stopRotateFunc{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRotateFunc_temp) object:nil];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopRotateFunc_temp) object:nil];
    [self performSelector:@selector(stopRotateFunc_temp) withObject:nil afterDelay:0.1];
//    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopRotateFunc_temp) object:nil];
}


-(void)stopRotateFunc_temp{
    //停止0x13-左
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"13",[NSString stringWithFormat:@"%@%@0000",pos,seatPosition],msgCRC16]];
    
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
        NSLog(@"数据返回：read0x13==%@",array);
        isTouchDown = NO;
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [self maxConnectState:NO];
            return ;
        }
        
        isEnterNext = YES;
        if ([[self responseData:array] intValue] == 0) {
            
        }
        else
        {
            //锁定
            [self isLockState:^(BOOL locked) {
            }];
        }
        
    };

}


@end
