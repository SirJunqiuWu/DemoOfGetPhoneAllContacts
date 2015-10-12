//
//  ViewController.m
//  DemoOfGetContact
//
//  Created by 吴 吴 on 15/10/12.
//  Copyright © 2015年 吴 吴. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <ContactsUI/ContactsUI.h>
#import <ContactsUI/ContactsUI.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *infoTable;
    NSMutableArray *dataArray;
    
    /**
     *  创建CNContactStore对象,用与获取和保存通讯录信息
     */
    CNContactStore *contactStore;
}

@end

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavRightItem];
    [self setupUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 自定义方法

- (void)setNavRightItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemPressed)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 创建UI

- (void)setupUI {
    
    [self getAllContactsByContact];
    
    infoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    infoTable.backgroundColor = [UIColor clearColor];
    infoTable.dataSource = self;
    infoTable.delegate = self;
    [self.view addSubview:infoTable];
    
}

#pragma mark - 按钮点击事件

- (void)rightItemPressed {
    [infoTable reloadData];
}

#pragma mark - 数据源

/**
 *  获取所有本地所有联系人 ios9前
 */
- (void)getAllContactsByAdressBook {
    /**
     *  取得本地通信录名柄
     */
    ABAddressBookRef tmpAddressBook = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0)
    {
        tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        tmpAddressBook =ABAddressBookCreate();
    }
    /**
     *  取得本地所有联系人记录
     */
    if (tmpAddressBook==nil) {
        return ;
    };
    NSArray* allContactsArray = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    dataArray = [NSMutableArray arrayWithArray:allContactsArray];
    CFRelease(tmpAddressBook);
}

/**
 *  获取所有本地所有联系人 ios9后
 */
- (void)getAllContactsByContact {
    /**
     * 首次访问通讯录会调用
     */
    contactStore = [[CNContactStore alloc] init];
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined)
    {
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
            if (error) return;
            if (granted)
            {
                NSLog(@"授权访问通讯录");
                [self fetchContactWithContactStore:contactStore];
            }
            else
            {
                NSLog(@"拒绝访问通讯录");
            }  
        }];  
    }
    else
    {
        [self fetchContactWithContactStore:contactStore];//访问通讯录  
    }
}

- (void)fetchContactWithContactStore:(CNContactStore *)cnContactStore {
    
    /**
     *  有权限访问
     */
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
    {
        NSError *error = nil;
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        //创建获取联系人的请求
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        //遍历查询
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop)
        {
            if (!error)
            {
                NSLog(@"familyName = %@", contact.familyName);//姓
                NSLog(@"givenName = %@", contact.givenName);//名字
                NSLog(@"phoneNumber = %@", ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue);//电话
                [dataArray addObject:contact];
            }
            else
            {
                NSLog(@"error:%@", error.localizedDescription);  
            }  
        }];  
    }
    else
    {
        NSLog(@"拒绝访问通讯录");  
    }
}

#pragma mark - UITableViewSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"myCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    id tempPerson = dataArray[indexPath.row];
//    NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tempPerson), kABPersonFirstNameProperty);
    CNContact *tempConact = dataArray[indexPath.row];
    NSString *phone = ((CNPhoneNumber *)(tempConact.phoneNumbers.lastObject.value)).stringValue;
    cell.textLabel.text = [NSString stringWithFormat:@"%@     %@",tempConact.givenName,phone];
    return cell;
}

@end
