extension StringProtocol {
  func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.lowerBound
  }
  func lastIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
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
    let char = Character(hxChar!)
    return Int(char.asciiValue!)
  }

  func charAt(index: Int?) -> String? {
    return self.stringSlicing(startIndex: index, endIndex: index)
  }

  func lastIndexOf(str: String?, startIndex: Int? = 0) -> Int? {
    if startIndex! > self.length! { return -1 }
    if startIndex! < 0 { return -1 }

    let str2 = self.substring(startIndex: startIndex)
    let index = str2!.lastIndex(of: str!)
    if index == nil { return -1 }
    return self.distance(from: self.startIndex, to: index!) + startIndex!
  }

  func indexOf(str: String?, startIndex: Int? = 0) -> Int? {
    if startIndex! > self.length! { return -1 }
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
    if startIndex! > self.length! { return "" }

    return self.stringSlicing(startIndex: startIndex, endIndex: endIndex! - 1)
  }

  func stringSlicing(startIndex: Int?, endIndex: Int?) -> String? {
    let sub = self[startIndex!...endIndex!]
    return String(sub)
  }
}

extension Array {
  var length: Int? { count }
}
