import UIKit

final class ContactDetailViewController: UIViewController {
    
    var contact: Contact?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        applySoftGradientBackground()
        setupLabelsStyle()
        populateFields()
    }

    func populateFields() {
        guard let contact = contact else { return }

        nameLabel.attributedText = styledInfo(icon: "person.fill", title: "Kişi", value: contact.name ?? "-")
        accountNameLabel.attributedText = styledInfo(icon: "building.2.fill", title: "Cari Hesap", value: contact.firm ?? "-")
        phoneLabel.attributedText = styledInfo(icon: "phone.fill", title: "Telefon", value: contact.phone ?? "-")
        addressLabel.attributedText = styledInfo(icon: "mappin.and.ellipse", title: "Adres", value: contact.address ?? "-")
        descriptionLabel.attributedText = styledInfo(icon: "doc.text", title: "Açıklama", value: contact.descriptionText ?? "-")
    }
    
    func setupLabelsStyle() {
        [nameLabel, accountNameLabel, phoneLabel, addressLabel, descriptionLabel].forEach {
            $0?.numberOfLines = 0
            $0?.font = UIFont.systemFont(ofSize: 16)
            $0?.textColor = .label
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

}
