
import UIKit
import Firebase
class iniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(user, error) in
            print("Intentamos Iniciar sesión")
            if error != nil {
                print("Tenemos el siguiente error: \(String(describing: error))")
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: {(user, error) in
                    print("Intentamos Crear un usuario")
                    if error != nil {
                        print("Tenemos el siguiente error: \(String(describing: error))")
                    } else {
                        Database.database().reference().child("usuarios").child(user!.uid).child("email").setValue(user!.email)
                        print("El usuario fue creado exitosamentes")
                        
                        self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                    }
                })
            } else {
                print("Inicio de sesion exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        })
        
    }
    
}

