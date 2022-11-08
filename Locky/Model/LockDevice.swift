//
//  Lock.swift
//  Locky
//
//  Created by Shaolin Zhou on 2022/11/7.
//

import Foundation

/// the model is public, and it can be used beyond the module 'Locky'
public struct LockDevice {
    public var id: String = ""      // lock id
    public var name: String = ""    //lock name
    public var hasBLE = false       // hasBLE means the lock is discovered by bluetooth or not
}
