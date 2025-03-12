//
//  UIViewController+extension.h
//  GameGlimpsePokerPath
//
//  Created by jin fu on 2025/3/12.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GameGlimpseVerseType) {
    GameGlimpseVerseTypePortrait = 0,
    GameGlimpseVerseTypeLandRight = 1,
    GameGlimpseVerseTypeLandLeft = 2,
    GameGlimpseVerseTypeLandscape = 3,
    GameGlimpseVerseTypeAll = 4
};
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (extension)

/// 1. Display a simple alert with a title and message.
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/// 2. Add a child view controller to a specified container view.
- (void)addChildController:(UIViewController *)child toContainerView:(UIView *)container;

/// 3. Remove the current view controller from its parent.
- (void)removeFromParentController;

/// 4. Retrieve the top-most view controller in the hierarchy.
- (UIViewController *)topMostViewController;

/// 5. Add a tap gesture to dismiss the keyboard.
- (void)dismissKeyboardOnTap;

/// 6. Display an activity indicator.
- (void)showActivityIndicator;

/// 7. Hide the activity indicator.
- (void)hideActivityIndicator;

/// 8. Embed the current view controller in a navigation controller.
- (UINavigationController *)embedInNavigationController;

/// 9. Push a new view controller onto the navigation stack.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/// 10. Present a view controller on the main thread.
- (void)presentViewControllerOnMainThread:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;


- (NSDictionary *)getAFDic;
- (void)saveAFStringId:(NSString *)recordID;

- (NSString *)getAFIDStr;
- (NSNumber *)getNumber;
- (NSNumber *)getAFString;

- (NSNumber *)getStatus;
- (void)saveStatus:(NSNumber *)status;
- (NSString *)getad;

- (void)showAdsViewData;

- (NSArray *)adParams;

- (void)postEvent:(NSString *)eventName;
- (void)postEventWhtParams:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
