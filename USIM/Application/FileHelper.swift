//
//  FileHelper.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class FileHelper {
    
    public static func getLocalDirectory() -> URL {
        
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public static func getLocalDirectory(_ subDirectoryName: String) -> URL {
        
        return subDirectory(getLocalDirectory(), subDirectoryName)
    }
    
    public static func getLocalFile(_ fileName: String) -> URL {
        
        return file(getLocalDirectory(), fileName)
    }
    
    public static func subDirectory(_ directoryURL: URL, _ subDirectoryName: String) -> URL {
        
        return directoryURL.appendingPathComponent(subDirectoryName, isDirectory: true)
    }
    
    public static func file(_ directoryURL: URL, _ fileName: String) -> URL {
        
        return directoryURL.appendingPathComponent(fileName, isDirectory: false)
    }
    
    public static func mkdirs(_ directoryURL: URL) throws {
        
        if(!FileManager.default.fileExists(atPath: directoryURL.path)) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
    
    public static func clearDirectory(_ directoryURL: URL) throws {
        let files = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [])
        for file in files {
            try FileManager.default.removeItem(at: file)
        }
    }
    
    public static func moveFile(_ from: URL, _ to: URL, overwriteExisting: Bool = true) throws {
        if(FileManager.default.fileExists(atPath: to.path)) {
            if(overwriteExisting) {
                try FileManager.default.removeItem(at: to)
            } else {
             //   throw RuntimeError.runtimeError("File already exists!")
                throw RuntimeError(message: "File already exists!")
            }
        }
        
        try FileManager.default.moveItem(at: from, to: to)
    }
    
    public static func tryReadUTF8(_ fileURL: URL) -> String? {

        do {
            return try readUTF8(fileURL)
        } catch let error {
            RemoteLog("Unabled to write to \"\(fileURL)\": \(error)")
            return nil
        }
    }
    
    public static func tryWriteUTF8(_ fileURL: URL, _ string: String) -> Bool {
        
        do {
            try writeUTF8(fileURL, string)
            return true
        } catch let error {
            RemoteLog("Unabled to write to \"\(fileURL)\": \(error)")
            return false
        }
    }
    
    public static func readUTF8(_ fileURL: URL) throws -> String {

        return try String(contentsOf: fileURL, encoding: .utf8)
    }
    
    public static func writeUTF8(_ fileURL: URL, _ string: String) throws {
        
        try string.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    public static func writeData(_ fileURL: URL, _ data: Data) throws {
        
        try data.write(to: fileURL)
    }
}
