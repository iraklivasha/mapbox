//
//  BasePresenter.swift
//  app
//
//  Created by Irakli Vashakidze on 13.04.22.
//

import Foundation

protocol BasePresenterView: AnyObject {
    func notifyError(message: String, okAction: (() -> Void)?)
    func reloadView()
    func willAppear()
    func willDisappear()
}

protocol Presenter: AnyObject {
    func attach(this view: BasePresenterView)
    func willAppear()
    func willDisappear()
    func detach()
}

class BasePresenter<View> : NSObject, Presenter {
    
    private var firstLaunch = true
    weak var baseView: BasePresenterView?
    
    var view : View? {
        return self.baseView as? View
    }
    
    func attach(this view: BasePresenterView) {
        self.baseView = view
        
        if firstLaunch {
            firstLaunch = false
            onFirstViewAttach()
        }
    }
    
    func detach() {
        self.baseView = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func onFirstViewAttach() { }
    
    func willAppear() {
        self.baseView?.willAppear()
    }
    
    func willDisappear() {
        self.baseView?.willDisappear()
    }
    
    func handleResponse<T: Any>(response: Result<T, Error>,
                                preReloadHandler:(()->Void)? = nil,
                                postReloadHandler:(()->Void)? = nil,
                                errorHandler:((Error)->Void)? = nil,
                                reload: Bool = true) {
        main {
            switch response {
            case .success(_):
                preReloadHandler?()
                if reload { self.baseView?.reloadView()  }
                postReloadHandler?()
                break
            case .failure(let error):
                self.baseView?.notifyError(message: error.message, okAction: nil)
                errorHandler?(error)
            }
        }
    }
}

