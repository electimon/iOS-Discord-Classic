//
//  DCInfoPageViewController.m
//  Discord Classic
//
//  Created by Trevir on 11/24/18.
//  Copyright (c) 2018 Julian Triveri. All rights reserved.
//

#import "DCInfoPageViewController.h"

@interface DCInfoPageViewController ()
@property NSArray *creditLinks;
@end

@implementation DCInfoPageViewController

- (void)viewDidLoad{
	[super viewDidLoad];
	self.creditLinks = [NSArray arrayWithObjects:@"https://twitter.com/electimon", "https://twitter.com/_cellomonster", @"https://twitter.com/TyBrasher", @"https://twitter.com/IPGSecondary", @"https://github.com/ndcube", @"https://discordapp.com", nil];
}

- (void)didReceiveMemoryWarning{[super didReceiveMemoryWarning];}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[UIApplication.sharedApplication openURL:[NSURL URLWithString:[self.creditLinks objectAtIndex:(indexPath.row + indexPath.section * 3)]]];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
