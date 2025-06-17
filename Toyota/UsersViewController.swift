//
//  UsersViewController.swift
//  Toyota
//
//  Created by Reynald Marquez-Gragasin on 5/27/25.
//
import PhotosUI
import UIKit
import CoreData
import PDFKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
    private let picker = UIImagePickerController()

    private var headingTitle = UILabel()
    private var imageView = UIView()
    private var pdfView:PDFView?
    private var pdfDocument:PDFDocument?

    var imagePdf = UIImageView()
    var imagePdfx = NSMutableData()
    var pdfImage = UIImage()
    var ln: Int = 1
    var filteredWords = [NSManagedObject]()
    private var indexno = 0
    private var item: String = ""
    let mode: [String] = ["ADD","UPDATE"]
    var modeText: String = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let addImage    = UIImage(systemName: "plus")
    let searchImage  = UIImage(systemName: "magnifyingglass")
    let printerImage  = UIImage(systemName: "printer.fill")

    var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var searchBar = UISearchBar()
    private var dataentryView = UIView()
    private var dataentryTitle = UILabel()
    private var closeIcon = UIImageView()
    private var idNo = UITextField()
    private var firstName = UITextField()
    private var lastName = UITextField()
    private var emailadd = UITextField()
    private var mobileno = UITextField()
    private var username = UITextField()
    private var password = UITextField()
    private var saveBtn = UIButton()
    private var pdfBody: String = ""
    private var pdf1: String = ""
    private var pdf2: String = ""
    private var pdf3: String = ""

    private var models = [UserEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllItems()
        view.addSubview(tableView)
        
        headingTitle = UILabel(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: 40))
        headingTitle.text = "   User's Core Data"
        headingTitle.textColor = .blue
        headingTitle.backgroundColor = UIColor.systemGray5
        headingTitle.font = UIFont(name: "Arial", size: 20)
        view.addSubview(headingTitle)
        
        //TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 110, width: view.frame.width, height: view.frame.height)
        
        //Navigation Bar
        let addButton   = UIBarButtonItem(image: addImage,  style: .plain, target: self, action: #selector(didTapAdd))
        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearch))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        //UISearchBar
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
    }
    
    @objc private func didTapAdd() {
        self.modeText = "ADD"
        dataentrySetup()
    }
    
    @objc func didTapPrinter() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let formattedDate = dateFormatter.string(from: Date())
        let dateNow = "As of \(formattedDate)"
        
        //CONCATIBATE HTML TAGS
        pdf1 = "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\">" +
            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
            "<title>User's Core Data Report</title></head><body><center>" +
            "<h3 style=\"margin-top:80px;\">User's Core Data Report</h3>" +
            "<h5 style=\"margin-top: -10px;\">\(dateNow)</h5>" +
            "<table style=\"margin-top: 50px;border-style:inset; border-width:thin\">" +
            "<thead style=\"background-color: lightgray;\"><tr>" +
            "<td style=\"width:50px;border-style:solid;border-width:thin\">#</th>" +
            "<td style=\"width:150px;border-style:solid;border-width:thin\">Firstname</th>" +
            "<td style=\"width:150px;border-style:solid;border-width:thin\">Lastname</th>" +
            "<td style=\"width:200px;border-style:solid;border-width:thin\">Email Address</th>" +
            "<td style=\"width:130px;border-style:solid;border-width:thin\">Mobile No.</th>" +
            "</tr></thead><tbody>"

        //LOOP DATA FROM MODELS
        for xresults in models {
            pdf2 += "<tr><td style=\"width: 50px;;border-style:solid;border-width:thin\" scope=\"row\">\(ln)</td>" +
                "<td style=\"width: 150px;border-style:solid;border-width:thin\">\(xresults.firstname!)</td>" +
                "<td style=\"width: 150px;border-style:solid;border-width:thin\">\(xresults.lastname!)</td>" +
                "<td style=\"width: 200px;border-style:solid;border-width:thin\">\(xresults.emailadd!)</td>" +
                "<td style=\"width: 130px;border-style:solid;border-width:thin\">\(xresults.mobileno!)</td></tr>"
            ln = ln + 1
        }
        
        pdf3 = "</tbody></table></center></body></html>"
        pdfBody = pdf1 + pdf2 + pdf3
        
        convertToPdfFileAndShare(textMessage: pdfBody )
    }
    
    @objc private func didTapSearch() {
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }
        
    func dataentrySetup() {
        switch modeText {
        case "ADD":
            self.modeText = ""
            self.modeText = mode[0]
        case "UPDATE":
            self.modeText = ""
            self.modeText = mode[1]
        default:
            break
        }
        
        dataentryView = UIView(frame: CGRect(x: 40, y: 100, width: 300, height: 500))
        dataentryView.backgroundColor = .blue
        dataentryView.clipsToBounds = true
        dataentryView.layer.cornerRadius = 20
        dataentryView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner
        view.addSubview(dataentryView)
        
        dataentryTitle.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        dataentryTitle.text = "  \(modeText) RECORD"
        dataentryTitle.backgroundColor = UIColor.black
        dataentryTitle.textColor = .white
        dataentryTitle.clipsToBounds = true
        dataentryTitle.layer.cornerRadius = 20
        dataentryTitle.textAlignment = .center
        dataentryTitle.font = UIFont(name: "arial", size: 18)
        dataentryTitle.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner
        dataentryView.addSubview(dataentryTitle)
        
        closeIcon.frame = CGRect(x: 260, y: 10, width: 30, height: 30)
        closeIcon.image = UIImage(systemName: "xmark.square")
        closeIcon.isUserInteractionEnabled = true
        closeIcon.tintColor = .white
        let closeGestureTapped = UITapGestureRecognizer(target: self, action: #selector(closeButton))
        closeIcon.addGestureRecognizer(closeGestureTapped)
        dataentryView.addSubview(closeIcon)
        
        idNo.frame = CGRect(x: 30, y: -160, width: 250, height: 30)
        idNo.backgroundColor = .yellow
        idNo.autocapitalizationType = .none
        idNo.placeholder = "idno"
        idNo.autocorrectionType = .no
        dataentryView.addSubview(idNo)
        
        
        firstName.frame = CGRect(x: 30, y: 100, width: 250, height: 40)
        firstName.backgroundColor = .white
        firstName.autocapitalizationType = .none
        firstName.autocorrectionType = .no
        firstName.placeholder = "enter your First Name"
        dataentryView.addSubview(firstName)
        
        lastName.frame = CGRect(x: 30, y: 150, width: 250, height: 40)
        lastName.backgroundColor = .white
        lastName.placeholder = "enter your Last Name"
        lastName.autocapitalizationType = .none
        lastName.autocorrectionType = .no
        dataentryView.addSubview(lastName)
        
        emailadd.frame = CGRect(x: 30, y: 200, width: 250, height: 40)
        emailadd.backgroundColor = .white
        emailadd.placeholder = "enter your Email Address"
        emailadd.autocapitalizationType = .none
        emailadd.autocorrectionType = .no
        dataentryView.addSubview(emailadd)
        
        mobileno.frame = CGRect(x: 30, y: 250, width: 250, height: 40)
        mobileno.backgroundColor = .white
        mobileno.placeholder = "enter your Mobile No."
        mobileno.autocapitalizationType = .none
        mobileno.autocorrectionType = .no
        dataentryView.addSubview(mobileno)
        
        username.frame = CGRect(x: 30, y: 300, width: 250, height: 40)
        username.backgroundColor = .white
        username.placeholder = "enter Username"
        username.autocapitalizationType = .none
        username.autocorrectionType = .no
        dataentryView.addSubview(username)
        
        password.frame = CGRect(x: 30, y: 350, width: 250, height: 40)
        password.backgroundColor = .white
        password.placeholder = "enter Password"
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        dataentryView.addSubview(password)
        
        saveBtn.frame = CGRect(x: 70, y: 400, width: 150, height: 40)
        saveBtn.setTitle(self.modeText, for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.backgroundColor = .purple
        saveBtn.layer.cornerRadius = 20
        saveBtn.clipsToBounds = true
        saveBtn.addTarget(self, action: #selector(addsaveButon), for: .touchUpInside)
        dataentryView.addSubview(saveBtn)
    }
    
    func getAllItems() {
        do {
            models = try context.fetch(UserEntity.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            //error
        }
    }
    
    func deleteItem(item: UserEntity) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            //error
        }
        
    }
    
    func updateItem(item: UserEntity, newUserid: String) {
        item.userid = newUserid
        do {
            try context.save()
        } catch {
            //error
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let name1 = model.firstname
        let spacer = " "
        let name2 = model.lastname
        let name = name1?.appending(spacer).appending(name2!)
        cell.textLabel?.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexno = indexPath.item
        self.modeText = "UPDATE"
        dataentrySetup()
        idNo.text = "\(models[indexPath.row].userid!)"
        firstName.text = models[indexPath.row].firstname
        lastName.text = models[indexPath.row].lastname
        emailadd.text = models[indexPath.row].emailadd
        mobileno.text = models[indexPath.row].mobileno
        username.text = models[indexPath.row].username
        password.text = models[indexPath.row].password
    }
    
    ///DELETE ITEM
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            models.remove(at: indexPath.row)
            deleteItem(item: models[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func addsaveButon() {
        findItem()
    }
    
    @objc func closeButton() {
        DispatchQueue.main.async {
            self.dataentryView.isHidden = true
        }
    }
    
    func clearText() {
        firstName.text = nil
        lastName.text = nil
        emailadd.text = nil
        mobileno.text = nil
        username.text = nil
        password.text = nil
    }
    
    func findItem() {
        let query:NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let key = idNo.text
        let predicate = NSPredicate(format: "userid contains[c] %@", key!)
        query.predicate = predicate
        let xuser: UserEntity
        
        let results = try? context.fetch(query)
        if results?.count == 0 {
            
            // INSERT
            let uuid = UUID().uuidString
            xuser = UserEntity(context: context)
            xuser.userid = "\(uuid)"
            xuser.firstname = firstName.text
            xuser.lastname = lastName.text
            xuser.emailadd = emailadd.text
            xuser.mobileno = mobileno.text
            xuser.username = username.text
            xuser.password = password.text
            xuser.createdAt = Date()
            do {
                try context.save()
                getAllItems()
                clearText()
                
            } catch {
                //error
            }
            
            return
        } else {
            // UPDATE
            xuser = (results?.first)!
        }
        
        xuser.firstname = firstName.text
        xuser.lastname = lastName.text
        xuser.emailadd = emailadd.text
        xuser.mobileno = mobileno.text
        xuser.username = username.text
        xuser.password = password.text
        xuser.updatedAt = Date()
        try? context.save()
        getAllItems()
    }
    
    func showSearchBarButton(shouldShow: Bool) {
        if shouldShow {
            let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearch))
            navigationItem.rightBarButtonItems = [ searchButton]
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func search(shouldShow: Bool) {
        showSearchBarButton(shouldShow: !shouldShow)
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
    }
}

extension UsersViewController: UISearchBarDelegate {
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
        navigationItem.rightBarButtonItems = nil
        let addButton   = UIBarButtonItem(image: addImage,  style: .plain, target: self, action: #selector(didTapAdd))
        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearch))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            models = fetchSearchData(key: searchText)
            self.tableView.reloadData()
        } else {
            getAllItems()
            self.tableView.reloadData()
        }
    }
    
    func fetchSearchData(key:String) -> [UserEntity] {
        var sData = [UserEntity]()
        let predicate = NSPredicate(format: "lastname contains[c] %@", key)
        let request:NSFetchRequest = UserEntity.fetchRequest()
        request.predicate = predicate
        do {
            sData = try (context.fetch(request))
        } catch {
            print("Error while fetching data.")
        }
        
        return sData
    }
    
    
    func convertToPdfFileAndShare(textMessage: String) {

        let heading = UIMarkupTextPrintFormatter(markupText: textMessage.uppercased())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(heading, startingAtPageAt: 0)

        let page = CGRect(x:0, y:0, width: 595.2, height: 841.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")

        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext();
                
        guard let outputUrl = try? FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output")
            .appendingPathExtension("pdf") else { fatalError("Destination URL not created.") }

        
        
        pdfData.write(to: outputUrl, atomically: true)
            print("Open \(outputUrl.path)")

        pdfImage = drawPDFfromURL(url: outputUrl)!

        //SAVE PDF AS IMAGE TO PHOTO LIBRARY
        UIImageWriteToSavedPhotosAlbum(pdfImage, nil, nil, nil)

            if FileManager.default.fileExists(atPath: outputUrl.path) {
                let url = URL(fileURLWithPath: outputUrl.path)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)


                let excludeActivities = [UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.message, UIActivity.ActivityType.mail,
                    UIActivity.ActivityType.print,
                    UIActivity.ActivityType.markupAsPDF,
                    UIActivity.ActivityType.copyToPasteboard,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.addToReadingList,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.airDrop,
                    UIActivity.ActivityType.postToTencentWeibo]

                    activityViewController.excludedActivityTypes = excludeActivities
                    activityViewController.popoverPresentationController?.sourceView = self.view

                    //if user on iPad
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                        }
                    }
                    present(activityViewController, animated: true, completion: nil)
            } else {
                print("Document was not found.")
            }
    }
            
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        return img
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard
              let url = urls.first,
              url.startAccessingSecurityScopedResource()
          else {
                  return
          }
          defer { url.stopAccessingSecurityScopedResource() }
            pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            pdfView?.autoScales = true
            self.view.addSubview(pdfView!)
            
            pdfDocument = PDFDocument(url: url)
            pdfView!.document = pdfDocument
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("testing.......")
        
        self.picker.dismiss(animated: true, completion: nil)
        guard let ximage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        imageView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imageView.backgroundColor = .red
        self.view.addSubview(imageView)
        
        imagePdf = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imagePdf.image = ximage
        self.imageView.addSubview(imagePdf)

    }

    func createPDFDataFromImage(image: UIImage) -> NSMutableData {
        let pdfData = NSMutableData()
        let imgView = UIImageView.init(image: image)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginPDFContextToData(pdfData, imageRect, nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        imgView.layer.render(in: context!)
        UIGraphicsEndPDFContext()

        //try saving in doc dir to confirm:
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = dir?.appendingPathComponent("file.pdf")

        do {
                try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
        } catch {
            print("error catched")
        }

        return pdfData
    }

    
    
}

