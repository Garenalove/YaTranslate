//
//  ViewController.swift
//  YaTranslate
//
//  Created by Admin on 10.06.2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Dropper
class ViewController: UIViewController {
    let dropper = Dropper(width: 150, height: 250)
    let apiKey = "trnsl.1.1.20190610T030523Z.6c01dad8f727ecdd.809121ddc3a6645fcc228c8d248677e8d1512fe1"
    let ui = "en"
    @IBOutlet weak var translatedField: UITextView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var translateField: UITextView!
    var langDict = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let langUrlStr = "https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=\(apiKey)&ui=\(ui)"
        let langUrl = URL(string: langUrlStr)
        self.dropdownButton.setTitle("Russian", for: .normal)
        let task = URLSession.shared.dataTask(with: langUrl!) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                if let langs = json["langs"] as? [String:String]{
                    for (key, value) in langs{
                        self.langDict[value] = key
                    }
                }
            }
            catch let jsonError{
                print(jsonError)
            }
        }
        task.resume()
    }

		
    @IBAction func DropdownAction(_ sender: Any) {
        if dropper.status == .hidden {
            dropper.items = Array(langDict.keys) // Item displayed
            dropper.theme = Dropper.Themes.white
            dropper.delegate = self
            dropper.cornerRadius = 3
            dropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: dropdownButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
    }
    @IBAction func translate(_ sender: Any) {
        let lang = langDict[dropdownButton.title(for:.normal)!]!
        let translateUrlStr = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=\(apiKey)&lang=\(lang)&format=plain&text=\(translateField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        let translateUrl = URL(string: translateUrlStr)
        let task = URLSession.shared.dataTask(with: translateUrl!) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                if let text = (json["text"] as! NSArray) as Array?{
                    DispatchQueue.main.async {
                        self.translatedField.text = text[0] as? String
                    }
                }
            }
            catch let jsonError{
                print(jsonError)
            }
        }
        task.resume()
        
    }
}
extension ViewController: DropperDelegate{
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        dropdownButton.setTitle(contents, for: .normal)
    }
}
extension ViewController: UITextViewDelegate{
    
}
