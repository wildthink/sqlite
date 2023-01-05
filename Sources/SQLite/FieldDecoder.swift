import Foundation

public struct KeyInfo {
    var key: CodingKey
    var valueType: Any.Type
}

extension KeyInfo: CustomStringConvertible {
    public var description: String {
        "\(key.stringValue):\(valueType)(\(key.stringValue.snakeCased))"
    }
}

public class FieldsDecoder: Decoder {

    public var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    var keys: [String] = []
    var schema: [KeyInfo] = []

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KDC(self))
    }

    func report<T>(_ key: CodingKey, for type: T = T.self) {
        keys.append(key.stringValue)
        schema.append(.init(key: key, valueType: T.self))
    }

    struct KDC<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey] = []
        var allKeys: [Key] = []
        let decoder: FieldsDecoder

        init(_ decoder: FieldsDecoder) {
            self.decoder = decoder
        }

        func contains(_ key: Key) -> Bool {
            return true
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            decoder.report(key, for: Bool.self)

            return true
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            decoder.report(key, for: type)
            return false
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            decoder.report(key, for: type)
            return ""
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            decoder.report(key, for: type)
            return 0
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            decoder.report(key, for: type)
            return 0
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            decoder.report(key, for: type)
            return try T(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError()
        }

        func superDecoder() throws -> Decoder {
            fatalError()
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError()
        }
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return SVDC(self)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SVDC(self)
    }

    struct SVDC: SingleValueDecodingContainer {
        var codingPath: [CodingKey] = []

        func decodeNil() -> Bool {
            return true
        }

        func decode(_ type: Bool.Type) throws -> Bool {
            return false
        }

        func decode(_ type: String.Type) throws -> String {
            return ""
        }

        func decode(_ type: Double.Type) throws -> Double {
            return 0
        }

        func decode(_ type: Float.Type) throws -> Float {
            return 0
        }

        func decode(_ type: Int.Type) throws -> Int {
            return 0
        }

        func decode(_ type: Int8.Type) throws -> Int8 {
            return 0
        }

        func decode(_ type: Int16.Type) throws -> Int16 {
            return 0
        }

        func decode(_ type: Int32.Type) throws -> Int32 {
            return 0
        }

        func decode(_ type: Int64.Type) throws -> Int64 {
            return 0
        }

        func decode(_ type: UInt.Type) throws -> UInt {
            return 0
        }

        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return 0
        }

        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return 0
        }

        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return 0
        }

        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return 0
        }

        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T(from: decoder)
        }

        let decoder: FieldsDecoder
        init(_ decoder: FieldsDecoder) {
            self.decoder = decoder
        }
    }

}

extension FieldsDecoder.SVDC: UnkeyedDecodingContainer {
    var count: Int? {
        0
    }

    var isAtEnd: Bool {
        true
    }

    var currentIndex: Int {
        0
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    mutating func superDecoder() throws -> Decoder {
        fatalError()
    }


}

//
//  Postgres.swift
//  QueryGenerator
//
//  Created by Chris Eidhof on 14.08.18.
//  Copyright © 2018 Chris Eidhof. All rights reserved.
//

extension String {
    // todo attribution: copied from swift's standard library
    var snakeCased: String {
        guard !self.isEmpty else { return self }
        let stringKey = self // todo inline

        var words : [Range<String.Index>] = []
        // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
        //
        // myProperty -> my_property
        // myURLProperty -> my_url_property
        //
        // We assume, per Swift naming conventions, that the first character of the key is lowercase.
        var wordStart = stringKey.startIndex
        var searchRange = stringKey.index(after: wordStart)..<stringKey.endIndex

        // Find next uppercase character
        while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
            let untilUpperCase = wordStart..<upperCaseRange.lowerBound
            words.append(untilUpperCase)

            // Find next lowercase character
            searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
            guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                // There are no more lower case letters. Just end here.
                wordStart = searchRange.lowerBound
                break
            }

            // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
            let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                // The next character after capital is a lower case character and therefore not a word boundary.
                // Continue searching for the next upper case for the boundary.
                wordStart = upperCaseRange.lowerBound
            } else {
                // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                // Next word starts at the capital before the lowercase we just found
                wordStart = beforeLowerIndex
            }
            searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
        }
        words.append(wordStart..<searchRange.upperBound)
        let result = words.map({ (range) in
            return stringKey[range].lowercased()
        }).joined(separator: "_")
        return result
    }
}

