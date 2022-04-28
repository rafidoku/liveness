import UIKit

public class LivenessCameraViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}

public class LivenessCameraView {
    var rootViewController: UIViewController?
    
    public init(rootVC: UIViewController) {
        self.rootViewController = rootVC
    }
    
    public func loadLivenessCamera() {
        if let viewStoryboard = UIStoryboard(name: "LivenessCameraStoryboard", bundle: Bundle.module).instantiateInitialViewController() as? LivenessCameraViewController {
            viewStoryboard.modalPresentationStyle = .fullScreen
            self.rootViewController?.present(viewStoryboard, animated: true, completion: nil)
        }
    }
}
