//
//  LayoutSofaView.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/23.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "LayoutSofaView.h"

@implementation LayoutSofaView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
        //画网格
        DotView * containerView = [DotView new];
        containerView.backgroundColor = [UIColor clearColor];
//        containerView.layer.borderColor = kUIColorFromRGB(0xb1b9bd).CGColor;
//        containerView.layer.borderWidth = 1;
        [self addSubview:containerView];
        
        containerView.row = heng_box;//行
        containerView.col = shu_box;//列
        containerView.width = boxWidth;
//        containerView.layer.shadowOpacity = 0.5;// 阴影透明度
//        containerView.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
//        containerView.layer.shadowRadius = 3;// 阴影扩散的范围控制
//        containerView.layer.shadowOffset  = CGSizeMake(3, 3);// 阴影的范围
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(boxWidth * shu_box);
            make.height.mas_equalTo(boxWidth * heng_box);
        }];
        
        [containerView setNeedsDisplay];//调用

    }
    return self;
}


-(void)layoutSetDataToBox:(NSArray *)sofaArr isMove:(BOOL)isMove isBack:(BOOL)isBack isTest:(BOOL)isTest finishCallBack:(finishRecvData)block{
    
    //删除以前布局，只保留一层
    for (UIView *sub in self.subviews) {
        if (sub.tag >99) {
            [sub removeFromSuperview];
        }
    }
    
    isLayoutBack = isBack;
    isLayoutMove = isMove;
    if (isBack) {
        
        self.finishData = block;
    }
    
    opArr = sofaArr;
//    NSLog(@"opArr==%@",opArr);
    for(int i = 0;i<sofaArr.count;i++){
        
        if ([[sofaArr objectAtIndex:i] isKindOfClass:[NSString class]]) {
            continue;
        }
        
        int x = [[[sofaArr objectAtIndex:i] objectForKey:@"x"] intValue];
        int y = [[[sofaArr objectAtIndex:i] objectForKey:@"y"] intValue];
        
        int num = [[[sofaArr objectAtIndex:i] objectForKey:@"num"] intValue];//沙发的个数
        int power = [[[sofaArr objectAtIndex:i] objectForKey:@"powerNum"] intValue];//沙发的个数
        
        //方格显示
        UIView *singleView= [[UIView alloc] initWithFrame:CGRectMake(boxWidth*x+(boxWidth-boxContentWidth)/2*num,boxWidth*y+(boxWidth-boxContentHeight)/2,boxContentWidth*num, boxContentHeight)];
        
        //获取到tag值
        int tag = [[[sofaArr objectAtIndex:i] objectForKey:@"tag"] intValue];
        singleView.tag = tag;
        

        //添加背景图片
        UIImageView *bg = [[UIImageView alloc] initWithFrame:singleView.bounds];
        if (num == 1) {
             bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s",num,power]];
        }
        else{
             bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_all_%d",power]];
        }
       
        [singleView addSubview:bg];
        
        /*
        //根据沙发的位数,添加按钮
        NSArray * sofadata = [[sofaArr objectAtIndex:i] objectForKey:@"sofadata"];
        
        for (int j = 0; j<sofadata.count; j++) {
            
            int lockInt = [[[sofadata objectAtIndex:j] objectForKey:@"isLock"] intValue];
            int selfLockInt = [[[sofadata objectAtIndex:j] objectForKey:@"isSelfLock"] intValue];
            NSLog(@"lockInt==%d",lockInt);
            if (lockInt == 1 || selfLockInt == 1) {
                
                UIImageView *lockImg = [UIImageView new];
                lockImg.image = [UIImage imageNamed:@"ic_suo"];
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
                    
                    make.size.mas_equalTo(CGSizeMake(20, 24));
                }];
            }
        }
       */
        
        
        //方向
        int direct = [[[sofaArr objectAtIndex:i] objectForKey:@"sofaDirect"] intValue];
//        NSLog(@"direct==%d",direct);
        
//        if (direct == 2 || direct == 4) {
//            singleView.frame = CGRectMake(boxWidth*x+(boxWidth-boxContentHeight)/2,boxWidth*y+(boxWidth-boxContentHeight)/2,boxContentHeight, boxContentWidth*num);
//        }
        if (direct > 1) {
            //判断2人位时
            if(tag >= 200 && tag < 300 &&  direct != 3){
                
                if (singleView.transform.b == 1){
                    //顺90
                    singleView.center = CGPointMake(singleView.center.x-boxWidth/2, singleView.center.y-boxWidth/2);
                }
                else if (singleView.transform.a == -1){
                    
                    singleView.center = CGPointMake(singleView.center.x+boxWidth/2, singleView.center.y-boxWidth/2);
                }
                else if (singleView.transform.c == 1){
                    
                    singleView.center = CGPointMake(singleView.center.x+boxWidth/2, singleView.center.y+boxWidth/2);
                }
                else{
                    //横
                    singleView.center = CGPointMake(singleView.center.x-boxWidth/2, singleView.center.y+boxWidth/2);
                }
            }
            
            singleView.transform = CGAffineTransformMakeRotation(M_PI_2*(direct-1));
        }

        
        isLayoutTest = isTest;
        if (isTest) {
            //判断是否为测试
            int current = [[[sofaArr objectAtIndex:i] objectForKey:@"isCurrent"] intValue];//判断是否当前选中沙发
            int test = [[[sofaArr objectAtIndex:i] objectForKey:@"isTest"] intValue];
            
            //判断是否错误
            int error1 = [[[[[sofaArr objectAtIndex:i] objectForKey:@"sofadata"] objectAtIndex:0]objectForKey:@"isError"] intValue];
            int error2 = 0;
            if (num == 2) {
                error2 = [[[[[sofaArr objectAtIndex:i] objectForKey:@"sofadata"] objectAtIndex:1]objectForKey:@"isError"] intValue];
            }
            
            //判断是否锁定
            int lock1 = [[[[[sofaArr objectAtIndex:i] objectForKey:@"sofadata"] objectAtIndex:0]objectForKey:@"isLock"] intValue];
            int lock2 = 0;
            if (num == 2) {
                lock2 = [[[[[sofaArr objectAtIndex:i] objectForKey:@"sofadata"] objectAtIndex:1]objectForKey:@"isLock"] intValue];
            }
            //判断是否当前选中
            if (current == 1) {
                  bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_un",num,power]];
            }
            else{
                
                if (num == 1) {
                    //单人位沙发选中
                    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s",num,power]];
                }
                else{
                    
                    bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_all_%d",power]];
                    
                }
                
            }
            
            //判断是否已经测试过
            if (test == 1 || isTest) {
                if (num == 2) {
                    if (direct == 2 || direct == 4) {
                        
                        if (error1 || error2) {
                            //显示错误
                            UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.height - 20)/2, (singleView.frame.size.width - 20)/2, 20, 20)];
                            checkbg.image = [UIImage imageNamed:@"ic_huai"];
                            [singleView addSubview:checkbg];
                        }
                        else if (lock1 || lock2){
                            //显示锁
                            UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.height - 27)/2, (singleView.frame.size.width - 23)/2, 23, 27)];
                            checkbg.image = [UIImage imageNamed:@"ic_suo"];
                            [singleView addSubview:checkbg];
                        }
                        else if(test == 1) {
                            //添加勾
                            UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.height - 20)/2, (singleView.frame.size.width - 23)/2, 23, 20)];
                            checkbg.image = [UIImage imageNamed:@"check"];
                            [singleView addSubview:checkbg];
                        }
                        
                    }
                    else{
                        if (error1 || error2) {
                            //显示错误
                            UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.width - 20)/2, (singleView.frame.size.height - 20)/2, 20, 20)];
                            checkbg.image = [UIImage imageNamed:@"ic_huai"];
                            [singleView addSubview:checkbg];
                        }
                        else if (lock1 || lock2){
                            //显示锁
                            UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.width - 23)/2, (singleView.frame.size.height - 27)/2, 23, 27)];
                            checkbg.image = [UIImage imageNamed:@"ic_suo"];
                            [singleView addSubview:checkbg];
                        }
                        else if(test == 1) {
                            //添加勾
                            UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.width - 23)/2, (singleView.frame.size.height - 20)/2, 23, 20)];
                            checkbg.image = [UIImage imageNamed:@"check"];
                            [singleView addSubview:checkbg];
                        }
                    }
                }
                else{
                    if (error1 || error2) {
                        //显示错误
                        UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.width - 20)/2, (singleView.frame.size.height - 20)/2, 20, 20)];
                        if (direct == 2 || direct == 4) {
                            checkbg.frame = CGRectMake((singleView.frame.size.height - 20)/2, (singleView.frame.size.width - 20)/2, 20, 20);
                        }
                        checkbg.image = [UIImage imageNamed:@"ic_huai"];
                        [singleView addSubview:checkbg];
                    }
                    else if (lock1 || lock2){
                        //显示锁
                        UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.width - 23)/2, (singleView.frame.size.height - 27)/2, 23, 27)];
                        if (direct == 2 || direct == 4) {
                            checkbg.frame = CGRectMake((singleView.frame.size.height - 23)/2, (singleView.frame.size.width - 27)/2, 23, 27);
                        }
                        checkbg.image = [UIImage imageNamed:@"ic_suo"];
                        [singleView addSubview:checkbg];
                    }
                    else if(test == 1) {
                        //添加勾
                        UIImageView *checkbg = [[UIImageView alloc] initWithFrame:CGRectMake((singleView.frame.size.width - 23)/2, (singleView.frame.size.height - 20)/2, 23, 20)];
                        if (direct == 2 || direct == 4) {
                            checkbg.frame = CGRectMake((singleView.frame.size.height - 23)/2, (singleView.frame.size.width - 20)/2, 23, 20);
                        }
                        checkbg.image = [UIImage imageNamed:@"check"];
                        [singleView addSubview:checkbg];
                    }
                }
                
            }

        }

        
        //根据沙发的位数,添加按钮
        NSArray *sofadata = [[sofaArr objectAtIndex:i] objectForKey:@"sofadata"];
        
        for (int j = 0; j<sofadata.count; j++) {
            //单人位沙发
            UIButton *sofaBtn = nil;
            if (num == 1) {
                
               sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width-btnWidth)/2, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
            }
            else if (num == 2){
                 if (direct == 2 || direct == 4) {
                     //垂直方向
                     sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.height/num-btnWidth)+btnWidth*j, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
                 }
                 else{
                     //水平方向
                     sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width/num-btnWidth)+btnWidth*j, (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
                 }
            }
            else{
                 if (direct == 2 || direct == 4) {
                     //垂直方向
                     sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.height/num-40), (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
                 }
                 else{
                     //水平方向
                     sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width/num-40), (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
                 }
            }
            
            
            if (j == 0) {
                sofaBtn.tag = 1000 + tag;
//                sofaBtn.backgroundColor = [UIColor greenColor];
            }
            else{
                sofaBtn.tag = 1000 + tag + 500;
//                sofaBtn.backgroundColor = [UIColor redColor];
            }
            
            int m_select = 0;
            CGRect rect = CGRectZero;
            
            //判断是否在操作界面选中
            if (!isTest) {
                //判断是否选中
                if ([[[sofadata objectAtIndex:j] objectForKey:@"isCurrentPosition"] intValue]==1) {
                
                    if (num == 1) {
                        //单人位沙发选中
                        bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_un",num,power]];
                    }
                    else{
                        /*-----*/
                        /*
                        if (j==0) {
                            //右边沙发选中
                            bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_r",num,power]];
                        }
                        else{
                            //左边沙发选中
                            bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_l",num,power]];
                        }
                        */
                        /*-----*/
                        
                        if (j==0) {
                            //左边沙发选中
                            bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_l",num,power]];
                        }
                        else{
                            //右边沙发选中
                            bg.image = [UIImage imageNamed:[NSString stringWithFormat:@"sofa_%d_%d_s_r",num,power]];
                        }
                    }
                }
                
                //判断是否有锁定，是否有异常
                int lockInt = [[[sofadata objectAtIndex:j] objectForKey:@"isLock"] intValue];
                int selfLockInt = [[[sofadata objectAtIndex:j] objectForKey:@"isSelfLock"] intValue];
                int selfErrorInt = [[[sofadata objectAtIndex:j] objectForKey:@"isError"] intValue];
                
                if (lockInt == 1 || selfLockInt == 1 || selfErrorInt == 1) {
                    //
                    
                    //                UIImageView *lockImg = [[UIImageView alloc] initWithFrame:CGRectMake((sofaBtn.frame.size.width - 20)/2, (sofaBtn.frame.size.height - 24)/2, 20, 24)];
                    //                if (direct == 2 || direct == 4) {
                    //                    lockImg.frame = CGRectMake((sofaBtn.frame.size.width - 24)/2, (sofaBtn.frame.size.height - 20)/2, 24, 20);
                    //                }
                    
                    if (num == 1) {
                        /*
                         UIImageView *lockImg = [UIImageView new];
                         lockImg.image = [UIImage imageNamed:@"ic_suo"];
                         [singleView addSubview:lockImg];
                         
                         [lockImg mas_makeConstraints:^(MASConstraintMaker *make) {
                         make.center.mas_equalTo(singleView);
                         make.size.mas_equalTo(CGSizeMake(20, 24));
                         
                         
                         }];
                         */
                        
//                        UIImageView *lockImg = [[UIImageView alloc] initWithFrame:CGRectMake(sofaBtn.frame.origin.x+(sofaBtn.frame.size.width - 20)/2+5, sofaBtn.frame.origin.y+(sofaBtn.frame.size.height - 24)/2, 20, 24)];
                        UIImageView *lockImg = [[UIImageView alloc] initWithFrame:CGRectMake(sofaBtn.frame.origin.y+(sofaBtn.frame.size.height - 20)/2, sofaBtn.frame.origin.x+(sofaBtn.frame.size.width - 24)/2, 20, 24)];
                        
                        if (direct == 1 || direct == 3) {
                            lockImg.frame =CGRectMake(sofaBtn.frame.origin.x+(sofaBtn.frame.size.width - 20)/2, sofaBtn.frame.origin.y+(sofaBtn.frame.size.height - 24)/2, 20, 24);
                        }
                        
                        if (selfErrorInt == 1) {
//
                            if (direct == 2 || direct == 4) {
                               lockImg.frame=CGRectMake(lockImg.frame.origin.y+5, lockImg.frame.origin.x, 20, 20);
                            }
                            else{
                               lockImg.frame=CGRectMake(lockImg.frame.origin.x, lockImg.frame.origin.y, 20, 20);
                            }
                     
                            lockImg.image = [UIImage imageNamed:@"ic_huai"];
                        }
                        else{
                            
                            if (direct == 1 || direct == 3) {
                                 lockImg.frame=CGRectMake(lockImg.frame.origin.x, lockImg.frame.origin.y-5, 20, 24);
                            }
                            lockImg.image = [UIImage imageNamed:@"ic_suo"];
                        }
                        //lockImg.backgroundColor =[UIColor greenColor];
                        [singleView addSubview:lockImg];
                    }
                    else if(num == 2){
                        
                        /*
                        UIImageView *lockImg = [[UIImageView alloc] initWithFrame:CGRectMake(sofaBtn.frame.origin.x+(sofaBtn.frame.size.width - 20)/2 +(j==0 ? +10 :-10), sofaBtn.frame.origin.y+(sofaBtn.frame.size.height - 24)/2, 20, 24)];
                        if (direct == 1 || direct ==3) {
                            lockImg.frame =CGRectMake(sofaBtn.frame.origin.x+(sofaBtn.frame.size.width - 20)/2+(j==0 ? +10 :-10) , sofaBtn.frame.origin.y+(sofaBtn.frame.size.height - 24)/2 +(-5), 20, 24);
                        }
                        if (selfErrorInt == 1) {
                            lockImg.frame=CGRectMake(lockImg.frame.origin.x, lockImg.frame.origin.y+5, 20, 20);
                            lockImg.image = [UIImage imageNamed:@"ic_huai"];
                        }
                        else{
                            
                            lockImg.image = [UIImage imageNamed:@"ic_suo"];
                        }
                        
                        
                        //lockImg.backgroundColor =[UIColor greenColor];
                        [singleView addSubview:lockImg];
                         */
                        
                        if (j==0) {
                            //左边沙发选中
                            m_select = 1;
                        }
                        else{
                            //右边沙发选中
                            m_select = 0;
                        }
                        
                        if (direct == 2 || direct == 4) {
                            //垂直方向
                            rect = CGRectMake((singleView.frame.size.height/num-btnWidth)+btnWidth*m_select, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth);
                        }
                        else{
                            //水平方向
                            rect = CGRectMake((singleView.frame.size.width/num-btnWidth)+btnWidth*m_select, (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth);
                        }
                        
                        UIImageView *lockImg = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x+(rect.size.width - 20)/2 +(m_select == 0 ? +10 :-10), rect.origin.y+(rect.size.height - 24)/2, 20, 24)];
                        if (direct == 1 || direct ==3) {
                            lockImg.frame =CGRectMake(rect.origin.x+(rect.size.width - 20)/2+(m_select == 0 ? +10 :-10) , rect.origin.y+(rect.size.height - 24)/2 +(-5), 20, 24);
                        }
                        if (selfErrorInt == 1) {
                            lockImg.frame=CGRectMake(lockImg.frame.origin.x, lockImg.frame.origin.y+5, 20, 20);
                            lockImg.image = [UIImage imageNamed:@"ic_huai"];
                        }
                        else{
                            lockImg.image = [UIImage imageNamed:@"ic_suo"];
                        }
                    
                        [singleView addSubview:lockImg];
                        
                    }
                }
            }
            
            
                /*
                [lockImg mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (num == 1) {
                        make.center.mas_equalTo(singleView);
                    }
                    else{
                        
                        if (direct == 1 || direct == 3) {
                            if (j==0) {
                                make.centerX.mas_equalTo(singleView.mas_centerX).offset(-((singleView.frame.size.width/2-20)/2)-5);
                            }
                            else{
                                make.centerX.mas_equalTo(singleView.mas_centerX).offset(((singleView.frame.size.width/2-20)/2)+5);
                            }
                            
                            make.centerY.mas_equalTo(singleView);
                        }
                        else if (direct == 2 || direct == 4){
                            if (j==0) {
//                                make.centerY.mas_equalTo(singleView.mas_centerY);
                                make.centerX.mas_equalTo(singleView.mas_centerX).offset(-(singleView.frame.size.height/2)-5);
                            }
                            else{
                                make.centerX.mas_equalTo(singleView.mas_centerX).offset((singleView.frame.size.height/2)+5);
                            }
                            
                            make.centerY.mas_equalTo(singleView.mas_centerY).offset(-singleView.frame.size.height/2);
//                            make.centerX.mas_equalTo(singleView);
                        }
                    }
                    
                    make.size.mas_equalTo(CGSizeMake(20, 24));
                }];
                 */
            
            
            
