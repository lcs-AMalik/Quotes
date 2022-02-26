//
//  ContentView.swift
//  Quotes
//
//  Created by Abdul Malik on 2022-02-22.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    // Detect when app moves between the foreground, background, and inactive states
    // NOTE: A complete list of keypaths that can be used with @Environment can be found here:
    // https://developer.apple.com/documentation/swiftui/environmentvalues
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentQuote: Quote = Quote(quoteText: "You can't stop the waves, but you can learn to surf.",
                                           quoteAuthor: "Jon Kabat-Zinn",
                                           senderName: "",
                                           senderLink: "",
                                           quoteLink: "http://forismatic.com/en/eeb8220c64/")
    // Hold a list of favourite jokes
    @State var favourites: [Quote] = [] // Empty list
    
    // This will let us know whether the current joke has been added to the list
    @State var currentQuoteAddedToFavourites: Bool = false
    
    // MARK: Computed properties
    var body: some View {
        VStack {
            
            Text(currentQuote.quoteText)
                .font(.title)
            // Shrinks text to at most half of its original size
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            
            Image(systemName: "heart.circle")
                .resizable()
            // Make the image red when the current jjoke is favourite
                .foregroundColor(currentQuoteAddedToFavourites == true ? .red : .secondary)
                .frame(width: 40, height: 40)
                .onTapGesture {
                    
                    // Only if the joke already does not exist, add it
                    if currentQuoteAddedToFavourites == false {
                        
                        // Add the current joke to the list
                        favourites.append(currentQuote)
                        
                        // Keep track of the fact that the joke is now a favourite
                        currentQuoteAddedToFavourites = true
                        
                        
                    }
                }
            
            Button(action: {
                print("button was pressed")
                
                // "Call" loadNewQuote
                // It must be called within a Task structure
                // so that it runs asynchronosly
                // NOTE: Button's action normally expects synchronous code.
                Task {
                    await loadNewQuote()
                }
                
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack{
                Text("Favourites")
                    .bold()
                    .font(.title3)
                
                Spacer()
            }
            
            // Iterat (loop) over the list (array) of jokes
            // Make each joke accessible using the name "currentJoke"
            // id: \.self   <-- That tells the List structure
            //                  to identify each koke using the text fo the
            //                  joke itself
            List(favourites, id: \.self) { currentQuote in
                Text(currentQuote.quoteText)
            }
            
            Spacer()
            
        }
        // React to changes of state for the app (foreground, background, and inactive)
        .onChange(of: scenePhase) { newPhase in
            
            if newPhase == .inactive {
                
                print("Inactive")
                
            } else if newPhase == .active {
                
                print("Active")
                
            } else if newPhase == .background {
                
                print("Background")
                
                // Permanently save the list of tasks
                persistFavourites()
                
            }
            
        }
        // When the app opens, get a new joke from the web service
        .task {
            
            // We "call" the loadNewQuote function to tell the computer
            // to get that new Quote
            // By typing "await" we are acknowleding that we know this
            // function may be run at the same time as other tasks in the app
            await loadNewQuote()
            
            // DEBUG
            print("Have just attempted to load a new Quote.")
            
            //Loading favourites from local device
            loadFavourites()
        }
        .navigationTitle("Quote?")
        .padding()
    }
    
    // MARK: Functions
    // This function loads a new joke by talking to an endpoint on the web.
    // We must mark the function as "async" so that it can be asynchronously which
    // means it may be run at the same time as other tasks.
    // This is the function definition (it is where the computer "learns" what
    // it takes to load a new joke).
    func loadNewQuote() async {
        
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://api.forismatic.com/api/1.0/?method=getQuote&key=457653&format=json&lang=en")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        //Ask for JSON data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Start a session to intercat (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift struct
            //Takes what is in "data" and tries to put it into "currentJoke"
            //                                  DATA TYPE TO DECODE
            //                                        ||
            //                                        \/
            currentQuote = try JSONDecoder().decode(Quote.self, from: data)
            
            // If we got here, a new joke has beeen ser (line 146)
            // So, we must reset the flag ti track whether the current joke is
            // a favourite
            currentQuoteAddedToFavourites = false
            
        } catch {
            print("Could not retrieveor decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the d-caatch block
            // populates
            print(error)
        }
        
    }
    // Saves (persists) the data to local storage on the device
    func persistFavourites() {
        
        // Get a URL that points to the saved JSON data containing our list of tasks
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        
        // Try to encode the data in our people array to JSON
        do {
            // Create an encoder
            let encoder = JSONEncoder()
            
            // Ensure the JSON written to the file is human-readable
            encoder.outputFormatting = .prettyPrinted
            
            // Encode the list of favourites we've collected
            let data = try encoder.encode(favourites)
            
            // Actually write the JSON file to the documents directory
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            // See the data that was written
            print("Saved data to documents directory successfully.")
            print("===")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            
            print(error.localizedDescription)
            print("Unable to write list of favourites to documents directory in app bundle on device.")
            
        }

    }
    
    // Loads favourites from local storage on the device into the list of favourites
    func loadFavourites() {
        
        // Get a URL that points to the saved JSON data containing our list of favourites
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
                
        // Attempt to load from the JSON in the stored / persisted file
        do {
            
            // Load the raw data
            let data = try Data(contentsOf: filename)
            
            // What was loaded from the file?
            print("Got data from file, contents are:")
            print(String(data: data, encoding: .utf8)!)

            // Decode the data into Swift native data structures
            // Note that we use [DadJoke] since we are loading into a list (array)
            // of instances of the DadJoke structure
            favourites = try JSONDecoder().decode([Quote].self, from: data)
            
        } catch {
            
            // What went wrong?
            print(error.localizedDescription)
            print("Could not load data from file, initializing with tasks provided to initializer.")

        }

        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}

