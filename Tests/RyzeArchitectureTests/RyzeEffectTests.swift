import Testing

@testable import RyzeArchitecture

struct RyzeEffectTests {
    @Test
    func noneProducesNoActions() async {
        let actions = await collectActions(from: RyzeEffect<CounterAction>.none)

        #expect(actions.isEmpty)
    }

    @Test
    func sendAndSequenceEmitActionsInOrder() async {
        let single = await collectActions(
            from: RyzeEffect<CounterAction>.send(.increment)
        )
        let sequence = await collectActions(
            from: RyzeEffect<CounterAction>.sequence([
                CounterAction.increment,
                .decrement,
            ])
        )

        #expect(single == [CounterAction.increment])
        #expect(sequence == [CounterAction.increment, .decrement])
    }

    @Test
    func runExecutesAsyncWorkAndMergeCollectsAllActions() async {
        let asyncEffect = RyzeEffect<CounterAction>.run { send in
            send(.increment)
        }
        let merged = RyzeEffect.merge(
            RyzeEffect.send(.decrement),
            asyncEffect
        )

        let actions = await collectActions(from: merged)

        #expect(Set(actions) == Set([.increment, .decrement]))
        #expect(actions.count == 2)
    }

    @Test
    func mergeOfEmptyEffectsBehavesLikeNone() async {
        let actions = await collectActions(
            from: RyzeEffect<CounterAction>.merge([])
        )

        #expect(actions.isEmpty)
    }

    @Test
    func mergeSkipsEmptyEffectsAndPreservesSingleNonEmptyEffect() async {
        let actions = await collectActions(
            from: RyzeEffect<CounterAction>.merge([
                .none,
                .sequence([]),
                .send(.increment),
            ])
        )

        #expect(actions == [.increment])
    }
}
