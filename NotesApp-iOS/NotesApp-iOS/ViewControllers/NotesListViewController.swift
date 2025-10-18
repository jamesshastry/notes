import UIKit

class NotesListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var notes: [Note] = []
    private var userProfile: UserProfile?
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search notes..."
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No notes yet\nTap + to create your first note"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigationBar()
        loadUserProfile()
        loadNotes()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Notes"
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    private func setupNavigationBar() {
        // Add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddNote))
        
        // Profile button (shows premium status)
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(handleProfile))
        
        // Sign out button
        let signOutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        
        navigationItem.rightBarButtonItems = [addButton, profileButton]
        navigationItem.leftBarButtonItem = signOutButton
    }
    
    // MARK: - Data Loading
    
    private func loadUserProfile() {
        guard let userId = AuthService.shared.currentUserId else { return }
        
        Task {
            do {
                userProfile = try await SupabaseService.shared.fetchUserProfile(userId: userId)
                await MainActor.run {
                    updatePremiumStatus()
                }
            } catch {
                print("⚠️ Failed to load user profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadNotes() {
        guard let userId = AuthService.shared.currentUserId else { return }
        
        activityIndicator.startAnimating()
        
        Task {
            do {
                notes = try await SupabaseService.shared.fetchNotes(userId: userId)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.updateUI()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showError(message: "Failed to load notes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI() {
        emptyStateLabel.isHidden = !notes.isEmpty
        tableView.reloadData()
    }
    
    private func updatePremiumStatus() {
        guard let profile = userProfile else { return }
        
        if profile.isPremium {
            title = "Notes ⭐ Premium"
        } else {
            title = "Notes"
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleAddNote() {
        let noteDetailVC = NoteDetailViewController()
        noteDetailVC.delegate = self
        let navController = UINavigationController(rootViewController: noteDetailVC)
        present(navController, animated: true)
    }
    
    @objc private func handleProfile() {
        let isPremium = userProfile?.isPremium ?? false
        let message: String
        
        if isPremium {
            message = "You are a Premium user! ⭐"
        } else {
            message = "You are using the free version.\n\nUpgrade to Premium on the web app for additional features!"
        }
        
        let alert = UIAlertController(
            title: "Account Status",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func handleSignOut() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.signOut()
        })
        
        present(alert, animated: true)
    }
    
    private func signOut() {
        AuthService.shared.signOut { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self?.present(loginVC, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showError(message: "Sign out failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteNote(at indexPath: IndexPath) {
        let note = notes[indexPath.row]
        guard let userId = AuthService.shared.currentUserId else { return }
        
        activityIndicator.startAnimating()
        
        Task {
            do {
                try await SupabaseService.shared.deleteNote(id: note.id, userId: userId)
                
                await MainActor.run {
                    self.notes.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.activityIndicator.stopAnimating()
                    self.updateUI()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showError(message: "Failed to delete note: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension NotesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier, for: indexPath) as? NoteTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: notes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let note = notes[indexPath.row]
        let noteDetailVC = NoteDetailViewController(note: note)
        noteDetailVC.delegate = self
        let navController = UINavigationController(rootViewController: noteDetailVC)
        present(navController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteNote(at: indexPath)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UISearchBarDelegate

extension NotesListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: Implement search functionality
    }
}

// MARK: - NoteDetailDelegate

extension NotesListViewController: NoteDetailDelegate {
    func didSaveNote() {
        loadNotes()
    }
}

// MARK: - NoteTableViewCell

class NoteTableViewCell: UITableViewCell {
    
    static let identifier = "NoteTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with note: Note) {
        titleLabel.text = note.title
        contentLabel.text = note.content
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let date = ISO8601DateFormatter().date(from: note.createdAt) {
            dateLabel.text = "Created: \(dateFormatter.string(from: date))"
        } else {
            dateLabel.text = "Created: \(note.createdAt)"
        }
    }
}

