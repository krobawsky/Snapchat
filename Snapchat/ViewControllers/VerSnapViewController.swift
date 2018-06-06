
import UIKit
import Firebase
import SDWebImage

class VerSnapViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text? = snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imageURL))
    }

    override func viewWillDisappear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child(Auth.auth().currentUser!.uid).child("snaps").child(snap.id).removeValue()
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete{(error) in print("Se elimino la imagen correctamente")}
    }

}
