
import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate,
     UIImagePickerControllerDelegate {

    private var imagePicker = UIImagePickerController()
    
    // this class represents the google model. we are creting a property called var model
    // we are going to initilaize it(var model) with googlenetplaces()
    private var model = GoogLeNetPlaces()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    
    }
    //  
    // func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
    //    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any] ) {
        dismiss(animated: true, completion: nil)
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
        }
        
        self.photoImageView.image = pickedImage
        
        //processing the image into another function. we made up the name processImage(image :)
        // we are passing in the image the user has picked "pickedImage" from the photo library
        processImage(image :pickedImage)
    }
    // here is where we start implementing the image. Image type is UIImage
    private func processImage(image :UIImage) {
                // this will take in a CGI image and not a UIImage- so we are converting from UIImage to CGimage
                // we are passing in the image, and if for some reason it is unable to convert, then if it fails to convert we will throw in the error message
                guard let ciImage = CIImage(image :image) else {
                    fatalError("Unable to create the climate object")
                }
                
            // we are creating a vision model. that vision model will be passed to the vision API
            // so that it can further pass along to the CoreML model.
            // we are calling in the "mode" in line 18 GoogleNetPlaces. i think visionModel here was created by us
            // we have to use they try? keyword because this can actually blow up? lol
                guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
                fatalError("unable to create vision model")
            }
            // we are passing in visionModel.
            // and its going to give us a completion block of request and error
            let visionRequest = VNCoreMLRequest(model: visionModel) { request,
                error in
                //doing something with the results
                if error != nil {
                    return
                }
                // if there is no error then we can move forward. now give me the results
                //this is the model telling you "im 90% sure this is a volcanoe"
                // we are doing casting here with as?
                guard let results = request.results as? [VNClassificationObservation]
                    else {
                        return
                }
                // map means going over each item. inside the results, each item will be called obervations.
                let classifications = results.map { observation in
                    "\(observation.identifier) \(observation.confidence * 100)"
                }
                // this is how we are going to display the results in the text view
                // lets go on the main thread and assign it. classification is an array
                DispatchQueue.main.async {
                    //desctiptionTextView is the name of the connection to the text box on ur UI
                    self.descriptionTextView.text = classifications.joined(separator: "\n")
                }
                
              }
                // we need to create a visionrequesthandler which is going to execute the rquest
                // make sure you are referencing the image and not the class CIImage
                let visionRequestHandler = VNImageRequestHandler(ciImage: ciImage,
                    orientation: .up, options: [:])
                //the final thing is to invoke the request. qos is quality of service on the main thread
                //the request is in a seperate Queue. And we actually perform the actual request
                //we are passing in visionRequest in an array. below we are invoking the vision request handler
        DispatchQueue.global(qos: .userInteractive).async {
            // we declared visionRequest earlier in line 59
            try! visionRequestHandler.perform([visionRequest])
        }
    }
    @IBAction func openPhotoLibraryButtonPressed(_ sender: Any) {
        
        self.present(self.imagePicker,animated: true, completion: nil)
    }
}

