//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/11/23.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler:
    @escaping (Data?, URLResponse?, Error?) ->
    Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
     private let session: HTTPSession

     init(session: HTTPSession) {
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
//     redundant
//     func test_getFromURL_createsDataTaskWithURL() {
//         let url = URL(string: "http://any-url.com")!
//         let session = URLSessionSpy()
//         let sut = URLSessionHTTPClient(session: session)
//
//         sut.get(from: url)
//
//         XCTAssertEqual(session.receivedURLs, [url])
//     }
     
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
     
     private class URLSessionSpy: HTTPSession {
         private var stubs = [URL: Stub]()
         
         func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
             stubs[url] = Stub(error: error, task: task)
         }
         
         struct Stub{
             let error: Error?
             let task: HTTPSessionTask
         }
         
         func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
             guard let stub = stubs[url] else {
                 fatalError("Couldn't find stub for the \(url)")
             }
             completionHandler(nil, nil, stub.error)
             return stub.task
         }
     }

     private class FakeURLSessionDataTask: HTTPSessionTask {
         func resume() {}
     }
     private class URLSessionDataTaskSpy: HTTPSessionTask {
         var resumeCallCount = 0
         
         func resume() {
             resumeCallCount += 1
         }
     }

 }
