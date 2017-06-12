//
//  UIImageView+Extension.h
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/14.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Extension)
/**
 1. 创建二维码
 2. URLString: 生成二维码的链接
 3. Image内部的图片,可以为nil
 4. 图片的圆角
 */
- (void)creatRQCode:(NSString *)URLString ContentImage:(UIImage *)Image andImageCorner:(CGFloat)imageCorner;
@end
