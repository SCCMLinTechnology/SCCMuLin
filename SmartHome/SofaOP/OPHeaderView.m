//
//  OPHeaderView.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/24.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "OPHeaderView.h"

@implementation OPHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initView];//初始化view
    }
    return self;
}

-(void)initView{
    
    //背景图
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"bg_headerbg"];
    bgImg.tag = 1000;
    [self addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.left.mas_offset(70);
            make.right.mas_offset(-70);
            make.top.bottom.mas_offset(0);
//            make.left.right.top.bottom.mas_equalTo(0);
        }
        else{
            make.left.right.top.bottom.mas_equalTo(0);
        }
        
    }];
    
    //布局按钮
    UIButton *layoutBtn = [UIButton new];
    [layoutBtn setImage:[UIImage imageNamed:@"bt_buju_n"] forState:UIControlStateNormal];
    [layoutBtn setBackgroundImage:[UIImage imageNamed:@"bt_buju_n"] forState:UIControlStateNormal];
    layoutBtn.tag = 1001;
    [layoutBtn addTarget:self action:@selector(clicklayout) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:layoutBtn];
    [layoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.right.mas_equalTo(-20-90);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }
        else{
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(37, 37));
        }
        
    }];
}

//点击进入布局
-(void)clicklayout{
    
    [_delegate clickLayoutFunc:NO];//进入布局
}
//头部布局
-(void)opHeaderViewLayout:(NSDictionary *)data isLock:(BOOL)isLock isError:(BOOL)isError{
    
    //删除以前布局
    for (UIView *sub in self.subviews) {
        if (sub.tag < 1000) {
            [sub removeFromSuperview];
        }
    }
//    NSLog(@"data======头部数据======%@",data);
    tempData = data;
    lock = isLock;
    error = isError;
    
    int num = [[data objectForKey:@"num"] intValue];//沙发的个数
    int power = [[data objectForKey:@"powerNum"] intValue];//沙发的个数
    int tag = [[data objectForKey:@"tag"] intValue];//获取到tag值
    //方格显示
    UIView *singleView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - boxContentWidth*num)/2 , (self.frame.size.height - boxContentHeight)/2 ,boxContentWidth*num, boxContentHeight)];
    [self addSubview:singleView];
//    [singleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(boxContentWidth*num, boxContentHeight));
//    }];
    
    //添加背景图片
    UIImageView *bg = [UIImageView new];
//    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s",num,power]];
    if (num == 1) {
        bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s",num,power]];
    }
    else{
        bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_all_%d",power]];
    }
    [singleView addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(0);
    }];
    
  
    //根据沙发的位数,添加按钮
    NSArray * sofadata = [data objectForKey:@"sofadata"];
    
    for (int j = 0; j<sofadata.count; j++) {
        //单人位沙发
        UIButton *sofaBtn = nil;
        if (num == 1) {
            sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width-btnWidth)/2, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
        }
        else if (num == 2){
            //2人位水平方向
            sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width/num-btnWidth)+btnWidth*j, (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
        }
        else{
            //3人位水平方向
            sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width/num-40), (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
        }
        
        if (j == 0) {
            sofaBtn.tag = 1000 + tag;
//            sofaBtn.backgroundColor = [UIColor greenColor];
        }
        else{
            sofaBtn.tag = 1000 + tag + 500;
            //                sofaBtn.backgroundColor = [UIColor redColor];
        }
        
        //判断是否选中
        if ([[[sofadata objectAtIndex:j] objectForKey:@"isCurrentPosition"] intValue]==1) {
            if (num == 1) {
                //单人位沙发选中
                bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_un",num,power]];
            }
            else{
                /*-----*/
               
                if (j==0) {
                    //右边沙发选中
                    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_r",num,power]];
                    
                }
                else{
                    //左边沙发选中
                    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_l",num,power]];
                }
                
                /*-----*/
                /*
                if (j==0) {
                    //左边沙发选中
                    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_l",num,power]];
                    
                    
                }
                else{
                    //右边沙发选中
                    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_r",num,power]];
                }
                */
            }
        }
        
        int lockInt = [[[sofadata objectAtIndex:j] objectForKey:@"isLock"] intValue];
        int selfLockInt = [[[sofadata objectAtIndex:j] objectForKey:@"isSelfLock"] intValue];
        
        int selfErrorInt = [[[sofadata objectAtIndex:j] objectForKey:@"isError"] intValue];
