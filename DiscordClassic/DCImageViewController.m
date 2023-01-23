//
//  DCImageViewController.m
//  Discord Classic
//
//  Created by Trevir on 11/17/18.
//  Copyright (c) 2018 Julian Triveri. All rights reserved.
//

#import "DCImageViewController.h"

@interface DCImageViewController ()

@end

@implementation DCImageViewController

- (void)viewDidLoad{
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[self setImageView:nil];
    [self setScrollView:nil];
	[super viewDidUnload];
}

-(IBAction)presentShareSheet:(id)sender{
	//Show share sheet with appropriate options
	NSArray *itemsToShare = @[self.imageView.image];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{return self.imageView;}
@end
