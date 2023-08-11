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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnextectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult)-> Void) {
         session.dataTask(with: url) { _, _, error in
             if let error = error {
                 completion(.failure(error))
             } else {
                 completion(.failure(UnextectedValuesRepresentation()))
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
    //     redundant
    //     func test_getFromURL_resumeDataTaskWithURL() {
    //         let url = URL(string: "http://any-url.com")!
    //         let session = URLSessionSpy()
    //         let task = URLSessionDataTaskSpy()
    //         session.stub(url: url, task: task)
    //         let sut = URLSessionHTTPClient(session: session)
    //
    //         sut.get(from: url) { _ in }
    //
    //         XCTAssertEqual(task.resumeCallCount, 1)
    //     }
    
    override class func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET" )
            exp.fulfill()
        }
        makeSUT().get(from: anyURL()) { _ in }
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_getFromURL_failOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        let receivedError = resultForError(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(requestError.code, receivedError?.code)
        XCTAssertEqual(requestError.domain, receivedError?.domain)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        XCTAssertNotNil(resultForError(data: nil, response: nil, error: nil))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func resultForError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line ) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let expectation = expectation(description: "Wait for completion")
        var receivedError: Error?
        let sut = makeSUT(file: file, line: line)
        sut.get(from: anyURL()) { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expect failure but received \(result) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        return receivedError
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest)->Void)?
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void){
        requestObserver = observer
        }
        
        struct Stub{
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return URLProtocolStub.stub != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive:response, cacheStoragePolicy:.notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
