#!/usr/bin/env python3
"""Generate SampleSwiftUI.xcodeproj for iOS and visionOS app targets."""

from __future__ import annotations

import pathlib
import uuid

ROOT = pathlib.Path(__file__).resolve().parent
PROJECT_NAME = "SampleSwiftUI"
PACKAGE_RELATIVE_PATH = "../../../VisionPro/vp_work/VisionProApp/HLSDK/Release/binary-spm/rendered-local/HLSDK"

SHARED_SOURCES = [
    "Shared/SampleSwiftUIApp.swift",
    "Shared/RootView.swift",
    "Shared/AuthView.swift",
    "Shared/SetupView.swift",
    "Shared/JoinView.swift",
    "Shared/DemoConfiguration.swift",
    "Shared/DemoSessionState.swift",
    "Shared/DemoFlowModel.swift",
    "Shared/DemoCallCoordinator.swift",
    "Shared/HLServerClient.swift",
    "Shared/FBLPromiseAsync.swift",
]

EXTENSION_SOURCES = [
    "Extensions/ScreenSharingExtension/SampleHandler.swift",
]


def uid() -> str:
    return uuid.uuid4().hex[:24].upper()


def pbx_file_ref(path: str, file_id: str) -> str:
    name = pathlib.Path(path).name
    quoted_name = f'"{name}"' if "+" in name or " " in name else name
    return (
        f"\t\t{file_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {quoted_name}; sourceTree = \"<group>\"; }};"
    )


def main() -> None:
    ids = {key: uid() for key in [
        "project", "mainGroup", "productsGroup", "sharedGroup", "extensionGroup", "iosGroup", "visionGroup",
        "iosApp", "visionApp", "iosExt", "visionExt",
        "iosAppProduct", "visionAppProduct", "iosExtProduct", "visionExtProduct",
        "packageRef", "iosPkgHLSDK", "iosPkgSwiftUI", "iosPkgScreenSharing",
        "visionPkgHLSDK", "visionPkgSwiftUI", "visionPkgScreenSharing",
        "iosExtPkgScreenSharing", "visionExtPkgScreenSharing",
        "iosSources", "visionSources", "iosExtSources", "visionExtSources",
        "iosFrameworks", "visionFrameworks", "iosExtFrameworks", "visionExtFrameworks",
        "iosEmbed", "visionEmbed", "iosConfigList", "visionConfigList", "iosExtConfigList", "visionExtConfigList",
        "projectConfigList", "iosDebug", "iosRelease", "visionDebug", "visionRelease",
        "iosExtDebug", "iosExtRelease", "visionExtDebug", "visionExtRelease",
        "projectDebug", "projectRelease",
        "iosEntitlements", "visionEntitlements", "extEntitlements", "extInfoPlist",
        "iosProxy", "visionProxy", "iosTargetDep", "visionTargetDep",
    ]}

    shared_file_ids = {path: uid() for path in SHARED_SOURCES}
    ext_file_ids = {path: uid() for path in EXTENSION_SOURCES}

    ios_embed_build = uid()
    vision_embed_build = uid()

    shared_build_ids = {path: uid() for path in SHARED_SOURCES}
    ios_ext_build_ids = {path: uid() for path in EXTENSION_SOURCES}
    vision_ext_build_ids = {path: uid() for path in EXTENSION_SOURCES}

    shared_file_refs = "\n".join(pbx_file_ref(p, shared_file_ids[p]) for p in SHARED_SOURCES)
    ext_file_refs = "\n".join(pbx_file_ref(p, ext_file_ids[p]) for p in EXTENSION_SOURCES)

    shared_children = "\n".join(f"\t\t\t\t{shared_file_ids[p]} /* {pathlib.Path(p).name} */," for p in SHARED_SOURCES)
    ext_children = "\n".join(f"\t\t\t\t{ext_file_ids[p]} /* {pathlib.Path(p).name} */," for p in EXTENSION_SOURCES)

    ios_shared_builds = "\n".join(
        f"\t\t{shared_build_ids[p]} /* {pathlib.Path(p).name} in Sources */ = {{isa = PBXBuildFile; fileRef = {shared_file_ids[p]} /* {pathlib.Path(p).name} */; }};"
        for p in SHARED_SOURCES
    )
    vision_shared_builds = ios_shared_builds

    ios_ext_builds = "\n".join(
        f"\t\t{ios_ext_build_ids[p]} /* {pathlib.Path(p).name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ext_file_ids[p]} /* {pathlib.Path(p).name} */; }};"
        for p in EXTENSION_SOURCES
    )
    vision_ext_builds = "\n".join(
        f"\t\t{vision_ext_build_ids[p]} /* {pathlib.Path(p).name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ext_file_ids[p]} /* {pathlib.Path(p).name} */; }};"
        for p in EXTENSION_SOURCES
    )

    ios_source_phase = "\n".join(
        f"\t\t\t\t{shared_build_ids[p]} /* {pathlib.Path(p).name} in Sources */," for p in SHARED_SOURCES
    )
    vision_source_phase = ios_source_phase

    ios_ext_source_phase = "\n".join(
        f"\t\t\t\t{ios_ext_build_ids[p]} /* {pathlib.Path(p).name} in Sources */," for p in EXTENSION_SOURCES
    )
    vision_ext_source_phase = "\n".join(
        f"\t\t\t\t{vision_ext_build_ids[p]} /* {pathlib.Path(p).name} in Sources */," for p in EXTENSION_SOURCES
    )

    content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 60;
