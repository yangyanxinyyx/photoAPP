//
//  CustomCollectionViewLayout.m
//  menuChooseDemo
//
//  Created by Melody on 2017/8/27.
//  Copyright © 2017年 Melody. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

@implementation CustomCollectionViewLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)prepareLayout{
    [super prepareLayout];
    // 水平滚动
    self.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
}



@end
