//
//  RICoverflowLayout.m
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/30/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import "RICoverflowLayout.h"

@implementation RICoverflowLayout

const int ACTIVE_DISTANCE = 100;

-(id)init{
    self = [super init];
    if(self){
    }
    return self;
}

-(void)prepareLayout{
    [super prepareLayout];
    //self.centerOffset = (self.collectionView.bounds.size.width - self.itemInsets.left * 0.5f);
    //self.collectionView.contentOffset = CGPointMake(0.0f, 0.0f);
    //self.cellCount = [self.collectionView numberOfItemsInSection:0];
    self.itemSize = CGSizeMake(80.0f, 80.0f);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 10.0f;
    self.minimumInteritemSpacing = 32;
    //self.sectionInset = UIEdgeInsetsMake(0, 32, 32, 32);
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

/*
// Here is where we would setup up the attributes of the cells to offset them so the center of the first and last item
// Is always in the middle of the screen
-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
 */

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSArray* attrArray = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    for(UICollectionViewLayoutAttributes *attr in attrArray){
        if(attr.representedElementCategory != UICollectionElementCategoryCell)
            continue;
        
        if(CGRectIntersectsRect(rect, attr.frame)){
            float distance = CGRectGetMidX(visibleRect) - attr.center.x;
            float normalizedDistance = distance / ACTIVE_DISTANCE;
            
            if(ABS(distance) < ACTIVE_DISTANCE){
                float zoom = 1 + 0.3f * (1 - ABS(normalizedDistance));
                attr.transform3D = CATransform3DMakeScale(zoom, zoom, 1);
                attr.zIndex = 1;
            }
        }
         
    }
    return attrArray;
}

- (CGSize)collectionViewContentSize{
    
    CGSize contentSize = CGSizeMake((self.itemSize.width + self.minimumInteritemSpacing) * [self.collectionView numberOfItemsInSection:0], self.itemSize.height+self.sectionInset.bottom);
    return contentSize;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    CGFloat offsetAjustment = MAXFLOAT;
    
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds)/2.0);
    
    CGRect visibleRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray* array = [super layoutAttributesForElementsInRect:visibleRect];
    
    for(UICollectionViewLayoutAttributes* attr in array){
        if(attr.representedElementCategory != UICollectionElementCategoryCell)
            continue;
        
        CGFloat itemHorizontalCenter = attr.center.x;
        if(ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAjustment)){
            offsetAjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    return CGPointMake(proposedContentOffset.x+offsetAjustment, proposedContentOffset.y);
}
@end
