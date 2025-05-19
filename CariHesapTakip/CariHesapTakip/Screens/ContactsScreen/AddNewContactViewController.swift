import UIKit

final class AddNewContactViewController: UIViewController {

    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var firmTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func saveInformationButtonTapped(_ sender: UIButton) {
        guard
            let name = nameTF.text, !name.isEmpty,
            let firm = firmTF.text, !firm.isEmpty,
            let phone = phoneTF.text, !phone.isEmpty,
            let address = addressTF.text, !address.isEmpty,
            let description = descriptionTF.text, !description.isEmpty
        else {
            showAlert(title: "Eksik Bilgi", message: "Lütfen tüm alanları doldurun.")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let newContact = Contact(context: context)
        newContact.name = name
        newContact.firm = firm
        newContact.phone = phone
        newContact.address = address
        newContact.descriptionText = description

        do {
            try context.save()
            showAlert(title: "Başarılı", message: "Kişi başarıyla kaydedildi.")
            clearTextFields()
        } catch {
            showAlert(title: "Hata", message: "Kayıt sırasında bir hata oluştu.")
            print("Error saving contact: \(error.localizedDescription)")
        }
    }

    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    func clearTextFields() {
        nameTF.text = ""
        firmTF.text = ""
        phoneTF.text = ""
        addressTF.text = ""
        descriptionTF.text = ""
    }

    

}
