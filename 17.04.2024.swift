//
//  main.swift
//  CodingExample
//
//
//
//  Created by David Thorn on 17.07.24.
//

import Foundation

protocol Model1Protocol {
    var content: String { get }
}

protocol Model2Protocol {
    var content: String { get }
}

struct View1Model: Model1Protocol {
    let content: String
}

struct View2Model: Model2Protocol {
    let content: String
}

protocol ViewProtocol {
    func render() -> String
}

protocol View1ViewModelProtocol {
    func getContent() -> String
    func addNewItem()
}

protocol View2ViewModelProtocol {
    func getContent() -> String
    func getView1ItemsCount() -> Int
}

protocol ApplicationInteractorProtocol {
    func getView1Model() -> Model1Protocol
    func getView2Model() -> Model2Protocol
    func addNewView1ModelItem()
    func getView1ItemsCount() -> Int
    func didTap3TimesAction() -> Void
}

protocol Model1RepositoryProtocol {
    func getItems() -> [Model1Protocol]
    func getCurrent() -> Model1Protocol
    func addItem() -> Void
}

protocol RouterProtocol {
    func getCurrentRoute() -> Routes
    func route(to route: Routes)
}

class Router: RouterProtocol {
    private var currentRoute: Routes = .view1
    
    func getCurrentRoute() -> Routes {
        currentRoute
    }
    
    func route(to route: Routes) {
        currentRoute = route
    }
}


class Model1Repository: Model1RepositoryProtocol {
    private var items: [Model1Protocol] = [
        View1Model(content: "Interactor Model: View 1")
    ]
    
    func getItems() -> [Model1Protocol] {
        items
    }
    
    func getCurrent() -> Model1Protocol {
        items.last!
    }
    
    func addItem() {
        let item = View1Model(content: "Interactor Model: View 1.\((items.count - 1) + 1)")
        items.append(item)
    }
}

class ApplicationInteractor: ApplicationInteractorProtocol {
    
    private var model1Repository: Model1RepositoryProtocol
    private var router: RouterProtocol
    
    init(model1Repository: Model1RepositoryProtocol, router: RouterProtocol) {
        self.model1Repository = model1Repository
        self.router = router
    }
    
    private var view2ModelItems: [String] = [
        "Interactor Model: View 1",
    ]
    
    func getView1Model() ->  Model1Protocol {
        model1Repository.getCurrent()
    }
    
    func getView2Model() ->  Model2Protocol {
        View2Model(content: view2ModelItems.last!)
    }
    
    func addNewView1ModelItem() {
        model1Repository.addItem()
    }
    
    func getView1ItemsCount() -> Int {
        model1Repository.getItems().count
    }
    
    func didTap3TimesAction() {
        router.route(to: .view2)
    }
}

class View1ViewModel: View1ViewModelProtocol {
    
    private var interactor: ApplicationInteractorProtocol
    private var tapCount: Int = 0
    
    init(interactor: ApplicationInteractorProtocol) {
        self.interactor = interactor
    }
    
    func getContent() -> String {
        interactor.getView1Model().content
    }
    
    func addNewItem() {
        
        if tapCount == 2 {
            tapCount = 0
            interactor.didTap3TimesAction()
        } else {
            tapCount += 1
            interactor.addNewView1ModelItem()
        }
    }
}

struct View2ViewModel: View2ViewModelProtocol {
    
    private var interactor: ApplicationInteractorProtocol
    
    init(interactor: ApplicationInteractorProtocol) {
        self.interactor = interactor
    }
    
    func getContent() -> String {
        interactor.getView2Model().content
    }
    
    func getView1ItemsCount() -> Int {
        interactor.getView1ItemsCount()
    }
}

struct View1: ViewProtocol {
    
    private var viewModel: View1ViewModelProtocol
    
    init(viewModel: View1ViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func render() -> String {
        return viewModel.getContent()
    }
    
    func addNewItemButtonClickAction() {
        viewModel.addNewItem(/** arguments received from form */)
    }
}

struct View2: ViewProtocol {
    private var viewModel: View2ViewModelProtocol
    
    init(viewModel: View2ViewModelProtocol) {
        self.viewModel = viewModel
    }
    func render() -> String {
        return "Content: |\(viewModel.getContent())| -- Items: \(viewModel.getView1ItemsCount())"
    }
}

enum Routes: String {
    case view1
    case view2
    
    func getPath() -> String {
        return "/\(rawValue)"
    }
}

// Router
let router = Router()

// Repositories

let model1Repository = Model1Repository()

// Interactor's
let applicationInteractor = ApplicationInteractor(model1Repository: model1Repository, router: router)

// Views
let viewModel1 = View1ViewModel(interactor: applicationInteractor)
let view1 = View1(viewModel: viewModel1)

let viewModel2 = View2ViewModel(interactor: applicationInteractor)
let view2 = View2(viewModel: viewModel2)

let route = router.getCurrentRoute()

// Screen
switch route {
case .view1:
    print(view1.render())
    view1.addNewItemButtonClickAction()
    print(view1.render())
    view1.addNewItemButtonClickAction()
    print(view1.render())
    view1.addNewItemButtonClickAction()
    print(view1.render())
case .view2:
    print(view2.render())
}

let routeChanged = router.getCurrentRoute()

print("")
print("")
print("")

// Screen Changed
switch routeChanged {
case .view1:
    print(view1.render())
case .view2:
    print(view2.render())
}

