@main
class _Main {
	static func main()->Void {
	IfTest.main()
	}
}

typealias HxEnumConstructor = (_hx_name: String, _hx_index: Int, enum: String, params: Array<Any>)
class HxError:Error {
				init(value:Any) {

				}
			}
			
			extension StringProtocol {
				subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
				subscript(range: Range<Int>) -> SubSequence {
					let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
					return self[startIndex..<index(startIndex, offsetBy: range.count)]
				}
				subscript(range: ClosedRange<Int>) -> SubSequence {
					let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
					return self[startIndex..<index(startIndex, offsetBy: range.count)]
				}
				subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
				subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
				subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
			}
			