//
//  ViewController.swift
//  HomeRobot
//
//  Created by Dmitry Suvorov on 21/10/2018.
//  Copyright © 2018 homesuvorov. All rights reserved.
//

import Alamofire
import AlamofireImage
import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, VLCMediaPlayerDelegate {
    private let videoStreamUrl = "rtsp://192.168.1.53:8554/stream"
    private var viewModel = ViewModel()
    private var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()

    @IBOutlet private weak var mediaView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var co2Label: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var controlView: UIView!
    @IBOutlet private weak var infoView: UIView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundCorners()
        bindViewModel()
        bindOutlets()
        playStream()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mediaPlayer.play()
    }
}

private extension ViewController {
    func bindViewModel() {
        viewModel.co2
            .bind(to: co2Label.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.temperature
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.humidity
            .bind(to: humidityLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindOutlets() {
        leftButton.rx.tap.bind(to: viewModel.left).disposed(by: disposeBag)
        rightButton.rx.tap.bind(to: viewModel.right).disposed(by: disposeBag)
        forwardButton.rx.tap.bind(to: viewModel.forward).disposed(by: disposeBag)
        backButton.rx.tap.bind(to: viewModel.back).disposed(by: disposeBag)
    }
    
    func roundCorners() {
        leftButton.layer.cornerRadius = 4.0
        leftButton.clipsToBounds = true
        rightButton.layer.cornerRadius = 4.0
        rightButton.clipsToBounds = true
        forwardButton.layer.cornerRadius = 4.0
        forwardButton.clipsToBounds = true
        backButton.layer.cornerRadius = 4.0
        backButton.clipsToBounds = true
        infoView.layer.cornerRadius = 4.0
        infoView.clipsToBounds = true
    }
    
    func playStream() {
        //Playing RTSP from internet
        let url = URL(string: videoStreamUrl)
        if url == nil {
            print("Invalid URL")
            return
        }
        let media = VLCMedia(url: url!)
        
        // Set media options
        // https://wiki.videolan.org/VLC_command-line_help
        //media.addOptions([
        //    "network-caching": 300
        //])
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = self.mediaView
        mediaPlayer.play()
    }
}

