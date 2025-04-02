//
//  UnitViewDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.02.2025.
//

import Foundation
import CoreModule
import DesignSystem

protocol UnitViewDelegate<ID>: ListDelegate, ToolbarDelegate, MenuDelegate, DropDelegate, ViewDelegate { }
