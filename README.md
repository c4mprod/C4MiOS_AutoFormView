C4MiOS_AutoFormView
===================

This component is a Customized UIScrollView that helps to navigate between text form items (UITextField, UITextView).

Features
--------

The features are :

* Add a customizable toolbar above the keyboard with next/previous buttons to quickly focus form items and a Ok button to dismiss the keyboard.
* Automatic scolling of the scrollview to show the focused item centered in the visible space of the screen.
* Supports natively UITextField and UITextView.
* Supports subviews.

Usage
-----
1. Unzip the component anywhere in your project
2. Add the UI component C4MAutoFormView in your XIB
3. Link the outlet selectionBar to either the provided view in KeyboardToolBar.xib (copied in your XIB) or a custom view of your choice. This view will be shown above the keyboard and is optional if you don't want to use the field navigation.
4. Link the toolbar buttons to the actions nextButtonPressed, previousButtonPressed and okButtonPressed if you want to support these features. You can link these actions to other buttons or views if you don't wat to use a keyboard toolbar.
5. Add text fields in the scrollview. The navigation order is the order of the views in the view hierarchy.
6. Then everything else is handled magically !


Change Logs
-----------

### v1.1
* handles views with tab bar
* better calculation for the scrolling, now the superview of the auto form view can be anything.

### v1.0
First release