//            }

            
            [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
            [singleView addSubview:sofaBtn];
        }
        
        
        /*
        if (num == 1) {
            //单人位沙发
            UIButton *sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width-btnWidth)/2, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
            
            sofaBtn.tag = 1000 + tag;
            sofaBtn.backgroundColor = [UIColor greenColor];
         
            //判断是否选中
            if ([[[sofadata objectAtIndex:0] objectForKey:@"isCurrentPosition"] intValue]==1) {
                
                [sofaBtn setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                //上,右,下，左
                sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth, spaceWidth, spaceWidth);
            }
            //判断是否锁住
            if ([[[sofadata objectAtIndex:0] objectForKey:@"isLock"] intValue]==1) {
                
                [sofaBtn setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth, spaceWidth, spaceWidth);
                //                [sofaBtn setEnabled:NO];
            }
         
            [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
            [singleView addSubview:sofaBtn];
            
            
        }
        else if(num == 2){
            //双人位沙发
            if (direct == 2 || direct == 4) {//垂直方向
                
                UIButton *sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.height/num-btnWidth), (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn.tag = 1000 + tag;
                sofaBtn.backgroundColor = [UIColor redColor];
                
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    [sofaBtn setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                    
                }
                
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isLock"] intValue]==1) {
                    
                    [sofaBtn setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                    //                    [sofaBtn setEnabled:NO];
                }
         
                [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn];
                
                
                
                
                UIButton *sofaBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(singleView.frame.size.height/num, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn1.tag = 1000 + tag + 500;
                sofaBtn1.backgroundColor = [UIColor greenColor];
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    
                    [sofaBtn1 setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth, spaceWidth+10);
                }
                
                
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn1 setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth, spaceWidth+10);
                    //                    [sofaBtn1 setEnabled:NO];
                }
         
                
                [sofaBtn1 addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn1];
                
            }
            else{
                //水平方向
                UIButton *sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width/2-btnWidth), (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn.tag = 1000 + tag;
                sofaBtn.backgroundColor = [UIColor redColor];
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    
                    [sofaBtn setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                    
                }
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                    //                    [sofaBtn setEnabled:NO];
                }
         
                
                [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn];
                
                
                
                
                UIButton *sofaBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(singleView.frame.size.width/2, (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn1.tag = 1000 + tag + 500;
                sofaBtn1.backgroundColor = [UIColor greenColor];
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    
                    [sofaBtn1 setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth,spaceWidth+10);
                    
                }
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn1 setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth,spaceWidth-10, spaceWidth, spaceWidth+10);
                    //                    [sofaBtn1 setEnabled:NO];
                }
         
                
                [sofaBtn1 addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn1];
            }
        }
        else{
            //三人位沙发
            if (direct == 2 || direct == 4) { //垂直方向
                
                UIButton *sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.height/num-40), (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn.tag = 1000 + tag;
                sofaBtn.backgroundColor = [UIColor redColor];
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    [sofaBtn setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                }
                
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                    //                    [sofaBtn setEnabled:NO];
                }
         
                [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn];
                
                
                
                
                
                UIButton *sofaBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(singleView.frame.size.height/num*2-10, (singleView.frame.size.width-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn1.tag = 1000 + tag + 500;
                sofaBtn1.backgroundColor = [UIColor greenColor];
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    
                    [sofaBtn1 setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth, spaceWidth+10);
                }
                
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn1 setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth, spaceWidth+10);
                    //                    [sofaBtn1 setEnabled:NO];
                }
         
                [sofaBtn1 addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn1];
                
            }
            else{ //水平方向
                
                UIButton *sofaBtn = [[UIButton alloc] initWithFrame:CGRectMake((singleView.frame.size.width/num-40), (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn.tag = 1000 + tag;
                sofaBtn.backgroundColor = [UIColor redColor];
                
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    
                    [sofaBtn setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth+10, spaceWidth, spaceWidth-10);
                }
                
                if ([[[sofadata objectAtIndex:0] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth,spaceWidth+10, spaceWidth, spaceWidth-10);
                    //                    [sofaBtn setEnabled:NO];
                }
         
                
                [sofaBtn addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn];
                
                
                
                
                
                UIButton *sofaBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(singleView.frame.size.width/num*2-10, (singleView.frame.size.width/num-btnWidth)/2, btnWidth, btnWidth)];
                sofaBtn1.tag = 1000 + tag + 500;
                sofaBtn1.backgroundColor = [UIColor greenColor];
                
         
                //判断是否选中
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isCurrentPosition"] intValue]==1) {
                    
                    [sofaBtn1 setImage:[UIImage imageNamed:@"seat"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth, spaceWidth+10);
                    
                }
                
                if ([[[sofadata objectAtIndex:1] objectForKey:@"isLock"] intValue]==1) {
                    [sofaBtn1 setImage:[UIImage imageNamed:@"锁定"] forState:UIControlStateNormal];
                    sofaBtn1.imageEdgeInsets = UIEdgeInsetsMake(spaceWidth, spaceWidth-10, spaceWidth, spaceWidth+10);
                    //                    [sofaBtn1 setEnabled:NO];
                }
         
                
                
                [sofaBtn1 addTarget:self action:@selector(clickSofa:) forControlEvents:UIControlEventTouchUpInside];
                [singleView addSubview:sofaBtn1];
            }
         
        }
        */

        if (isMove) {
            //双击,旋转方向
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
            tap.numberOfTapsRequired = 2;
            [singleView addGestureRecognizer:tap];
            
            
            //Add the drag gesture recognizer with default values.
            if (holdDragRecognizer != nil) {
                [singleView removeGestureRecognizer:holdDragRecognizer];
            }
            holdDragRecognizer = [[BFDragGestureRecognizer alloc] init];
            holdDragRecognizer.minimumPressDuration = 0.5;
            [holdDragRecognizer addTarget:self action:@selector(dragRecognized:)];
            [singleView addGestureRecognizer:holdDragRecognizer];

        }
        
        [self addSubview:singleView];
    }

}




