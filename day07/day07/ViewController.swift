//
//  ViewController.swift
//  day07
//
//  Created by Danil Vdovenko on 10/10/18.
//  Copyright © 2018 Danil Vdovenko. All rights reserved.
//

import UIKit
import RecastAI
import DarkSkyKit
import MessageKit
import Speech

class ViewController: MessagesViewController, SFSpeechRecognizerDelegate {
    
    let theRecastBot = RecastAIClient(token: "", language: nil)
    let theForecastClient = DarkSkyKit(apiToken: "")
    
    var messages: [Message] = []
    var member: Member!
    var theChatBot: Member!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        member = Member(name: "dvdovenk", color: .blue)
        theChatBot = Member(name: "ForecastBot", color: .purple)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Voice", style: .plain, target: self, action: #selector(voiceController))
        
        requestSpeechAuthorization()
    }
    
    @IBAction func voiceController() {
        
        guard let theText = navigationItem.rightBarButtonItem?.title else { return }
        
        if theText == "Voice" {
            navigationItem.rightBarButtonItem?.title = "Stop"
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
                self?.request.append(buffer)
            }
            request.shouldReportPartialResults = true
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch (let theError) {
                return print(theError)
            }
            guard let theRecognizer = SFSpeechRecognizer() else { return }
            if !theRecognizer.isAvailable { return }
            recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] (result, error) in
                if let theResult = result {
                    let theBestString = theResult.bestTranscription.formattedString
                    self?.messageInputBar.inputTextView.text = theBestString
                } else if let theError = error {
                    print(theError)
                    if self?.audioEngine != nil {
                        self?.audioEngine.stop()
                        self?.audioEngine.inputNode.removeTap(onBus: 0)
                        self?.recognitionTask = nil
                    }
                }
            })
        } else {
            navigationItem.rightBarButtonItem?.title = "Voice"
            recognitionTask?.cancel()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                case .denied:
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    self?.showMessageFromBot(withMessage: "You denied access to speech recognition")
                case .restricted:
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    self?.showMessageFromBot(withMessage: "Speech recognition restricted on this device")
                case .notDetermined:
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    self?.showMessageFromBot(withMessage: "Speech recognition not yet authorized")
                }
            }
        }
    }
    
    func sendRequestToRecast(withText text: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        theRecastBot.textRequest(text, successHandler: { [weak self] (aResponse) in
            guard let _ = aResponse.intents, let theEntities = aResponse.entities, let theLocation = theEntities["location"] as? Array<Dictionary<String, Any>>, let theLatitude = theLocation[0]["lat"] as? Double, let theLongitude = theLocation[0]["lng"] as? Double, let theCity = theLocation[0]["raw"] as? String else {
                self?.showAnError(title: "Error", message: "Not enought information, try to input correctly your location")
                return
            }
            self?.theForecastClient.current(latitude: theLatitude, longitude: theLongitude, result: { (aResult) in
                switch aResult {
                case .success(let theForecast):
                    DispatchQueue.main.async { [weak self] in
                        guard let theTextForecast = self?.generateTextForecast(withForecast: theForecast, withCity: theCity) else { return }
                        self?.showMessageFromBot(withMessage: theTextForecast)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                case .failure(let theError):
                    self?.showAnError(title: "Error", message: theError.localizedDescription)
                }
            })
        }) { [weak self] (anError) in
            self?.showAnError(title: "Error", message: anError.localizedDescription)
        }
    }
    
    func generateTextForecast(withForecast aForecast: Forecast, withCity aCity: String) -> String {
        
        guard let theCurrentTemperature = aForecast.currently?.temperature,
                    let theDailyForecast = aForecast.daily,
                    let theSummaryWeather = theDailyForecast[0].summary,
                    let theCurrentPressure = theDailyForecast[0].pressure,
                    let theCurrentWind = theDailyForecast[0].windSpeed,
                    let theCurrentMaxTemperature = theDailyForecast[0].apparentTemperatureMax,
                    let theCurrentMinTemperature = theDailyForecast[0].apparentTemperatureMin,
                    let theRainPercent = theDailyForecast[0].cloudCover
                    else { return "Problem with parsing data" }
        
        let theTemperature = convertToCelsius(fahrenheit: Int(theCurrentTemperature))
        let theMaxTemperature = convertToCelsius(fahrenheit: Int(theCurrentMaxTemperature))
        let theMinTemperature = convertToCelsius(fahrenheit: Int(theCurrentMinTemperature))
        
        return "Weather forecast in \(aCity)\n\nThe summary weather is: \(theSummaryWeather)\nThe current temperature is: \(theTemperature)°C\nThe max temperature is: \(theMaxTemperature)°C\nThe min temperature is: \(theMinTemperature)°C\nProbability of rain is: \(Int(theRainPercent * 100.0))%\nThe current pressure is: \(theCurrentPressure)\nThe wind speed is: \(theCurrentWind) m/s"
    }
    
    func convertToCelsius(fahrenheit: Int) -> Int {
        return Int(5.0 / 9.0 * (Double(fahrenheit) - 32.0))
    }
    
    func showMessageFromBot(withMessage message: String) {
        let theMessage = Message(member: theChatBot, text: message, messageId: UUID().uuidString)
        messages.append(theMessage)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }

}

extension ViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

extension ViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }
}

extension ViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

extension ViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
    
        view.endEditing(true)
        
        guard text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            showAnError(title: "Error", message: "Missing text")
            return
        }
        
        let newMessage = Message(
            member: member,
            text: text,
            messageId: UUID().uuidString)
        
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        
        sendRequestToRecast(withText: text)
        
    }
}

extension ViewController {
    
    func showAnError(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let theChatBot = self?.theChatBot else { return }
            let theMessage = Message(member: theChatBot, text: message, messageId: UUID().uuidString)
            self?.messages.append(theMessage)
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
}

