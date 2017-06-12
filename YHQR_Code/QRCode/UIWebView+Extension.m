//
//  UIWebView+Extension.m
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/15.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "UIWebView+Extension.h"

#define ISIOS8LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define ISIOS10LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

@implementation UIWebView (Extension)

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    // add by zcj 实现图片长按识别功能
    UILongPressGestureRecognizer* longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [self addGestureRecognizer:longPressed];
    // ]end
    
}

// add by zcj 长按识别图中二维码
- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self];
    // 获取手势所在图片的URL，js中图片的地址是用src引用的
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [self stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (urlToSave.length == 0) {
        return;
    }
    
    [self showImageOptionsWithUrl:urlToSave];
}

- (void)showImageOptionsWithUrl:(NSString *)imgURL
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    UIImage* image = [UIImage imageWithData:data];
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"CIDetectorAccuracy", @"CIDetectorAccuracyHigh",nil];
    CIDetector *detector = nil;
    if (ISIOS8LATER())
        detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                      context:nil
                                      options:options];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    // 识别图中二维码
    UIAlertAction *judgeCode = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        
        if (ISIOS10LATER()) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:feature.messageString]];
        }else{
            // 加载二维码信息
            UIWebView *webView = [[UIWebView alloc] initWithFrame:self.frame];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feature.messageString]]];
            [self addSubview:webView];
        }

    
//    // 保存图片到手机
//    UIAlertAction *saveImage = [UIAlertAction actionWithTitle:@"保存图片到手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }];
//    
//    // 取消
//    UIAlertAction *cancell = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
   }];
    
    
    if (features.count >= 1) {
        [alertController addAction:judgeCode];
    }
    
//    [alertController addAction:saveImage];
//    [alertController addAction:cancell];
        [alertController addAction:judgeCode];
//    [self presentViewController:alertController animated:YES completion:nil];
    
}
// 功能：显示图片保存结果
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
//{
//    if (error){
//        [Util Alert:@"保存图片失败" title:@"温馨提示"];
//    }else {
//        // 这一句仅仅是提示保存成功
//        [CJUtil showInBottomWithTitle:@"保存成功" backgroundColor:nil textColor:nil];
//    }
//}
                                
@end
