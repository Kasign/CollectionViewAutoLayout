//
//  FlyAutoStopLayout.h
//  
//
//  Created by Fly on 2018/2/11.
//

#import <UIKit/UIKit.h>

@interface FlyAutoStopLayout : UICollectionViewFlowLayout

/**
 *是否渐隐,默认：yes
 */
@property (nonatomic, assign) BOOL    isFadeOut;

/**
 *是否在到达右边界时停靠，默认：yes
 */
@property (nonatomic, assign) BOOL    isKeepRight;

/**
 * 控制开始消失的位置：
 *    0：cell的左顶点
 *  0.5：cell中心位置
 *    1：cell右顶点
 * 默认：0.5
 */
@property (nonatomic, assign) CGFloat  disappearPosition;

@end
