import Foundation
import Testing

@testable import RyzeFoundation

struct RyzeEntityAndErrorTests {
    @Test
    func entityDescriptionUsesJSONRepresentation() throws {
        let entity = SampleEntity(name: "Ryze", count: 7)
        let data = try #require(entity.description.data(using: .utf8))
        let decoded: SampleEntity = try data.entity(for: SampleEntity.self)

        #expect(decoded == entity)
    }

    @Test
    func entityDescriptionFallsBackWhenEncodingFails() {
        let entity = BrokenEntity()

        #expect(entity.description == BrokenEncodingError.forced.localizedDescription)
    }

    @Test
    func entityAndEntityArraysCanLogWithoutCrashing() {
        SampleEntity(name: "Ryze", count: 7).log()
        BrokenEntity().log()
        [SampleEntity(name: "Ryze", count: 7)].log()
        [BrokenEntity()].log()
    }

    @Test
    func ryzeErrorLogsDetailedAndMinimalVariants() {
        SampleRyzeError.detailed.log()
        SampleRyzeError.minimal.log()

        #expect(SampleRyzeError.detailed.errorDescription == "Something went wrong")
        #expect(SampleRyzeError.minimal.failureReason == nil)
    }
}
