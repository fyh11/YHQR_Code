//
//  YHAlertAction.h
//  YHQR_Code
//
//  Created by 樊义红 on 17/4/14.
//  Copyright © 2017年 樊义红. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHAlertAction : NSObject

+ (void)showAlertWithTitle:(NSString*)title msg:(NSString*)msg chooseBlock:(void (^)(NSInteger buttonIdx))block  buttonsStatement:(NSString*)cancelString, ...;

+ (void)showActionSheetWithTitle:(NSString*)title message:(NSString*)message chooseBlock:(void (^)(NSInteger buttonIdx))block
               cancelButtonTitle:(NSString*)cancelString destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitle:(NSString*)otherButtonTitle,...;

@end
