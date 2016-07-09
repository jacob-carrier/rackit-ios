//
//  RIClosetViewController.m
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/30/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import "RIClosetViewController.h"
#import "RIArticleViewController.h"

@interface RIClosetViewController (){
}
@end

@implementation RIClosetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)returnToScreen:(id)sender {
    [self.view endEditing:YES];
}

-(void)setUser:(RIUser*)user{
    currentUser = user;
    NSLog(@"User's Id: %@", currentUser._id);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.navigationItem.hidesBackButton = YES;
    NSLog(@"View Did Load");
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(addArticle)];
    
    self.tabBarController.navigationItem.rightBarButtonItem = addButton;
    
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@", @"http://192.168.0.2:3000/api/closet/", currentUser._id];
    NSLog(@"URL: %@", urlString);
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

    NSURLSessionDataTask* task = [session dataTaskWithRequest:request];
    
    [task resume];
}

-(void)addArticle{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController: picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* chosenImage = info[UIImagePickerControllerEditedImage];
    
    NSLog(@"Image result: %@", info);
    
    NSData* imageData = UIImageJPEGRepresentation(chosenImage, 1.0);
    NSString* base64String = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    //Here we would create a task to upload the data to the server
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL* url = [NSURL URLWithString:@"http://192.168.0.2:3000/api/articles/upload"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSString* postBody = [NSString stringWithFormat:@"_id=%@&filename=%@&imageString=%@", currentUser._id, @"generic", base64String];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }];
    
    [task resume];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //return 2;

    if(searchQuery != NULL){
        return searchQuery.count;
    }
    return allQuery.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ArticleCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView* cellImage = (UIImageView*)[cell viewWithTag:100];
    //cellImage.image = nil;
    
    //GET THE IMAGE DATA
    //STORE IN IMAGE CACHE IF IT DOESNT EXISTS
    if(cellImage.image == nil){
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        
        
        NSDictionary* imageDictionary = [allQuery objectAtIndex:indexPath.row];
        NSLog(@"%@", imageDictionary);
        
        //If base64 encoded string is stored as the img, then simply retrieve and decode that string. It would save up to n requests, although the database size and initial requests will increase a lot.
        //Also no need for the thumbnail as it is UIImage is automatically resized to fit the container.
        
        NSString* urlString = [[NSString alloc] initWithFormat:@"%@%@/%@", @"http://192.168.0.2:3000/api/articles/image/", currentUser._id, [imageDictionary valueForKey:@"img"]];
        //NSLog(@"URL: %@", urlString);
        NSURL* url = [NSURL URLWithString:urlString];
    
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSHTTPURLResponse* resp = (NSHTTPURLResponse*)response;
            if([resp statusCode] == 500){
                NSLog(@"No image with this name");
            }else{
                //NSLog(@"Response: %@", response);
                NSString* itemdata = [json objectForKey:@"imgData"];
                //NSLog(@"String Data: %@", itemdata);
                NSData* imageData = [[NSData alloc] initWithBase64EncodedString:itemdata options:0];
                UIImage* articlePic = [UIImage imageWithData:imageData];
                //NSLog(@"Image Data: %@", articlePic);
                dispatch_async(dispatch_get_main_queue(), ^{
                    cellImage.image = articlePic;
                });
            }
        }];
    
        [task resume];
    }
    
    return cell;
}

//Do the session task to figure out which images to download
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSHTTPURLResponse* resp = (NSHTTPURLResponse*)dataTask.response;
    NSLog(@"Response code %ld", (long)[resp statusCode]);
    if([resp statusCode] == 200){
        NSLog(@"Data: %@", json);
        allQuery = [json objectForKey:@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.collectionView reloadData];
        });
    }else{
        
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
}

//Do the session task in order to download all the images

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSPredicate* tagPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary* tags, NSDictionary *bindings) {
        NSMutableArray* tagList = [tags objectForKey:@"tags"];
        for(NSString* tag in tagList){
            if([tag isEqualToString:searchBar.text]){
                return YES;
            }
        }
        return NO;
    }];
    searchQuery = [allQuery filteredArrayUsingPredicate:tagPredicate];
    NSLog(@"Search: %@", searchQuery);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if([searchBar.text isEqualToString:@""]){
        searchQuery = NULL;
        [self.collectionView reloadData];
    }else{
        NSPredicate* tagPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary* tags, NSDictionary *bindings) {
            NSMutableArray* tagList = [tags objectForKey:@"tags"];
            for(NSString* tag in tagList){
                if([tag isEqualToString:searchBar.text]){
                    return YES;
                }
            }
            return NO;
        }];
        searchQuery = [allQuery filteredArrayUsingPredicate:tagPredicate];
        NSLog(@"Search: %@", searchQuery);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}
@end
