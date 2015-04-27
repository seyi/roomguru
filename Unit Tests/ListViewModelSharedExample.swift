//
//  ListViewModelSharedExample.swift
//  Roomguru
//
//  Created by Radoslaw Szeja on 26/04/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick

import Roomguru

class FixtureListItem: NSObject {
    
    var fixtureText: String
    
    init(fixtureText: String = "") {
        self.fixtureText = fixtureText
        super.init()
    }
}

class ListViewModelFactory {
    
    private let viewModelClass: ListViewModel<FixtureListItem>.Type
    
    init(viewModelClass: ListViewModel<FixtureListItem>.Type) {
        self.viewModelClass = viewModelClass
    }
    
    private func viewModelWithItems(items: [FixtureListItem]) -> ListViewModel<FixtureListItem> {
        return viewModelClass(items)
    }
    
    private func viewModelWithItems(items: [FixtureListItem], sortingKey: String) -> ListViewModel<FixtureListItem> {
        return viewModelClass(items, sortingKey: sortingKey)
    }
    
    private func viewModelWithSections(sections: [Section<FixtureListItem>]) -> ListViewModel<FixtureListItem> {
        return viewModelClass(sections)
    }
}

class ListViewModelSharedExampleConfiguration : QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("list view model") { (sharedExampleContext: SharedExampleContext) in
            var configDict: [String: AnyObject] = sharedExampleContext() as! [String: AnyObject]
            
            let fixtureItems = configDict["items"] as! [FixtureListItem]
            let expectedSectionsCount = configDict["sectionsCount"] as! Int
            let factory = configDict["listViewModelFactory"] as! ListViewModelFactory
            
            var sut: ListViewModel<FixtureListItem>!
            
            beforeEach {
                sut = factory.viewModelWithItems(fixtureItems)
            }
            
            afterEach {
                sut = nil
            }
            
            describe("when newly initialized") {
                
                context("with items") {

                    it("should not be nil") {
                        expect(sut).notTo(beNil())
                    }
                    
                    it("should have correct sections count") {
                        expect(sut.sectionsCount()).to(equal(1))
                    }
                }
                
                context("with items and sorting key") {
                    
                    beforeEach {
                        sut = factory.viewModelWithItems(fixtureItems, sortingKey: "fixtureText")
                    }
                    
                    it("should not be nil") {
                        expect(sut).notTo(beNil())
                    }
                    
                    it("should have correct sections count") {
                        expect(sut.sectionsCount()).to(equal(expectedSectionsCount))
                    }
                }
                
                context("with sections") {
                    
                    beforeEach {
                        let itemsCount = fixtureItems.count
                        let firstSection = Array(fixtureItems[0...(itemsCount/2)-1])
                        let secondSection = Array(fixtureItems[itemsCount/2...itemsCount-1])
                        sut = factory.viewModelWithSections([Section(firstSection), Section(secondSection)])
                    }
                    
                    it("should not be nil") {
                        expect(sut).notTo(beNil())
                    }
                    
                    it("should have correct sections count") {
                        expect(sut.sectionsCount()).to(equal(2))
                    }
                }
            }
            
            describe("subscript") {
                
                it("should return first item in section") {
                    expect(sut[0]).to(beIdenticalTo(fixtureItems.first!))
                }
                
                it("should return last item in section") {
                    expect(sut[fixtureItems.count-1]).to(beIdenticalTo(fixtureItems.last!))
                }
            }
            
            describe("itemize") {
                
                var paths: [Path] = []
                var items: [FixtureListItem] = []
                
                afterEach {
                    paths = []
                    items = []
                }
                
                it("should itemize all paths") {
                    sut.itemize { path, item in
                        paths.append(path)
                    }
                    expect(paths.count).to(equal(fixtureItems.count))
                }
                
                it("should itemize all items") {
                    sut.itemize { path, item in
                        items.append(item)
                    }
                    expect(items.count).to(equal(fixtureItems.count))
                }
            }
            
            describe("index path operation") {

                var itemsCount: Int!
                
                context("add item at indexpath") {
                    
                    var newFixtureItem = FixtureListItem()
                    
                    beforeEach {
                        itemsCount = sut[0].count
                        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                        sut.addItem(newFixtureItem, atIndexPath: indexPath)
                    }
                    
                    it("should add item") {
                        expect(sut[0][1]).to(beIdenticalTo(newFixtureItem))
                    }
                    
                    it("should have higher number of items in section") {
                        expect(sut[0].count).to(equal(itemsCount+1))
                    }
                }
                
                context("remove item at index path") {
                    
                    var removedItem: FixtureListItem!
                    
                    beforeEach {
                        itemsCount = sut[0].count
                        removedItem = sut[0][1]
                        println(removedItem)
                        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                        println(indexPath)
                        sut.removeAtIndexPath(indexPath)
                    }
                    
                    it("should remove item") {
                        println("\(__FUNCTION__) | sut[0][1]: \(sut[0][1])")
                        expect(sut[0][1]).notTo(beIdenticalTo(removedItem))
                    }
                    
                    it("should have lower number of items in section") {
                        expect(sut[0].count).to(equal(itemsCount-1))
                    }
                    
                    it("should not have removed item") {
                        var hasItem = false
                        sut.itemize { path, item in
                            if item == removedItem {
                                hasItem = true
                            }
                        }
                        
                        expect(hasItem).notTo(beTrue())
                    }
                }
                
                context("remove few items at indexpaths") {
                    
                    pending("should remove items") {
                        
                    }
                    
                    pending("should have correct nubmer of items in sections") {
                        
                    }
                }
            }
        }
    }
}