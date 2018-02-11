//
//  FlyAutoStopLayout.m
//
//
//  Created by Fly on 2018/2/11.
//

#import "FlyAutoStopLayout.h"

@interface FlyAutoStopLayout ()
@property (nonatomic, strong) NSMutableArray  *  cellLayoutList;
@end

@implementation FlyAutoStopLayout

- (instancetype)init
{
    if(self=[super init]){
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _cellLayoutList    = [NSMutableArray array];
        _isKeepRight       = YES;
        _isFadeOut         = YES;
        _disappearPosition = 0.5f;
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = [super collectionViewContentSize];
    if (contentSize.width <= CGRectGetWidth(self.collectionView.frame)) {
        contentSize.width = CGRectGetWidth(self.collectionView.frame) + 1.0f;//为了让不能滑变可滑
    }
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (void)prepareLayout
{
    [super prepareLayout];
    [self.cellLayoutList removeAllObjects];
    
    NSInteger rowCount = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger row = 0 ; row < rowCount; row++) {
        UICollectionViewLayoutAttributes * attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
        [self.cellLayoutList addObject:attribute];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes * attribute in self.cellLayoutList) {
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            [array addObject:attribute];
        }
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes * layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    CGFloat cellAlpha = 1.0f;
    
    CGFloat cellWidth = layoutAttributes.frame.size.width;//cell宽度
    
    CGFloat maxX = layoutAttributes.frame.origin.x + cellWidth;//cell右顶点
    
    CGFloat startdisappearX = self.collectionView.contentOffset.x + self.sectionInset.left - self.minimumLineSpacing;//完全消失位置坐标:x
    
    CGFloat distanceX = maxX - startdisappearX;//距离完全消失位置距离
    
    CGFloat maxDistance = cellWidth * (1 - _disappearPosition) + self.minimumLineSpacing;//开始消失距离
    
    if (distanceX < maxDistance && distanceX >= 0) {
        if (maxDistance != 0) {
            cellAlpha = distanceX/maxDistance;
        } else {
            cellAlpha = 0;
        }
    } else if(distanceX < 0) {
        cellAlpha = 0;
    } else if (distanceX >= maxDistance) {
        cellAlpha = 1.0f;
    }
    
    layoutAttributes.alpha = cellAlpha;
    
    return layoutAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    //1. 获取UICollectionView停止的时候的可视范围
    CGRect contentFrame;
    
    contentFrame.size   = self.collectionView.frame.size;
    contentFrame.origin = proposedContentOffset;
    
    NSArray * array = [self layoutAttributesForElementsInRect:contentFrame];//可视范围内个item属性
    
    //2. 计算在可视范围的距离左边距最近的Item
    CGFloat minDistanceX        = CGFLOAT_MAX;
    CGFloat nearestCellWidth    = 0.f;
    CGFloat collectionViewLeftX = proposedContentOffset.x + self.sectionInset.left; //要对齐的基准点
    for (UICollectionViewLayoutAttributes * attrs in array) {
        if(ABS(attrs.frame.origin.x - collectionViewLeftX) < ABS(minDistanceX)){
            minDistanceX      = attrs.frame.origin.x - collectionViewLeftX;
            nearestCellWidth  = attrs.frame.size.width;
        }
    }
    
    CGFloat newOffsetX = minDistanceX;//最后要加的偏移量
    if (proposedContentOffset.x + CGRectGetWidth(self.collectionView.frame) >= self.collectionView.contentSize.width + self.collectionView.contentInset.right - 1.0f)
    {//如果到最右边最大值
        if (!_isKeepRight) {
            if (minDistanceX >= -1.f) {//精度问题
                newOffsetX = minDistanceX;
            } else {
                newOffsetX = minDistanceX + nearestCellWidth + self.minimumLineSpacing;
            }
            CGFloat oldRight = self.collectionView.contentInset.right;
            if (oldRight + newOffsetX > 0) {
                [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, newOffsetX + oldRight)];
            }
        }
    }
    
    if (velocity.x < 0.01) {//防止抖动
        [self.collectionView setContentOffset:CGPointMake(proposedContentOffset.x + newOffsetX, proposedContentOffset.y) animated:YES];
    }
    
    //3. 补回ContentOffset，则正好将Item居左边
    return CGPointMake(proposedContentOffset.x + newOffsetX , proposedContentOffset.y);
}

@end
