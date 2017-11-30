//
//  EasyShowView+Alert.m
//  EasyShowViewDemo
//
//  Created by nf on 2017/11/30.
//  Copyright © 2017年 chenliangloveyou. All rights reserved.
//

#import "EasyShowView+Alert.h"
#import <objc/runtime.h>

#import "EasyShowUtils.h"

@interface EasyShowView()

@property (nonatomic,strong)showAlertCallback showAlertCallback ;

@end

@implementation EasyShowView (Alert)

- (showAlertCallback)showAlertCallback
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setShowAlertCallback:(showAlertCallback)showAlertCallback
{
    [self willChangeValueForKey:@"showAlertCallback"];
    objc_setAssociatedObject(self, @selector(showAlertCallback), showAlertCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"showAlertCallback"];
}

+ (void)showAlertWithTitle:(NSString *)title
                      desc:(NSString *)desc
               buttonArray:(NSArray *)buttonArray
                  callBack:(showAlertCallback)callback
{
    
}
+ (void)showAlertSystemWithTitle:(NSString *)title
                            desc:(NSString *)desc
                     buttonArray:(NSArray *)buttonArray
                        callBack:(showAlertCallback)callback
{
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:desc preferredStyle:UIAlertControllerStyleActionSheet];
        
        [buttonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *tempTitle = (NSString *)obj ;
            
            UIAlertActionStyle showStyle = UIAlertActionStyleDefault ;
            if (idx == 0) {
                showStyle = UIAlertActionStyleDestructive ;
            }
            else if (idx == 1){
                showStyle = UIAlertActionStyleCancel ;
            }
            UIAlertAction *action = [UIAlertAction actionWithTitle:tempTitle style:showStyle handler:^(UIAlertAction *action){
                dispatch_after(0.2, dispatch_get_main_queue(), ^{
//                    if (sure) sure() ;
                    callback(idx);
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            [alertController addAction:action];
            
        }];
        
        
//        UIAlertAction *action2 = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//
//            dispatch_after(0.2, dispatch_get_main_queue(), ^{
//                if (cancel)  cancel() ;
//                [alertController dismissViewControllerAnimated:YES completion:nil];
//            });
//        }];
//        [alertController addAction:action2];
        [kTopViewController presentViewController:alertController animated:YES completion:nil];
    }
    else{
        
//        if (ISEMPTY(sureTitle)) {
//
//            _alertMessageCancel = cancel ;
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:contentMessage delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];
//            [alertView show];
//        }
//        else{
//
//            _alertMessageSure = sure ;
//            _alertMessageCancel = cancel ;
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:contentMessage delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:sureTitle, nil];
//            [alertView show];
//        }
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex == 0) {
//        if(_alertMessageCancel) _alertMessageCancel() ;
//    }
//    else if (buttonIndex == 1){
//        if(_alertMessageSure) _alertMessageSure() ;
//    }
}
@end