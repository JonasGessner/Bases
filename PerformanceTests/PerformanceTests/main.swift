//
//  main.swift
//  PerformanceTests
//
//  Created by Matt Rubin on 4/26/16.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation
import Base32

func measureBlock(_ block: @noescape () -> ()) -> CFTimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    block()
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime - startTime
}

func measureEncoding(from data: NSData, to encodedString: String, using encodingFunction: NSData -> String, times: Int) -> CFTimeInterval {
    return measureBlock {
        for _ in 0..<times {
            let result = encodingFunction(data)
            assert(encodedString == result)
        }
    }
}

func compareEncoding(from data: NSData, to encodedString: String, times: Int) {
    let secDuration = measureEncoding(from: data, to: encodedString, using: secBase32Encode, times: times)
    print("Base duration: \(secDuration)")
    let duration = measureEncoding(from: data, to: encodedString, using: Base32.encode, times: times)
    print("  My duration: \(duration)")
    let previousBest = 0.199999356269836
    print("Previous best: \(previousBest)")
    let improvement = 1 - (duration / previousBest)
    print("Improvement: \(round(improvement*10000)/100)%")
    print("Now \(round((secDuration/duration)*100)/100) times as fast as the system baseline.")
}

func secBase32Encode(data: NSData) -> String {
    let encoder = SecEncodeTransformCreate(kSecBase32Encoding, nil)!
    SecTransformSetAttribute(encoder, kSecTransformInputAttributeName, data, nil);
    let encodedData = SecTransformExecute(encoder, nil) as! CFData
    return String(data: encodedData, encoding: NSASCIIStringEncoding)!
}

func fox(times: Int) -> String {
    let foxString = "The quick brown fox jumps over a lazy dog"
    var s = String()
    for _ in 1...times {
        s += foxString
    }
    return s
}

let fox1000 = fox(times: 1000)
let foxData = fox1000.data(using: NSASCIIStringEncoding)!
let foxResult = secBase32Encode(data: foxData)
let n = 1000
compareEncoding(from: foxData, to: foxResult, times: n)

/*
let c = 25
let avg = (0..<c).map({ _ in
    measureEncoding(from: foxData, to: foxResult, using: base32, times: n)
}).reduce(0) { (total, time) in
    total + time
} / Double(c)
print("avg: \(avg)")
*/