//
//  UIImageView+Extension.m
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/14.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "UIImageView+Extension.h"

#define ImageSize self.bounds.size.width

@implementation UIImageView (Extension)

- (void)creatRQCode:(NSString *)URLString ContentImage:(UIImage *)Image andImageCorner:(CGFloat)imageCorner
{
    // 异步生成二维码
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIFilter *codeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [codeFilter setDefaults];
        NSData *codeData = [URLString dataUsingEncoding:NSUTF8StringEncoding];
        //设置滤镜数据
        [codeFilter setValue:codeData forKey:@"inputMessage"];
        //获得滤镜输出的图片
        CIImage *outputImage = [codeFilter outputImage];
        // 图像位图转换
        UIImage *translateImage = [self creatUIImageFromCIImage:outputImage andSize:ImageSize];
        UIImage *resultImage = [self setSuperImage:translateImage andSubImage:[self imageCornerRadius:imageCorner andImage:Image]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = resultImage;
        });
    });
}

- (UIImage *)creatUIImageFromCIImage:(CIImage *)image andSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceGray();
    
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorRef, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    
    CGContextScaleCTM(contextRef, scale, scale);
    
    CGContextDrawImage(contextRef, extent, imageRef);
    
    CGImageRef  newImage = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return [UIImage imageWithCGImage:newImage];
}

// 设置二维码内的图片
- (UIImage *)imageCornerRadius:(CGFloat)cornerRadius andImage:(UIImage *)image
{
    CGRect frame = CGRectMake(0, 0, ImageSize/5, ImageSize/5);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius] addClip];
    [image drawInRect:frame];
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipImage;
}

// 绘制图片
- (UIImage *)setSuperImage:(UIImage *)superImage andSubImage:(UIImage *)subImage
{
    UIGraphicsBeginImageContextWithOptions(superImage.size, YES, 0);
    [superImage drawInRect:CGRectMake(0, 0, superImage.size.width, superImage.size.height)];
    [subImage drawInRect:CGRectMake((ImageSize - ImageSize/5)/2, (ImageSize - ImageSize/5)/2, subImage.size.width, subImage.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 返回新的图片
    return resultImage;
}

@end
