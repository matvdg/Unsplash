import Foundation
import Dip

extension DependencyContainer {
    
    /// Configure the MVVM/Repository stack
    func configure() {
        // dataSource
        self.register(.singleton) { PhotoDataSource() as PhotoDataSourceProtocol }
        
        // repository
        self.register(.singleton) { try PhotoRepository(photoDataSource: self.resolve()) as PhotoRepositoryProtocol }
        
        // viewModel
        self.register(.unique) { try PhotoViewModel(photoRepository: self.resolve()) as PhotoViewModelProtocol }
        
        // viewControllers
        self.register(storyboardType: PhotosViewController.self, tag: "PhotosViewController")
            .resolvingProperties { container, vc in
                vc.viewModel = try self.resolve() as PhotoViewModelProtocol
        }
        
        self.register(storyboardType: PhotoCollectionViewController.self, tag: "PhotoCollectionViewController")
            .resolvingProperties { container, vc in
                vc.viewModel = try self.resolve() as PhotoViewModelProtocol
        }
    }
    
}
