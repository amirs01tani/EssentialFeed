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
         session.dataTask(with: url) { data, response, error in
             if let error = error {
                 completion(.failure(error))
             } else if let data = data, let response = response as? HTTPURLResponse {
                 completion(.success(data, response))
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
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
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
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(requestError.code, receivedError?.code)
        XCTAssertEqual(requestError.domain, receivedError?.domain)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
       
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        
    }
    
    func test_getFromURL_succeedsOnHTTPULResponseData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
    }
    
    func test_getFromURL_succedsWithEmptyDataOnHTTPULResponseWithNilData() {
        let emptyData = Data()
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: emptyData, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
        
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
    
    private func anyData() -> Data {
        return Data("anv data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL () , mimeType: nil,
                           expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse? {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion:
                                nil, headerFields: nil)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
            switch result {
            case .failure(let error):
                return error
            default:
                XCTFail("Expect failure but received \(result) instead", file: file, line: line)
                return nil
            }
            
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
            switch result {
            case .success(let receivedData, let receivedResponse):
                return (receivedData, receivedResponse)
            case .failure:
                XCTFail("Expected success, but received \(result)", file: file, line: line)
                return nil
            }
            
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        var receivedResult: HTTPClientResult!
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
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
