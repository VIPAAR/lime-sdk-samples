#import <Foundation/Foundation.h>

/// ObjC UIKit sample call-start workflow.
///
/// 0 (default): `HLCallConfiguration` + `-[HLClient startCallWithConfiguration:]`
/// 1: legacy `-[HLClient startCall:withPresentingViewController:]`
///
/// Set to 1 in this target's build settings (`GCC_PREPROCESSOR_DEFINITIONS`) or
/// uncomment the line below to validate the ObjC facade compatibility path.
#ifndef SAMPLE_PRESENCE_USE_LEGACY_UIKIT_START_CALL
#define SAMPLE_PRESENCE_USE_LEGACY_UIKIT_START_CALL 0
#endif
