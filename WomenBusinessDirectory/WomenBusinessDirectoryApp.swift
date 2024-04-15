//
//  WomenBusinessDirectoryApp.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import SwiftData


@main
@MainActor
struct WomenBusinessDirectoryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Entrepreneur.self, Company.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            let companies: [Company] = [
                Company(name: "Tech Innovations", logoImg: "comp_logo1", aboutUs: "Leading in innovative tech solutions.", dateFounded: "2010",
                        entrepreneur: Entrepreneur(firstName: "John", lastName: "Doe", image: "placeholder", bioDescr: "description of the biography"), 
                        address: "123 Tech Lane, Silicon Valley, CA", phoneNum: "123-456-7890", email: "info@techinnovations.com", workHours: "9AM-5PM", directions: "Near Tech Park", category: Category(name: "Technology", image: "technology"), isFavorite: false),
                
                Company(name: "Code Wizards", logoImg: "comp_logo2", aboutUs: "Crafting magical code for the modern web.", dateFounded: "2012",
                        entrepreneur: Entrepreneur(firstName: "John", lastName: "Smith", image: "placeholder", bioDescr: "Some description of bio"), 
                        address: "456 Wizardry Way, New York, NY", phoneNum: "234-567-8901", email: "contact@codewizards.com", workHours: "10AM-6PM", directions: "Next to Central Park", category: Category(name: "Media & Digital Services", image: "digital_marketing"), isFavorite: true),
                
                Company(name: "Gourmet Bites", logoImg: "comp_logo3", aboutUs: "Delicious gourmet food delivered to your door.", dateFounded: "2015",
                        entrepreneur: Entrepreneur(firstName: "Maria", lastName: "Sharapova", image: "placeholder", bioDescr: "Description of biography is here"),
                        address: "789 Gourmet St, Los Angeles, CA", phoneNum: "345-678-9012", email: "hello@gourmetbites.com", workHours: "8AM-10PM", directions: "In the heart of Food District", category: Category(name: "Food and Beverages", image: "food_beverage"), isFavorite: true),
                
                Company(name: "Fresh Farm Produce", logoImg: "comp_logo4", aboutUs: "Bringing the farm directly to your table.", dateFounded: "2018", 
                        entrepreneur: Entrepreneur(firstName: "Susan", lastName: "Stephanson", image: "placeholder", bioDescr: "Some description of bio"),
                        address: "123 Fresh Ave, Portland, OR", phoneNum: "456-789-0123", email: "support@freshfarmproduce.com", workHours: "6AM-8PM", directions: "Next to Farmers Market", category: Category(name: "Financial Services", image: "financial_service"), isFavorite: false),
                
                Company(name: "Innovative Learning", logoImg: "comp_logo5", aboutUs: "Future-focused education for all ages.", dateFounded: "2020",
                        entrepreneur: Entrepreneur(firstName: "Michael", lastName: "Peters", image: "placeholder", bioDescr: "Some description goes here"), address: "321 Learn Ln, Boston, MA", phoneNum: "567-890-1234", email: "info@innovativelearning.com", workHours: "8AM-9PM", directions: "Adjacent to Innovation Hub", category: Category(name: "Professional Services", image: "professional_service"), isFavorite: false),
                Company(name: "Tasty food", logoImg: "comp_logo5", aboutUs: "Future-focused education for all ages.", dateFounded: "2020",
                        entrepreneur: Entrepreneur(firstName: "Julia", lastName: "Roberts", image: "placeholder", bioDescr: "Description goes here"), address: "321 Learn Ln, Boston, MA", phoneNum: "567-890-1234", email: "info@innovativelearning.com", workHours: "8AM-9PM", directions: "Adjacent to Innovation Hub", category: Category(name: "Food and Beverages", image: "food_beverage"), isFavorite: false),
                Company(name: "Health and Wellness", logoImg: "comp_logo5", aboutUs: "Future-focused education for all ages.", dateFounded: "2020", 
                        entrepreneur: Entrepreneur(firstName: "Sarah", lastName: "Shmidt", image: "placeholder", bioDescr: "This is going to be a description of life"),
                        address: "321 Learn Ln, Boston, MA", phoneNum: "567-890-1234", email: "info@innovativelearning.com", workHours: "8AM-9PM", directions: "Adjacent to Innovation Hub", category: Category(name: "Health and Wellness", image: "health"), isFavorite: true)
            ]
            
            for company in companies {
                container.mainContext.insert(company)
            }
            
            return container

//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
