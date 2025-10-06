//
//  BuildFlags.swift
//  Manifests
//
//  Created by Malik Timurkaev on 23.09.2025.
//

import ProjectDescription

public enum BuildFlags {
    public static let base: SettingsDictionary = [
        "SWIFT_VERSION": "6",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
        "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES"
    ]
}
