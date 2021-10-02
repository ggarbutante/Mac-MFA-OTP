//
//  TOTPWindowController.h
//  MacOS-MFA
//
//  Created by garbutante on 2/28/21.
//

#import <Cocoa/Cocoa.h>
#include <Security/AuthorizationPlugin.h>   
#import <Foundation/Foundation.h>
#import "AuthorizationPlugin.h"
#import "MechanismHelper.h"

NS_ASSUME_NONNULL_BEGIN

//OSStatus initializePromptWindowController(AuthorizationMechanismRef inMechanism, BOOL isWarning);

OSStatus initializeTOTPWindowController(AuthorizationMechanismRef inMechanism, BOOL isWarning);

@interface TOTPWindowController : NSWindowController <NSWindowDelegate> {
    void *mMechanismRef;
}

- (void)setRef:(void *)ref;
- (void) awakeFromNib;

@property (nonatomic) BOOL isWarned;

@property (weak) IBOutlet NSTextField *otpLabel01;
@property (weak) IBOutlet NSTextField *totpAC01;

@property (weak) IBOutlet NSTextField *totpAC02;
@property (weak) IBOutlet NSTextField *totpAC03;
@property (weak) IBOutlet NSTextField *totpAC04;
@property (weak) IBOutlet NSTextField *totpAC05;

@property (weak) IBOutlet NSTextField *totpAC06;

@property (weak) IBOutlet NSButton *totpACSubmit;


- (IBAction)totpACSubmit:(NSButton *)sender;

@property (weak) IBOutlet NSButton *totpCancel;

- (IBAction)totpCancel:(id)sender;

/**
 *  This is the mechanism for the plugin. It makes the authorization
 *    decisions.
 *  Check for admin in the username.
 *  Stop the login if admin exists in the username.
 *
 *  @param authVerified AuthorizationMechanismRef
 *
 *  @return OSStatus
 */
OSStatus verifyTOTP(AuthorizationMechanismRef inMechanism, NSString* authVerified);

@end

NS_ASSUME_NONNULL_END
