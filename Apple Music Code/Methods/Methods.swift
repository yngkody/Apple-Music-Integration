//
//  Methods.swift
//  Apple Music Code
//
//  Created by Kody Young on 7/21/21.
//

import Foundation
import StoreKit
import MediaPlayer


final class AppleMusicManager {
    /// Shared instance of class
    public static let shared = AppleMusicManager()
    
    typealias SearchComplete = () -> ()
    
    var setterQueue = DispatchQueue(label: "AppleMusicManager")

    var song = [[SongItem]]()
    
    var identifier = String()
    
    var countryCode = String()
    
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer

    typealias CatalogSearchCompletionHandler = (_ SongItems: [[SongItem]], _ error: Error?) -> Void

    lazy var urlSession: URLSession = {

        let urlSessionConfiguration = URLSessionConfiguration.default
        
        return URLSession(configuration: urlSessionConfiguration)
    }()
    
    func processSongItemSections(from json: Data) throws -> [[SongItem]] {
        
        
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        var SongItems = [[SongItem]]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songSongItems = try processSongItems(from: dataArray)
                SongItems.append(songSongItems)
            }
        }
        
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumSongItems = try processSongItems(from: dataArray)
                SongItems.append(albumSongItems)
            }
        }
        
        return SongItems
    }
    
    func processSongItems(from json: [[String: Any]]) throws -> [SongItem] {
        let songSongItems = try json.map { try SongItem(json: $0) }
        return songSongItems
    }
    
    func createAPISearchRequest(with songTitle: String, countryCode: String, developerToken: String) -> URLRequest {
            
            // Create the URL components for the network call.
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "api.music.apple.com"
            urlComponents.path = "/v1/catalog/\(countryCode)/search"
            
            let expectedTerms = songTitle.replacingOccurrences(of: " ", with: "+")
            let urlParameters = ["term": expectedTerms,
                                 "limit": "10",
                                 "types": "songs,albums"]
            
            var queryItems = [URLQueryItem]()
            for (key, value) in urlParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            urlComponents.queryItems = queryItems
            
            // Create and configure the `URLRequest`.
            
            var urlRequest = URLRequest(url: urlComponents.url!)
            urlRequest.httpMethod = "GET"
            
            urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
            print(urlRequest)
            return urlRequest
        

    }
    

    func searchAppleMusic(with song: String, countryCode: String, developerToken: String, completion: @escaping CatalogSearchCompletionHandler){
        
        let urlRequest = createAPISearchRequest(with: song, countryCode: countryCode, developerToken: developerToken)
        
        let task = AppleMusicManager.shared.urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                let url = response as? HTTPURLResponse
                print(url)
                print(url?.statusCode)
                return
            }
            print(response)
            
            do {
                let SongItems = try AppleMusicManager.shared.processSongItemSections(from: data!)
                completion(SongItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()

    }



}

extension AppleMusicManager {
    //typealias SearchComplete = () -> ()

    
    func find(songTitle: String, developerToken: String, completed: @escaping SearchComplete) {
        
       

        let countryCode = "us"
        
        AppleMusicManager.shared.searchAppleMusic(with: songTitle,
                                                  countryCode: countryCode, developerToken: developerToken,
                                                  
                                                         completion: { [weak self] (songResults, error) in
                                                         //   if error == nil{
                                                               // print(error)
                                                           // }
                                                            
                                                           // else{
                                                                
                   
                                                            AppleMusicManager.shared.identifier = songResults[0][0].identifier
                                                                print(songResults)
                                                                completed()
                                                                return
                                                           // }
                                                                                                            
                                                            

            })
        }
    

    
    
    func play(song: [String]){
        
        AppleMusicManager.shared.musicPlayer.setQueue(with: song)
        AppleMusicManager.shared.musicPlayer.play()

    }
    
    func pause(){
        
        AppleMusicManager.shared.musicPlayer.setQueue(with: [AppleMusicManager.shared.song[0][0].identifier])
        AppleMusicManager.shared.musicPlayer.pause()

    }
    
    func rewind(){
        AppleMusicManager.shared.musicPlayer.setQueue(with: [AppleMusicManager.shared.song[0][0].identifier])
        AppleMusicManager.shared.musicPlayer.beginSeekingBackward()

    }
    
    func getArtistName() -> String{
      return AppleMusicManager.shared.song[0][0].artistName
    }
    
    func getTrackTitle() -> String{
        return AppleMusicManager.shared.song[0][0].name
    }
    
    func getCoverArt() -> UIImageView{
        
        let coverArt = UIImageView()
        
        let url = (AppleMusicManager.shared.song[0][0].artwork.imageURL(size: CGSize(width: 500, height: 500))).absoluteString
        
        coverArt.loadImagesUsingCacheWithUrlString(urlString: url)
        
        return coverArt
    }
    
}

