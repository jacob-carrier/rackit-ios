//
//  RIClosetViewController.h
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/30/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICoverflowLayout.h"
#import "RIUser.h"

@interface RIClosetViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    RIUser* currentUser;
    NSArray* searchQuery;
    NSArray* allQuery;
    NSDictionary* imageCache;
    //NSMutableArray* tags;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)returnToScreen:(id)sender;
-(void)setUser:(RIUser*)user;
-(void)addArticle;
@end
