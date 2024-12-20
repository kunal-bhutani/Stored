
import UIKit
import FirebaseAuth

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HouseholdDelegate {
    
    // Reloads specific rows in the table view when user profile changes
    func nameChanged() {
        let indexPaths = [IndexPath(row: 1, section: 0), IndexPath(row: 1, section: 0)]
        accountTableView.reloadRows(at: indexPaths, with: .automatic)
    }

    var users: [User]?
    var profilePhoto: UIImage? {
        didSet {
            self.nameChanged()
        }
    }
    var profileName: String?
    var user: User?
    var accountNavigtionController: AccountNavigationController?
    var accountHouseholdViewController: AccountHouseholdViewController?

    // Data for the table view, organized by sections
//    let accountData: [Int: [String]] = [
//        0: ["", "Household"],
//        1: ["Manage Household", "Leave Houshold"],
//        2: ["Notifications", "Help", "Privacy Statement", "Tell a Friend"],
//        3: ["Log Out", "Delete Account"] // Added "Delete Account"
//    ]
    let accountData: [Int: [String]] = [
        0: ["", "Household"],
        1: ["Manage Household", "Leave Houshold"],
        2: ["Help", "Privacy Statement"],
        3: ["Log Out", "Delete Account"] // Added "Delete Account"
    ]

    // Returns the number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accountData[section]?.count ?? 0
    }

    // Configures the table view cell based on the section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
            guard let user = self.user else {
                return UITableViewCell()
            }
            
            // Set user image if available, or download it
            if let image = user.image {
                cell.userImage.image = image
                cell.userImage.contentMode = .scaleAspectFit
            } else {
                let path = "images/\(user.profilePictureFileName)"
                StorageManager.shared.downloadURL(for: path, completion: { result in
                    switch result {
                    case .success(let url):
                        self.downloadImage(from: url) { image in
                            if let image = image {
                                DispatchQueue.main.async {
                                    cell.userImage.image = image
                                    cell.userImage.contentMode = .scaleAspectFill
                                    user.image = image
                                }
                            }
                        }
                    case .failure:
                        print("Image not set")
                    }
                })
            }
            
            cell.userImage.layer.cornerRadius = 25
            cell.userName.text = "\(user.firstName)"
            cell.userNumber.text = "\(user.email)"
            return cell
        } else if indexPath.section == 0 && indexPath.row == 1 {
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountSmallTableViewCell", for: indexPath) as! AccountSmallTableViewCell
            cell.accessoryType = .none
            cell.accountSmallNameLabel.text = user?.household?.name
            return cell
        } else {
            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountSmallTableViewCell", for: indexPath) as! AccountSmallTableViewCell
            let titles = accountData[indexPath.section]!
            let title = titles[indexPath.row]
            
            if title == "Leave Houshold " {
                cell.accountSmallNameLabel.textColor = .red
                cell.accessoryType = .none
            } else if title == "Log Out" {
                cell.accountSmallNameLabel.textColor = .red
                cell.accessoryType = .none
                let tap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
                cell.addGestureRecognizer(tap)
                cell.accountSmallNameLabel.text = title
            } else if title == "Delete Account" {
                cell.accountSmallNameLabel.textColor = .red
                cell.accessoryType = .none
                let tap = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped))
                cell.addGestureRecognizer(tap)
                cell.accountSmallNameLabel.text = title
            } else {
                cell.accountSmallNameLabel.text = title
            }
            return cell
        }
    }

    // Downloads an image from a URL
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }

    // Handles row selection in the table view
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath == IndexPath(row: 0, section: 1) {
//            performSegue(withIdentifier: "HouseholdSegue", sender: indexPath)
//        }
//        if indexPath == IndexPath(row: 1, section: 1) {
//            let alertController = UIAlertController(title: "Leave this house?", message: "Are you sure you want to leave this household?", preferredStyle: .alert)
//            let leaveAction = UIAlertAction(title: "Leave", style: .default) { _ in
//                self.confirmLeaveHousehold()
//            }
//            leaveAction.setValue(UIColor.red, forKey: "titleTextColor")
//            alertController.addAction(leaveAction)
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            self.present(alertController, animated: true)
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }

    
//    __________________
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: 1) {
            performSegue(withIdentifier: "HouseholdSegue", sender: indexPath)
        }
        if indexPath == IndexPath(row: 1, section: 1) {
            let alertController = UIAlertController(title: "Leave this house?", message: "Are you sure you want to leave this household?", preferredStyle: .alert)
            let leaveAction = UIAlertAction(title: "Leave", style: .default) { _ in
                self.confirmLeaveHousehold()
            }
            leaveAction.setValue(UIColor.red, forKey: "titleTextColor")
            alertController.addAction(leaveAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
        } else if indexPath.section == 2 {
            let titles = accountData[indexPath.section]!
            let title = titles[indexPath.row]
            
            if title == "Help" {
                if let url = URL(string: "https://stored-website.vercel.app/") {
                    UIApplication.shared.open(url)
                }
            } else if title == "Privacy Statement" {
                if let url = URL(string: "https://www.freeprivacypolicy.com/live/4d859d0e-82b9-46df-bbdb-2a642739dd3c") {
                    UIApplication.shared.open(url)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
    
    
    // Confirms and processes household leaving
    func confirmLeaveHousehold() {
        DatabaseManager.shared.leaveHousehold(user: UserData.getInstance().user!) { success in
            if success {
                guard let joinOrCreateHouseholdViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinCreateVC") as? JoinOrCreateHouseholdViewController else {
                    return
                }
                joinOrCreateHouseholdViewController.user = UserData.getInstance().user!
                joinOrCreateHouseholdViewController.modalPresentationStyle = .fullScreen
                joinOrCreateHouseholdViewController.storedTabBarController = self.accountNavigtionController?.storedTabBarController
                self.present(joinOrCreateHouseholdViewController, animated: true)
            } else {
                print("Failed to leave household")
            }
        }
    }

    // Logs the user out
    func confirmLogout() {
        do {
            try Auth.auth().signOut()
            guard let loginNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationVC") as? LoginNavigationController else {
                return
            }
            loginNavigationViewController.modalPresentationStyle = .fullScreen
            present(loginNavigationViewController, animated: true)
            HouseholdData.getInstance().householdMembers = []
            UserData.getInstance().user = nil
            self.accountNavigtionController?.storedTabBarController?.selectedIndex = 0
        } catch {
            print("Error signing out: \(error)")
        }
    }

    @objc func logoutTapped() {
        let alertController = UIAlertController(title: "Log out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) { _ in
            self.confirmLogout()
        }
        logOutAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(logOutAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }

//    @objc func deleteAccountTapped() {
//        // Step 1: Show confirmation alert
//        let alertController = UIAlertController(title: "Delete Account?", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
//        
//        // Step 2: Add the "Delete" action to the alert
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
//            // Step 3: Ask user for their password to reauthenticate
//            self.askUserForPasswordAndDelete()
//        }
//        
//        // Step 4: Add the "Cancel" action to the alert
//        alertController.addAction(deleteAction)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the alert to the user
//        self.present(alertController, animated: true)
//    }
//
//    // Function to ask for the user's password
//    func askUserForPasswordAndDelete() {
//        let alertController = UIAlertController(title: "Reauthenticate", message: "Please enter your password to delete your account.", preferredStyle: .alert)
//        
//        // Add a password text field to the alert
//        alertController.addTextField { textField in
//            textField.isSecureTextEntry = true
//            textField.placeholder = "Password"
//        }
//        
//        // Add "Confirm" action to perform deletion
//        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
//            guard let password = alertController.textFields?.first?.text, !password.isEmpty else {
//                print("Password is empty.")
//                return
//            }
//            
//            // Step 5: Attempt to delete the user with the provided password
//            self.deleteUserWithPassword(password)
//        }
//        
//        // Add "Cancel" action
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        // Add actions to the alert
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//        
//        // Present the alert to the user
//        self.present(alertController, animated: true)
//    }
//
//    // Function to delete the user
//    func deleteUserWithPassword(_ password: String) {
//        guard let email = UserData.getInstance().user?.email else {
//            print("Email not found")
//            return
//        }
//
//        // Step 6: Reauthenticate the user before deletion
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { _,_ in [weak, self]; #error),_  in
//            if let error = error {
//                print("Reauthentication failed: \(error.localizedDescription)")
//                return
//            }
//            
//            // Step 7: Proceed to delete the user after successful reauthentication
//            DatabaseManager.shared.deleteUser(email: email) { success, message in
//                if success {
//                    print("User account deleted successfully.")
//                    self?.logoutTapped()
//                } else {
//                    if let errorMessage = message {
//                        print("Failed to delete user: \(errorMessage)")
//                    }
//                }
//            }
//        })
//    }

    
    
    
    @objc func deleteAccountTapped() {
        // Step 1: Show confirmation alert
        let alertController = UIAlertController(title: "Delete Account?", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        // Step 2: Add the "Delete" action to the alert
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Step 3: Ask user for their password to reauthenticate
            self.reauthenticateUserForDeletion()
        }
        
        // Step 4: Add the "Cancel" action to the alert
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert to the user
        self.present(alertController, animated: true)
    }

    // Function to prompt for user password and perform reauthentication for deletion
    func reauthenticateUserForDeletion() {
        guard let user = Auth.auth().currentUser else { return }
        let email = user.email ?? ""

        // Prompt for password using an alert
        let alert = UIAlertController(title: "Reauthenticate", message: "Please enter your password to delete your account.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let password = alert.textFields?.first?.text, !password.isEmpty else {
                print("Password is empty.")
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    print("Error reauthenticating user: \(error.localizedDescription)")
                } else {
                    // After reauthentication, delete the account
                    self.deleteUserAccount()
                }
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    // Function to delete the user account after reauthentication
    func deleteUserAccount() {
        guard let email = UserData.getInstance().user?.email else {
            print("Email not found")
            return
        }

        // Call deleteUser from your DatabaseManager to delete the user's account
        DatabaseManager.shared.deleteUser(email: email) { success, message in
            if success {
                print("User account deleted successfully.")
//                self.logoutTapped()// Call logout function after successful deletion
                self.confirmLogout()
                
            } else {
                if let errorMessage = message {
                    print("Failed to delete user: \(errorMessage)")
                }
            }
        }
    }

    
     // Replace with the email of the user you want to delete

   


//    func deleteAccount() {
//        guard let user = Auth.auth().currentUser else {
//            print("No user is currently logged in.")
//            return
//        }
//        user.delete { error in
//            if let error = error {
//                if let authError = error as NSError?, authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
//                    self.reauthenticateUser()
//                } else {
//                    print("Error deleting account: \(error.localizedDescription)")
//                }
//            } else {
//                print("User account deleted successfully.")
//                self.confirmLogout()
//            }
//        }
//    }
//
    
    
//    func reauthenticateUser() {
//        guard let user = Auth.auth().currentUser else { return }
//        let email = user.email ?? ""
//
//        // Prompt for password using an alert
//        let alert = UIAlertController(title: "Reauthenticate", message: "Please enter your password to delete your account.", preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "Password"
//            textField.isSecureTextEntry = true
//        }
//
//        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
//            guard let password = alert.textFields?.first?.text, !password.isEmpty else {
//                print("Password is empty.")
//                return
//            }
//
//            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//            user.reauthenticate(with: credential) { _, error in
//                if let error = error {
//                    print("Error reauthenticating user: \(error.localizedDescription)")
//                } else {
//                    self.deleteAccount()
//                }
//            }
//        }
//        alert.addAction(confirmAction)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(alert, animated: true)
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }

    @IBOutlet var accountTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        user = UserData.getInstance().user
        let household = UserData.getInstance().user?.household
        if let household = household {
            var filteredUsers: [User] = []
            for user in UserData.getInstance().users {
                if user.household?.name == household.name {
                    filteredUsers.append(user)
                }
            }
            users = filteredUsers
        }
        accountTableView.delegate = self
        accountTableView.dataSource = self
        accountTableView.isScrollEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        if profileName == nil || profilePhoto == nil {
            getUserData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HouseholdSegue" {
            if let destinationVC = segue.destination as? AccountHouseholdViewController {
                destinationVC.accountViewController = self
                self.accountHouseholdViewController = destinationVC
            }
        }
    }

    func getUserData() {
        guard let email = UserDefaults.standard.object(forKey: "email") as? String else {
            return
        }
        guard let name = UserDefaults.standard.object(forKey: "name") as? String else {
            return
        }
        self.profileName = name
        let safeEmail = StorageManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                self.downloadImage(from: url)
            case .failure(let error):
                print("Failed to get URL: \(error)")
            }
        })
    }

    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to download image")
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.profilePhoto = image
                self.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }.resume()
    }
}
