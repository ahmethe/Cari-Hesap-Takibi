import UIKit
import DGCharts
import CoreData

final class BalancesViewController: UIViewController {

    @IBOutlet weak var creditTableView: UITableView!
    @IBOutlet weak var debtTableView: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!

    let refreshControl = UIRefreshControl()

    var allTransactions: [Transaction] = []
    var creditTransactions: [Transaction] = []
    var debtTransactions: [Transaction] = []

    var contacts: [Contact] = []
    var selectedContact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()

        creditTableView.delegate = self
        creditTableView.dataSource = self
        creditTableView.separatorColor = UIColor.systemGray5
        debtTableView.delegate = self
        debtTableView.dataSource = self
        debtTableView.separatorColor = UIColor.systemGray5
        
        view.backgroundColor = .white
        creditTableView.backgroundColor = .white
        debtTableView.backgroundColor = .white
        pieChartView.backgroundColor = .white


        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .systemGray
        creditTableView.refreshControl = refreshControl
        debtTableView.refreshControl = refreshControl


        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]

        setupTitleButton()
        fetchContacts()
        fetchTransactionsByType()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchContacts()
        refreshData()
    }

    @objc func refreshData() {
        fetchTransactionsByType()
        creditTableView.reloadData()
        debtTableView.reloadData()
        setupPieChart()
        refreshControl.endRefreshing()
    }

    func setupTitleButton() {
        let titleButton = UIButton(type: .system)
        titleButton.setTitle("Tüm Hesaplar ▼", for: .normal)
        titleButton.setTitleColor(.label, for: .normal)
        titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        titleButton.titleLabel?.lineBreakMode = .byTruncatingMiddle
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.7
        titleButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleButton.addTarget(self, action: #selector(selectAccountTapped(_:)), for: .touchUpInside)
        navigationItem.titleView = titleButton
    }

    func updateTitleButtonText(_ text: String) {
        if let titleButton = navigationItem.titleView as? UIButton {
            titleButton.setTitle(text, for: .normal)
        }
    }

    @objc func selectAccountTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Cari Hesap Seç", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Tüm Hesaplar", style: .default, handler: { _ in
            self.selectedContact = nil
            self.updateTitleButtonText("Tüm Hesaplar ▼")
            self.filterTransactions()
        }))

        for contact in contacts {
            let title = contact.firm ?? contact.name ?? "Bilinmeyen"
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                self.selectedContact = contact
                self.updateTitleButtonText("\(title) ▼")
                self.filterTransactions()
            }))
        }

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    func fetchContacts() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            contacts = try context.fetch(request)
        } catch {
            print("Kişiler alınamadı: \(error.localizedDescription)")
        }
    }

    func fetchTransactionsByType() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            allTransactions = try context.fetch(request)
            filterTransactions()
        } catch {
            print("İşlemler alınamadı: \(error.localizedDescription)")
        }
    }

    func filterTransactions() {
        if let selected = selectedContact {
            creditTransactions = allTransactions.filter { $0.type == "Alacak" && $0.contact == selected }
            debtTransactions = allTransactions.filter { $0.type == "Borç" && $0.contact == selected }
        } else {
            creditTransactions = allTransactions.filter { $0.type == "Alacak" }
            debtTransactions = allTransactions.filter { $0.type == "Borç" }
        }

        creditTableView.reloadData()
        debtTableView.reloadData()
        setupPieChart()
    }

    func setupPieChart() {
        let (credit, debt) = calculateBalanceData()

        guard credit > 0 || debt > 0 else {
            pieChartView.data = nil
            pieChartView.centerText = "Veri yok"
            return
        }

        let entries: [PieChartDataEntry] = [
            PieChartDataEntry(value: credit, label: "Gelir"),
            PieChartDataEntry(value: debt, label: "Gider")
        ]

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor.systemGreen, UIColor.systemRed]
        dataSet.sliceSpace = 2
        dataSet.selectionShift = 8

        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(.black)
        data.setValueFont(UIFont.systemFont(ofSize: 13, weight: .semibold))

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₺"
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))

        pieChartView.data = data
        pieChartView.usePercentValuesEnabled = false
        pieChartView.drawHoleEnabled = true
        pieChartView.holeRadiusPercent = 0.5
        pieChartView.transparentCircleRadiusPercent = 0.55
        pieChartView.drawEntryLabelsEnabled = true
        pieChartView.entryLabelColor = .black
        pieChartView.entryLabelFont = UIFont.systemFont(ofSize: 12)
        pieChartView.legend.enabled = false // isteğe bağlı
        pieChartView.centerText = "Bakiye\n₺\(String(format: "%.2f", credit - debt))"
        pieChartView.centerTextRadiusPercent = 0.95
        pieChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }

    func calculateBalanceData() -> (credit: Double, debt: Double) {
        let creditTotal = creditTransactions.compactMap { $0.amount?.doubleValue }.reduce(0, +)
        let debtTotal = debtTransactions.compactMap { $0.amount?.doubleValue }.reduce(0, +)
        return (creditTotal, debtTotal)
    }
}

extension BalancesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = tableView == creditTableView ? creditTransactions.count : debtTransactions.count

        if count == 0 {
            let messageLabel = UILabel()
            messageLabel.text = "Henüz kayıt yok"
            messageLabel.textColor = .gray
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.italicSystemFont(ofSize: 14)
            tableView.backgroundView = messageLabel
        } else {
            tableView.backgroundView = nil
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction: Transaction = tableView == creditTableView
            ? creditTransactions[indexPath.row]
            : debtTransactions[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        let dateString = formatter.string(from: transaction.date ?? Date())
        let amount = transaction.amount?.stringValue ?? "0"
        let type = transaction.type ?? "-"
        let contactName = transaction.contact?.name ?? "Kişi yok"
        let accountName = transaction.contact?.firm ?? "Cari Adı Yok"

        cell.textLabel?.text = "\(type): \(amount)₺"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = .label

        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "\(contactName) – \(accountName)\n\(dateString)"
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = .gray
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
