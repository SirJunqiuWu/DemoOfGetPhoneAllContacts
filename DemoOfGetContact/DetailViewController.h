//
//  DetailViewController.h
//  DemoOfGetContact
//
//  Created by 吴 吴 on 15/10/13.
//  Copyright © 2015年 吴 吴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

@interface DetailViewController : UIViewController

/**
 *  当前联系人
 */
@property (nonatomic,strong)CNContact *tempContact;

@end
