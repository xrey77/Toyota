//
//  ViewController.swift
//  Toyota
//
//  Created by Reynald Marquez-Gragasin on 5/26/25.
//

import CoreGraphics
import PhotosUI
import UIKit
import PDFKit
import UniformTypeIdentifiers
import MobileCoreServices

let supportedTypes: [UTType] = [UTType.pdf]

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = UIColor.black
        return sv
    }()
        
    private var bodyView: UIView = {
        let v = UIScrollView()
        return v
    }()

    
    private let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
    private let picker = UIImagePickerController()

    var imagePdfx = NSMutableData()
    var imagePdf = UIImageView()
    var closeButton = UIBarButtonItem()
    var printButton = UIBarButtonItem()

    private var pdfView:PDFView?
    private var pdfDocument:PDFDocument?

/// BLUETOOTH FILE SHARING IS UNDER CONSTRUCTION
/// let bluetoothImage = UIImage(named: "bluetooth")
    
    let closeImage = UIImage(systemName: "xmark.square")
    let usersImage    = UIImage(systemName: "person.3.fill")
    let printerImage  = UIImage(systemName: "printer.fill")
    let pdfImage = UIImage(systemName: "doc.text.magnifyingglass")
    let logoImage = UIImage(named: "toyota")

    let assetFolderUrl = Bundle.main.resourceURL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let imageFront = UIImageView(frame: CGRect(x: 0, y: 10, width: 400, height: 250))
        imageFront.image = UIImage(named: "1")
        self.bodyView.addSubview(imageFront)
        
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 280, width: 350, height: 50)
        label.text = "Several new Toyota models are expected to be released or updated for the 2025 model year, including the Camry, Crown, Land Cruiser, and Corolla Cross. Additionally, the Fortuner, Innova, HiAce, Vios, and bZ4X are also anticipated to have new versions.\n\nHere's a more detailed look at some of the key models:\n\nTOYOTA CAMRY:\nThe 2025 Camry is expected to feature a redesigned exterior, upgraded technology, and enhanced performance. It will continue to offer both front-wheel drive and all-wheel drive options, with the all-wheel drive model utilizing an electric motor for increased power.\n\nTOYOTA CROWN:\nThe 2025 Crown is a unique sedan that blends the look of a traditional sedan with the ride height of an SUV. It offers a premium cabin with high-quality materials and thoughtful features.\n\nTOYOTA LAND CRUISER:\nThe 2025 Land Cruiser is expected to have intuitive safety features like Pre-Collision with Pedestrian Detection, Blind Spot Monitoring, and Intelligent Cruise Control.\n\nTOYOTA COROLLA CROSS:\nThe 2025 Corolla Cross will feature a sleek new design and advanced safety features.\n\nTOYOTA FORTUNER:\nThe 2025 Fortuner is expected to have a bold new look, upgraded technology, improved fuel efficiency, and a luxurious interior.\n\nTOYOTA INNOVA:\nThe 2025 Innova will have a modern and robust design with a bold grille and sleek headlights.\n\nTOYOTA HIACE:\nThe 2025 HiAce will be a versatile van with a sleek exterior, a large front grille, and sharp LED headlight\n\nTOYOTA VIOS:\nThe 2025 Vios is expected to launch in March 2025 and will feature a 1.5-liter gasoline engine.\n\nTOYOTA bZ4X:\nThe 2025 bZ4X is Toyota's battery electric vehicle, offering a modern design and advanced technology."
        label.numberOfLines = 0 //UNLIMITED LINES
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .justified
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.sizeToFit()
        self.bodyView.addSubview(label)
        
        //RIGHT IMAGE
        let addButton   = UIBarButtonItem(image: usersImage,  style: .plain, target: self, action: #selector(didTapUser))
        let viewPdfButton = UIBarButtonItem(image: pdfImage,  style: .plain, target: self, action: #selector(didTapViewPdf))
///        let bluetoothButton = UIBarButtonItem(image: bluetoothImage,  style: .plain, target: self, action: #selector(didTapBluetooth))
        
        closeButton = UIBarButtonItem(image: closeImage,  style: .plain, target: self, action: #selector(didTapClose))
        printButton = UIBarButtonItem(image: printerImage,  style: .plain, target: self, action: #selector(didTapPrint))
        
        navigationItem.rightBarButtonItems = [addButton, viewPdfButton]
        
        //LEFT IMAGE
        let image = UIImage(named: "toyota")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        
    }
    
    private func setupUI() {
        self.view.addSubview(self.scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.bodyView)
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        
        let hConst = bodyView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            bodyView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            bodyView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            bodyView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            bodyView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, multiplier: 1),
            bodyView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor, multiplier: 2.9),
        ])
    }
