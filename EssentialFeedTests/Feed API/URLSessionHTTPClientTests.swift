//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/11/23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
     private let session: URLSession

     init(session: URLSession) {
         self.session = session
     }

    func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void) {
         session.dataTask(with: url) { _, _, error in
             if let error = error {
                 completion(.failure(error))
             }
         }.resume()
     }
 }

 class URLSessionHTTPClientTests: XCTestCase {
     
     func test_getFromURL_resumeDataTaskWithURL() {
         let url = URL(string: "http://any-url.com")!
         let session = URLSessionSpy()
         let task = URLSessionDataTaskSpy()
         session.stub(url: url, task: task)
         let sut = URLSessionHTTPClient(session: session)

         sut.get(from: url) { _ in }

         XCTAssertEqual(task.resumeCallCount, 1)
     }
     
     func test_getFromURL_failOnRequestError() {
         let url = URL(string: "http://any-url.com")!
         let session = URLSessionSpy()
         let error = NSError(domain: "Test", code: 1)
         session.stub(url: url, error: error)
         let sut = URLSessionHTTPClient(session: session)
         let expectation = expectation(description: "Wait for completion")
         sut.get(from: url) { result in
             switch result {
             case let .failure(receivedError as NSError):
                 XCTAssertEqual(receivedError, error)
             default:
                 XCTFail("Expect error for url \(url) but received \(result) instead")
             }
             expectation.fulfill()
         }
         
         wait(for: [expectation], timeout: 1.0)
     }

     // MARK: - Helpers
     
     private class URLSessionSpy: URLSession {
         private var stubs = [URL: Stub]()
         
         func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
             stubs[url] = Stub(error: error, task: task)
         }
         
         struct Stub{
             let error: Error?
             let task: URLSessionDataTask
         }
         
         override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
             guard let stub = stubs[url] else {
                 fatalError("Couldn't find stub for the \(url)")
             }
             completionHandler(nil, nil, stub.error)
             return stub.task
         }
     }

     private class FakeURLSessionDataTask: URLSessionDataTask {
         override func resume() {}
     }
     private class URLSessionDataTaskSpy: URLSessionDataTask {
         var resumeCallCount = 0
         
         override func resume() {
             resumeCallCount += 1
         }
     }

 }
