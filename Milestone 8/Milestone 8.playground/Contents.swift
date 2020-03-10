import PlaygroundSupport
import UIKit


// Challenge 1: Extend UIView so that it has a bounceOut(duration:) method that uses animation to scale its size down to 0.0001
extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

class vc: UIViewController {
    let animateLabel: UILabel = {
        let label = UILabel()
        label.text = "ANIMATE"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Perform BounceOut", for: .normal)
        button.addTarget(self, action: #selector(performBounceOut), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [animateLabel, button].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            animateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: animateLabel.bottomAnchor, constant: 50)
        ])
    }
    
    @objc private func performBounceOut() {
        animateLabel.bounceOut(duration: 3)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.animateLabel.transform = CGAffineTransform.identity
        }
    }
}

PlaygroundPage.current.liveView = vc()


// Challenge 2: Extend Int with a times() method that runs a closure as many times as the number is high
extension Int {
    func times(_ closure: ()->Void) {
        guard self > 0 else { return }
        
        for _ in 0 ..< self {
            closure()
        }
    }
}

var counter1 = 0
5.times { counter1 += 1 }
assert(counter1 == 5)

var counter2 = -5
counter2.times { counter2 += 1 }
assert(counter2 == -5)



// Challenge 3: Extend Array so that it has a mutating remove(item:) method
extension Array where Element: Equatable {
    mutating func remove(item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}

var array1 = ["abc", "def", "ghi"]
array1.remove(item: "def")
assert(array1 == ["abc", "ghi"])

var array2 = ["abc", "def", "def", "ghi"]
array2.remove(item: "def")
assert(array2 == ["abc", "def", "ghi"])


var array3 = [String]()
array3.remove(item: "def")
assert(array3 == [])
