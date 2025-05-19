import UIKit

class AddTransactionsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var creditDebtSegmentedControl: UISegmentedControl!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var transactionType: UIButton!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addButton: UIButton!
    
    var selectedContact: Contact?
    let transactionTypes = ["Fiş/Makbuz", "Pos", "Belge", "Havale/Transfer", "Çek/Senet", "Kredi Kartı", "Fatura", "Nakit", "EFT/Banka Havalesi"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTF.delegate = self
        descriptionTF.delegate = self
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateSegmentColor()
    }
    
    func updateSegmentColor() {
        let isDebt = creditDebtSegmentedControl.selectedSegmentIndex == 1
        let targetColor = isDebt ? UIColor.systemRed : UIColor.systemGreen

        UIView.animate(withDuration: 0.4) {
            self.creditDebtSegmentedControl.selectedSegmentTintColor = targetColor
        }
    }

    @IBAction func transactionTypeButtonTapped(_ sender: UIButton) {
        print("transactionType Button tapped")
        let alert = UIAlertController(title: "İşlem Tipi", message: nil, preferredStyle: .actionSheet)
        
        transactionTypes.forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default, handler: { [weak self] _ in
                self?.transactionType.setTitle(type, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        present(alert, animated: true)
    }

    
    
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        
        print("contact Button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContactSelectionViewController") as! ContactSelectionViewController
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        guard let amountText = amountTF.text,
              let amount = Decimal(string: amountText),
              let selectedContact = selectedContact else {
            showAlert(title: "Eksik Bilgi", message: "Lütfen tutar girin ve kişi seçin.")
            return
        }
        
        let transaction = Transaction(context: context)
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.descriptionText = descriptionTF.text ?? ""
        transaction.date = datePicker.date
        transaction.type = creditDebtSegmentedControl.selectedSegmentIndex == 0 ? "Alacak" : "Borç"
        transaction.contact = selectedContact
        let selectedTransactionKind = transactionType.title(for: .normal)
        transaction.transactionKind = selectedTransactionKind
        
        do {
            try context.save()
            showAlert(title: "Başarılı", message: "İşlem kaydedildi.")
            clearForm()
        } catch {
            showAlert(title: "Hata", message: "İşlem kaydedilemedi: \(error.localizedDescription)")
        }
    }

    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    func clearForm() {
        amountTF.text = ""
        descriptionTF.text = ""
        datePicker.date = Date()
        creditDebtSegmentedControl.selectedSegmentIndex = 0
        selectedContact = nil
        contactButton.setTitle("Kişi Seç", for: .normal)
        transactionType.setTitle("İşlem Tipi", for: .normal)
    }
}

extension AddTransactionsViewController: ContactSelectionDelegate {
    func didSelectContact(_ contact: Contact) {
        selectedContact = contact
        contactButton.setTitle(contact.name, for: .normal)
    }
}



