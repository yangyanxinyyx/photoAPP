//
//  BIAlertViewController.h
//  PocoCamera
//
//  Created by yanxin_yang on 13/9/17.
//  Copyright © 2017年 yanxin_yang. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BIAlertActionStyle) {
    BIAlertActionStyleDefault,
    BIAlertActionStyleCancel,
};


@interface BIAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(BIAlertActionStyle)style handler:(void (^ __nullable)(BIAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) BIAlertActionStyle style;
@property (nonatomic, assign) BOOL enabled;

@end


@interface BIAlertViewController : UIViewController

+ (instancetype)alertControllerWithMessage:(nullable NSString *)message;

- (void)addAction:(BIAlertAction *)action;
@property (nonatomic, readonly) NSArray<BIAlertAction *> *actions;

@property (nullable, nonatomic, copy) NSString *message;

@end
NS_ASSUME_NONNULL_END
