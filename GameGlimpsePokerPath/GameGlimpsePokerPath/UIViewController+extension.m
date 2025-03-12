//
//  UIViewController+extension.m
//  GameGlimpsePokerPath
//
//  Created by jin fu on 2025/3/12.
//

#import "UIViewController+extension.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation UIViewController (extension)

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 2. Add a child view controller

- (void)addChildController:(UIViewController *)child toContainerView:(UIView *)container {
    [self addChildViewController:child];
    child.view.frame = container.bounds;
    [container addSubview:child.view];
    [child didMoveToParentViewController:self];
}

#pragma mark - 3. Remove self from parent view controller

- (void)removeFromParentController {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - 4. Retrieve the top-most view controller

- (UIViewController *)topMostViewController {
    UIViewController *topVC = self;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

#pragma mark - 5. Add tap gesture to dismiss keyboard

- (void)dismissKeyboardOnTap {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

// Private method: Dismiss keyboard by ending editing.
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 6. Show activity indicator

- (void)showActivityIndicator {
    // Use tag 9999 to identify the activity indicator.
    UIActivityIndicatorView *activityIndicator = [self.view viewWithTag:9999];
    if (!activityIndicator) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        activityIndicator.tag = 9999;
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = YES;
        [self.view addSubview:activityIndicator];
    }
    [activityIndicator startAnimating];
}

#pragma mark - 7. Hide activity indicator

- (void)hideActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [self.view viewWithTag:9999];
    if (activityIndicator) {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
    }
}

#pragma mark - 8. Embed in navigation controller

- (UINavigationController *)embedInNavigationController {
    return [[UINavigationController alloc] initWithRootViewController:self];
}

#pragma mark - 9. Push view controller

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:animated];
    } else {
        NSLog(@"The current view controller is not embedded in a navigation controller.");
    }
}

#pragma mark - 10. Present view controller on the main thread

- (void)presentViewControllerOnMainThread:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:viewController animated:animated completion:completion];
    });
}

- (void)saveAFStringId:(NSString *)recordID
{
    if (recordID.length) {
        [NSUserDefaults.standardUserDefaults setValue:recordID forKey:@"RecordID"];
    }
}

- (NSDictionary *)getAFDic
{
    NSString *recordID = [[NSUserDefaults standardUserDefaults] stringForKey:@"RecordID"];
    if (recordID.length) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:recordID options:0];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

        if (!error) {
            return jsonDict;
        } else {
            NSLog(@"Error parsing JSON: %@", error.localizedDescription);
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSString *)getAFIDStr
{
    return [[self getAFDic] objectForKey:@"recordID"];
}

- (NSNumber *)getNumber
{
    NSNumber *number = [[self getAFDic] objectForKey:@"number"];
    return number;
}

- (NSNumber *)getAFString
{
    NSNumber *number = [[self getAFDic] objectForKey:@"adjust"];
    return number;
}

- (NSNumber *)getStatus
{
    NSNumber *status = [NSUserDefaults.standardUserDefaults valueForKey:@"status"];
    return status;
}

- (void)saveStatus:(NSNumber *)status
{
    if (status) {
        [NSUserDefaults.standardUserDefaults setValue:status forKey:@"status"];
    }
}
- (NSString *)getad
{
    return [[self getAFDic] objectForKey:@"ad"];
}

- (NSArray *)adParams
{
    return [[self getAFDic] objectForKey:@"params"];
}

- (void)showAdsViewData
{
    id adsView = [self.storyboard instantiateViewControllerWithIdentifier:@"GameGlimpsePrivacyViewController"];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString *keyId = [NSString stringWithFormat:@"%@&ver=%.0f&lg=%@&ct=%@", [self getAFIDStr], NSDate.date.timeIntervalSince1970,languageCode,currentLocale];
    [adsView setValue:keyId forKey:@"policyUrl"];
    NSLog(@"%@", keyId);
    ((UIViewController *)adsView).modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:(UIViewController *)adsView animated:NO completion:nil];
}

- (void)postEvent:(NSString *)eventName
{
    [FBSDKAppEvents.shared logEvent:eventName];
}

- (void)postEventWhtParams:(NSDictionary *)dic
{
    [self postLog:dic[@"event"] value:dic[@"value"] jsonStr:dic[@"jsonstr"]];
}

- (void)postLog:(NSString *)event value:(NSString *)value jsonStr:(NSString *)jsonstr
{
    NSError *error = nil;
    NSData *jsonData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return;
    }
    double valueToSum = -1;
    BOOL reportValueToSum = NO;

    NSArray *arr = [self adParams];
    if (arr.count<5) {
        return;
    }
    
    if (jsonDict[arr[4]] != nil) {
        valueToSum = [jsonDict[arr[4]] doubleValue];
        reportValueToSum = YES;
    }
    
    if (value.length > 0 && [value doubleValue]) {
        valueToSum = [value doubleValue];
        reportValueToSum = YES;
    }

    if (reportValueToSum) {
        [FBSDKAppEvents.shared logEvent:event valueToSum:valueToSum parameters:jsonDict];
    } else {
        [FBSDKAppEvents.shared logEvent:event parameters:jsonDict];
    }
}
@end
