//
//  UIAlertController+Extension.m
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/14.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import "UIAlertController+Extension.h"
#import "YHAlertAction.h"

@implementation UIAlertController (Extension)

- (void)showError:(NSString*)str
{
    [YHAlertAction showAlertWithTitle:@"提示" msg:str chooseBlock:nil buttonsStatement:@"知道了",nil];
}


@end
