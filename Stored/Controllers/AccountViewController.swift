//
//
//import UIKit
//import FirebaseAuth
//
//class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, HouseholdDelegate {
//    func nameChanged() {
//        // indexPath of the row you want to reload
//        let indexPaths = [IndexPath(row: 1, section: 0), IndexPath(row: 1, section: 0)]
//        
//        accountTableView.reloadRows(at: indexPaths, with: .automatic)
//        
//    }
//    
//    var users : [User]?
//    var profilePhoto : UIImage?{
//        didSet{
//            print("profiiile")
//            self.nameChanged()
//        }
//    }
//    var profileName : String?
//    
//    var user : User?
//    
//    var accountNavigtionController : AccountNavigationController?
//    var accountHouseholdViewController : AccountHouseholdViewController?
//    
//    let accountData: [Int : [String]] = [0:["", "Household"], 1 : ["Manage Household", "Leave Houshold"], 2: ["Notifications", "Help", "Privacy Statement", "Tell a Friend"], 3: ["Log Out"]]
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        accountData[section]?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 && indexPath.row == 0 {
//            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
//            guard let user = self.user else {
//                return UITableViewCell()
//            }
//            if let image = user.image {
//                cell.userImage.image = image
//                cell.userImage.contentMode = .scaleAspectFit
//                print("Member image found")
//            }else{
//                let path = "images/\(user.profilePictureFileName)"
//                StorageManager.shared.downloadURL(for: path, completion: {result in
//                    switch result {
//                    case .success(let url) :
//                        self.downloadImage(from: url){ image in
//                            if let image = image {
//                                DispatchQueue.main.async {
//                                    cell.userImage.image = image
//                                    cell.userImage.contentMode = .scaleAspectFill
//                                    user.image = image
//                                    print("Member image set")
//                                }
//                                
//                            }
//                        }
//                    case .failure(let error) :
//                        print("image not set")
//                    }
//                })
//            }
//            cell.userImage.contentMode = .scaleAspectFill
//            cell.userImage.layer.cornerRadius = 25
//            cell.userName.text = "\(user.firstName)"
//            cell.userNumber.text = "\(user.email)"
//            
//            
//            return cell
//        }else if indexPath.section == 0 && indexPath.row == 1 {
//            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountSmallTableViewCell", for: indexPath) as! AccountSmallTableViewCell
//            cell.accessoryType = .none
//            cell.accountSmallNameLabel.text = user?.household?.name
//            
//            
//            return cell
//        }else{
//            let cell = accountTableView.dequeueReusableCell(withIdentifier: "AccountSmallTableViewCell", for: indexPath) as! AccountSmallTableViewCell
//            
//            let titles = accountData[indexPath.section]!
//            let title = titles[indexPath.row]
//            if indexPath.section == 0 && indexPath.row == 1 {
//                cell.accessoryType = .none
//                
//            }
//            if title == "Leave Houshold"{
//                cell.accountSmallNameLabel.textColor = .red
//                cell.accessoryType = .none
//                
//            }
//            
//            if title == "Log Out"{
//                cell.accountSmallNameLabel.textColor = .red
//                cell.accessoryType = .none
//                let tap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
//                cell.addGestureRecognizer(tap)
//                cell.accountSmallNameLabel.text = title
//                return cell
//            }
//            cell.accountSmallNameLabel.text = title
//            
//            
//            return cell
//        }
//    }
//    
//    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                print("Failed to download image:", error?.localizedDescription ?? "Unknown error")
//                completion(nil)
//                return
//            }
//            
//            let image = UIImage(data: data)
//            completion(image)
//        }.resume()
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath == IndexPath(row: 0, section: 1){
//            print(indexPath)
//            performSegue(withIdentifier: "HouseholdSegue", sender: indexPath)
//        }
//        
//        if indexPath == IndexPath(row: 1, section: 1) {
//            let alertController = UIAlertController(title: "Leave this house?", message: "Are you sure you want to leave this household?", preferredStyle: .alert)
//
//            // Log Out action
//            let logOutAction = UIAlertAction(title: "Leave", style: .default) { _ in
//                self.confirmLeaveHousehold()
//            }
//            // Customize Log Out button color to red
//            logOutAction.setValue(UIColor.red, forKey: "titleTextColor")
//            alertController.addAction(logOutAction)
//
//            // Cancel action
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            alertController.addAction(cancelAction)
//
//            // Present buttons side by side using a horizontal stack view
//            let subview = alertController.view.subviews.first! as UIView
//            let alertContentView = subview.subviews.first! as UIView
//            for constraint in alertContentView.constraints {
//                if constraint.description.contains("Width") {
//                    constraint.isActive = false
//                    NSLayoutConstraint(item: alertContentView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250).isActive = true
//                    break
//                }
//            }
//
//            self.present(alertController, animated: true, completion: nil)
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func confirmLeaveHousehold(){
//        DatabaseManager.shared.leaveHousehold(user: UserData.getInstance().user!) { success in
//            if success {
//                guard let joinOrCreateHouseholdViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinCreateVC") as? JoinOrCreateHouseholdViewController else {
//                    return
//                }
//                joinOrCreateHouseholdViewController.user = UserData.getInstance().user!
//                joinOrCreateHouseholdViewController.modalPresentationStyle = .fullScreen
//                joinOrCreateHouseholdViewController.storedTabBarController = self.accountNavigtionController?.storedTabBarController
//                
//                self.present(joinOrCreateHouseholdViewController, animated: true)
//            } else {
//                print("Failed to leave household")
//            }
//        }
//    }
//    
//    func confirmLogout(){
//        do {
//            try Auth.auth().signOut()
//            print("User logged out successfully")
//            guard let loginNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationVC") as? LoginNavigationController else {
//                return
//            }
//            print("prese")
//            loginNavigationViewController.modalPresentationStyle = .fullScreen
//            present(loginNavigationViewController, animated: true)
//            HouseholdData.getInstance().householdMembers = []
//            UserData.getInstance().user = nil
//            self.accountNavigtionController?.storedTabBarController?.selectedIndex = 0
//            // Perform any additional actions after logout, such as navigating to a different screen or updating UI
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//    }
//    
//    @objc func logoutTapped(){
//        
//        let alertController = UIAlertController(title: "Log out?", message: "Are you sure you want to log out?", preferredStyle: .alert)
//
//        // Log Out action
//        let logOutAction = UIAlertAction(title: "Log Out", style: .default) { _ in
//            self.confirmLogout()
//        }
//        // Customize Log Out button color to red
//        logOutAction.setValue(UIColor.red, forKey: "titleTextColor")
//        alertController.addAction(logOutAction)
//
//        // Cancel action
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//
//        // Present buttons side by side using a horizontal stack view
//        let subview = alertController.view.subviews.first! as UIView
//        let alertContentView = subview.subviews.first! as UIView
//        for constraint in alertContentView.constraints {
//            if constraint.description.contains("Width") {
//                constraint.isActive = false
//                NSLayoutConstraint(item: alertContentView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250).isActive = true
//                break
//            }
//        }
//
//        self.present(alertController, animated: true, completion: nil)
//
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        4
//    }
//    
//    
//    @IBOutlet var accountTableView: UITableView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        user = UserData.getInstance().user
//        let household = UserData.getInstance().user?.household
//        if let household = household {
//            var filteredUsers: [User] = []
//            for user in UserData.getInstance().users {
//                if user.household?.name == household.name {
//                    filteredUsers.append(user)
//                }
//            }
//            users = filteredUsers
//        }
//        accountTableView.delegate = self
//        accountTableView.dataSource = self
//        accountTableView.isScrollEnabled = false
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        if profileName == nil || profilePhoto == nil {
//            getUserData()
//        }
//    }
//    
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "HouseholdSegue" {
//            if let destinationVC = segue.destination as? AccountHouseholdViewController {
//                destinationVC.accountViewController = self
//                self.accountHouseholdViewController = destinationVC
//            }
//        }
//    }
//    
//    func getUserData(){
//        print("asasas")
//        guard let email = UserDefaults.standard.object(forKey: "email") as? String else {
//            return
//        }
//        guard let name = UserDefaults.standard.object(forKey: "name") as? String else {
//            return
//        }
//        self.profileName = name
//        print("reaaa")
//        let safeEmail = StorageManager.safeEmail(email: email)
//        let fileName = safeEmail + "_profile_picture.png"
//        let path = "images/" + fileName
//        
//        StorageManager.shared.downloadURL(for: path, completion: {result in
//            switch result {
//            case .success(let url) :
//                self.downloadImage(from: url)
//            case .failure(let error) :
//                print("Failed to get Url, Error : \(error)")
//            }
//        })
//    }
//    
//    func downloadImage(from url: URL){
//        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
//            guard let data = data, error == nil else {
//                print("Failed to download Image")
//                return
//            }
//            
//            let image = UIImage(data: data)
//            DispatchQueue.main.async {
//                self.profilePhoto = image
//                self.accountTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//            }
//        }).resume()
//    }
//    
//    
//}


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
    let accountData: [Int: [String]] = [
        0: ["", "Household"],
        1: ["Manage Household", "Leave Houshold"],
        2: ["Notifications", "Help", "Privacy Statement", "Tell a Friend"],
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
            
            if title == "Leave Houshold" {
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

    @objc func deleteAccountTapped() {
        let alertController = UIAlertController(title: "Delete Account?", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAccount()
        }
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently logged in.")
            return
        }
        user.delete { error in
            if let error = error {
                if let authError = error as NSError?, authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    self.reauthenticateUser()
                } else {
                    print("Error deleting account: \(error.localizedDescription)")
                }
            } else {
                print("User account deleted successfully.")
                self.confirmLogout()
            }
        }
    }

    func reauthenticateUser() {
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
                    self.deleteAccount()
                }
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

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
