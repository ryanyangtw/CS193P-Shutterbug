//
//  ImageViewController.m
//  Imaginariun
//
//  Created by Ryan on 2015/1/30.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

# pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"ViewDidLoad before");
    [self.scrollView addSubview:self.imageView];
    //NSLog(@"ViewDidLoad after");
}

# pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView
{
    if(!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{

    self.imageView.image = image; // does not change the frame the UIImageView
    //[self.imageView sizeToFit]; // update the frame of the UIImageView
    
    // had to add these two lines in Shutterbug to fix a bug in "reusing" ImageViewController's MVC
    self.scrollView.zoomScale = 1.0;
    self.imageView.frame = CGRectMake(0,0 ,image.size.width, image.size.height);
    //NSLog(@"%@" ,self.scrollView);
    
    //NSLog(@"setImage before");
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    //NSLog(@"setImage after");
    
    
    [self.spinner stopAnimating];
}


// outlet setting is before viewDidLoad
// When outlet setting, setSctollView will be execuated automatically
- (void)setScrollView:(UIScrollView *)scrollView
{
    //NSLog(@"setScrollView");
    _scrollView = scrollView;
    
    // next three lines are necessary for zooming
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    
    // next line is necessary in case self.image gets set before self.scrollView does
    // for example, prepareForSegue:sender: is called before outlet-setting phase
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
}



# pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Setting the Image from the Image's URL

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    //self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL ]]; // blocks main queue!!
    [self startDownloadingImage];
}


- (void)startDownloadingImage {
    self.image = nil;
    
    if (self.imageURL)
    {
        [self.spinner startAnimating];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        
        // another configuration option is backgroundsSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                //this handler is not executing on the main queue, so we can't so UI directly here
            if(!error) {
                if ([request.URL isEqual:self.imageURL]) {
                    // UIImage is am exception to the "can't do UI here"
                    // The locakfile url is only for the lifetime of this block, as long as block stops execuate. The file will be deleted. If you want keep it, you should copy it (using NSFileManager )
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile] ];
                    
                    // but calling "self.image = " is definitely not an exception to that!
                    // so we must dispatch this back to the main queue
                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; } );
                }
            }
        
        }];
        
        [task resume]; // don't forget taht all NSURLSession tasks start out suspended!

    }
}



#pragma mark - UISplitViewControllerDelegate

// this section added during Shutterbug demo

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}






@end
