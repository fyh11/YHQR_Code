//
//  ViewController.m
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/14.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Extension.h"
#import <SDCycleScrollView.h>
#import "YHWebViewController.h"

#define BCWidth   [UIScreen mainScreen].bounds.size.width

// 判断当前版本是否大于10.0
#define ISIOS10LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

@interface ViewController ()<SDCycleScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *text;
@property (weak, nonatomic) IBOutlet UIButton *createQRCode;
@property (weak, nonatomic) IBOutlet UIButton *scanQRCode;

- (IBAction)QRCode:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载轮播
    [self addBannerView];
  
   // 添加一个长按识别的手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(readQRCoding:)];
    [self.view addGestureRecognizer:longPress];
    
}

// 轮播
- (void) addBannerView
{
    NSArray *imagesURLStrings = @[
                                  @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                                  @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                                  @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
                                  ];
    
    CGFloat width = self.view.bounds.size.width;
    
    SDCycleScrollView *bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 64, width, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    bannerView.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    bannerView.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    bannerView.imageURLStringsGroup = imagesURLStrings;
    [self.view addSubview:bannerView];
    
}

- (void)QRCode:(UIButton *)sender
{
     NSString *enStr = _text.text;
    if (sender == _createQRCode) {
        if (enStr.length == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先输入链接" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [_text becomeFirstResponder];
            }];
            [alert addAction:cancelAction];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else {
            UIImageView *codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((BCWidth - 200)/2, 290, 200, 200)];
            codeImageView.layer.borderColor = [UIColor orangeColor].CGColor;
            codeImageView.layer.borderWidth = 1;
            [self.view addSubview:codeImageView];
            // 用输入的链接生成二维码
             [codeImageView creatRQCode:enStr ContentImage:nil andImageCorner:4];
        }
    }else{
    
    }
}

- (void)readQRCoding: (UILongPressGestureRecognizer *)longPressGesture
{
    // 获取图片
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIContext *ciContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:ciContext options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciImage];
    for (CIQRCodeFeature *feature in features) {
 
        NSLog(@"msg = %@",feature.messageString);
        if ([feature.messageString hasPrefix:@"http"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"二维码识别" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (ISIOS10LATER()) {
                    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:feature.messageString]];
                }else{
                    // 加载二维码信息
                    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
                    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feature.messageString]]];
                    [self.view addSubview:webView];
                }
            
            }];
            UIAlertAction *saveImage = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSData* imageData =  UIImagePNGRepresentation(image);
                UIImage* newImage = [UIImage imageWithData:imageData];
                UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(self));
            }];
            [alert addAction:cancelAction];
            [alert addAction:okAction];
            [alert addAction:saveImage];
            [self presentViewController:alert animated:YES completion:nil];
        }else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到有效二维码" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    
    }
    return;
}

// 保存相册的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    YHWebViewController *webViewC = [[YHWebViewController alloc] init];
    webViewC.Navtitle = @"banner";
    webViewC.urlString = @"http://mp.weixin.qq.com/s?__biz=MzI1OTQwOTg2Mg==&mid=2247484701&idx=1&sn=acf6b9f50b2b3f8df0cba1612942f5a0&chksm=ea7817b4dd0f9ea2d8a4f7fb580a84260ffce499aee2a9aacbc240f5a9ecf72758d749594518&mpshare=1&scene=1&srcid=0414ZicMU9fWBGgE3V0mMVMv#rd";
    [self presentViewController:webViewC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createQRCode:(UIButton *)sender {
}
@end
