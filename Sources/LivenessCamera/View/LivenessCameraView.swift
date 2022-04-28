import UIKit
import AVFoundation

public class LivenessCameraViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let devices = AVCaptureDevice.devices(for: .video)
//        for device in devices {
//            if device.position == AVCaptureDevice.Position.front {
//                do {
//                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
//                    if captureSession.canAddInput(input) {
//                        captureSession.addInput(input)
//                        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
//
//                        if captureSession.canAddOutput(sessionOutput) {
//                            captureSession.addOutput(sessionOutput)
//                            captureSession.startRunning()
//                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//                            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//                            cameraView.layer.addSublayer(previewLayer)
//                            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
//                            previewLayer.bounds = cameraView.frame
//                        }
//                    }
//                } catch let error {
//                    print("error device ", error.localizedDescription)
//                }
//            }
//        }
        self.setupCamera()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        guard let frontCamera = AVCaptureDevice.default(for: AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.layer.masksToBounds = true
        cameraView.layer.cornerRadius = cameraView.frame.width / 2
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
