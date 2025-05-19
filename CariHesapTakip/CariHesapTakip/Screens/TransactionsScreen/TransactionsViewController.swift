import UIKit
import CoreData

final class TransactionsViewController: UIViewController {

    @IBOutlet weak var transactionListTableView: UITableView!
    var transactions: [Transaction] = []
    let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        transactionListTableView.delegate = self
        transactionListTableView.dataSource = self

        transactionListTableView.separatorColor = UIColor.systemGray5
        transactionListTableView.tableFooterView = UIView()

        refreshControl.tintColor = .systemGray
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        transactionListTableView.refreshControl = refreshControl

        applySoftGradientBackground()
        fetchTransactions()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTransactions()
    }
    
    
    @objc func refreshData() {
        fetchTransactions()
        refreshControl.endRefreshing()
    }
    
    func fetchTransactions() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            transactions = try context.fetch(request)
            transactionListTableView.reloadData()
        } catch {
            print("İşlemler alınamadı: \(error.localizedDescription)")
        }
        transactionListTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTransactionDetail",
           let destinationVC = segue.destination as? TransactionDetailViewController,
           let indexPath = sender as? IndexPath {
            destinationVC.transaction = transactions[indexPath.row]
        }
    }
    
    func applySoftGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.systemGray6.cgColor,
            UIColor.white.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactions.isEmpty {
            let emptyView = UIView(frame: tableView.bounds)

            let icon = UIImageView(image: UIImage(systemName: "tray"))
            icon.tintColor = .systemGray3
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = "Henüz işlem bulunamadı"
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

        return transactions.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)

        let amount = transaction.amount?.stringValue ?? "0"
        let contactName = transaction.contact?.name ?? "Kişi yok"
        let accountName = transaction.contact?.firm ?? "Cari Adı Yok"
        let type = transaction.type ?? "-"

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: transaction.date ?? Date())

        cell.textLabel?.text = "\(amount)₺ – \(type)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = type == "Borç" ? .systemRed : .systemGreen

        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "\(accountName) – \(contactName)\n\(dateString)"
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = .gray

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        return cell
    }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowTransactionDetail", sender: indexPath)
    }


    
}
