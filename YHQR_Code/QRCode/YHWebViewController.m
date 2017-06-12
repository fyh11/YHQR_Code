//
//  YHWebViewController.m
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/14.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "YHWebViewController.h"
#import "UIWebView+Extension.h"

#define ISIOS8LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define ISIOS10LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

@interface YHWebViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation YHWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _Navtitle;
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.frame = [UIScreen mainScreen].bounds;
    [webView setUserInteractionEnabled:YES];
    webView.scrollView.bounces = NO;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    self.webView = webView;
    [self.view addSubview:_webView];
    // 添加长按手势
    UILongPressGestureRecognizer* longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressed.delegate = self;
    [self.webView addGestureRecognizer:longPressed];
}

#pragma mark---webView代理
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self.webView];
    // 获取手势所在图片的URL，js中图片的地址是用src引用的
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *imageURL = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (imageURL.length == 0) {
        return;
    }
    
    [self showImageOptionsWithUrl:imageURL];
}

- (void)showImageOptionsWithUrl:(NSString *)imgURL
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    UIImage* image = [UIImage imageWithData:data];
    
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"CIDetectorAccuracy", @"CIDetectorAccuracyHigh",nil];
    CIDetector *detector = nil;
    detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                      context:nil
                                      options:options];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    // 识别图中二维码
    UIAlertAction *judgeCode = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        
        if (ISIOS10LATER()) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:scannedResult]];
        }
    }];
    
    // 取消
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    if (features.count >= 1) {
        [alertController addAction:judgeCode];
    }
    [alertController addAction:cancle];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
