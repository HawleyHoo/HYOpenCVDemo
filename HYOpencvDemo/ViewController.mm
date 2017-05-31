//
//  ViewController.m
//  HYOpencvDemo
//
//  Created by 胡杨 on 2017/5/31.
//  Copyright © 2017年 Hoo.c. All rights reserved.
//

#import "ViewController.h"
#import "HYImageUtils.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonCliced:(UIButton *)sender {
    NSInteger tag = sender.tag;
    switch (tag) {
        case 10: // 还原
        {
            self.imageView2.image = [UIImage imageNamed:@"test.jpg"];
        } break;
            
        case 11: // 美白
        {
            self.imageView2.image = [HYImageUtils imageWhitening:[UIImage imageNamed:@"test.jpg"]];
//            self.imageView2.image = [HYImageUtils opencvImageWhitening:[UIImage imageNamed:@"test.jpg"]];
        } break;
            
        case 12: // 马赛克
        {
            self.imageView2.image = [HYImageUtils imageProcess:[UIImage imageNamed:@"test.jpg"]];
        } break;
            
        case 13:
        {
            
        } break;
            
        case 20: // 灰度
        {
            
        } break;
            
        case 21: // 圆角
        {
            self.imageView4.image = [HYImageUtils dealImage:[UIImage imageNamed:@"test2.png"] cornerRadius:20];
        } break;
            
        case 22: // 模糊
        {
            self.imageView4.image = [HYImageUtils blurryImage:[UIImage imageNamed:@"test2.png"] withBlurLevel:0.2];
        } break;
            
        case 23:
        {
            
        } break;
            
        case 24:
        {
            
        } break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