//        NSLog(@"lockInt==%d",lockInt);
        if (lockInt == 1 || selfLockInt == 1 || selfErrorInt == 1) {
            
            UIImageView *lockImg = [UIImageView new];
            if (selfErrorInt == 1) {
                lockImg.image = [UIImage imageNamed:@"ic_huai"];
            }
            else{
                lockImg.image = [UIImage imageNamed:@"ic_suo"];
            }
            
            [singleView addSubview:lockImg];
            [lockImg mas_makeConstraints:^(MASConstraintMaker *make) {
                if (num == 1) {
                    make.center.mas_equalTo(singleView);
                }
                else{
                    if (j==0) {
                        make.centerX.mas_equalTo(singleView.mas_centerX).offset(-((singleView.frame.size.width/2-20)/2)-5);
                    }
                    else{
                        make.centerX.mas_equalTo(singleView.mas_centerX).offset(((singleView.frame.size.width/2-20)/2)+5);
                    }
                    
                    make.centerY.mas_equalTo(singleView);
                }
               
                if (selfErrorInt == 1) {
                    make.size.mas_equalTo(CGSizeMake(20, 20));
                }
                else{
                    make.size.mas_equalTo(CGSizeMake(20, 24));
                }
                
            }];

        }

       /*
        if (selfErrorInt) {
            UIImageView *lockImg = [UIImageView new];
            lockImg.image = [UIImage imageNamed:@"ic_huai"];
            [singleView addSubview:lockImg];
            [lockImg mas_makeConstraints:^(MASConstraintMaker *make) {
                if (num == 1) {
                    make.center.mas_equalTo(singleView);
                }
                else{
                    if (j==0) {
                        make.centerX.mas_equalTo(singleView.mas_centerX).offset(-((singleView.frame.size.width/2-20)/2)-5);
                    }
                    else{
                        make.centerX.mas_equalTo(singleView.mas_centerX).offset(((singleView.frame.size.width/2-20)/2)+5);
                    }
                    
                    make.centerY.mas_equalTo(singleView);
                }
                
                make.size.mas_equalTo(CGSizeMake(20, 20));
            }];

        }
        */

        [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
        [singleView addSubview:sofaBtn];
    }

    
    
    
}

//点击某个沙发
-(void)clickSofa:(UIButton *)sender{
    NSLog(@"sofa:::%@",sender);
    
    //    orderNum = (int)(sender.tag);
    //解析沙发的位置
    [self layoutsofa:(int)(sender.tag)];
    
}



-(void)layoutsofa:(int)num{
    
    int tag = 0;
    tag = num-1000;//取得tag值
    
    //判断当是2人位或者3人位的时候，是哪一个沙发触发
    /*-----*/
    
    int index = 0;
    if (tag>500) {
        tag=tag - 500;
        index =1;
    }
     
    /*-----*/
    /*
    int index = 1;
    if (tag>500) {
        tag=tag - 500;
        index = 0;
    }
    */
    //获取数组中的每一个字典数据
    NSMutableDictionary *d=[[NSMutableDictionary alloc]initWithDictionary:tempData];
    
//    int num_sofa = [[tempData objectForKey:@"num"] intValue];//沙发的个数
//    if (num_sofa == 1) {
//        index = 0;
//    }
    
    //读取字典数据中的sofadata字段
    NSMutableArray *temp =[[NSMutableArray alloc] initWithArray:[d objectForKey:@"sofadata"]];
    //判断字段中有几组数据
    for (int j =0; j<temp.count; j++) {
        
        NSMutableDictionary *chooseDic = [[NSMutableDictionary alloc]initWithDictionary:[temp objectAtIndex:j]];
        //如果序号和组号都对应的上。则选中
        if (index == j) {
            //将选中isCurrentPosition字段置为1
            [chooseDic setObject:[NSNumber numberWithInt:1] forKey:@"isCurrentPosition"];
            
        }
        else{
            //其余将isCurrentPosition置为0
            [chooseDic setObject:[NSNumber numberWithInt:0] forKey:@"isCurrentPosition"];
        }
        
        [temp removeObjectAtIndex:j];
        [temp insertObject:chooseDic atIndex:j];
    }
    
    [d setObject:temp forKey:@"sofadata"];//将修改后的sofadata保存
    
//    NSLog(@"dddd==%@",d);
    
//    [self opHeaderViewLayout:d isLock:lock isError:error]; //刷新界面

    //将数据返回到界面上
    [_delegate saveHandleDataFunc:d position:index];
  

}





@end
