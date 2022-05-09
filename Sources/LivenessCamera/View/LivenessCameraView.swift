import UIKit
import AVFoundation

public class LivenessCameraViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    private lazy var shapeLayer: ProgressShapeLayer = {
        return ProgressShapeLayer(strokeColor: .green, lineWidth: 8.0)
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCamera()
        self.animateStroke()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.layer.masksToBounds = true
        cameraView.layer.cornerRadius = cameraView.frame.width / 2
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.cameraView.bounds.width, height: self.cameraView.bounds.height))
        shapeLayer.path = path.cgPath
    }
    
    func animateStroke() {
        let startAnimation = StrokeAnimation(type: .start, beginTime: 0.25, fromValue: 0.0, toValue: 0.6, duration: 0.45)
        let endAnimation = StrokeAnimation(type: .end, fromValue: 0.0, toValue: 0.6, duration: 0.75)
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 0.8
        strokeAnimationGroup.repeatDuration = .zero
        strokeAnimationGroup.animations = [startAnimation, endAnimation]
        
        shapeLayer.add(strokeAnimationGroup, forKey: nil)
        self.cameraView.layer.addSublayer(shapeLayer)
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
