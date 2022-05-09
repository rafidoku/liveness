import UIKit
import AVFoundation

public class LivenessCameraViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
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
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.cameraView.frame.height - 2, width: self.cameraView.frame.width, height: 2)
        border.backgroundColor = UIColor.green.cgColor

        self.cameraView.layer.addSublayer(border)
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