/**
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
         if UIDevice.current.orientation.isLandscape {
             print("Landscape")
            imagePdf = UIImageView(frame: CGRect(x: 0, y: 250, width: self.view.frame.width, height: self.view.frame.height))


         } else {
             print("Portrait")
            imagePdf = UIImageView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height))

         }
    }
*/
    
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
            pdfView?.displayMode = .singlePageContinuous
            self.view.addSubview(pdfView!)
            
            pdfDocument = PDFDocument(url: url)
            pdfView!.document = pdfDocument
            navigationItem.leftBarButtonItems = [closeButton, printButton]
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.picker.dismiss(animated: true, completion: nil)
        guard let ximage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        if UIDevice.current.orientation.isLandscape {

            imagePdf = UIImageView(frame: CGRect(x: 0, y: 250, width: self.view.frame.width, height: self.view.frame.height))

        } else {

            imagePdf = UIImageView(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height))

        }
        ///CONVERT IMAGE TO NSMutableData
        let data: NSMutableData = createPDFDataFromImage(image: ximage)
        
        pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        pdfView?.autoScales = true
        pdfView?.displayMode = .singlePageContinuous

        navigationItem.leftBarButtonItems = [closeButton, printButton]
        
        self.view.addSubview(pdfView!)
        
        pdfDocument = PDFDocument(data: data as Data)
        pdfView!.document = pdfDocument
        
    }
    
    @objc func didTapClose() {
        pdfView?.removeFromSuperview()
        navigationItem.leftBarButtonItems = nil
    }
    
    @objc func didTapViewPdf() {
        
        let alertController = UIAlertController(title: "Browse PDFfiles", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { [self] _ in
            self.picker.allowsEditing = false
            self.picker.delegate = self
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
         }))
        alertController.addAction(UIAlertAction(title: "iCloud Photo Album", style: UIAlertAction.Style.default, handler: { _ in
            self.pickerViewController.delegate = self
            self.pickerViewController.allowsMultipleSelection = false
            self.pickerViewController.shouldShowFileExtensions = true
            self.present(self.pickerViewController, animated: true, completion: nil)
        }))
         alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
             print("cancel")
         }))
         present(alertController, animated: true, completion: nil)
        
        
        
    }
 
    @objc func didTapUser() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC") as! UsersViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func didTapPrint() {
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let information = UIPrintInfo(dictionary: nil)
        information.outputType = UIPrintInfo.OutputType.general
        information.jobName = "Print View"
        
        let printerViewController = UIPrintInteractionController.shared
        printerViewController.printInfo = information
        printerViewController.printingItem = viewImage
        
        printerViewController.present(animated: true, completionHandler: nil)
    }
    
    func displayPdf(file: String) {
        pdfView = PDFView(frame: self.view.bounds)
        self.view.addSubview(pdfView!)
        
        guard let path = Bundle.main.url(forResource: "output", withExtension: "pdf") else {
            print("Unable to locate file.")
            return
        }
        
        pdfDocument = PDFDocument(url: path)
        pdfView!.document = pdfDocument

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

/**
    @objc func didTapBluetooth() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bluetoothVC") as! BluetoothViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
*/
    
}


extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object,
                error in

                if let image = object as? UIImage{
                    print(image)
                    guard let fileName = result.itemProvider.suggestedName else { return }
                    print(fileName)
                }

            }
        }
        
    }
    
    
}
