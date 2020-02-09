# Unsplash Demo
![Overview](https://github.com/matvdg/Unsplash/blob/master/Demo.png?raw=true)

This is the main repository for the Unsplash Demo iOS app, built in Swift 5 targeting from iOS 13.2 and later.
Open the project with Xcode 11.3.1 or later.

## Features
- Vertical list (UITableView) displaying photo collections
- In each photo collection, each cell displays the collection title, description, pagination and a UICollectionView with a load more button
- A tap on a picture displays the photo in full screen
- The user can pinch to zoom, double tap to zoom, drag the image and save it to the user photo library
- A tap on a photo collection displays a UICollectionView in full screen
- Landscape and portrait mode are handled for all views
- Dark mode (iOS 13) is supported

## Architecture

### MVVM / Repository
The app uses MVVM architecture design pattern and Repository pattern.

#### Overview
![Overview](https://github.com/matvdg/Unsplash/blob/master/overview.png?raw=true)

#### Description
- Each View Controller (V) delegates to a View Model (VM) the business logic and subscribe in return to Rx streams from VM to update itself. Many V can share a same instance of a given VM because they depend of the same business logic. (e.g. here PhotosVC and PhotoCollectionVC share the same PhotoVM in order to factorize the same loadMore photos logic)
- Each VM delegates to one (or more) Repository (R) the data logic and subscribe in return to Rx streams from R to execute its business logic. 
- Each R delegates to one (or more) DataSource (DS) the data fetching (local, remote, ...) and subscribe in return to Rx streams from DS to execute its data logic. 

#### Outlooks
- In this demo project we only have one R (PhotoRepository) at the moment but we could imagine to add a UserRepository to add a favorite feature (we would be able to save favorite photos and retrieve a user's favorite pictures)
- We have also just one DataSource at the moment (using Unsplasher Swift SDK), but we could imagine the need to plug to a different remote DataSource (such as a REST or GraphQL or Firebase DataSource) or sync data in a local database (such as CoreData or Realm) to let the app run without an internet connection. In that case we would have had a local DataSource (e.g. RealmDataSource) and the PhotoRepository underneath would handle the logic between the local and remote DataSources which both would be plugged to it.

## Unit testing
The layers Repository, ViewModel and ViewController are tested in the target UnsplashTests.
To ensure each layer is independent and well tested, we use protocols and each implementation has a correspondent mock (e.g. PhotoDataSource implements PhotoDataSourceProtocol and has a mock called MockPhotoDataSource), so that we can inject in the underneath layer (such as PhotoRepository) the mock implementation to let test that layer without any dependency.

## Libraries used
- **RxSwift/RxCocoa/RxTest**: the ReactiveX design pattern adapted to Swift letting us use streams to communicate between layers
- **Dip**: a dependency injection library to automatically inject the MVVM/Repository/DataSource hierarchy with the appropriate scope. One or several DataSources are injected in a Repository, which is injected in a ViewModel, which is injected in a ViewController and so on...
- **Mockit**:  a test library used to use mocks, stubs and spies in order to test every case
- **AlomofireImage**: a library used to cache images locally (better performance and less network usage)
