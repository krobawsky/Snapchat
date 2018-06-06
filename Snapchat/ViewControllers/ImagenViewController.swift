
import UIKit
import Firebase
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var grabarAudioBoton: UIButton!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    var audioID = NSUUID().uuidString
    var audioURLs : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imagenSeleccionada = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = imagenSeleccionada
        imageView.backgroundColor = UIColor.clear
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        elegirContactoBoton.isEnabled = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        elegirContactoBoton.isEnabled = false
        let imagesFolder = Storage.storage().reference().child("imagenes")
        let audiosFolder = Storage.storage().reference().child("audios")
        let imagenData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
        let audioData = NSData(contentsOf:audioURL!)! as Data
        
        imagesFolder.child("\(imagenID).jpg").putData(imagenData, metadata: nil, completion:{(metadata, error) in
            print("Intentando subir imagen")
            if error != nil {
                print("Ocurrió un error \(String(describing: error))")
            }
            else {
                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: metadata?.downloadURL()!.absoluteString)
            }
        })
        
        audiosFolder.child("\(audioID).m4a").putData(audioData, metadata: nil, completion:{(metadata, error) in
            print("Intentando subir audio")
            if error != nil {
                print("Ocurrió un error \(String(describing: error))")
            }
            else {
                self.audioURLs = (metadata?.downloadURL()!.absoluteString)!
                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: metadata?.downloadURL()!.absoluteString)
            }
        })
    }
    
    func setupRecorder(){
        do {
            // creando una sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // Creando una direccion para el archivo audio
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("******************************")
            print(audioURL!)
            print("******************************")
            
            // Crear opciones para el grabador de audio
            var settings : [String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            // Crear el objeto de grabaciones de audio
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
            
        } catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func grabarAudioTaped(_ sender: Any) {
        if audioRecorder!.isRecording{
            // Detener la grabacion
            audioRecorder?.stop()
            // Cambiar el texto del boton grabar
            grabarAudioBoton.setTitle("Audio grabado", for: .normal)
        } else {
            // Empieza a grabar
            audioRecorder?.record()
            // Cambiar le texto del boton detener
            grabarAudioBoton.setTitle("Stop", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.audioURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
        siguienteVC.audioID = audioID
    }
    
}