\tobjects = {{

/* Begin PBXBuildFile section */
{ios_shared_builds}
{ios_ext_builds}
{vision_ext_builds}
\t\t{ios_embed_build} /* ScreenSharingExtension-iOS.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {ids['iosExtProduct']} /* ScreenSharingExtension-iOS.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
\t\t{vision_embed_build} /* ScreenSharingExtension-visionOS.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {ids['visionExtProduct']} /* ScreenSharingExtension-visionOS.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
\t\t{ids['iosProxy']} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {ids['project']} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {ids['iosExt']};
\t\t\tremoteInfo = "ScreenSharingExtension-iOS";
\t\t}};
\t\t{ids['visionProxy']} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {ids['project']} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {ids['visionExt']};
\t\t\tremoteInfo = "ScreenSharingExtension-visionOS";
\t\t}};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
\t\t{ids['iosEmbed']} /* Embed Foundation Extensions */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "";
\t\t\tdstSubfolderSpec = 13;
\t\t\tfiles = (
\t\t\t\t{ios_embed_build} /* ScreenSharingExtension-iOS.appex in Embed Foundation Extensions */,
\t\t\t);
\t\t\tname = "Embed Foundation Extensions";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['visionEmbed']} /* Embed Foundation Extensions */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "";
\t\t\tdstSubfolderSpec = 13;
\t\t\tfiles = (
\t\t\t\t{vision_embed_build} /* ScreenSharingExtension-visionOS.appex in Embed Foundation Extensions */,
\t\t\t);
\t\t\tname = "Embed Foundation Extensions";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
{shared_file_refs}
{ext_file_refs}
\t\t{ids['iosEntitlements']} /* SampleSwiftUI-iOS.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = "SampleSwiftUI-iOS.entitlements"; sourceTree = "<group>"; }};
\t\t{ids['visionEntitlements']} /* SampleSwiftUI-visionOS.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = "SampleSwiftUI-visionOS.entitlements"; sourceTree = "<group>"; }};
\t\t{ids['extEntitlements']} /* ScreenSharingExtension.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = ScreenSharingExtension.entitlements; sourceTree = "<group>"; }};
\t\t{ids['extInfoPlist']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
\t\t{ids['iosAppProduct']} /* SampleSwiftUI-iOS.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "SampleSwiftUI-iOS.app"; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{ids['visionAppProduct']} /* SampleSwiftUI-visionOS.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "SampleSwiftUI-visionOS.app"; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{ids['iosExtProduct']} /* ScreenSharingExtension-iOS.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = "ScreenSharingExtension-iOS.appex"; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{ids['visionExtProduct']} /* ScreenSharingExtension-visionOS.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = "ScreenSharingExtension-visionOS.appex"; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{ids['iosFrameworks']} /* Frameworks */ = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
\t\t{ids['visionFrameworks']} /* Frameworks */ = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
\t\t{ids['iosExtFrameworks']} /* Frameworks */ = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
\t\t{ids['visionExtFrameworks']} /* Frameworks */ = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{ids['sharedGroup']} /* Shared */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{shared_children}
\t\t\t);
\t\t\tpath = Shared;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['extensionGroup']} /* ScreenSharingExtension */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{ext_children}
\t\t\t\t{ids['extEntitlements']} /* ScreenSharingExtension.entitlements */,
\t\t\t\t{ids['extInfoPlist']} /* Info.plist */,
\t\t\t);
\t\t\tpath = Extensions/ScreenSharingExtension;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['iosGroup']} /* iOS */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{ids['iosEntitlements']} /* SampleSwiftUI-iOS.entitlements */,
\t\t\t);
\t\t\tpath = iOS;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['visionGroup']} /* visionOS */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{ids['visionEntitlements']} /* SampleSwiftUI-visionOS.entitlements */,
\t\t\t);
\t\t\tpath = visionOS;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['productsGroup']} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{ids['iosAppProduct']} /* SampleSwiftUI-iOS.app */,
\t\t\t\t{ids['visionAppProduct']} /* SampleSwiftUI-visionOS.app */,
\t\t\t\t{ids['iosExtProduct']} /* ScreenSharingExtension-iOS.appex */,
\t\t\t\t{ids['visionExtProduct']} /* ScreenSharingExtension-visionOS.appex */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{ids['mainGroup']} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{ids['sharedGroup']} /* Shared */,
\t\t\t\t{ids['extensionGroup']} /* ScreenSharingExtension */,
\t\t\t\t{ids['iosGroup']} /* iOS */,
\t\t\t\t{ids['visionGroup']} /* visionOS */,
\t\t\t\t{ids['productsGroup']} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{ids['iosApp']} /* SampleSwiftUI-iOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {ids['iosConfigList']} /* Build configuration list for PBXNativeTarget "SampleSwiftUI-iOS" */;
\t\t\tbuildPhases = (
\t\t\t\t{ids['iosSources']} /* Sources */,
\t\t\t\t{ids['iosFrameworks']} /* Frameworks */,
\t\t\t\t{ids['iosEmbed']} /* Embed Foundation Extensions */,
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = (
\t\t\t\t{ids['iosTargetDep']} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = "SampleSwiftUI-iOS";
\t\t\tpackageProductDependencies = (
\t\t\t\t{ids['iosPkgHLSDK']} /* HLSDK */,
\t\t\t\t{ids['iosPkgSwiftUI']} /* HLSDKSwiftUI */,
\t\t\t\t{ids['iosPkgScreenSharing']} /* HLSDKScreenSharing */,
\t\t\t);
\t\t\tproductName = "SampleSwiftUI-iOS";
\t\t\tproductReference = {ids['iosAppProduct']} /* SampleSwiftUI-iOS.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{ids['visionApp']} /* SampleSwiftUI-visionOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {ids['visionConfigList']} /* Build configuration list for PBXNativeTarget "SampleSwiftUI-visionOS" */;
\t\t\tbuildPhases = (
\t\t\t\t{ids['visionSources']} /* Sources */,
\t\t\t\t{ids['visionFrameworks']} /* Frameworks */,
\t\t\t\t{ids['visionEmbed']} /* Embed Foundation Extensions */,
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = (
\t\t\t\t{ids['visionTargetDep']} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = "SampleSwiftUI-visionOS";
\t\t\tpackageProductDependencies = (
\t\t\t\t{ids['visionPkgHLSDK']} /* HLSDK */,
\t\t\t\t{ids['visionPkgSwiftUI']} /* HLSDKSwiftUI */,
\t\t\t\t{ids['visionPkgScreenSharing']} /* HLSDKScreenSharing */,
\t\t\t);
\t\t\tproductName = "SampleSwiftUI-visionOS";
\t\t\tproductReference = {ids['visionAppProduct']} /* SampleSwiftUI-visionOS.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{ids['iosExt']} /* ScreenSharingExtension-iOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {ids['iosExtConfigList']} /* Build configuration list for PBXNativeTarget "ScreenSharingExtension-iOS" */;
\t\t\tbuildPhases = (
\t\t\t\t{ids['iosExtSources']} /* Sources */,
\t\t\t\t{ids['iosExtFrameworks']} /* Frameworks */,
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = ();
\t\t\tname = "ScreenSharingExtension-iOS";
\t\t\tpackageProductDependencies = (
\t\t\t\t{ids['iosExtPkgScreenSharing']} /* HLSDKScreenSharing */,
\t\t\t);
\t\t\tproductName = "ScreenSharingExtension-iOS";
\t\t\tproductReference = {ids['iosExtProduct']} /* ScreenSharingExtension-iOS.appex */;
\t\t\tproductType = "com.apple.product-type.app-extension";
\t\t}};
\t\t{ids['visionExt']} /* ScreenSharingExtension-visionOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {ids['visionExtConfigList']} /* Build configuration list for PBXNativeTarget "ScreenSharingExtension-visionOS" */;
\t\t\tbuildPhases = (
\t\t\t\t{ids['visionExtSources']} /* Sources */,
\t\t\t\t{ids['visionExtFrameworks']} /* Frameworks */,
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = ();
\t\t\tname = "ScreenSharingExtension-visionOS";
\t\t\tpackageProductDependencies = (
\t\t\t\t{ids['visionExtPkgScreenSharing']} /* HLSDKScreenSharing */,
\t\t\t);
\t\t\tproductName = "ScreenSharingExtension-visionOS";
\t\t\tproductReference = {ids['visionExtProduct']} /* ScreenSharingExtension-visionOS.appex */;
\t\t\tproductType = "com.apple.product-type.app-extension";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{ids['project']} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 2600;
\t\t\t\tLastUpgradeCheck = 2600;
\t\t\t}};
\t\t\tbuildConfigurationList = {ids['projectConfigList']} /* Build configuration list for PBXProject "{PROJECT_NAME}" */;
\t\t\tcompatibilityVersion = "Xcode 15.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (en, Base);
\t\t\tmainGroup = {ids['mainGroup']};
\t\t\tpackageReferences = (
\t\t\t\t{ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */,
\t\t\t);
\t\t\tproductRefGroup = {ids['productsGroup']} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{ids['iosApp']} /* SampleSwiftUI-iOS */,
\t\t\t\t{ids['visionApp']} /* SampleSwiftUI-visionOS */,
\t\t\t\t{ids['iosExt']} /* ScreenSharingExtension-iOS */,
\t\t\t\t{ids['visionExt']} /* ScreenSharingExtension-visionOS */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
\t\t{ids['iosSources']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{ios_source_phase}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['visionSources']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{vision_source_phase}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['iosExtSources']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{ios_ext_source_phase}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{ids['visionExtSources']} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{vision_ext_source_phase}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
\t\t{ids['iosTargetDep']} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {ids['iosExt']} /* ScreenSharingExtension-iOS */;
\t\t\ttargetProxy = {ids['iosProxy']} /* PBXContainerItemProxy */;
\t\t}};
\t\t{ids['visionTargetDep']} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {ids['visionExt']} /* ScreenSharingExtension-visionOS */;
\t\t\ttargetProxy = {ids['visionProxy']} /* PBXContainerItemProxy */;
\t\t}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\t{ids['projectDebug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['projectRelease']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{ids['iosDebug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "iOS/SampleSwiftUI-iOS.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = SampleSwiftUI;
\t\t\t\tINFOPLIST_KEY_NSCameraUsageDescription = "Camera access is required for Help Lightning video calls.";
\t\t\t\tINFOPLIST_KEY_NSMicrophoneUsageDescription = "Microphone access is required for Help Lightning video calls.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['iosRelease']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "iOS/SampleSwiftUI-iOS.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = SampleSwiftUI;
\t\t\t\tINFOPLIST_KEY_NSCameraUsageDescription = "Camera access is required for Help Lightning video calls.";
\t\t\t\tINFOPLIST_KEY_NSMicrophoneUsageDescription = "Microphone access is required for Help Lightning video calls.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{ids['visionDebug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "visionOS/SampleSwiftUI-visionOS.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = SampleSwiftUI;
\t\t\t\tINFOPLIST_KEY_NSCameraUsageDescription = "Camera access is required for Help Lightning video calls.";
\t\t\t\tINFOPLIST_KEY_NSMicrophoneUsageDescription = "Microphone access is required for Help Lightning video calls.";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = xros;
\t\t\t\tSUPPORTED_PLATFORMS = "xros xrsimulator";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 7;
\t\t\t\tXROS_DEPLOYMENT_TARGET = 2.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['visionRelease']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "visionOS/SampleSwiftUI-visionOS.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = SampleSwiftUI;
\t\t\t\tINFOPLIST_KEY_NSCameraUsageDescription = "Camera access is required for Help Lightning video calls.";
\t\t\t\tINFOPLIST_KEY_NSMicrophoneUsageDescription = "Microphone access is required for Help Lightning video calls.";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = xros;
\t\t\t\tSUPPORTED_PLATFORMS = "xros xrsimulator";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 7;
\t\t\t\tXROS_DEPLOYMENT_TARGET = 2.0;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{ids['iosExtDebug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Extensions/ScreenSharingExtension/ScreenSharingExtension.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Extensions/ScreenSharingExtension/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI.ScreenSharingExtension;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['iosExtRelease']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Extensions/ScreenSharingExtension/ScreenSharingExtension.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Extensions/ScreenSharingExtension/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI.ScreenSharingExtension;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{ids['visionExtDebug']} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Extensions/ScreenSharingExtension/ScreenSharingExtension.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Extensions/ScreenSharingExtension/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI.ScreenSharingExtension;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = xros;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSUPPORTED_PLATFORMS = "xros xrsimulator";
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tXROS_DEPLOYMENT_TARGET = 2.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{ids['visionExtRelease']} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = Extensions/ScreenSharingExtension/ScreenSharingExtension.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = Extensions/ScreenSharingExtension/Info.plist;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.helplightning.sdk.SampleSwiftUI.ScreenSharingExtension;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = xros;
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSUPPORTED_PLATFORMS = "xros xrsimulator";
\t\t\t\tSWIFT_VERSION = 6.0;
\t\t\t\tXROS_DEPLOYMENT_TARGET = 2.0;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{ids['projectConfigList']} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['projectDebug']} /* Debug */,
\t\t\t\t{ids['projectRelease']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{ids['iosConfigList']} /* Build configuration list for PBXNativeTarget "SampleSwiftUI-iOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['iosDebug']} /* Debug */,
\t\t\t\t{ids['iosRelease']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{ids['visionConfigList']} /* Build configuration list for PBXNativeTarget "SampleSwiftUI-visionOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['visionDebug']} /* Debug */,
\t\t\t\t{ids['visionRelease']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{ids['iosExtConfigList']} /* Build configuration list for PBXNativeTarget "ScreenSharingExtension-iOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['iosExtDebug']} /* Debug */,
\t\t\t\t{ids['iosExtRelease']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{ids['visionExtConfigList']} /* Build configuration list for PBXNativeTarget "ScreenSharingExtension-visionOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{ids['visionExtDebug']} /* Debug */,
\t\t\t\t{ids['visionExtRelease']} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
\t\t{ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */ = {{
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = "{PACKAGE_RELATIVE_PATH}";
\t\t}};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
\t\t{ids['iosPkgHLSDK']} /* HLSDK */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDK;
\t\t}};
\t\t{ids['iosPkgSwiftUI']} /* HLSDKSwiftUI */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDKSwiftUI;
\t\t}};
\t\t{ids['iosPkgScreenSharing']} /* HLSDKScreenSharing */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDKScreenSharing;
\t\t}};
\t\t{ids['visionPkgHLSDK']} /* HLSDK */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDK;
\t\t}};
\t\t{ids['visionPkgSwiftUI']} /* HLSDKSwiftUI */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDKSwiftUI;
\t\t}};
\t\t{ids['visionPkgScreenSharing']} /* HLSDKScreenSharing */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDKScreenSharing;
\t\t}};
\t\t{ids['iosExtPkgScreenSharing']} /* HLSDKScreenSharing */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDKScreenSharing;
\t\t}};
\t\t{ids['visionExtPkgScreenSharing']} /* HLSDKScreenSharing */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {ids['packageRef']} /* XCLocalSwiftPackageReference "HLSDK" */;
\t\t\tproductName = HLSDKScreenSharing;
\t\t}};
/* End XCSwiftPackageProductDependency section */
\t}};
\trootObject = {ids['project']} /* Project object */;
}}
"""

    project_dir = ROOT / f"{PROJECT_NAME}.xcodeproj"
    project_dir.mkdir(parents=True, exist_ok=True)
    (project_dir / "project.pbxproj").write_text(content)

    workspace_dir = project_dir / "project.xcworkspace"
    workspace_dir.mkdir(exist_ok=True)
    (workspace_dir / "contents.xcworkspacedata").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Workspace\n   version = "1.0">\n'
        f'   <FileRef\n      location = "self:">\n   </FileRef>\n'
        '</Workspace>\n'
    )

    schemes_dir = project_dir / "xcshareddata" / "xcschemes"
    schemes_dir.mkdir(parents=True, exist_ok=True)
    for target in ("SampleSwiftUI-iOS", "SampleSwiftUI-visionOS"):
        (schemes_dir / f"{target}.xcscheme").write_text(
            f"""<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Scheme LastUpgradeVersion=\"2600\" version=\"1.7\">
   <BuildAction parallelizeBuildables=\"YES\" buildImplicitDependencies=\"YES\">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting=\"YES\" buildForRunning=\"YES\" buildForProfiling=\"YES\" buildForArchiving=\"YES\" buildForAnalyzing=\"YES\">
            <BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"{ids['iosApp' if 'iOS' in target else 'visionApp']}\" BuildableName=\"{target}.app\" BlueprintName=\"{target}\" ReferencedContainer=\"container:SampleSwiftUI.xcodeproj\"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <LaunchAction buildConfiguration=\"Debug\" selectedDebuggerIdentifier=\"Xcode.DebuggerFoundation.Debugger.LLDB\" selectedLauncherIdentifier=\"Xcode.DebuggerFoundation.Launcher.LLDB\" launchStyle=\"0\" useCustomWorkingDirectory=\"NO\">
      <BuildableProductRunnable runnableDebuggingMode=\"0\">
         <BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"{ids['iosApp' if 'iOS' in target else 'visionApp']}\" BuildableName=\"{target}.app\" BlueprintName=\"{target}\" ReferencedContainer=\"container:SampleSwiftUI.xcodeproj\"/>
      </BuildableProductRunnable>
   </LaunchAction>
</Scheme>
"""
        )

    print(f"Wrote {project_dir / 'project.pbxproj'}")


if __name__ == "__main__":
    main()
