import UIKit
import Alamofire

class ViewController: UIViewController, UINavigationControllerDelegate {
    var imageUrl: String?
    var imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func downloadLocally(_ sender: UIButton) {
        guard let imageUrl = urlTextField.text, !imageUrl.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Invalid URL")
            return
        }
        downloadImage(urltext: imageUrl)
        
    }
    
    @IBAction func PickImageButtonPressed(_ sender: UIButton) {
        pickImage()
        
    }
    @IBAction func viewButtonTapped(_ sender: UIButton) {
        guard let imageUrl = urlTextField.text, !imageUrl.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Invalid URL")
            return
        }
        viewImage(url: imageUrl)
    }

    // Function to handle text field changes
    
    

    func viewImage(url: String) {
        DispatchQueue.main.async {
            
            AF.download(url).responseData { response in
                if let data = response.value {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
  @objc  func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
           if let error = error {
               // we got back an error!
               let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
               ac.addAction(UIAlertAction(title: "OK", style: .default))
               present(ac, animated: true)
           } else {
               let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
               ac.addAction(UIAlertAction(title: "OK", style: .default))
               present(ac, animated: true)
           }
       }
    
    func downloadImage(urltext: String){
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("image.png")
            print("\(fileURL) ----->>>>>>>>>")

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download(urltext, to: destination).response { response in
            debugPrint(response)

            if let error = response.error {
                // Handle download error
                print("Download error: \(error)")
                return
            }

            if response.error == nil, let imagePath = response.fileURL?.path {
                let image = UIImage(contentsOfFile: imagePath)
                if let image = image {
                    // Image downloaded successfully
                    print("Image downloaded: \(image)")
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                } else {
                    // Unable to create image from downloaded file
                    print("Error: Unable to create image from downloaded file")
                }
            }
        }
    }
    

}


extension ViewController: UIImagePickerControllerDelegate {
    
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("Camera is not available")
            }
        }
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


