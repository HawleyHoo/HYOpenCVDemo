//
//  HYImageUtils.h
//  HYOpenCVDemo
//
//  Created by 胡杨 on 2017/5/29.
//  Copyright © 2017年 Hoo. All rights reserved.
//



// 导入核心头文件
// 3.2的framework 这里导入会有问题，放到pch文件里就可以了
//、#import <opencv2/opencv.hpp>
// 导入opencv支持iOS平台下头文件
//#import <opencv2/imgcodecs/ios.h>
//using namespace cv;
// github 上传不了大文件，framework传不了

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYImageUtils : NSObject
// 美白
+ (UIImage *)imageWhitening:(UIImage *)image;

//+ (UIImage *)opencvImageWhitening:(UIImage *)image;

// 马赛克
+ (UIImage *)imageProcess:(UIImage *)image;


// 将图像转换为灰度显示
//+ (UIImage *)imageGray:(UIImage *)image;


/**
 图片圆角效果
 */
+ (UIImage *)dealImage:(UIImage *)img cornerRadius:(CGFloat)corner;


/**
    加模糊效果，image是图片，blur是模糊度
 */
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

@end
