//
//  HandyTodoUITests.swift
//  HandyTodoUITests
//
//  Created by Muhammed Saeed on 20/04/2023.
//

import XCTest

let categories = ["Primary", "Secondary", "Tertiary"]
let primaryTodos = [
    "Working on Handy todo app",
    "Call you loved ones today",
]

let secondaryTodos = [
    "fix react-native-tooltipilize issues",
    "open-source Handy todo app"
]

let tertiaryTodos = [
    "Pick you dry-cleaning",
    "Watch man-city vs bayern munich today.",
    "Seach for jobs!"
]


final class HandyTodoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
       
        snapshot("01.emptyStatus")
        
        func addNewTodo(category: String, todo: String) -> Void {
            let categoryTextInput = app.textFields["\(category)_testInput"]
            
            XCTAssertTrue(categoryTextInput.exists)
            
            categoryTextInput.tap()
            categoryTextInput.typeText(todo)
            snapshot("02.addingNewTodo-\(category)")
            app.keyboards.buttons["return"].tap()
            
            snapshot("03.todoAdded-\(category)")
            let text = app.staticTexts[todo]
            // Use XCTAssert and related functions to verify your tests produce the correct results.
            XCTAssertTrue(text.waitForExistence(timeout: 2))
        }
        
        categories.forEach { category in
            if category == "Primary" {
                primaryTodos.forEach { todo in
                    addNewTodo(category: category, todo: todo)
                }
            } else if category == "Secondary" {
                secondaryTodos.forEach { todo in
                    addNewTodo(category: category, todo: todo)
                }
            } else {
                tertiaryTodos.forEach { todo in
                    addNewTodo(category: category, todo: todo)
                }
            }
        }
        
        snapshot("04.FilledStatus")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
