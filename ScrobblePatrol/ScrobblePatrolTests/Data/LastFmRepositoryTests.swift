import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class LastFmRepositoryTests: XCTestCase {
    func testGetRecentTracksRequestsExpectedEndpoint() async throws {
        let client = LastFmAPIClientMock(result: .success(RecentTracksResponseDTO.fixture(tracks: [], page: 1, totalPages: 0)))
        let repository = LastFmRepository(apiClient: client)

        await repository.getRecentTracks(username: "listener", page: 3) { _ in }.value

        XCTAssertEqual(client.requestedEndpoints.count, 1)
        let endpoint = try XCTUnwrap(client.requestedEndpoints.first)
        switch endpoint {
        case let .recentTracks(username, page):
            XCTAssertEqual(username, "listener")
            XCTAssertEqual(page, 3)
        default:
            XCTFail("Expected the recent tracks endpoint")
        }
    }

    func testGetRecentTracksReturnsMappedPage() async throws {
        let client = LastFmAPIClientMock(result: .success(RecentTracksResponseDTO.fixture()))

        let page = try await getResult(client: client).get()

        XCTAssertEqual(page.page, 2)
        XCTAssertEqual(page.totalPages, 4)
        XCTAssertEqual(page.scrobbles.count, 1)
        let track = try XCTUnwrap(page.scrobbles.first)
        XCTAssertEqual(track.trackName, "Everything In Its Right Place")
        XCTAssertEqual(track.artistName, "Radiohead")
        XCTAssertEqual(track.albumName, "Kid A")
        XCTAssertEqual(track.imageURL?.absoluteString, "https://example.com/large.jpg")
        XCTAssertEqual(track.playedAt, Date(timeIntervalSince1970: 1700000000))
        XCTAssertFalse(track.isNowPlaying)
    }

    func testGetRecentTracksSupportsNowPlayingWithoutOptionalFields() async throws {
        let client = LastFmAPIClientMock(result: .success(RecentTracksResponseDTO.fixture(
            tracks: [.fixture(
                name: "Idioteque",
                album: nil,
                images: nil,
                timestamp: nil,
                nowPlaying: "true"
            )],
            page: 1,
            totalPages: 1
        )))

        let page = try await getResult(client: client).get()
        let track = try XCTUnwrap(page.scrobbles.first)

        XCTAssertEqual(track.trackName, "Idioteque")
        XCTAssertTrue(track.isNowPlaying)
        XCTAssertNil(track.albumName)
        XCTAssertNil(track.imageURL)
        XCTAssertNil(track.playedAt)
    }

    func testGetRecentTracksReturnsEmptyPageAsSuccess() async throws {
        let client = LastFmAPIClientMock(result: .success(RecentTracksResponseDTO.fixture(tracks: [], page: 1, totalPages: 0)))

        let page = try await getResult(client: client).get()

        XCTAssertTrue(page.scrobbles.isEmpty)
        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.totalPages, 0)
    }

    func testGetRecentTracksPreservesAPIError() async throws {
        let client = LastFmAPIClientMock(result: .failure(LastFmError.api(code: 6, message: "User not found")))

        let result = try await getResult(client: client)

        guard case let .failure(.api(code, message)) = result else {
            return XCTFail("Expected the original API error")
        }
        XCTAssertEqual(code, 6)
        XCTAssertEqual(message, "User not found")
    }

    func testGetRecentTracksPreservesNetworkError() async throws {
        let client = LastFmAPIClientMock(result: .failure(LastFmError.network(URLError(.notConnectedToInternet))))

        let result = try await getResult(client: client)

        guard case let .failure(.network(error)) = result else {
            return XCTFail("Expected the original network error")
        }
        XCTAssertEqual(error.code, .notConnectedToInternet)
    }

    func testGetRecentTracksPreservesDecodingError() async throws {
        let underlying = NSError(domain: "FixtureDecoding", code: 1)
        let client = LastFmAPIClientMock(result: .failure(LastFmError.decoding(underlying)))

        let result = try await getResult(client: client)

        guard case let .failure(.decoding(error)) = result else {
            return XCTFail("Expected the original decoding error")
        }
        XCTAssertEqual(error as NSError, underlying)
    }

    func testGetRecentTracksConvertsCancellationError() async throws {
        let client = LastFmAPIClientMock(result: .failure(CancellationError()))

        let result = try await getResult(client: client)

        guard case .failure(.cancelled) = result else {
            return XCTFail("Expected cancellation")
        }
    }

    func testCancelledTaskDoesNotDeliverSuccess() async throws {
        let client = LastFmAPIClientMock(result: .success(RecentTracksResponseDTO.fixture()))
        let repository = LastFmRepository(apiClient: client)
        var results: [Result<RecentScrobblesPage, LastFmError>] = []

        let task = repository.getRecentTracks(username: "listener") { results.append($0) }
        task.cancel()
        await task.value

        XCTAssertEqual(results.count, 1)
        guard case .failure(.cancelled) = try XCTUnwrap(results.first) else {
            return XCTFail("A cancelled request must not deliver success")
        }
    }

    func testGetRecentTracksWrapsUnexpectedError() async throws {
        let underlying = NSError(domain: "Unexpected", code: 42)
        let client = LastFmAPIClientMock(result: .failure(underlying))

        let result = try await getResult(client: client)

        guard case let .failure(.unexpected(error)) = result else {
            return XCTFail("Expected an unexpected error")
        }
        XCTAssertEqual(error as NSError, underlying)
    }

    private func getResult(
        client: LastFmAPIClientMock,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> Result<RecentScrobblesPage, LastFmError> {
        let repository = LastFmRepository(apiClient: client)
        var results: [Result<RecentScrobblesPage, LastFmError>] = []

        await repository.getRecentTracks(username: "listener") { results.append($0) }.value

        XCTAssertEqual(results.count, 1, "Completion must run exactly once", file: file, line: line)
        return try XCTUnwrap(results.first, file: file, line: line)
    }
}