//点击某个沙发
-(void)clickSofa:(UIButton *)sender{
//    NSLog(@"sofa:::%@",sender);
    
//    orderNum = (int)(sender.tag);
    //解析沙发的位置
    [self layoutsofa:(int)(sender.tag)];
    
}



-(void)layoutsofa:(int)num{
    
    int tag = 0;
    tag = num-1000;//取得tag值
    
    //判断当是2人位或者3人位的时候，是哪一个沙发触发
    /*-----*/
    
//    index = 0;
//    if (tag>500) {
//        tag=tag - 500;
//        index = 1;
//    }
    
    /*-----*/
    
    index = 1;
    if (tag>500) {
        tag=tag - 500;
        index = 0;
    }
    
    //首先判断沙发在数组中那个位置,查找对应的位置
    currentIndex = 0;
    for (NSDictionary * dic in opArr) {
        if ([[dic objectForKey:@"tag"] intValue] == (int)(tag)) {
            currentIndex = (int)[opArr indexOfObject:dic];
            break;
        }
    }
    
    int num_sofa = [[[opArr objectAtIndex:currentIndex] objectForKey:@"num"] intValue];//沙发的个数
    if (num_sofa == 1) {
        index = 0;
    }
    
    [self refreshLayoutView];//刷新布局界面
}


