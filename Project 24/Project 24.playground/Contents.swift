import UIKit

extension String {
    // Challenge 1
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return self
        } else {
            return prefix + self
        }
    }
    
    // Challenge 2
    var isNumeric: Bool {
        return Double(self) == nil ? false : true
    }
    
    // Challenge 3
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

// Test for challenge 1
assert("test".withPrefix("te") == "test")
assert("pet".withPrefix("car") == "carpet")

// Test for challenge 2
assert("test".isNumeric == false)
assert("123".isNumeric == true)
assert("456.7".isNumeric == true)

// Test for challenge 3
assert("this\nis\na\ntest".lines == ["this", "is", "a", "test"])

