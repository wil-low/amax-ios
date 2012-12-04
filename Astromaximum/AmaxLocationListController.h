//
//  AmaxLocationListController.h
//  
//
//  Created by admin on 03.12.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface AmaxLocationListController : UIViewController
{
    int mCurrentLocationIndex;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
