import Foundation

#if DEBUG
public extension DBMockup {
    final class Image: Sendable {
        // MARK: - BONES
        
        // MARK: FOOT
        private static let firstFoot: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.foot.1.foot",
            description: "bo4.vod.side.quests.shield.upgrade.bones.foot.1.foot.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.foot",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        
        private static let secondFoot: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.foot.2.foot",
            description: "bo4.vod.side.quests.shield.upgrade.bones.foot.2.foot.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.foot",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let footImages: [SerializedImageModel] = [firstFoot, secondFoot]
        
        // MARK: HAND
        private static let firstHand: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.hand.1.hand",
            description: "bo4.vod.side.quests.shield.upgrade.bones.hand.1.hand.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.hand",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        
        private static let secondHand: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.hand.2.hand",
            description: "bo4.vod.side.quests.shield.upgrade.bones.hand.2.hand.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.hand",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let handImages: [SerializedImageModel] = [firstHand, secondHand]

        // MARK: LEG
        private static let firstLeg: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.leg.1.leg",
            description: "bo4.vod.side.quests.shield.upgrade.bones.hand.1.hand.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.hand",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        
        private static let secondLeg: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.hand.2.leg",
            description: "bo4.vod.side.quests.shield.upgrade.bones.hand.2.hand.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.hand",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let legImages: [SerializedImageModel] = [firstLeg, secondLeg]

        // MARK: SKULL
        private static let firstSkull: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.skull.1.skull",
            description: "bo4.vod.side.quests.shield.upgrade.bones.skull.1.skull.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.skull",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        
        private static let secondSkull: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.bones.skull.2.skull",
            description: "bo4.vod.side.quests.shield.upgrade.bones.skull.2.skull.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.bones.skull",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let skullImages: [SerializedImageModel] = [firstSkull, secondSkull]

        // MARK: - PIPES
        private static let upstairsFromSpawnPipe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.1.upstairs.from.spawn.1",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.1.upstairs.from.spawn.1.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let rk5WallbuyPipe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.2.rk5.wallbuy",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.2.rk5.wallbuy.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let leftZeusPerkPipe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.3.left.of.zeus.perk",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.3.left.of.zeus.perk.caption",
            position: 2,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let frontSentinelArtifactPipe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.4.window.front.of.sentinel.artifact",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.4.window.front.of.sentinel.artifact.caption",
            position: 3,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let belowSentinelArtifactPipe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.5.below.sentinel.artifact",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.5.below.sentinel.artifact.caption",
            position: 4,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )

        public static let pipesImages: [SerializedImageModel] = [
            upstairsFromSpawnPipe,
            rk5WallbuyPipe,
            leftZeusPerkPipe,
            frontSentinelArtifactPipe,
            belowSentinelArtifactPipe,
        ]

        
        // MARK: - PIPES PICKUP LOCATIONS
        private static let engineRoomPipePickup: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.engine.room",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.engine.room.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let fireworkPipePickup: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.mail.room.firework",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.mail.room.firework.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )

        private static let venusSymbolPipePickup: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.venus.symbol",
            description: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.venus.symbol.caption",
            position: 2,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let pipesPickupLocationsImages: [SerializedImageModel] = [
            engineRoomPipePickup,
            fireworkPipePickup,
            venusSymbolPipePickup
        ]

        // MARK: - SAFES
        private static let upstairsFromSpawnSafe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.safes.upstair.from.spawn",
            description: "bo4.vod.side.quests.shield.upgrade.safes.upstair.from.spawn.caption",
            position: 0,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.safes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let zeusPerkSafe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.safes.zeus.perk",
            description: "bo4.vod.side.quests.shield.upgrade.safes.zeus.perk.caption",
            position: 1,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.safes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let venusSymbolSafe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.safes.venus.symbol",
            description: "bo4.vod.side.quests.shield.upgrade.safes.venus.symbol.caption",
            position: 2,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.safes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let sentinelArtifactSafe: SerializedImageModel = .init(
            name: "bo4.vod.side.quests.shield.upgrade.safes.sentinel.artifact",
            description: "bo4.vod.side.quests.shield.upgrade.safes.sentinel.artifact.caption",
            position: 3,
            searchLabel: nil,
            gallery: "bo4.vod.side.quests.shield.upgrade.safes",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let safesImages: [SerializedImageModel] = [
            upstairsFromSpawnSafe,
            zeusPerkSafe,
            venusSymbolSafe,
            sentinelArtifactSafe
        ]

    }
}
#endif
