import UIKit
import AVFoundation

public class LivenessCameraViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var borderView: UIView!
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCamera()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.layer.masksToBounds = true
        cameraView.layer.cornerRadius = cameraView.frame.width / 2
        borderView.layer.masksToBounds = true
        borderView.layer.cornerRadius = borderView.frame.width / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: self.borderView.frame.size.width/2, y: self.borderView.frame.size.height/2),
                                radius: self.borderView.frame.size.height/2,
                                startAngle: CGFloat(270.0).toRadians(),
                                endAngle: CGFloat(10.0).toRadians(),
                                clockwise: true)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.6078431373, alpha: 1)
        shape.lineWidth = 10
        shape.strokeColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.6078431373, alpha: 1)
        self.borderView.layer.addSublayer(shape)
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        if #available(iOS 10.0, *) {
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
                print("Unable to access camera")
                return
            }
            do {
                let input = try AVCaptureDeviceInput(device: frontCamera)
                sessionOutput.isHighResolutionStillImageOutputEnabled = true
                if captureSession.canAddInput(input) && captureSession.canAddOutput(sessionOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(sessionOutput)
                    self.setuCameraPreview()
                }
            } catch let error {
                print("error unable to initialize front camera \(error.localizedDescription)")
            }
        }
    }
    
    private func setuCameraPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraView.layer.addSublayer(previewLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.previewLayer.frame = self.cameraView.bounds
            }
        }
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

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}
