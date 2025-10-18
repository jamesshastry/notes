import UIKit
import PhotosUI

protocol NoteDetailDelegate: AnyObject {
    func didSaveNote()
}

class NoteDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private var existingNote: Note?
    weak var delegate: NoteDetailDelegate?
    private var selectedAttachments: [Data] = []
    private var selectedFileNames: [String] = []
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Note Title"
        textField.font = .systemFont(ofSize: 24, weight: .bold)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let attachFilesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📎 Attach Files", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let attachmentsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initializers
    
    init(note: Note? = nil) {
        self.existingNote = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        populateExistingNote()
        
        // Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(contentTextView)
        contentView.addSubview(attachFilesButton)
        contentView.addSubview(attachmentsLabel)
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            attachFilesButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20),
            attachFilesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            attachFilesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            attachFilesButton.heightAnchor.constraint(equalToConstant: 44),
            
            attachmentsLabel.topAnchor.constraint(equalTo: attachFilesButton.bottomAnchor, constant: 10),
            attachmentsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            attachmentsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            attachmentsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = existingNote == nil ? "New Note" : "Edit Note"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(handleCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(handleSave)
        )
    }
    
    private func setupActions() {
        attachFilesButton.addTarget(self, action: #selector(handleAttachFiles), for: .touchUpInside)
    }
    
    private func populateExistingNote() {
        guard let note = existingNote else { return }
        
        titleTextField.text = note.title
        contentTextView.text = note.content
        
        if let attachments = note.attachments, !attachments.isEmpty {
            attachmentsLabel.isHidden = false
            attachmentsLabel.text = "Attachments: \(attachments.map { $0.name }.joined(separator: ", "))"
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleSave() {
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            showError(message: "Please fill in both title and content")
            return
        }
        
        guard let userId = AuthService.shared.currentUserId else {
            showError(message: "User not authenticated")
            return
        }
        
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        Task {
            do {
                // Upload attachments if any
                var uploadedAttachments: [Attachment] = []
                
                for (index, fileData) in selectedAttachments.enumerated() {
                    let fileName = selectedFileNames[index]
                    let attachment = try await SupabaseService.shared.uploadFile(
                        data: fileData,
                        fileName: fileName,
                        userId: userId
                    )
                    uploadedAttachments.append(attachment)
                }
                
                // Create or update note
                if let existingNote = existingNote {
                    // Update existing note
                    var allAttachments = existingNote.attachments ?? []
                    allAttachments.append(contentsOf: uploadedAttachments)
                    
                    _ = try await SupabaseService.shared.updateNote(
                        id: existingNote.id,
                        title: title,
                        content: content,
                        attachments: allAttachments
                    )
                } else {
                    // Create new note
                    _ = try await SupabaseService.shared.createNote(
                        title: title,
                        content: content,
                        userId: userId,
                        attachments: uploadedAttachments
                    )
                }
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.delegate?.didSaveNote()
                    self.dismiss(animated: true)
                }
                
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.showError(message: "Failed to save note: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func handleAttachFiles() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate

extension NoteDetailViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            do {
                let fileData = try Data(contentsOf: url)
                selectedAttachments.append(fileData)
                selectedFileNames.append(url.lastPathComponent)
            } catch {
                print("❌ Failed to read file: \(error.localizedDescription)")
            }
        }
        
        if !selectedFileNames.isEmpty {
            attachmentsLabel.isHidden = false
            attachmentsLabel.text = "Selected files: \(selectedFileNames.joined(separator: ", "))"
        }
    }
}