//刷新布局界面
-(void)refreshLayoutView{
    //重新赋值
    NSMutableArray *temp_opArr=[[NSMutableArray alloc] initWithArray:opArr];
    
    for (int i =0; i<opArr.count; i++) {
        //获取数组中的每一个字典数据
        NSMutableDictionary *d=[[NSMutableDictionary alloc]initWithDictionary:[opArr objectAtIndex:i]];
        //读取字典数据中的sofadata字段
        NSMutableArray *temp =[[NSMutableArray alloc] initWithArray:[d objectForKey:@"sofadata"]];
        
//        int isTest = [[d objectForKey:@"isTest"] intValue];
        if (isLayoutTest) {
            //如果是测试布局
            if (currentIndex == i) {
                [d setObject:[NSNumber numberWithInt:1] forKey:@"isCurrent"];
            }
            else{
                [d setObject:[NSNumber numberWithInt:0] forKey:@"isCurrent"];
            }
        }
        else{
            
            //判断字段中有几组数据
            for (int j =0; j<temp.count; j++) {
                
                NSMutableDictionary *chooseDic = [[NSMutableDictionary alloc]initWithDictionary:[temp objectAtIndex:j]];
                //如果序号和组号都对应的上。则选中
                if (currentIndex == i && index == j) {
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
        }
        
        [temp_opArr removeObjectAtIndex:i];
        [temp_opArr insertObject:d atIndex:i];
    }
//    NSLog(@"temp_opArr::%@",temp_opArr);
    
    opArr = temp_opArr;
    [self layoutSetDataToBox:opArr isMove:isLayoutMove isBack:isLayoutBack isTest:isLayoutTest finishCallBack:self.finishData];
//    [self layoutSetDataToBox:opArr  finishCallBack:self.finishData];
//  [self layoutSetDataToBox:opArr ];//重新布局
    
//    if (isLayoutTest) {
//        [_delegate RefreshLayoutData:opArr];//刷新界面数据
//    }
    
     [_delegate RefreshLayoutData:opArr position:index];//刷新界面数据
    
    if (isLayoutBack) {
        //返回到LayoutSofaViewController处理
        if (self.finishData) {
            self.finishData([opArr objectAtIndex:currentIndex], currentIndex, index);
        }
    }
    
}


//将沙发刷新到网格中
-(void)layoutRefreshDataToBox:(NSArray *)sofaArr{
    
    [self layoutSetDataToBox:sofaArr isMove:isLayoutMove isBack:isLayoutBack isTest:isLayoutTest finishCallBack:self.finishData];
    
    
}
//双击旋转
-(void)doubleTap:(UITapGestureRecognizer *)recognizer {
    
    UIView *view = recognizer.view;
//    NSLog(@"viewview::%@",view);
    _startCenter = view.center;//获取当前移动试图的中心坐标
    
    int nBox = (int)(view.tag /100);//获取当前沙发位置的个数,1个/2个／3个
    
    int index_temp = 0;
    for (NSDictionary * dic in opArr) {
        if ([[dic objectForKey:@"tag"] intValue] == (int)(view.tag)) {
            index_temp = (int)[opArr indexOfObject:dic];
            break;
        }
    }
    
    //取出direct的方向
    int direct = [[[opArr objectAtIndex:index_temp] objectForKey:@"sofaDirect"] intValue];
//    NSLog(@"direct===%d",direct);
    
    int x = [[[opArr objectAtIndex:index_temp] objectForKey:@"x"] intValue];
    int y = [[[opArr objectAtIndex:index_temp] objectForKey:@"y"] intValue];
//    NSLog(@"x===%d,y===%d",x,y);
    
    
    //如果双击碰到四周的话，无法跳转
    if (nBox > 1) {
        if (direct == 1 ) {
            //开口朝下
            if (y==heng_box-1) {
                return;
            }
        }
        else if (direct == 2){
            //开口朝左
            if (x==0) {
                return;
            }
        }
        else if (direct ==3){
            //开口朝上
            if (y==0) {
                return;
            }
        }
        else if (direct ==4){
            //开口朝右
            if (x==shu_box-1) {
                return;
            }
        }
    }
    
    //方向,1:开口朝下,2:开口朝左,3:开口朝上,4:开口朝右
    direct ++;
    if (direct == 5) {
        direct = 1;
    }
    
    
    int r = x;
    int c = y;
    
    if (nBox == 2) {
        
        //表明2个沙发位置，拖动的时候
        //        if (direct == 1 || direct == 3) {
        //            r = r-1;
        //            if (r<0) {
        //                r=0;
        //            }
        //        }
        //        else{
        //            c = c-1;
        //            if (c<0) {
        //                c=0;
        //            }
        //       }
        
        if (direct == 1) {
            r=x;
            c=y+1;
        }
        else if (direct == 2){
            r=x;
            c=y;
        }
        else if (direct == 3){
            r=x-1;
            c=y;
        }
        else if (direct == 4){
            r=x+1;
            c=y-1;
        }
    }
    else if (nBox == 3){
        //        r = r - 1;
    }
    

    if(nBox == 2){
        /*
        for (int i =0 ; i<opArr.count; i++) {
            if (i == index_temp) {
                continue;
            }
            else{
                //判断周围是否有沙发位
                int x1 = [[[opArr objectAtIndex:i] objectForKey:@"x"] intValue];
                int y1 = [[[opArr objectAtIndex:i] objectForKey:@"y"] intValue];
                
                if (direct == 1) {
                    if ((r == x1 && c == y1) || (r == x1-1 && c == y1)) {
                        return;
                    }
                }
                else if (direct == 2){
                    if ((r == x1 && c+1 == y1) || (r-1 == x1 && c+1 == y1)) {
                        return;
                    }
                }
                else if (direct == 3){
                    if ((x1 == r-1 && y1 == c-1)) {
                        return;
                    }
                }
                else if (direct == 3){
                    if ((x1 == r+1 && y1 == c-1)) {
                        return;
                    }
                }
            }
        }
        */
        
        if (view.transform.b == 1){
            //顺90
            view.center = CGPointMake(view.center.x-boxWidth/2, view.center.y-boxWidth/2);
        }
        else if (view.transform.a == -1){
            
            view.center = CGPointMake(view.center.x+boxWidth/2, view.center.y-boxWidth/2);
        }
        else if (view.transform.c == 1){
            
            view.center = CGPointMake(view.center.x+boxWidth/2, view.center.y+boxWidth/2);
        }
        else{
            //横
            view.center = CGPointMake(view.center.x-boxWidth/2, view.center.y+boxWidth/2);
        }
    }
    
    //判断点击是否重叠，重叠的话则不旋转
    BOOL isCoincide = NO;
    if (nBox == 2) {
        
//        NSLog(@"opArropArr==%@",opArr);
        NSMutableArray *op_temp = [[NSMutableArray alloc] initWithArray:opArr];
        [op_temp removeObjectAtIndex:index_temp];
        
//        NSLog(@"op_temp==%@",op_temp);
        
        CGRect frame1 = CGRectZero;
        if (direct == 1 || direct == 3) {
            frame1 = CGRectMake(boxWidth*r+(boxWidth-boxContentWidth)/2*nBox,boxWidth*c+(boxWidth-boxContentHeight)/2,boxContentWidth*nBox, boxContentHeight);
        }
        else{
            frame1 = CGRectMake(boxWidth*r+(boxWidth-boxContentHeight)/2,boxWidth*c+(boxWidth-boxContentHeight)/2,boxContentHeight, boxContentWidth*nBox);
        }
        
//        NSLog(@"fr=x=%d,y==%d",r,c);
        
        for (int i =0; i<op_temp.count; i++) {
            
            int x1 = [[[op_temp objectAtIndex:i] objectForKey:@"x"] intValue];
            int y1 = [[[op_temp objectAtIndex:i] objectForKey:@"y"] intValue];
            int num1 = [[[op_temp objectAtIndex:i] objectForKey:@"num"] intValue];//沙发的个数
            int direct1 = [[[op_temp objectAtIndex:i] objectForKey:@"sofaDirect"] intValue];
            
            
            CGRect frame = CGRectZero;
            
            if (direct1 == 1 || direct1 == 3 ) {
                frame = CGRectMake(boxWidth*x1+(boxWidth-boxContentWidth)/2*num1,boxWidth*y1+(boxWidth-boxContentHeight)/2,boxContentWidth*num1, boxContentHeight);
                
            }
            else{
                frame = CGRectMake(boxWidth*x1+(boxWidth-boxContentHeight)/2,boxWidth*y1+(boxWidth-boxContentHeight)/2,boxContentHeight, boxContentWidth*num1);
            }
            
            //如果有重合则返回1
            if (CGRectIntersectsRect(frame, frame1)) {
                isCoincide = YES;
                break;
               
            }
        }
        
        if (isCoincide) {
            view.center = _startCenter;
            return;
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2]; //动画时长
    view.transform = CGAffineTransformRotate(view.transform, M_PI_2);
    
    CGAffineTransform transform = view.transform;
    transform = CGAffineTransformScale(transform, 1,1);
    view.transform = transform;
    [UIView commitAnimations];
    
    
    //将转换的当前数据读取出来
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:[opArr objectAtIndex:index_temp]];
    [tempDic setObject:[NSNumber numberWithInt:direct] forKey:@"sofaDirect"];
    
//    int r = (int)((view.center.x)/boxWidth);//行
//    int c = (int)((view.center.y)/boxWidth);//列
       //x,y
    [tempDic setObject:[NSNumber numberWithInt:r] forKey:@"x"];
    [tempDic setObject:[NSNumber numberWithInt:c] forKey:@"y"];
    
    
    NSMutableArray *chooseArr =[[NSMutableArray alloc] initWithArray:opArr];
    [chooseArr removeObjectAtIndex:index_temp];
    [chooseArr insertObject:tempDic atIndex:index_temp];
    
    opArr = chooseArr;//赋值
    
    [_delegate RefreshLayoutData:opArr position:0];//刷新界面数据
    
//    [self layoutRefreshDataToBox:opArr];
    
    
    
    //重新布局
//    [self layoutSetDataToBox:chooseArr finishCallBack:nil];
    
}


//长按拖动
- (void)dragRecognized:(BFDragGestureRecognizer *)recognizer {
    
    UIView *view = recognizer.view;
    NSLog(@"viewviewview==%@",view);
    
    int nBox = (int)(view.tag /100);//获取当前拖动的是几个box
    
    //判断当前是哪一个沙发拖动
    int index_temp = 0;
    for (NSDictionary * dic in opArr) {
        if ([[dic objectForKey:@"tag"] intValue] == (int)(view.tag)) {
            index_temp = (int)[opArr indexOfObject:dic];
            break;
        }
    }
    
    //方向
    int direct = [[[opArr objectAtIndex:index_temp] objectForKey:@"sofaDirect"] intValue];
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"nBoxnBox==%d",nBox);
        _startCenter = view.center;//获取当前移动试图的中心坐标
        [view.superview bringSubviewToFront:view];
        [UIView animateWithDuration:0.1 animations:^{
        //view.transform = CGAffineTransformScale(view.transform, 1.2,1.2);
            view.alpha = 0.3;
        }];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // During the gesture, we just add the gesture's translation to the saved original position.
        // The translation will account for the changes in contentOffset caused by auto-scrolling.
        CGPoint translation = [recognizer translationInView:self];
        
        CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        view.center = center;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        [UIView animateWithDuration:0.2 animations:^{
            //view.transform = CGAffineTransformIdentity;
            view.alpha = 1.0;
            //判断越界的问题
            if (view.frame.origin.y< 0 || view.frame.origin.x <0 || (view.frame.origin.x + view.frame.size.width > boxWidth * shu_box) || view.frame.origin.y > boxWidth * heng_box) {
                //NSLog(@"越界");
                view.center = _startCenter;
                return ;
            }
            
            
//            NSLog(@"centercenter::x===%f,y===%f",view.center.x,view.center.y);
//            NSLog(@"boxWidth==%f",boxWidth);
            
            int x = 0;
            int y = 0;

            if (nBox == 2) {
                if (direct == 1 || direct == 3) {
                    x = (int)((view.center.x - boxContentWidth)/boxWidth);//行
                    y = (int)(view.center.y/boxWidth);//列
                    
                    if (x<0) {
                        x=0;
                    }
                    
//                    NSLog(@"x=====%d,y=======%d",x,y);
                    if (y == heng_box) {
                        view.center = _startCenter;
                        return ;
                    }
                    view.frame = CGRectMake(boxWidth*x+(boxWidth-boxContentWidth)/2*nBox,boxWidth*y+(boxWidth-boxContentHeight)/2,boxContentWidth*nBox, boxContentHeight);
                }
                else{
                    x = (int)(view.center.x/boxWidth);//行
                    y = (int)((view.center.y- boxContentWidth)/boxWidth);//列
                    
                    if (y<0) {
                        y=0;
                    }
//                     NSLog(@"x==2===%d,y====4===%d",x,y);
                    if (y == heng_box-1) {
                        view.center = _startCenter;
                        return ;
                    }
                
                    view.frame = CGRectMake(boxWidth*x+(boxWidth-boxContentHeight)/2,boxWidth*y+(boxWidth-boxContentHeight)/2,boxContentHeight, boxContentWidth*nBox);
                }

            }
            else{
                x = (int)(view.center.x/boxWidth);//行
                y = (int)(view.center.y/boxWidth);//列
                if (y == heng_box) {
                    view.center = _startCenter;
                    return ;
                }
                view.center = CGPointMake(x*boxWidth + (nBox%2>0 ? (boxWidth/2) : 0), y*boxWidth+(boxWidth-boxContentWidth)/2+boxContentWidth/2);
            }
            
//            NSLog(@"xx==%d,y==%d",x,y);
            
            //判断点击是否重叠，重叠的话则不旋转
            BOOL isCoincide = NO;
            CGRect frame1 = CGRectZero;
            if (nBox == 1) {
                frame1 = CGRectMake(boxWidth*x+(boxWidth-boxContentWidth)/2*nBox,boxWidth*y+(boxWidth-boxContentHeight)/2,boxContentWidth*nBox, boxContentHeight);
            }
            else{
                frame1 = view.frame;
            }
            
//            NSLog(@"opArropArr==%@",opArr);
            NSMutableArray *op_temp = [[NSMutableArray alloc] initWithArray:opArr];
            [op_temp removeObjectAtIndex:index_temp];
            
//            NSLog(@"op_temp==%@",op_temp);
            
            for (int i =0; i<op_temp.count; i++) {
                
                int x1 = [[[op_temp objectAtIndex:i] objectForKey:@"x"] intValue];
                int y1 = [[[op_temp objectAtIndex:i] objectForKey:@"y"] intValue];
                int num1 = [[[op_temp objectAtIndex:i] objectForKey:@"num"] intValue];//沙发的个数
                int direct1 = [[[op_temp objectAtIndex:i] objectForKey:@"sofaDirect"] intValue];
                
                
                CGRect frame = CGRectZero;
                if (direct1 == 1 || direct1 == 3) {
//                    NSLog(@"1.3");
                    frame = CGRectMake(boxWidth*x1+(boxWidth-boxContentWidth)/2*num1,boxWidth*y1+(boxWidth-boxContentHeight)/2,boxContentWidth*num1, boxContentHeight);
                }
                else{
//                    NSLog(@"2.4");
                    frame = CGRectMake(boxWidth*x1+(boxWidth-boxContentHeight)/2,boxWidth*y1+(boxWidth-boxContentHeight)/2,boxContentHeight, boxContentWidth*num1);
                }
                
                //如果有重合则返回1
                if (CGRectIntersectsRect(frame, frame1)) {
//                    NSLog(@"重合");
                    
                    isCoincide = YES;
                    break;
                }
            }
            
            if (isCoincide) {
                view.center = _startCenter;
                return;
            }
            
            //改变拖拽沙发的位置,保存x,y
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:[opArr objectAtIndex:index_temp]];
            
            [tempDic setObject:[NSNumber numberWithInt:x] forKey:@"x"];
            [tempDic setObject:[NSNumber numberWithInt:y] forKey:@"y"];
            
            NSMutableArray *chooseArr =[[NSMutableArray alloc] initWithArray:opArr];
            [chooseArr removeObjectAtIndex:index_temp];
            [chooseArr insertObject:tempDic atIndex:index_temp];
            
            opArr = chooseArr;//赋值
//            [self layoutsofa:((int)(view.tag)+1000)];//拖动即选中
            
            [_delegate RefreshLayoutData:opArr position:0];//进入布局
            
            
//           [self layoutRefreshDataToBox:opArr];
            
            /*
            int r = (int)(view.center.x/boxWidth);//行
            int c = (int)(view.center.y/boxWidth);//列
            NSLog(@"r=====%d,c=======%d",r,c);
            
            
            view.center = CGPointMake(r*boxWidth + (nBox%2>0 ? (boxWidth/2) : 0), c*boxWidth+(boxWidth-boxContentWidth)/2+boxContentWidth/2);
            //当沙发为2人位时
            if (nBox == 2) {
                //表明2个沙发位置，拖动的时候
                if (direct == 1 ) {
                    r = r-1;
                    if (r<0) {
                        r=1;
                    }
                }
                else if (direct == 3){
                    //r=r+1;
                }
                else{
                    c = c-1;
                    if (c<0) {
                        c=0;
                    }
                }
            }
            else if (nBox == 3){
                //当沙发为2人位时
                r = r - 1;
                
            }
            
            
            //NSLog(@"22rrrr===%d====22ccccc====%d",r,c);
            
            //改变拖拽沙发的位置,保存x,y
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:[opArr objectAtIndex:index_temp]];
        
            [tempDic setObject:[NSNumber numberWithInt:r] forKey:@"x"];
            [tempDic setObject:[NSNumber numberWithInt:c] forKey:@"y"];
            
            NSMutableArray *chooseArr =[[NSMutableArray alloc] initWithArray:opArr];
            [chooseArr removeObjectAtIndex:index_temp];
            [chooseArr insertObject:tempDic atIndex:index_temp];
            
            opArr = chooseArr;//赋值
            
             [_delegate RefreshLayoutData:opArr];//进入布局
            //NSLog(@"%@", [chooseArr objectAtIndex:index]);
            //当为2人位时，竖直方向
            if(nBox == 2 && (direct == 2 || direct == 4)){
    
                //NSLog(@"view.center.y-boxWidth/2::%f",view.center.y-boxWidth/2);
                view.center = CGPointMake(view.center.x+boxWidth/2, view.center.y-boxWidth/2 <=10 ? view.center.y+boxWidth/2 : view.center.y-boxWidth/2);
                
            }
            else{
                view.transform = CGAffineTransformMakeRotation(M_PI_2*(direct-1));
            }
             */
            
            
        }];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
    }
}

@end
