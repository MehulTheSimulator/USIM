//
//  RFIDInputHandler.swift
//  RFIDVideoPlayer
//
//  Created by Sagar Haval on 29/09/2022.
//

import Foundation
import AVKit

public protocol RFIDInputHandlerCallback {
    
    func handleValidInput(input: String)
}

public class RFIDInputManager {
    
    var provider: RFIDInputHandlerCallback?
    var callback: RFIDInputHandlerCallback?
    
    var currentInput = ""
    var currentTimer: Timer?
    
    var allowedCharacters: Set<Character> = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    let codeLength = 10
        
    func setCallback(_ callback: RFIDInputHandlerCallback) {
        self.callback = callback
    }
    
    func handleValidInput() {
        
        USIM.RemoteLog("HANDLE VALID INPUT!");
                
        USIM.RemoteLog("Our code is \(currentInput)")
        USIM.RemoteLog("Sending to callback \(callback)")
        
        callback?.handleValidInput(input: currentInput)
        
        currentInput = ""
    }
    
    @objc func onTimeOut() {
        
        resetInput()
    }
    
    func checkForValidInput() -> Bool {
        
        return currentInput.count > 0
    }
    
    func resetInput() {
        
        currentInput = ""
    }
    
    func lastInputTimer() {
        currentTimer?.invalidate()
        currentTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(RFIDInputManager.onTimeOut), userInfo: nil, repeats: false)
    }
    
    func handleInputEnd() {
        
        if(checkForValidInput()) {
            handleValidInput()
        }
        
        currentInput = ""
    }
    
    func handleInput(characters: String) -> Bool {
        
        var modifiedCharacters = characters
        modifiedCharacters.removeAll(where: {
            !allowedCharacters.contains($0)
        })
        //USIM.RemoteLog("HANDLE INPUT: \(modifiedCharacters)")
        currentInput += modifiedCharacters
        /*if(checkForValidInput()) {
            handleValidInput()
        } else {
        }*/
        lastInputTimer()
        
        return modifiedCharacters.count > 0
    }
    
    func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) -> Bool {
        
        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            var chars = key.charactersIgnoringModifiers
            //USIM.RemoteLog("Got chars: \"\(chars)\"")
            var containsNewline = false
            if(chars.contains("\r") || chars.contains("\n")) {
                containsNewline = true
                chars = chars.components(separatedBy: "\r")[0]
                chars = chars.components(separatedBy: "\n")[0]
                //USIM.RemoteLog("Chars after split: \"\(chars)\"")
            }
            if(handleInput(characters: chars)) {
                didHandleEvent = true
            }
            
            if(containsNewline) {
                handleInputEnd()
            }
        }
        
        return didHandleEvent;
    }
}

public let inputManager: RFIDInputManager = RFIDInputManager()
