import XCTest
import Combine
@testable import my_isp

final class DataStorageTests: XCTestCase {
    
    private var info: DataStorageTestsInfo!
    private var dataStorage: DataStorage!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        info = DataStorageTestsInfo()
        dataStorage = DataStorage.entry
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        info = nil
        dataStorage = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testEventSending() {
        let oneKey = info.key.one
        let expectation = XCTestExpectation()
        
        dataStorage.publisher.sink { [weak expectation, dataStorage] in
            switch $0 {
                case .save(_):
                    dataStorage?.removeInfo(key: oneKey)
                
                case .remove(_):
                    expectation?.fulfill()
            }
        }.store(in: &subscriptions)
        
        dataStorage.saveInfo(key: oneKey, value: info.value.one)
        wait(for: [expectation], timeout: 2)
    }

    func testDataSaving() {
        let oneKey = info.key.one
        let twoKey = info.key.two
        let threeKey = info.key.three
        let fourKey = info.key.four
        let fiveKey = info.key.five
        let sixKey = info.key.six
        
        dataStorage.saveInfo(key: oneKey, value: info.value.one)
        dataStorage.saveInfo(key: twoKey, value: info.value.two)
        dataStorage.saveInfo(key: threeKey, value: info.value.three)
        dataStorage.saveInfo(key: fourKey, value: info.value.four)
        dataStorage.saveInfo(key: fiveKey, collection: info.value.five)
        dataStorage.saveInfo(key: sixKey, value: info.value.five)
        
        let oneWrongCase = dataStorage.getInfo(key: oneKey, type: Int.self)
        let twoWrongCase = dataStorage.getInfo(key: twoKey, type: String.self)
        let threeWrongCase = dataStorage.getInfo(key: threeKey, type: String.self)
        let fourWrongCase = dataStorage.getInfo(key: fourKey, type: String.self)
        let fiveWrongCase = dataStorage.getInfo(key: fiveKey, type: Set<Int>.self)
        let sixWrongCase = dataStorage.getInfo(key: sixKey, type: String.self)
        
        let oneSuccessCase = dataStorage.getInfo(key: oneKey, type: String.self)
        let twoSuccessCase = dataStorage.getInfo(key: twoKey, type: Data.self)
        let threeSuccessCase = dataStorage.getInfo(key: threeKey, type: Date.self)
        let fourSuccessCase = dataStorage.getInfo(key: fourKey, type: Int.self)
        let fiveSuccessCase = dataStorage.getInfo(key: fiveKey, hashable: Set<Int>.self)
        
        XCTAssertNil(oneWrongCase)
        XCTAssertNil(twoWrongCase)
        XCTAssertNil(threeWrongCase)
        XCTAssertNil(fourWrongCase)
        XCTAssertNil(fiveWrongCase)
        XCTAssertNil(sixWrongCase)
        
        XCTAssertNotNil(oneSuccessCase)
        XCTAssertNotNil(twoSuccessCase)
        XCTAssertNotNil(threeSuccessCase)
        XCTAssertNotNil(fourSuccessCase)
        XCTAssertNotNil(fiveSuccessCase)
    }
    
    func testDataRemoving() {
        let oneKey = info.key.one
        let twoKey = info.key.two
        let threeKey = info.key.three
        let fourKey = info.key.four
        let fiveKey = info.key.five
        let sixKey = info.key.six
        
        dataStorage.removeInfo(key: oneKey)
        dataStorage.removeInfo(key: twoKey)
        dataStorage.removeInfo(key: threeKey)
        dataStorage.removeInfo(key: fourKey)
        dataStorage.removeInfo(key: fiveKey)
        dataStorage.removeInfo(key: sixKey)
        
        let oneCase = dataStorage.getInfo(key: oneKey, type: String.self)
        let twoCase = dataStorage.getInfo(key: twoKey, type: Data.self)
        let threeCase = dataStorage.getInfo(key: threeKey, type: Date.self)
        let fourCase = dataStorage.getInfo(key: fourKey, type: Int.self)
        let fiveCase = dataStorage.getInfo(key: fiveKey, type: String.self)
        let sixCase =  dataStorage.getInfo(key: sixKey, hashable: Set<Int>.self)
        
        XCTAssertNil(oneCase)
        XCTAssertNil(twoCase)
        XCTAssertNil(threeCase)
        XCTAssertNil(fourCase)
        XCTAssertNil(fiveCase)
        XCTAssertNil(sixCase)
    }
    
    func testEncryptedDataSaving() {
        let oneKey = info.key.one
        let twoKey = info.key.two
        let sixKey = info.key.six

        dataStorage.saveEncryptedInfo(key: oneKey, .value(info.value.one))
        dataStorage.saveEncryptedInfo(key: twoKey, .data(info.value.two))
        dataStorage.saveEncryptedInfo(key: sixKey, .value(info.key.one))
        
        let oneCase = dataStorage.getEncryptedInfo(key: oneKey)
        let twoCase = dataStorage.getEncryptedInfo(key: twoKey)
        let threeCase = dataStorage.getEncryptedInfo(key: sixKey)
        
        XCTAssertNotNil(oneCase)
        XCTAssertNotNil(twoCase)
        XCTAssertNil(threeCase)
    }
    
    func testEncryptedDataRemoving() {
        let oneKey = info.key.one
        let twoKey = info.key.two
        let sixKey = info.key.six
        
        dataStorage.removeEncryptedInfo(key: oneKey)
        dataStorage.removeEncryptedInfo(key: twoKey)
        dataStorage.removeEncryptedInfo(key: sixKey)
        
        let oneCase = dataStorage.getEncryptedInfo(key: oneKey)?.data
        let twoCase = dataStorage.getEncryptedInfo(key: twoKey)?.value
        let threeCase = dataStorage.getEncryptedInfo(key: sixKey)
        
        XCTAssertNil(oneCase)
        XCTAssertNil(twoCase)
        XCTAssertNil(threeCase)
    }

}

// MARK: - DataStorageTestsInfo
fileprivate struct DataStorageTestsInfo {
    let key = DataStorageTestsKeys()
    let value = DataStorageTestsValues()
}

// MARK: - DataStorageTestsKeys
fileprivate struct DataStorageTestsKeys {
    let one = "OneKeyUserStorageTestСase"
    let two = "TwoKeyUserStorageTestСase"
    let three = "ThreeKeyUserStorageTestСase"
    let four = "FourKeyUserStorageTestСase"
    let five = "FiveKeyUserStorageTestСase"
    let six = ""
}

// MARK: - DataStorageTestsValues
fileprivate struct DataStorageTestsValues {
    let one = UUID().uuidString
    let two = Data()
    let three = Date()
    let four = 5674684684
    let five = Set<Int>()
}
