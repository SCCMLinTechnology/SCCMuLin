//
//  DrawImageViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/8.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "DrawImageViewController.h"
#import "LayoutSofaView.h"

@interface DrawImageViewController (){
    
   LayoutSofaView *layoutsofa;//布局界面
}

@end

@implementation DrawImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)getImageByData:(NSArray *)data{
    
    if (layoutsofa !=nil) {
        [layoutsofa removeFromSuperview];
    }
    //布局界面
    layoutsofa = [[LayoutSofaView alloc] initWithFrame:CGRectMake(0,0, boxWidth *shu_box, boxWidth *heng_box)];
    [layoutsofa setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    [self.view addSubview:layoutsofa];
    [layoutsofa layoutSetDataToBox:data  isMove:NO isBack:YES isTest:NO finishCallBack:^(NSDictionary *data, int currentIndex, int position) {
    }];

    return [self ScreenShot];
}





-(UIImage *)ScreenShot{
    //*(iPhone6plus?3:2)*(iPhone6plus?2.5:2)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sWIDTH-spaceWidth*2,sHEIGHT/2- (ipad ? 120 :(iPhone5 ? 50 : 50))), NO, 0);     //设置截屏大小
    [[layoutsofa layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect = CGRectMake(0, 0, sWIDTH*(iPhone6plus?3:2), sHEIGHT*(iPhone6plus?2.5:2));//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    
//    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil, nil);//保存图片到照片库
    
    return sendImage;
}

@end
