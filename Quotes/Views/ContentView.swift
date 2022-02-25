//
//  ContentView.swift
//  Quotes
//
//  Created by Abdul Malik on 2022-02-22.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
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
        
        // When the app opens, get a new joke from the web service
        .task {
            
            // We "call" the loadNewQuote function to tell the computer
            // to get that new Quote
            // By typing "await" we are acknowleding that we know this
            // function may be run at the same time as other tasks in the app
            await loadNewQuote()
            
            // DEBUG
            print("Have just attempted to load a new Quote.")
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}

