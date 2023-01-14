//
//  ViewController.swift
//  DetectURLLinksInText
//
//  Created by Salman Biljeek on 1/14/23.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITextViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        let textView: UITextView = {
            let textView = UITextView()
            textView.isSelectable = true
            textView.delegate = self
            textView.text = "This is a UITextView that contains a URL link: https://www.apple.com clicking the link will open the web page in safari."
            textView.font = .systemFont(ofSize: 18)
            textView.textColor = .label.withAlphaComponent(0.7)
            textView.textAlignment = .left
            textView.backgroundColor = .clear
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainer.lineBreakMode = .byTruncatingTail
            return textView
        }()
        
        textView.detectLinks()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if url.absoluteString.contains("url:") {
            let urlString = String(url.absoluteString.dropFirst(4))
            guard let url = URL(string: urlString) else { return false }
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)
            return true
        }
        return false
    }
}

extension UITextView {
    func detectLinks() {
        let nsText: NSString = self.text as NSString
        let nsTxt = nsText.replacingOccurrences(of: "\\n", with: " ")
        let nsString = nsTxt.replacingOccurrences(of: "\n", with: " ")
        let paragraphStyle = self.typingAttributes[NSAttributedString.Key.paragraphStyle] ?? NSMutableParagraphStyle()
        let attrs = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.font!.pointSize),
            NSAttributedString.Key.foregroundColor: self.textColor as Any
        ] as [NSAttributedString.Key : Any]
        let attrString = NSMutableAttributedString(string: nsText as String, attributes: attrs)
        
        let urlDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let urlMatches = urlDetector.matches(in: nsString, options: [], range: NSRange(location: 0, length: nsString.utf16.count))
        
        for match in urlMatches {
            guard let range = Range(match.range, in: nsString) else { continue }
            let url = nsString[range]
            let urlString = String(url)
            let matchRange: NSRange = NSRange(range, in: nsString)
            attrString.addAttribute(NSAttributedString.Key.link, value: "url:\(urlString)", range: matchRange)
            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: self.font!.pointSize), range: matchRange)
        }
        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.link
        ]
        self.linkTextAttributes = linkAttributes
        
        self.attributedText = attrString
    }
}

