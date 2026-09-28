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

    func testGetAlbumInfoRequestsExpectedEndpoint() async throws {
        let client = LastFmAPIClientMock(result: .success(try AlbumInfoResponseDTO.fixture()))
        let repository = LastFmRepository(apiClient: client)

        await repository.getAlbumInfo(
            artist: "Weyes Blood",
            album: "Titanic Rising"
        ) { _ in }.value

        let endpoint = try XCTUnwrap(client.requestedEndpoints.first)
        guard case let .albumInfo(artist, album) = endpoint else {
            return XCTFail("Expected the album info endpoint")
        }
        XCTAssertEqual(artist, "Weyes Blood")
        XCTAssertEqual(album, "Titanic Rising")
    }

    func testGetAlbumInfoReturnsMappedAlbum() async throws {
        let client = LastFmAPIClientMock(result: .success(try AlbumInfoResponseDTO.fixture()))

        let album = try await getAlbumResult(client: client).get()

        XCTAssertEqual(album.name, "Titanic Rising")
        XCTAssertEqual(album.artistName, "Weyes Blood")
        XCTAssertEqual(album.imageURL?.absoluteString, "https://example.com/large.jpg")
        XCTAssertEqual(album.listeners, 1000)
        XCTAssertEqual(album.playcount, 2000)
        XCTAssertEqual(album.tags, ["baroque pop"])
        XCTAssertEqual(album.tracks.first?.name, "A Lot's Gonna Change")
        XCTAssertEqual(album.tracks.first?.duration, 262)
    }

    func testGetAlbumInfoPreservesAPIError() async throws {
        let client = LastFmAPIClientMock(
            result: .failure(LastFmError.api(code: 6, message: "Album not found"))
        )

        let result = try await getAlbumResult(client: client)

        guard case let .failure(.api(code, message)) = result else {
            return XCTFail("Expected the original API error")
        }
        XCTAssertEqual(code, 6)
        XCTAssertEqual(message, "Album not found")
    }

    func testGetTopAlbumsRequestsExpectedEndpoint() async throws {
        let client = LastFmAPIClientMock(result: .success(TopAlbumsResponseDTO.fixture()))
        let repository = LastFmRepository(apiClient: client)

        await repository.getTopAlbums(
            username: "listener",
            period: .month,
            page: 3,
            limit: 16
        ) { _ in }.value

        let endpoint = try XCTUnwrap(client.requestedEndpoints.first)
        guard case let .topAlbums(username, period, page, limit) = endpoint else {
            return XCTFail("Expected the top albums endpoint")
        }
        XCTAssertEqual(username, "listener")
        XCTAssertEqual(period, .month)
        XCTAssertEqual(page, 3)
        XCTAssertEqual(limit, 16)
    }

    func testGetTopAlbumsReturnsMappedPage() async throws {
        let client = LastFmAPIClientMock(result: .success(TopAlbumsResponseDTO.fixture()))

        let page = try await getTopAlbumsResult(client: client).get()

        XCTAssertEqual(page.page, 2)
        XCTAssertEqual(page.totalPages, 4)
        XCTAssertEqual(page.albums.count, 1)
        XCTAssertEqual(page.albums.first?.name, "Titanic Rising")
        XCTAssertEqual(page.albums.first?.artistName, "Weyes Blood")
        XCTAssertEqual(page.albums.first?.imageURL?.absoluteString, "https://example.com/large.jpg")
        XCTAssertEqual(page.albums.first?.playcount, 100)
    }

    func testGetTopAlbumsPreservesNetworkError() async throws {
        let client = LastFmAPIClientMock(
            result: .failure(LastFmError.network(URLError(.notConnectedToInternet)))
        )

        let result = try await getTopAlbumsResult(client: client)

        guard case let .failure(.network(error)) = result else {
            return XCTFail("Expected the original network error")
        }
        XCTAssertEqual(error.code, .notConnectedToInternet)
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

    private func getAlbumResult(
        client: LastFmAPIClientMock,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> Result<Album, LastFmError> {
        let repository = LastFmRepository(apiClient: client)
        var results: [Result<Album, LastFmError>] = []

        await repository.getAlbumInfo(
            artist: "Weyes Blood",
            album: "Titanic Rising"
        ) { results.append($0) }.value

        XCTAssertEqual(results.count, 1, "Completion must run exactly once", file: file, line: line)
        return try XCTUnwrap(results.first, file: file, line: line)
    }

    private func getTopAlbumsResult(
        client: LastFmAPIClientMock,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> Result<TopAlbumsPage, LastFmError> {
        let repository = LastFmRepository(apiClient: client)
        var results: [Result<TopAlbumsPage, LastFmError>] = []

        await repository.getTopAlbums(
            username: "listener",
            period: .week,
            page: 1,
            limit: 9
        ) { results.append($0) }.value

        XCTAssertEqual(results.count, 1, "Completion must run exactly once", file: file, line: line)
        return try XCTUnwrap(results.first, file: file, line: line)
    }
}
