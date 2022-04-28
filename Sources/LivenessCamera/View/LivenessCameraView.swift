import UIKit
import AVFoundation

public class LivenessCameraViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices {
            if device.position == AVCaptureDevice.Position.front {
                do {
                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                    if captureSession.canAddInput(input) {
                        captureSession.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                        
                        if captureSession.canAddOutput(sessionOutput) {
                            captureSession.addOutput(sessionOutput)
                            captureSession.startRunning()
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                            cameraView.layer.addSublayer(previewLayer)
                            previewLayer.position= CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            previewLayer.bounds = cameraView.frame
                        }
                    }
                } catch let error {
                    print("error device ", error.localizedDescription)
                }
            }
        }
    }
    
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
