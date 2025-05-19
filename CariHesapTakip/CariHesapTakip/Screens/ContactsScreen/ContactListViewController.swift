import UIKit
import CoreData

final class ContactListViewController: UIViewController {
    
    @IBOutlet weak var contactListTableView: UITableView!
    let refreshControl = UIRefreshControl()

    var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        contactListTableView.dataSource = self
        contactListTableView.delegate = self
        contactListTableView.separatorColor = UIColor.systemGray5
        contactListTableView.tableFooterView = UIView()

        refreshControl.tintColor = .systemGray
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        contactListTableView.refreshControl = refreshControl
        
        fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchContacts()
    }

    @objc func refreshData() {
        fetchContacts()
        refreshControl.endRefreshing()
    }

    
    func fetchContacts() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        do {
            contacts = try context.fetch(fetchRequest)
            contactListTableView.reloadData()
        } catch {
            print("Kişiler yüklenemedi: \(error.localizedDescription)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowContactDetail",
           let destination = segue.destination as? ContactDetailViewController,
           let indexPath = sender as? IndexPath {
            destination.contact = contacts[indexPath.row]
        }
    }

    
}

extension ContactListViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contacts.isEmpty {
            let emptyView = UIView(frame: tableView.bounds)

            let icon = UIImageView(image: UIImage(systemName: "person.crop.circle.badge.exclamationmark"))
            icon.tintColor = .systemGray3
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = "Kayıtlı kişi bulunamadı"
            label.textAlignment = .center
            label.textColor = .systemGray
            label.font = UIFont.italicSystemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false

            emptyView.addSubview(icon)
            emptyView.addSubview(label)

            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -10),
                icon.widthAnchor.constraint(equalToConstant: 40),
                icon.heightAnchor.constraint(equalToConstant: 40),

                label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 8),
                label.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
            ])

            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }

        return contacts.count
    }


    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        cell.textLabel?.text = contact.name ?? "-"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        cell.detailTextLabel?.text = contact.firm ?? contact.phone ?? "-"
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowContactDetail", sender: indexPath)
    }

}

