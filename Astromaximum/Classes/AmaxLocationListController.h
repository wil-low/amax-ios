//
//  AmaxLocationListController.h
//  
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class AmaxDataProvider;

@interface AmaxLocationListController : UIViewController
{
    AmaxDataProvider *mDataProvider;
    long workingLocationIndex;
    long selectedLocationIndex;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (IBAction)didSelectLocation:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
