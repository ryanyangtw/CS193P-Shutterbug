//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by Ryan on 2015/2/1.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import "FlickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface FlickrPhotosTVC ()

@end

@implementation FlickrPhotosTVC


// Whenever our Model is set, must update our View
- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    // reloadData will called numberOfSectionsInTableView, numberOfRowsInSection, cellForRowAtIndexPath
    [self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.photos count];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];

    return cell;
}





#pragma mark - UITableViewDelegate

// when a row is selected and we are in a UISplitViewController,
//   this updates the Detail ImageViewController (instead of segueing to it)
// knows how to find an ImageViewController inside a UINavigationController in the Detail too
// otherwise, this does nothing (because detail will be nil and not "isKindOfClass:" anything)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the Detail view controller in out UISplitViewController (nil if not in one)
    id detail = self.splitViewController.viewControllers[1];
    // if detail is a UINavigationController, look at its root view controller to find it
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    // is the Detail is an ImageViewController?
    if ([detail isKindOfClass:[ImageViewController class]]) {
        // yes ... we know how to update that!
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
    }

}

#pragma mark - Navigation


// prepares the given ImageViewController to show the given photo
// used either when segueing to an ImageViewController
//   or when our UISplitViewController's Detail view controller is an ImageViewController

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    NSLog(@"iamge url : %@", ivc.imageURL);
    ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];

}



// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]){
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                // yes ... is the destination an ImageViewController?
                if([segue.destinationViewController isKindOfClass:[ImageViewController class]]){
                    //YES ... then we know how to prepare for that segue!
                    [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.photos[indexPath.row]];
                
                }
            }
        
        }
    
    }
    
}


@end
