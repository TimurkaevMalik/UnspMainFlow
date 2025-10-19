//
//  PhotoSearchFeedController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 19.10.2025.
//

import UIKit

final class PhotoSearchFeedController: UIViewController {
        
    private let rootView: PhotoSearchFeedView
    
    init(rootView: PhotoSearchFeedView) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Feed"
        rootView.setup()
    }
}
