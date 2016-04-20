//
//  HXCollectionViewLayout.m
//  CollectionViewDemo
//
//  Created by miaios on 16/4/19.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXCollectionViewLayout.h"


@implementation HXCollectionViewLayout {
    NSArray<UICollectionViewLayoutAttributes *> *_layoutAttributes;
}

// 1
- (void)prepareLayout {
    [super prepareLayout];
    
    CGFloat controlWidht = self.collectionView.frame.size.width;
    CGFloat controlHeight = self.collectionView.frame.size.height;
    
    NSIndexPath *indexPath;
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:0];
    
    if (sectionCount > 1) {
        assert(@"Collection View Section Count Must Only One!");
        return;
    }
    
    // 计算卡片宽度
    CGFloat itemWidth = controlWidht - _itemSpacing*2 - _itemSpilled*2;
    CGFloat itemHeith = controlHeight;
    
    // 计算x轴
    CGFloat x = _itemSpacing + _itemSpilled;
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemsCount];
    // 遍历item
    for(NSInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++) {
        indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        // 通过协议回传卡片风格
        HXCollectionViewLayoutStyle style = [_delegate collectionView:self.collectionView layout:self styleForItemAtIndexPath:indexPath];
        
        // 计算y轴
        CGFloat y = 0.0f;
        HXCollectionViewLayoutStyle lastStyle = HXCollectionViewLayoutStyleHeavy;
        NSIndexPath *lastIndexPath = nil;
        if (itemIndex) {
            lastIndexPath = [NSIndexPath indexPathForItem:(itemIndex - 1) inSection:0];
            lastStyle = [_delegate collectionView:self.collectionView layout:self styleForItemAtIndexPath:lastIndexPath];
        }
        if (style == HXCollectionViewLayoutStylePetty) {
            itemHeith = (controlHeight - _itemSpacing) / 2;
            itemWidth = (controlWidht - _itemSpacing*3) / 2;
            if (lastIndexPath && (lastStyle == HXCollectionViewLayoutStylePetty)) {
                UICollectionViewLayoutAttributes *lastAttributes = [itemAttributes lastObject];
                if (lastAttributes.frame.origin.y == 0.0f) {
                    y = itemHeith + _itemSpacing;
                }
            }
        }
        
        attributes.frame = CGRectMake(x, y, itemWidth, itemHeith);
        // 下一个item的x坐标
        switch (style) {
            case HXCollectionViewLayoutStyleHeavy: {
                x += (itemWidth + _itemSpacing);
                break;
            }
            case HXCollectionViewLayoutStylePetty: {
                if (y > 0.0f) {
                    x += (itemWidth + _itemSpacing);
                }
                break;
            }
        }
        
        // 保存item属性
        [itemAttributes addObject:attributes];
    }
    _layoutAttributes = [itemAttributes copy];
}

// 2
- (CGSize)collectionViewContentSize {
    CGFloat sizeHeight = [_layoutAttributes firstObject].frame.size.height;
    __block CGFloat sizeWidth = 0;
    [_layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        sizeWidth += (attributes.frame.size.width + _itemSpacing);
    }];
    
    sizeWidth += (_itemSpacing + _itemSpilled);
    
    return CGSizeMake(sizeWidth, sizeHeight);
}

// 3
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = @[].mutableCopy;
    [_layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }];
    return allAttributes;
}

@end
