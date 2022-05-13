import UIKit
import AVFoundation

@available(iOS 11.0, *)
public class LivenessCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var borderView: UIView!
    @IBOutlet var poweredLabel: UILabel!
    @IBOutlet var testImage: UIImageView!
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var cameraTimer: Timer = Timer()
    var imageTaken: [UIImage] = []
    var allImageSize: CGFloat = 0
    let shape = CAShapeLayer()
    var progreeTaken: CGFloat = 0.0
    var counter: Int = 0
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
        cameraView.layer.masksToBounds = true
        cameraView.layer.cornerRadius = cameraView.frame.width / 2
        borderView.layer.masksToBounds = true
        borderView.layer.cornerRadius = borderView.frame.width / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: self.borderView.frame.size.width/2, y: self.borderView.frame.size.height/2),
                                radius: self.borderView.frame.size.height/2,
                                startAngle: -(CGFloat.pi / 2),
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        shape.path = path.cgPath
        shape.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        shape.lineWidth = 10
        shape.strokeColor = #colorLiteral(red: 0, green: 0.631372549, blue: 0.6078431373, alpha: 1)
        shape.strokeEnd = 0
        self.borderView.layer.addSublayer(shape)
        self.setTimer()
    }
    
    private func setTimer() {
        cameraTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(captureLiveness), userInfo: nil, repeats: true)
    }
    
    @objc func captureLiveness() {
        if imageTaken.count == 15 {
            for image in imageTaken {
                let imgData: NSData = image.jpegData(compressionQuality: 1.0) as! NSData;
                allImageSize += CGFloat(imgData.length)
                poweredLabel.text = "Total all taken picture : \(allImageSize)"
            }
            cameraTimer.invalidate()
        } else {
            if #available(iOS 10.0, *) {
                let photoSettings = AVCapturePhotoSettings()
                if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                    photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
                    sessionOutput.capturePhoto(with: photoSettings, delegate: self)
                }
            }
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)!
        counter += 1
        animateProgress(progress: counter)
        imageTaken.append(previewImage)
        testImage.image = previewImage
        poweredLabel.text = "Picture Captured \(imageTaken.count)"
    }
    
    private func animateProgress(progress: Int) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progreeTaken += 0.037
        basicAnimation.toValue =  progreeTaken
        shape.strokeEnd = progreeTaken
        basicAnimation.duration = 0.5
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shape.add(basicAnimation, forKey: "basicAnimation")
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

@available(iOS 11.0, *)
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
