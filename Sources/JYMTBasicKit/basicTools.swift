//
//  basicTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/21/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 User-friendly input
 */
public func input(name: String, type: String, defaultValue: Any? = nil, intRange:ClosedRange<Int>? = nil, doubleRange: ClosedRange<Double>? = nil, printAfterSec: Bool = false) -> String {
    let typeCode = type.lowercased()

    var pass = false
    var inputResult: String = ""
    
    while !pass {
        if defaultValue == nil {
            print("Please enter \(name): ", terminator: "")
        } else {
            print("Please enter \(name) [\(defaultValue!) by default]: ", terminator: "")
        }
        let response = readLine()
        var inputConverted: Any?
        guard let r: String = response else {
            fatalError("got nil response. Program exited.")
        }
        
        if defaultValue != nil && r.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            inputResult = String(describing: defaultValue!)
            break
        }
        
        switch typeCode {
        case "string":
            inputConverted = r
        case "int":
            inputConverted = Int(r)
        case "double":
            inputConverted = Double(r)
        default:
            inputConverted = r
        }
        
        if inputConverted == nil {
            pass = false
            print("Wrong format. Please try again.")
            continue
        } else {
            if doubleRange != nil && typeCode == "double" {
                guard let inputDouble = Double(String(describing: inputConverted!)), doubleRange!.contains(inputDouble) else {
                    pass = false
                    print("Out of range. Please try again.")
                    continue
                }
            } else if intRange != nil && typeCode == "int" {
                guard let inputInt = Int(String(describing: inputConverted!)), intRange!.contains(inputInt) else {
                    pass = false
                    print("Out of range. Please try again.")
                    continue
                }
            }
            pass = true
            inputResult = String(describing: inputConverted!)
        }
    }
    
    if printAfterSec {
        print("\(name) is set as \(inputResult).")
    }
    
    return inputResult
}

/**
 Returns the string of current time.
 */
public func timeNow() -> String {
    return displayTime(Date())
}

/**
 Returns the string discribing some time locally. *(More parameters to be added later)*
 */
public func displayTime(_ time: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    formatter.timeZone = TimeZone.current
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: time)
}

/**
 Returns a string with given total space `totSpace` filled by empty space after the given string `str`. If the length of the given string is larger than the given total space, it will directly return the string.
 
 - Parameter str: The string to be added empty space after.
 - Parameter totSpace: The total number of space (including the string itself) the string needed to be fitted in.
 
 */
public func stringWithSpace(_ str: String, _ totSpace: Int, trailing: Bool = true) -> String {
    guard totSpace >= str.count else {
        return str
    }
    if trailing {
        return str + String(repeating: "\u{0020}", count: totSpace - str.count)
    } else {
        return String(repeating: "\u{0020}", count: totSpace - str.count) + str
    }
}

/**
 The same as `stringWithSpace`, but it takes `Any` type as the input.
 */
public func toPrintWithSpace(_ item: Any, _ totSpace: Int, trailing: Bool = true) -> String {
    return stringWithSpace(String(describing: item), totSpace, trailing: trailing)
}

public extension String {
    func withSpace(_ totSpace: Int, trailing: Bool = true) -> String {
        return stringWithSpace(self, totSpace, trailing: trailing)
    }
}

/**
 To print string from the start of the console line.
 */
public func printStringInLine(_ str: String) {
    print(str, terminator: "\r")
    #if os(macOS)
    fflush(__stdoutp)
    #else
    fflush(stdout)
    #endif
}

/**
 The input for file/directory paths with a `tryAction` to determine the pass state of the inner loop.
*/
public func fileInput(name: String = "", message: String? = nil, successMessage: Bool = true, tryAction: (String) throws -> Bool) {
    var filePass = false
    var toPrint = ""
    if message != nil {
        toPrint = message!
    } else {
        toPrint = name + " path"
    }
    while !filePass {
        do {
            let filePath: String = input(name: toPrint, type: "string").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\", with: "")
            filePass = try tryAction(filePath)
            if successMessage && filePass {
                print("Successfully imported from \(name).")
            }
        } catch let error {
            print("Error:\n \(error).\n Please try again.")
        }
    }
}

/**
 Print the copyright information if the configuration is set to `release`.
 */

public func printWelcomeBanner(_ name: String) {
    #if DEBUG
    #else
    let year = Calendar.current.component(.year, from: Date())
    print()
    print("JYMoleculeTool - \(name)")
    print("Copyright © 2019-\(year) Jerry Yan. All rights reserved.")
    print()
    #endif
}

/**
 Create String in CSV format by giving the header and the array of dictionaries as data.
 */
public func createCSVString(header: [String], data: [Dictionary<String, AnyObject>], nilString: String = "N/A") -> String {
    var csvStr = header.joined(separator: ",") + "\n"
    for dict in data {
        csvStr += header.map({String(describing: dict[$0] ?? nilString as AnyObject)}).joined(separator: ",") + "\n"
    }
    return csvStr
}

/**
 Convert a timeinterval (Double) to a standard format string like "1421s".
 - NOTE: Converting to seconds only due to compatibility issues.
 */
public func timeIntervalToString(_ timeInterval: TimeInterval, allowedUnits: NSCalendar.Unit = [.day, .hour, .minute, .second], errorString: String = "N/A", maximumUnitCount: Int = 0) -> String {
//    let formatter = DateComponentsFormatter()
//    formatter.allowedUnits = allowedUnits
//    formatter.unitsStyle = unitsStyle
//    formatter.maximumUnitCount = maximumUnitCount
//    return formatter.string(from: timeInterval) ?? errorString
    return String(Int(timeInterval))
}

public extension String {
    /**
     Returns a string with self appended by the unix time.
     */
    func appendedUnixTime(_ time: Date = Date(), separator: String = "_") -> String {
        return self + separator + String(Int(time.timeIntervalSince1970))
    }
    
    /**
     Append the string with the unix time.
     */
    mutating func appendUnixTime(_ time: Date = Date(), separator: String = "_") {
        self = appendedUnixTime(time, separator: separator)
    }
}

public extension Double {
    /**
     Returns the string describing the double number with digits after decimal.
     */
    func srounded(digitsAfterDecimal: Int, option: String = "f") -> String {
        String(format: "%.\(digitsAfterDecimal)\(option)", self)
    }
}

public extension Array where Element == Double {
    /**
     Map the double array to a string array with each string describing the double element with digits after decimal.
     */
    func srounded(digitsAfterDecimal: Int, option: String = "f") -> [String] {
        self.map { String(format: "%.\(digitsAfterDecimal)\(option)", $0)}
    }
    
    /**
     Describes the `srounded(digitsAfterDecimal: Int, option: String)` as a standard array. (Mainly for printing)
     */
    func sroundedString(digitsAfterDecimal: Int, option: String = "f") -> String {
        "[" + srounded(digitsAfterDecimal: digitsAfterDecimal, option: option).joined(separator: ", ") + "]"
    }
}
