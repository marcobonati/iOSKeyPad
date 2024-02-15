//
//  SystemSound.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 15/02/24.
//

import UIKit
import AudioToolbox

enum SystemSound: UInt32 {
    
    case inputClick = 1104
    case delete = 1155
    case modify = 1156
    
    static func playInputClick() {
        SystemSound.inputClick.play()
        //UIDevice.current.playInputClick()
    }
    
    func play() {
        //guard LocalStorage.getBool(for: SettingsKey.isInputClickSoundEnabled) else { return }
        AudioServicesPlaySystemSound(rawValue)
    }
}
