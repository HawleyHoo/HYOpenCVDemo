//
//  HYImageUtils.m
//  HYOpenCVDemo
//
//  Created by 胡杨 on 2017/5/29.
//  Copyright © 2017年 Hoo. All rights reserved.
//

#import "HYImageUtils.h"
#import "HYColor.h"





@implementation HYImageUtils

#pragma mark --- 美白
+ (UIImage *)imageWhitening:(UIImage *)image {
    // 第一步：确定图片大小
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    // 第二步：开辟内存空间-> 创建颜色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    
    // UInt32的含义：图像学中像素点由（ARGB：alpha,red,green,blue）
    // UInt32 * 指向图片像素数组首地址指针（根据指针唯一获取对应像素点）
    UInt32 *inputPixels = (UInt32 *)calloc(width * height, sizeof(UInt32));
    
    /**
     // 第三步：创建图片上下文（保存了图片详情信息，类似于书的目录）

     param inputPixels 数据源，图片的像素数组
     param width#> 图片的宽
     param height#> 图片的高
     param bitsPerComponent#> 每一个像素点分量的大小（8）
     param bytesPerRow#> 每一行的内存大小（width * 每一个像素点的大小）
                            每一像素点的大小 = 4 * 8 = 32位 = 4字节
     param space#> 颜色空间
     param bitmapInfo#> 位图信息（是否需要透明度， 设计计算机字节序等）
     return 图片上下文
     */
    CGContextRef contextRef = CGBitmapContextCreate(inputPixels,
                                                    width,
                                                    height,
                                                    8,
                                                    width * 4,
                                                    colorSpaceRef,
                                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    // 第四步：根据图片上下文绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    // 第五步：美白图片
    // 操作像素点->操作分量->修改分量 0->255 越来越白
    int lumi = 50;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            // 遍历当前像素点（指针位移方式）
            UInt32 *currentPixels = inputPixels + i * width + j;
            
            // 获取像素点的值
            UInt32 color = *currentPixels;
            
            UInt32 thisR, thisG, thisB, thisA;
            thisR = R(color);
            thisR += lumi;
            thisR = thisR > 255 ? 255 : thisR;
            
            thisG = G(color);
            thisG += lumi;
            thisG = thisG > 255 ? 255 : thisG;
            
            thisB = B(color);
            thisB += lumi;
            thisB = thisB > 255 ? 255 : thisB;
            
            thisA = A(color);
            thisA += lumi;
            thisA = thisA > 255 ? 255 : thisA;
            
            thisA = A(color);
            
            *currentPixels = RGBAMake(thisR, thisG, thisB, thisA);
            
        }
    }
    
    // 第六步：创建UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(contextRef);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // 第七步：释放内存
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(contextRef);
    CGImageRelease(newImageRef);
    free(inputPixels);
    
    return newImage;
}
/*
+ (UIImage *)opencvImageWhitening:(UIImage *)image {
    Mat mat_image_src;
    UIImageToMat(image, mat_image_src);
    
    Mat mat_image_dst;
    
 
    // 类型转换
    // @param src#> 源文件 description#>
    // @param dst#> 目标文件 description#>
    // @param code#> 类型（四通道转三通道） description#>
 
    cvtColor(mat_image_src, mat_image_dst, CV_RGBA2RGB);
    // 克隆一张图片
    Mat mat_image_clone = mat_image_dst.clone();
    
    // 开始美白(增强美白效果 修改18)
    for (int i = 1; i < 18; i += 2) {
        bilateralFilter(mat_image_dst, mat_image_clone, i, i * 2, i / 2);
    }
    
    return MatToUIImage(mat_image_clone);
}
*/
#pragma mark --- 马赛克
+ (UIImage *)imageProcess:(UIImage *)image {
    // 第一步：确定图片大小
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    // 第二步：开辟内存空间-> 创建颜色空间
    // CGImageGetColorSpace(image.CGImage); 动态获取颜色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    // 第三步：创建图片上下文，（解析图片信息，）
    CGContextRef contextRef = CGBitmapContextCreate(nil,
                                                    width,
                                                    height,
                                                    8,
                                                    width * 4,
                                                    colorSpaceRef,
                                                    kCGImageAlphaPremultipliedLast);
    // 第四步：根据图片上下文绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    // 第五步：获取图片的像素数组
    unsigned char *bitmapDataSrc = (unsigned char *)CGBitmapContextGetData(contextRef);
    
    // 第六步：加入马赛克 ,让一个像素点替换和他相同颜色的的矩形区域
    // 选择马赛克区域
    NSUInteger currentIndex, preCurrentIndex, level = 60;
    // 像素点大小
    unsigned char *pixels[4] = {0};
    for (NSUInteger i = 0; i < height - 1; i++) {
        for (NSUInteger j = 0; j < width; j++) {
            // 获取当前像素点坐标
            currentIndex = i * width + j;
            // 计算矩形区域（筛选马赛克区域）
            if (i % level == 0) {
                if (j % level == 0) {
                    /**
                     c和c++使用的内存拷贝函数，memcpy函数的功能是从源src所指的内存地址的起始位置开始拷贝n个字节到目标dest所指的内存地址的起始位置中。
                     
                     void *dest 拷贝目标
                     const void *src 源文件
                     size_t n 截取长度（字节计算）
                     **/
                    memcpy(pixels, bitmapDataSrc + 4 * currentIndex, 4);
                } else {
                    // 将上一个像素点的值拷贝到下一个像素点
                    memcpy(bitmapDataSrc + 4 * currentIndex, pixels, 4);
                }
            } else {
                preCurrentIndex = (i - 1) * width + j;
                memcpy(bitmapDataSrc + 4 * currentIndex, bitmapDataSrc + 4 * preCurrentIndex, 4);
            }
            
        }
    }
    
    // 第七步：获取图片数据集合
    NSUInteger size = width * height * 4;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitmapDataSrc, size, NULL);
    
    
    /**
     // 第八步：创建马赛克图片（内存操作图片）
     param width           图片宽
     param height          图片高
     param 8               每一个像素点分量大小
     param 32              每一个像素点大小
     param width * 4       每一行内存大小
     param colorSpaceRef   颜色空间
     param kCGImageAlphaPremultipliedLast   位图信息（是否需要透明度）
     param providerRef     数据源
     param NULL            数据解码器
     param NO              是否抗锯齿
     param kCGRenderingIntentDefault 渲染器
     */
    CGImageRef mosaicImageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        4 * 8,
                                        width * 4,
                                        colorSpaceRef,
                                        kCGImageAlphaPremultipliedLast,
                                        providerRef,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    // 第九步：创建输出马赛克图片
    CGContextRef outputContextRef = CGBitmapContextCreate(nil,
                                                    width,
                                                    height,
                                                    8,
                                                    width * 4,
                                                    colorSpaceRef,
                                                    kCGImageAlphaPremultipliedLast);
    // 第十步：绘制图片
    CGContextDrawImage(outputContextRef, CGRectMake(0, 0, width, height), mosaicImageRef);
    
    // 创建图片
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContextRef);
    UIImage *resultImage = [UIImage imageWithCGImage:resultImageRef];
    
    // 释放内存
    CGImageRelease(resultImageRef);
    CGImageRelease(mosaicImageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(providerRef);
    CGContextRelease(contextRef);
    CGContextRelease(outputContextRef);
    
    return resultImage;
}


