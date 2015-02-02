//
//  JustPostedFlickrPhotosTVC.m
//  Shutterbug
//
//  Created by Ryan on 2015/2/1.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import "JustPostedFlickrPhotosTVC.h"
#import "FlickrFetcher.h"

@interface JustPostedFlickrPhotosTVC ()

@end

@implementation JustPostedFlickrPhotosTVC

// an argument can be made that this should be done in viewWillAppear:
//   (that way, the expensive operation of fetching will only happen
//    if our View is FOR SURE going to appear on screen).
// however, we'd have to be sure it only happens the first time
//   that viewWillAppear: is called, not on subsequent appearances


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchPhotos];
}

// this method is called in viewDidLoad,
//   but also when the user "pulls down" on the table view
//   (because this is the action of self.tableView.refreshControl)

// set to IBAction to connect this method to Refresh Control
- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing]; // start the spinner
    NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    
#warning Block Main Thread (I have already hadle it) 留下此行是為了紀錄用法
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        //fetch th Json data ftom Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *propertyListResult = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        
        // get NSArray of photo NSDictionarys out of the results
        NSArray *photos = [propertyListResult valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        
        // update the Model (and thus out UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            
            self.photos = photos;
        });

        
    
    });
    
    

    
    //NSLog(@"flicker results = %@", propertyListResult);
    /*
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: [[NSDictionary alloc] initWithObjectsAndKeys: @"first nested obj" , @"first_nested_key", nil], @"first_key", @"second obj", @"second_key", nil];
    
    NSLog(@"fuck: %@", [dic valueForKeyPath:@"first_key.first_nested_key"]);
    */

    
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
