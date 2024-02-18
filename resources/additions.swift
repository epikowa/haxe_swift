extension StringProtocol {
  func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.lowerBound
  }
  func lastIndex<S: StringProtocol>(
    of string: S, options: String.CompareOptions = [String.CompareOptions.backwards]
  ) -> Index? {
    range(of: string, options: options)?.lowerBound
  }
  subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
  subscript(range: Range<Int>) -> SubSequence {
    let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
    return self[startIndex..<index(startIndex, offsetBy: range.count)]
  }
  subscript(range: ClosedRange<Int>) -> SubSequence {
    let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
    return self[startIndex..<index(startIndex, offsetBy: range.count)]
  }
  subscript(range: PartialRangeFrom<Int>) -> SubSequence {
    self[index(startIndex, offsetBy: range.lowerBound)...]
  }
  subscript(range: PartialRangeThrough<Int>) -> SubSequence {
    self[...index(startIndex, offsetBy: range.upperBound)]
  }
  subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
    self[..<index(startIndex, offsetBy: range.upperBound)]
  }

  var length: Int? { count }
}

extension StringProtocol {
  func toLowerCase() -> String {
    return self.lowercased()
  }

  func toUpperCase() -> String {
    return self.uppercased()
  }

  func charCodeAt(index: Int?) -> Int? {
    let hxChar = self.charAt(index: index)
    if hxChar == "" { return nil }
    let char = Character(hxChar!)
    return Int(char.asciiValue!)
  }

  func charAt(index: Int?) -> String? {
    if index! < 0 || index! > self.length! - 1 { return "" }
    return self.stringSlicing(startIndex: index, endIndex: index)
  }

  func lastIndexOf(str: String?, startIndex: Int? = nil) -> Int? {
    var startIndex = startIndex
    if str == "" {
      if startIndex == nil { startIndex = self.length! + 1 }
      return Swift.min(self.length!, startIndex!)
    }
    if startIndex == nil { startIndex = self.length! - 1 }
    if startIndex! > self.length! { startIndex = self.length! - 1 }
    if startIndex! < 0 { return -1 }

    let str2 = self.substring(startIndex: 0, endIndex: startIndex! + str!.length!)
    let index: Index? = str2!.lastIndex(of: str!)
    if index == nil { return -1 }
    return self.distance(from: str2!.startIndex, to: index!)
  }

  func indexOf(str: String?, startIndex: Int? = 0) -> Int? {
    if str! == "" { return Swift.min(0 + startIndex!, self.length!) }
    if startIndex! > self.length! - 1 { return -1 }
    if startIndex! < 0 { return -1 }

    let str2 = self.substring(startIndex: startIndex)
    let index = str2!.index(of: str!)
    if index == nil { return -1 }
    return self.distance(from: self.startIndex, to: index!) + startIndex!
  }

  func substring(startIndex: Int?, endIndex: Int? = nil) -> String? {
    var startIndex = startIndex
    var endIndex = endIndex

    if endIndex == nil {
      endIndex = self.length
    }
    if startIndex! < 0 { startIndex = 0 }
    if endIndex! < 0 { endIndex = 0 }
    if startIndex! > endIndex! {
      let tmp = startIndex
      startIndex = endIndex
      endIndex = tmp
    }
    if endIndex! > self.length! {
      endIndex! = self.length!
    }
    if startIndex! > self.length! - 1 { return "" }
    if startIndex! == endIndex! {
      return ""
    }

    return self.stringSlicing(startIndex: startIndex, endIndex: endIndex! - 1)
  }

  func stringSlicing(startIndex: Int?, endIndex: Int?) -> String? {
    let sub = self[startIndex!...endIndex!]
    return String(sub)
  }

  func substr(pos: Int?, len: Int? = nil) -> String? {
    var pos = pos
    var len = len

    if pos! < 0 {
      pos = self.length! + pos!
      if pos! < 0 {
        pos = 0
      }
    }

    if len == nil {
      len = self.length! - pos!
    }
    var endIndex: Int? = nil
    if pos! + len! > self.length! {
      len = self.length!
    }
    if len != nil {
      endIndex = pos! + len! + 1
    }

    if len == 0 {
      return ""
    }

    if len! < 0 {
      return String(self)
    }

    return self.substring(startIndex: pos, endIndex: endIndex! - 1)
  }

  func split(delimiter: String?) -> [String?]? {
    if delimiter! == "" {
      return Array(self).map({ c -> String? in String(c) })
    }
    return self.components(separatedBy: delimiter!)
  }
}

extension Array {
  var length: Int? { count }
}

class _hxHelpers {
  static func isOfType<T>(value:Optional<Any>, type:Optional<T.Type>) -> Bool {
        return value! is T?
  }

  static func isOfTypeEnum(value:Optional<Any>, type:String) -> Bool {
        let mirror = Mirror(reflecting: value!)
        let actual = mirror.descendant("enum")
        return "Enum<" + String(describing: actual) + ">" == type
  }
}