#pragma mark --- 将图像转换为灰度显示
/*
+ (UIImage *)imageGray:(UIImage *)image {
//    cv::Mat cvImage;
    Mat cvImage;
    UIImageToMat(image, cvImage);
    if (!cvImage.empty()) {
        Mat gray;
        // 将图像转换为灰度显示
        cvtColor(cvImage, gray, CV_RGB2GRAY);
        // 应用高斯滤波器去除小的边缘
        GaussianBlur(gray, gray, cv::Size(5,5), 1.2, 1.2);
        // 计算与画布边缘
        Mat edges;
        Canny(gray, edges, 0, 50);
        // 使用白色填充
        cvImage.setTo(cv::Scalar::all(225));
        // 修改边缘颜色
        cvImage.setTo(cv::Scalar(0,128,255,255), edges);
        // 将Mat转换为Xcode的UIImageView显示
        
        return MatToUIImage(cvImage);
    }
    return nil;
}
*/

#pragma mark --- 圆角
// 裁剪圆角  (UInt32 *const img, int w, int h, CGFloat cornerRadius)
+ (void)cornerImage:(UInt32 *)img width:(int)w height:(int)h cornerRadius:(CGFloat)corner  {
    CGFloat c = corner;
    CGFloat min = w > h ? h : w;
    
    if (c < 0) { c = 0; }
    if (c > min * 0.5) { c = min * 0.5; }
    
    // 左上 y:[0, c), x:[x, c-y)
    for (int y=0; y<c; y++) {
        for (int x=0; x<c-y; x++) {
            UInt32 *p = img + y * w + x;    // p 32位指针，RGBA排列，各8位
            if (isCircle(c, c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
    // 右上 y:[0, c), x:[w-c+y, w)
    int tmp = w-c;
    for (int y=0; y<c; y++) {
        for (int x=tmp+y; x<w; x++) {
            UInt32 *p = img + y * w + x;
            if (isCircle(w-c, c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
    // 左下 y:[h-c, h), x:[0, y-h+c)
    tmp = h-c;
    for (int y=h-c; y<h; y++) {
        for (int x=0; x<y-tmp; x++) {
            UInt32 *p = img + y * w + x;
            if (isCircle(c, h-c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
    // 右下 y~[h-c, h), x~[w-c+h-y, w)
    tmp = w-c+h;
    for (int y=h-c; y<h; y++) {
        for (int x=tmp-y; x<w; x++) {
            UInt32 *p = img + y * w + x;
            if (isCircle(w-c, h-c, c, x, y) == false) {
                *p = 0;
            }
        }
    }
}
// 判断点 (px, py) 在不在圆心 (cx, cy) 半径 r 的圆内
static inline bool isCircle(float cx, float cy, float r, float px, float py) {
    if ((px-cx) * (px-cx) + (py-cy) * (py-cy) > r * r) {
        return false;
    }
    return true;
}

void releaseData(void *info, const void *data, size_t size) {
    free((void *)data);
}

+ (UIImage *)dealImage:(UIImage *)img cornerRadius:(CGFloat)corner {
    // 1.CGDataProviderRef 把 CGImage 转 二进制流
    CGDataProviderRef provider = CGImageGetDataProvider(img.CGImage);
    UInt32 *imgData = (UInt32 *)CFDataGetBytePtr(CGDataProviderCopyData(provider));
    int width = img.size.width * img.scale;
    int height = img.size.height * img.scale;
    
    // 2.处理 imgData
    [self cornerImage:imgData width:width height:height cornerRadius:corner];
    
    // 3.CGDataProviderRef 把 二进制流 转 CGImage
    CGDataProviderRef pv = CGDataProviderCreateWithData(NULL, imgData, width * height * 4, releaseData);
    CGImageRef content = CGImageCreate(width , height, 8, 32, 4 * width, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast, pv, NULL, true, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:content];
    CGDataProviderRelease(pv);      // 释放空间
    CGImageRelease(content);
    
    return result;
}




@end
