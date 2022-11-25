//
//  ViewController.swift
//  ImageLibrary
//
//  Created by Ganpat Jangir on 02/11/22.
//

import UIKit

class ViewController: UIViewController {
    private var images = [Image]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    var page = 1
    var isLoading = false
    let imageOperationManager = ImageOperationManager()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.identifier)
        // Do any additional setup after loading the view.
    }
    
    private func fetchData(page : Int ,completed: ((Bool) -> Void)? = nil) {
        ImageManager.shared.getPhotoData(page : page, imageToSearch: textField.text ?? "random") { [weak self] result in
            switch result{
            case .success(let urlArrayString):
                self?.images.append(contentsOf: urlArrayString!)
                self?.isLoading = false
                completed?(true)
            case .failure(let error):
                print(error.localizedDescription)
                completed?(false)
            }
        }
    }
    
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        images.removeAll()
        page = 1
        fetchData(page: page)
        page = page + 1
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
        let imageDetail = images[indexPath.row]
        cell.myImage.image = imageDetail.image
        cell.myImage.contentMode = .scaleToFill
        startOperation(for: imageDetail, at: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == images.count - 1 , !isLoading {
            self.isLoading = true
            print("Loading more data...")
            fetchData(page: page) { [weak self] success in
                if !success {
                    self?.page += 1
                }
            }
            
        }
    }
    
    
    func startOperation(for imageDetail : Image , at indexPath : IndexPath){
        switch (imageDetail.state) {
        case .new :
            startDownload(for: imageDetail, at: indexPath)
        case .downloaded,.saved:
            getImageFromDisk(for : imageDetail ,at : indexPath)
    }
        
        
        func startDownload(for imageDetail : Image , at indexPath : IndexPath) {
            guard imageOperationManager.downloadsInProgress[indexPath] == nil else {
                return
            }
            let downloader = ImageDownloader(imageDetail)
            imageOperationManager.downloadsInProgress[indexPath] = downloader
            imageOperationManager.downloadQueue.addOperation(downloader)
        }
        
        func getImageFromDisk(for imageDetails : Image ,at  indexPath : IndexPath){
            guard imageOperationManager.saveToDiskInProgress[indexPath] == nil else {
                return
            }
            let imageSaver = ImageSaveToDisk(imageDetails)
            imageOperationManager.saveToDiskInProgress[indexPath] = imageSaver
            imageOperationManager.saveToDiskQueue.addOperation(imageSaver)
        }
        
}
}
