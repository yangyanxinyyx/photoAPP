//
//  BIAlertViewController.m
//  PocoCamera
//
//  Created by yanxin_yang on 13/9/17.
//  Copyright © 2017年 yanxin_yang. All rights reserved.
//

#import "BIAlertViewController.h"

typedef NS_ENUM(NSUInteger, BIAlertViewControllerAnimationType) {
    BIAlertViewControllerAnimationTypePresent = 0,
    BIAlertViewControllerAnimationTypeDismiss,
};

@interface BIAlertViewControllerAnimation : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)animationWithType:(BIAlertViewControllerAnimationType)animationType;

@property (nonatomic, assign) BIAlertViewControllerAnimationType animationType;
@end

@implementation BIAlertViewControllerAnimation

+ (instancetype)animationWithType:(BIAlertViewControllerAnimationType)animationType {
    BIAlertViewControllerAnimation *animation = [BIAlertViewControllerAnimation new];
    animation.animationType = animationType;
    return animation;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.animationType == BIAlertViewControllerAnimationTypePresent) {
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.alpha = 0.0f;
        
        [[transitionContext containerView] addSubview:toView];
        
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        [UIView animateWithDuration:duration animations:^{
            toView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
    else if (self.animationType == BIAlertViewControllerAnimationTypeDismiss) {
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        [UIView animateWithDuration:duration animations:^{
            fromView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}
@end

#pragma mark - Action

@interface BIAlertAction()

@property (nullable, nonatomic) NSString *title;

@property (nonatomic, assign) BIAlertActionStyle style;
@property (nonatomic,   copy) void(^handler)();
@end

@implementation BIAlertAction

- (void)dealloc {
//    SLLogInfo(@"FCHAlertAction dealloc");
}

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(BIAlertActionStyle)style handler:(void (^ __nullable)(BIAlertAction *action))handler {
    BIAlertAction *action = [[BIAlertAction alloc] init];
    action.title = title;
    action.style = style;
    action.enabled = YES;
    
    __weak typeof(action) weakAction = action;
    
    if (handler) {
        action.handler = ^{
            handler(weakAction);
        };
    }
    
    return action;
}

// TODO
- (id)copyWithZone:(nullable NSZone *)zone {
    BIAlertAction *action = [[[self class] allocWithZone:zone] init];
    action.title = self.title;
    action.style = self.style;
    action.enabled = self.enabled;
    return action;
}

@end

#define k_contentViewColor   [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0f]
#define k_cancelButtonColor  [UIColor colorWithRed:75/255.0 green:255/255.0 blue:4/255.0 alpha:1.0f]
#define k_defaultButtonColor [UIColor colorWithRed:239/255.0 green:0/255.0 blue:9/255.0 alpha:1.0f]

#define k_contentViewLightColor   [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:0.9f]
#define k_cancelButtonLightColor  [UIColor colorWithRed:75/255.0 green:255/255.0 blue:4/255.0 alpha:0.9f]
#define k_defaultButtonLightColor [UIColor colorWithRed:239/255.0 green:0/255.0 blue:9/255.0 alpha:0.9f]

@interface BIAlertViewController ()<UIViewControllerTransitioningDelegate>

//@property (nonatomic, assign) BIAlertControllerStyle preferredStyle;

@property (nonatomic, strong) NSMutableArray<BIAlertAction *> *innerActions;
@property (nonatomic, strong) NSArray<BIAlertAction *> *actions;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;

@end

@implementation BIAlertViewController

+ (instancetype)alertControllerWithMessage:(nullable NSString *)message {
    BIAlertViewController *alertViewController = [[BIAlertViewController alloc] init];
    //alertViewController.preferredStyle = preferredStyle;
    alertViewController.message = message;
    return alertViewController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0f];
    
    _innerActions = [NSMutableArray array];
    _buttons = [NSMutableArray array];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat messageLabelH = 0.0f;
    CGFloat messageLabelW = 544/2.f;
    
    if (self.messageLabel) {
        messageLabelH = 205/2.f;
        
        self.messageLabel.frame = CGRectMake(0, 0, messageLabelW, messageLabelH);
    }
    
    CGFloat buttonH = 110/2.f;
    CGFloat addtionH = 0.0f;
    
    if (self.buttons.count == 1) {
        [self.buttons firstObject].frame = CGRectMake(0, messageLabelH, messageLabelW, buttonH);
        
        addtionH = buttonH;
    }
    else if (self.buttons.count == 2) {
        for (NSInteger index = 0; index < self.buttons.count; index++) {
            self.buttons[index].frame = CGRectMake((messageLabelW / 2) * index, messageLabelH, messageLabelW / 2, buttonH);
        }
        addtionH = buttonH;
    }
    else {
        for (NSInteger index = 0; index < self.buttons.count; index++) {
            self.buttons[index].frame = CGRectMake(0, messageLabelH + buttonH * index, messageLabelW, buttonH);
            addtionH += buttonH;
        }
    }
    
    // update
    self.contentView.frame = CGRectMake(0, 0, messageLabelW, messageLabelH + addtionH);
    self.contentView.center = self.view.center;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    [self.view addSubview:self.contentView];
    
    // set Message
    if ((self.message.length != 0) && self.message) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.text = self.message;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.font = [UIFont systemFontOfSize:16.0f];
        self.messageLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.messageLabel];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set actions
    self.actions = [NSArray arrayWithArray:self.innerActions];
    
    for (NSInteger index = 0; index < self.actions.count; index++) {
        @autoreleasepool {
            BIAlertAction *action = self.actions[index];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = index;
            //            button.backgroundColor = (action.style == FCHAlertActionStyleCancel) ? k_cancelButtonColor : k_defaultButtonColor;
            button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            
            [button setTitle:action.title forState:UIControlStateNormal];
            
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.f] forState:UIControlStateHighlighted];
            
            UIColor *backgroundColor = (action.style == BIAlertActionStyleCancel) ? k_cancelButtonColor : k_defaultButtonColor;
            UIColor *lightBackgroundColor = (action.style == BIAlertActionStyleCancel) ? k_cancelButtonLightColor : k_defaultButtonLightColor;
            
            [button setBackgroundImage:[self imageWithColor:backgroundColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[self imageWithColor:lightBackgroundColor] forState:UIControlStateHighlighted];
            
            // add targer
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:button];
            [self.buttons addObject:button];
        }
    }
    
    self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) * 0.5);
    self.contentView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
    
    // message 和 action 至少要存在一个
    NSAssert((self.messageLabel || self.actions.count != 0), @"message and action cant empty at the same time");
}

// add action
- (void)addAction:(BIAlertAction *)action {
    if (action) {
        [self.innerActions addObject:action];
    }
}

#pragma mark - Button Action

- (void)buttonAction:(UIButton *)sender {
    // handler
    [UIView animateWithDuration:0.3f animations:^{
        self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds));
        self.contentView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
        
        if (self.actions[sender.tag].handler) {
            self.actions[sender.tag].handler();
        }
    }];
}

#pragma mark - Color To Image

- (UIImage *)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [BIAlertViewControllerAnimation animationWithType:BIAlertViewControllerAnimationTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [BIAlertViewControllerAnimation animationWithType:BIAlertViewControllerAnimationTypeDismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
