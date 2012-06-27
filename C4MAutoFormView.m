/*******************************************************************************
 * This file is part of the C4MiOS_AutoFormView project.
 * 
 * Copyright (c) 2012 C4M PROD.
 * 
 * C4MiOS_AutoFormView is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * C4MiOS_AutoFormView is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with C4MiOS_AutoFormView. If not, see <http://www.gnu.org/licenses/lgpl.html>.
 * 
 * Contributors:
 * C4M PROD - initial API and implementation
 ******************************************************************************/
 
#import "C4MAutoFormView.h"
#define iPhoneKeyboardAnimationTime		0.3
#define iPhoneKeyboardHeight			216
#import <QuartzCore/QuartzCore.h>

@implementation C4MAutoFormView
@synthesize selectionBar = mSelectionBar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self findChildrenWithRoot:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
        [self findChildrenWithRoot:nil];
    }
    return self;
}

/**
 * Call this method to update the fields handled by the scrollview.
 * Mandatory if a text field is initially hidden then shown later.
 * rootViewOrNil : a subview in which to search for fields. Can be nil to use the whole scrollview.
 * return number of form items found.
 */
- (int)findChildrenWithRoot:(UIView*)rootViewOrNil {
    int i;
    if (rootViewOrNil == nil) {
        rootViewOrNil = self;
        if (mTextFieldCollection) {
            [mTextFieldCollection release];
        }
        mTextFieldCollection = [[NSMutableArray alloc] init];
        i = 0;
    } else {
        i = rootViewOrNil.tag;
    }
    for (UIView* v in [rootViewOrNil subviews]) {
        if (!v.hidden) {
            if ([v isKindOfClass:[UITextField class]]) {
                ((UITextField*) v).delegate = self;
                v.tag = i++;
                [mTextFieldCollection addObject:v];
            } else if ([v isKindOfClass:[UITextView class]] && [((UITextView*)v) isEditable]) {
                ((UITextView*) v).delegate = self;
                v.tag = i++;
                [mTextFieldCollection addObject:v];
            } else if ([[v subviews] count] > 0) {
                v.tag = i;
                i = [self findChildrenWithRoot:v];
            }
        }
    }
    
    return i;
}

- (void)initialize {
    NSString *reqSysVer = @"4.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        iOS4 = TRUE;
    } else {
        iOS4 = FALSE;
    }
    
    // Initialization code    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if (!iOS4) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }

    mKeyboardIsShowing = NO;
}

#pragma mark -
#pragma mark Selection bar
/**
 * Callback method for selection bar "next" button.
 * Focus the next text field in the scrollview.
 */
- (void)nextButtonPressed {
    int nextId = (((UIView*)mActiveField).tag + 1) % [mTextFieldCollection count];
    UITextField* tf = [mTextFieldCollection objectAtIndex:nextId];
    [tf becomeFirstResponder];
}

/**
 * Callback method for selection bar "previous" button.
 * Focus the previous text field in the scrollview
 */
- (void)previousButtonPressed {
    int nextId = ((UIView*)mActiveField).tag - 1;
    if (nextId < 0) {
        nextId = [mTextFieldCollection count] - 1;
    }
    UITextField* tf = [mTextFieldCollection objectAtIndex:nextId];
    [tf becomeFirstResponder];
}

/**
 * Callback method for selection bar "ok" button.
 * Dismiss the keyboard.
 */
- (void)okButtonPressed {
    [mActiveField resignFirstResponder];
}

/**
 * Show the selection bar above the keyboard.
 */
- (void)showSelectionBar {
    [self.window addSubview:mSelectionBar];
    
    CGRect newFrame = CGRectMake(0, self.window.frame.size.height-iPhoneKeyboardHeight-44, mSelectionBar.frame.size.width, mSelectionBar.frame.size.height);
    [UIView beginAnimations:@"showSelectionBar" context:nil];
    [UIView setAnimationDuration:iPhoneKeyboardAnimationTime];
	mSelectionBar.frame = newFrame;
    [UIView commitAnimations];
}

/**
 * Hide the selection bar.
 */
- (void)hideSelectionBar {    
    CGRect newFrame = CGRectMake(0, self.window.frame.size.height, mSelectionBar.frame.size.width, mSelectionBar.frame.size.height);
    [UIView beginAnimations:@"hideSelectionBar" context:nil];
    [UIView setAnimationDuration:iPhoneKeyboardAnimationTime];
	mSelectionBar.frame = newFrame;
    [UIView commitAnimations];
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    mActiveField = textField;
    //if (mKeyboardIsShowing) {
        [self scrollToActiveField];
    //}
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    mActiveField = textView;
    //if (mKeyboardIsShowing) {
        [self scrollToActiveField];
    //}
}

#pragma mark Keyboard callbacks
- (void)keyboardWillShow: (NSNotification *)notif {
    if (!mKeyboardIsShowing) {
        //reset bar position
        mSelectionBar.frame = CGRectMake(0, self.window.frame.size.height, mSelectionBar.frame.size.width, mSelectionBar.frame.size.height);
    }
    mKeyboardIsShowing = YES;
    //[self scrollToActiveField];
    [self showSelectionBar];
}

- (void)keyboardWillHide: (NSNotification *)notif {
    if (iOS4) {
        mKeyboardIsShowing = NO;
        [self hideSelectionBar];
        [self resetScroll];
    }
}
- (void)keyboardDidHide: (NSNotification *)notif {
    mKeyboardIsShowing = NO;
    [self hideSelectionBar];
    [self resetScroll];
}

#pragma mark Scroll
/**
 * Scroll the scrollview to center the focused text field in the middle of the visible area.
 */
- (void)scrollToActiveField {
    UIView* activeField = (UIView*)mActiveField;
    CGFloat originOfScrollViewInWindow = [self convertPoint:self.contentOffset toView:self.window].y;
    CGFloat displaySpace = (self.window.frame.size.height - originOfScrollViewInWindow - iPhoneKeyboardHeight);
    CGRect activeFieldFrame;
    if (activeField.superview == self) {
        //in this case convertRect is bugged - or return shit as a magical incredible feature -
        activeFieldFrame = activeField.frame;
    } else {
        activeFieldFrame = [activeField convertRect:activeField.frame toView:self];
    }
    CGFloat centeredOffset = activeFieldFrame.origin.y - (displaySpace - activeFieldFrame.size.height - mSelectionBar.frame.size.height) /2;
    
    [UIView beginAnimations:@"scrollToOffset" context:nil];
    [UIView setAnimationDuration:iPhoneKeyboardAnimationTime];
	[self setContentOffset:CGPointMake(0.0, centeredOffset) animated:YES];
    [UIView commitAnimations];
}

/**
 * Reset the scrollview to its origin position.
 */
- (void)resetScroll {
    [UIView beginAnimations:@"scrollToOffset" context:nil];
    [UIView setAnimationDuration:iPhoneKeyboardAnimationTime];
	[self setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Memory

- (void)dealloc
{
    [mSelectionBar release];
    [mTextFieldCollection release];
    [super dealloc];
}

@end