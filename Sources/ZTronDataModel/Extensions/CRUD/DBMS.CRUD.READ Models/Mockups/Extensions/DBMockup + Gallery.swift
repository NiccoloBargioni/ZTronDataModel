import Foundation

#if DEBUG
public extension DBMockup {
    final class Gallery: Sendable {
        /// Modelling the following gallery graph
        ///
        ///                          ----------------Shield Upgrade--------------
        ///                         /              /              \             \
        ///                ------bones -----    pipes           pickups         safes
        ///               /     /      \     \
        ///         skull     foot    hand    leg
        private static let bonesGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.bones",
            position: 0,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.bones.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )


        private static let bonesSkullGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.bones.skull",
            position: 0,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.bones.skull.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )


        private static let bonesFootGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.bones.foot",
            position: 1,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.bones.foot.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )


        private static let bonesHandGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.bones.hand",
            position: 2,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.bones.hand.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )


        private static let bonesLegGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.bones.leg",
            position: 3,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.bones.leg.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )


        private static let pipesGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.pipes",
            position: 1,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.pipes.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        
        private static let pipesPickupsGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations",
            position: 2,
            assetsImageName: "bo4.vod.side.quests.shield.upgrade.pipes.pickup.locations.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        private static let safesGallery = SerializedGalleryModel(
            name: "bo4.vod.side.quests.shield.upgrade.safes",
            position: 3,
            assetsImageName: "bo4.vod.easter.egg.shield.upgrade.safes.icon",
            tool: "bo4.vod.side.quests.shield.upgrade.tool.name",
            tab: "side quests",
            map: "voyage of despair",
            game: "black ops 4"
        )
        
        public static let rootGalleries: [SerializedGalleryModel] = [
            bonesGallery, pipesGallery, pipesPickupsGallery, safesGallery
        ]
        
        public static let bonesSubgalleries: [SerializedGalleryModel] = [
            bonesFootGallery, bonesHandGallery, bonesLegGallery, bonesSkullGallery
        ]
    }
    
    
}
#endif
