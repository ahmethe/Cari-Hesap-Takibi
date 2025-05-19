import UIKit
import CoreData

protocol ContactSelectionDelegate: AnyObject {
    func didSelectContact(_ contact: Contact)
}


final class ContactSelectionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var contacts: [Contact] = []
    weak var delegate: ContactSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        tableView.dataSource = self
        tableView.delegate = self
        fetchContacts()
    }
    
    func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
    
    func fetchContacts() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            contacts = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Kişiler alınamadı: \(error)")
        }
    }
}

extension ContactSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)

        cell.textLabel?.text = contact.name ?? "-"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        cell.detailTextLabel?.text = contact.firm ?? contact.phone ?? "-"
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = .gray

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = contacts[indexPath.row]
        delegate?.didSelectContact(selected)
        dismiss(animated: true)
    }
}
