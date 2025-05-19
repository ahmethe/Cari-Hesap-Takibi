import UIKit

class TransactionDetailViewController: UIViewController {
    var transaction: Transaction?

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var transactionKindLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
         applySoftGradientBackground()
         styleLabels()
         populateFields()
    }

    func populateFields() {
        guard let transaction = transaction else { return }

        amountLabel.attributedText = styledInfo(icon: "creditcard", title: "Tutar", value: "\(transaction.amount?.stringValue ?? "0") ₺")
        typeLabel.attributedText = styledInfo(icon: "arrow.left.arrow.right", title: "İşlem Tipi", value: transaction.type ?? "-")
        transactionKindLabel.attributedText = styledInfo(icon: "list.bullet.rectangle", title: "İşlem Türü", value: transaction.transactionKind ?? "-")
        contactLabel.attributedText = styledInfo(icon: "person.fill", title: "Kişi", value: transaction.contact?.name ?? "-")
        descriptionLabel.attributedText = styledInfo(icon: "doc.text", title: "Açıklama", value: transaction.descriptionText ?? "-")

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: transaction.date ?? Date())
        dateLabel.attributedText = styledInfo(icon: "calendar", title: "Tarih", value: dateString)
    }
    
    func styledInfo(icon: String, title: String, value: String) -> NSAttributedString {
        let symbol = UIImage(systemName: icon)?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))

        let attachment = NSTextAttachment()
        attachment.image = symbol
        attachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)

        let iconString = NSAttributedString(attachment: attachment)
        let titleString = NSAttributedString(string: " \(title): ", attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.systemGray
        ])
        let valueString = NSAttributedString(string: value, attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ])

        let combined = NSMutableAttributedString()
        combined.append(iconString)
        combined.append(titleString)
        combined.append(valueString)

        return combined
    }
    
    func styleLabels() {
        [amountLabel, typeLabel, transactionKindLabel, contactLabel, descriptionLabel, dateLabel].forEach {
            $0?.numberOfLines = 0
            $0?.textColor = .label
            $0?.font = UIFont.systemFont(ofSize: 16)
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
