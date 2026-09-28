import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class TopAlbumsDTOTests: XCTestCase {
    func testPaginationDecodesStringValues() throws {
        let pagination = try decodePagination(page: "2", totalPages: "10")

        XCTAssertEqual(pagination.page, 2)
        XCTAssertEqual(pagination.totalPages, 10)
    }

    func testPaginationAcceptsZeroTotalPages() throws {
        let pagination = try decodePagination(page: "1", totalPages: "0")

        XCTAssertEqual(pagination.page, 1)
        XCTAssertEqual(pagination.totalPages, 0)
    }

    func testPaginationRejectsZeroPage() {
        XCTAssertThrowsError(try decodePagination(page: "0", totalPages: "10"))
    }

    func testPaginationRejectsNegativeTotalPages() {
        XCTAssertThrowsError(try decodePagination(page: "1", totalPages: "-1"))
    }

    func testPaginationRejectsNonNumericValues() {
        XCTAssertThrowsError(try decodePagination(page: "first", totalPages: "many"))
    }

    private func decodePagination(
        page: String,
        totalPages: String
    ) throws -> TopAlbumsDTO.PaginationDTO {
        let json = #"{"page":"\#(page)","totalPages":"\#(totalPages)"}"#
        return try JSONDecoder().decode(
            TopAlbumsDTO.PaginationDTO.self,
            from: Data(json.utf8)
        )
    }
}
