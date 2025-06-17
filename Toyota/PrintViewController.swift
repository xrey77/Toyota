//
//  PrintViewController.swift
//  Toyota
//
//  Created by Reynald Marquez-Gragasin on 5/27/25.
//
import UIKit
import PDFKit
import Foundation

class PrintViewController: UIViewController {
    private let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
    private let picker = UIImagePickerController()

    private var pdfView:PDFView?
    private var pdfDocument:PDFDocument?
    
    var textMsg: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let formattedDate = dateFormatter.string(from: Date())
        let dateNow = "As of \(formattedDate)"


        textMsg = "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\">" +
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>PDF</title></head><body>" +
        "<h3 style=\"margin-left:60px;margin-right:50px;margin-top: 60px\">User's Core Graphics Report</h3>" +
        "<h5 style=\"margin-left:60px;margin-right:50px;margin-top: -20px;\">" + dateNow + "</h5>" +
        "<div style=\"margin-left:60px;margin-right:50px;text-align: justify;font-size:small;\">" +
        "I put together answers for over 600 of the most frequently asked questions I received from readers into one place: the Swift 5 Knowledge Base. It answers basic and advanced questions, and provides lots of free code you can re-use however you please. If you hit problems, try searching there first." +
        "If you're still having problems, you can post to the Hacking with Swift subreddit where you can expect an answer fairly quickly, or you can find me on Twitter where I'll do my best to help.<br/><br/>" +
        "You're probably tired of me saying this: iOS is full of powerful and easy to use programming frameworks. It's true, and you've already met UIKit, SpriteKit, Core Animation, Core Motion, Core Image, Core Location, Grand Central Dispatch and more. But how would you feel if I said that we've yet to use one of the biggest, most powerful and most important frameworks of all?" +
        "Well, it's true. And in this technique project we're going to right that wrong. The framework is called Core Graphics, and it's responsible for device-independent 2D drawing – when you want to draw shapes, paths, shadows, colors or so on, you'll want Core Graphics. Being device-independent means you can draw things to the screen or draw them in a PDF without having to change your code.<br/><br/>" +
        "Create a new Single View App project, name it Project27, then adjust its project settings so that it’s iPad-only. We're going to create a Core Graphics sandbox that's similar to project 15's Core Animation sandbox – a button you can type will trigger Core Graphics drawing in different ways." +
        "</div></body></html>"

        convertToPdfFileAndShare(textMessage: textMsg)
        
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
        
//        do {
//            let fileData = try Data.init(contentsOf: outputUrl)
//            let fileStream:String = fileData.base64EncodedString()
//            print(fileStream)
//            displayPdf(file: fileStream)
//        } catch {
//            print("error")
//            print(error.localizedDescription)
//        }
        
        pdfData.write(to: outputUrl, atomically: true)
//            print("Open \(outputUrl.path)")
//            displayPdf(file: "\(outputUrl.path)")

        
            if FileManager.default.fileExists(atPath: outputUrl.path) {
                let url = URL(fileURLWithPath: outputUrl.path)
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//                print("FILE : \(url)")
                displayPdf(file: "\(url)")
                let excludeActivities = [UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.message, UIActivity.ActivityType.mail,
                    UIActivity.ActivityType.print,
                    UIActivity.ActivityType.copyToPasteboard,
                    UIActivity.ActivityType.assignToContact,
//                    UIActivity.ActivityType.saveToCameraRoll,
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
                            print("for iPad")
                        }
                    }
                    present(activityViewController, animated: true, completion: nil)
            } else {
                print("Document was not found.")
            }
        
        
//        downloadFileCompletionHandler(urlstring: outputUrl.path) {(destinationUrl, error) in
//            if let url = destinationUrl {
//                print(url)
//                self.displayPdf(file: "\(url)")
//
//            } else {
//                print(error!)
//            }
//
//        }
    }
            

    
    private func downloadFileCompletionHandler(urlstring: String, completion: @escaping (URL?, Error?) -> Void) {

            let url = URL(string: urlstring)!
            let documentsUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
            print(destinationUrl)

            if FileManager().fileExists(atPath: destinationUrl.path) {

                print("File already exists [\(destinationUrl.path)]")
                try! FileManager().removeItem(at: destinationUrl)
                completion(destinationUrl, nil)
                return
            }

            let request = URLRequest(url: url)


            let task = URLSession.shared.downloadTask(with: request) { tempFileUrl, response, error in
    //            print(tempFileUrl, response, error)
                if error != nil {
                    completion(nil, error)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let tempFileUrl = tempFileUrl {
                            print("download finished")
                            try! FileManager.default.moveItem(at: tempFileUrl, to: destinationUrl)
                            completion(destinationUrl, error)
                        } else {
                            completion(nil, error)
                        }

                    }
                }

            }
            task.resume()
        }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("image picker.....")
        self.picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        print(image)
        
//        self.userPic.image = image
        
//        let strBase64 = convertImageToBase64String(img: self.userPic.image!)
        
        
        
//        updatePicture(userId: strUserID, token: token, base64Image: strBase64)
    }
    
}
