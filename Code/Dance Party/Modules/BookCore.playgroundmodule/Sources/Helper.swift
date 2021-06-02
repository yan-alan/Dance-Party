//
//  Constants.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-06.
//

import Foundation
import UIKit

public struct Helper {
    static let bottomApple = ["left_ear_joint": CGPoint(x:659.2867398262024, y:1388.7280654907227),"left_foot_joint": CGPoint(x:813.3831882476807, y:279.28985595703125),"root": CGPoint(x:620.0035411119461, y:890.4067611694336),"right_ear_joint": CGPoint(x:538.6051654815674, y:1378.0718994140625),"right_eye_joint": CGPoint(x:564.6881461143494, y:1403.7249755859375),"left_hand_joint": CGPoint(x:1048.0872702598572, y:1280.5160675048828),"right_upLeg_joint": CGPoint(x:533.1159818172455, y:880.2220916748047),"right_shoulder_1_joint": CGPoint(x:467.9371118545532, y:1249.8803329467773),"right_hand_joint": CGPoint(x:117.27930754423141, y:1264.6561431884766),"right_foot_joint": CGPoint(x:495.9808623790741, y:260.01983642578125),"head_joint": CGPoint(x:590.0667572021484, y:1381.3025665283203),"left_forearm_joint": CGPoint(x:917.520215511322, y:1210.9496307373047),"right_forearm_joint": CGPoint(x:255.63504695892334, y:1190.1056823730469),"left_eye_joint": CGPoint(x:613.2441973686218, y:1409.8887634277344),"left_leg_joint": CGPoint(x:765.6561064720154, y:596.4177703857422),"right_leg_joint": CGPoint(x:520.9495782852173, y:564.8242950439453),"left_shoulder_1_joint": CGPoint(x:735.5682492256165, y:1261.3245391845703),"left_upLeg_joint": CGPoint(x:706.8911004066467, y:900.5914306640625),"neck_1_joint": CGPoint(x:601.7526805400848, y:1255.6024360656738)]
    static let leftApple = ["right_hand_joint": CGPoint(x: 63.58763739466667, y:1290.0420532226562),"left_forearm_joint": CGPoint(x: 868.5757756233215, y:1264.4577026367188),"right_upLeg_joint": CGPoint(x: 465.055775642395, y:897.0174407958984),"left_eye_joint": CGPoint(x: 584.3869972229004, y:1405.9098815917969),"left_hand_joint": CGPoint(x: 1046.7243003845215, y:1357.3808288574219),"right_eye_joint": CGPoint(x: 535.3261005878448, y:1400.233154296875),"right_shoulder_1_joint": CGPoint(x: 428.63439202308655, y:1220.8806228637695),"right_foot_joint": CGPoint(x: 433.23667645454407, y:327.54981994628906),"left_leg_joint": CGPoint(x: 612.2325754165649, y:625.7862854003906),"left_ear_joint": CGPoint(x: 618.0995965003967, y:1379.5544815063477),"right_leg_joint": CGPoint(x: 464.92828488349915, y:614.2664337158203),"left_foot_joint": CGPoint(x: 604.2579817771912, y:320.16929626464844),"right_forearm_joint": CGPoint(x: 246.86362981796265, y:1232.8457260131836),"right_ear_joint": CGPoint(x: 501.1593496799469, y:1371.342430114746),"left_upLeg_joint": CGPoint(x: 624.1059851646423, y:902.7838897705078),"root": CGPoint(x: 544.5808804035187, y:899.9006652832031),"head_joint": CGPoint(x: 560.8164310455322, y:1378.9512634277344),"left_shoulder_1_joint": CGPoint(x: 680.775032043457, y:1210.9918975830078),"neck_1_joint": CGPoint(x: 554.7047120332718, y:1255.9362602233887)]
    static let rightSideApple = ["right_hand_joint": CGPoint(x: 144.61037635803223, y:1642.8302764892578)," left_forearm_joint": CGPoint(x: 796.0907936096191, y:1270.0368118286133)," right_upLeg_joint": CGPoint(x: 414.5529878139496, y:940.576286315918)," left_eye_joint": CGPoint(x: 500.64327120780945, y:1435.8501434326172)," left_hand_joint": CGPoint(x: 993.0401015281677, y:1264.2988586425781)," right_eye_joint": CGPoint(x: 455.2470016479492, y:1433.6872100830078)," right_shoulder_1_joint": CGPoint(x: 378.1617307662964, y:1325.9477233886719)," right_foot_joint": CGPoint(x: 502.77759075164795, y:355.4248809814453)," left_leg_joint": CGPoint(x: 580.0991749763489, y:651.606330871582)," left_ear_joint": CGPoint(x: 541.1286520957947, y:1419.7984313964844)," right_leg_joint": CGPoint(x: 470.15724062919617, y:619.8331832885742)," left_foot_joint": CGPoint(x: 569.5543599128723, y:294.1321563720703)," right_forearm_joint": CGPoint(x: 249.6608465909958, y:1485.2641296386719)," right_ear_joint": CGPoint(x: 425.0646507740021, y:1409.6145629882812)," left_upLeg_joint": CGPoint(x: 583.8306212425232, y:947.2614669799805)," root": CGPoint(x: 499.1918045282364, y:943.9188766479492)," head_joint": CGPoint(x: 478.58839988708496, y:1411.911735534668)," left_shoulder_1_joint": CGPoint(x: 620.3162169456482, y:1297.8521347045898)," neck_1_joint": CGPoint(x: 499.2389738559723, y:1311.8999290466309)]
    static let middleRight = ["left_forearm_joint": CGPoint(x: 860.1478672027588, y: 1264.8003387451172),"head_joint": CGPoint(x: 560.1822924613953, y: 1482.4536895751953),"left_leg_joint": CGPoint(x: 644.7965669631958, y: 670.8388137817383),"left_hand_joint": CGPoint(x: 1047.0735239982605, y: 1288.136100769043),"right_shoulder_1_joint": CGPoint(x: 420.51225543022156, y: 1403.371696472168),"right_hand_joint": CGPoint(x: 260.6685516834259, y: 1807.9524612426758),"right_upLeg_joint": CGPoint(x: 429.4137239456177, y: 982.2681427001953),"neck_1_joint": CGPoint(x: 553.9178162813187, y: 1366.758213043213),"right_leg_joint": CGPoint(x: 402.7322995662689, y: 689.3615341186523),"left_ear_joint": CGPoint(x: 618.5836815834045, y: 1478.1798934936523),"right_eye_joint": CGPoint(x: 533.1130850315094, y: 1508.0794143676758),"left_foot_joint": CGPoint(x: 697.1040844917297, y: 386.8309020996094),"right_ear_joint": CGPoint(x: 493.995920419693, y: 1493.1868743896484),"left_shoulder_1_joint": CGPoint(x: 687.3233771324158, y: 1330.1447296142578),"left_upLeg_joint": CGPoint(x: 604.5376825332642, y: 974.714469909668),"right_forearm_joint": CGPoint(x: 380.1266202926636, y: 1640.6976623535156),"root": CGPoint(x: 516.9757032394409, y: 978.4913063049316),"left_eye_joint": CGPoint(x: 586.3476061820984, y: 1505.8243560791016),"right_foot_joint": CGPoint(x: 344.00115966796875, y: 362.0822525024414)]
    
    
    static let topApple = ["head_joint": CGPoint(x: 474.91347312927246, y: 1461.6494750976562),"left_upLeg_joint": CGPoint(x: 548.0062651634216, y: 984.5962142944336),"left_hand_joint": CGPoint(x: 930.7908797264099, y: 1280.2945556640625),"right_upLeg_joint": CGPoint(x: 387.56585597991943, y: 976.0541152954102),"right_eye_joint": CGPoint(x: 451.0827434062958, y: 1487.5833892822266),"left_foot_joint": CGPoint(x: 633.0285358428955, y: 422.29625701904297),"left_ear_joint": CGPoint(x: 527.2256577014923, y: 1460.2486038208008),"right_hand_joint": CGPoint(x: 34.66002121567726, y: 1280.4026107788086),"left_forearm_joint": CGPoint(x: 764.879150390625, y: 1249.2091369628906),"right_foot_joint": CGPoint(x: 397.4089729785919, y: 406.7223358154297),"right_leg_joint": CGPoint(x: 400.5564272403717, y: 704.3099212646484),"root": CGPoint(x: 467.78606057167053, y: 980.3251647949219),"right_forearm_joint": CGPoint(x: 175.95248758792877, y: 1254.4609451293945),"left_leg_joint": CGPoint(x: 585.1809740066528, y: 696.7926406860352),"right_ear_joint": CGPoint(x: 409.2678987979889, y: 1466.0913848876953),"right_shoulder_1_joint": CGPoint(x: 346.47810459136963, y: 1326.6337966918945),"neck_1_joint": CGPoint(x: 469.1461980342865, y: 1328.8103485107422),"left_eye_joint": CGPoint(x: 498.81478786468506, y: 1484.6107864379883),"left_shoulder_1_joint": CGPoint(x: 591.8142914772034, y: 1330.9869003295898)]
    
    static let topRight = ["right_ear_joint": CGPoint(x: 480.1718473434448, y: 1498.3110809326172),"right_forearm_joint": CGPoint(x: 325.3848671913147, y: 1651.5631103515625),"left_shoulder_1_joint": CGPoint(x: 703.3922982215881, y: 1388.7474060058594),"left_foot_joint": CGPoint(x: 640.5800700187683, y: 169.5673370361328),"left_ear_joint": CGPoint(x: 625.170521736145, y: 1488.2648849487305),"left_eye_joint": CGPoint(x: 591.3565349578857, y: 1524.667854309082),"head_joint": CGPoint(x: 567.0151019096375, y: 1497.663688659668),"left_leg_joint": CGPoint(x: 652.0692372322083, y: 549.1564178466797),"left_forearm_joint": CGPoint(x: 888.9260172843933, y: 1500.4828262329102),"right_foot_joint": CGPoint(x: 460.2038848400116, y: 221.1068344116211),"left_upLeg_joint": CGPoint(x: 673.5098934173584, y: 918.3175277709961),"right_leg_joint": CGPoint(x: 458.95652890205383, y: 531.1277389526367),"right_upLeg_joint": CGPoint(x: 475.0776243209839, y: 915.941162109375),"right_shoulder_1_joint": CGPoint(x: 421.33339762687683, y: 1355.3643035888672),"root": CGPoint(x: 574.2937588691711, y: 917.1293449401855),"left_hand_joint": CGPoint(x: 1044.1099190711975, y: 1512.5047302246094),"right_hand_joint": CGPoint(x: 355.0057888031006, y: 1757.728385925293),"right_eye_joint": CGPoint(x: 534.8114383220673, y: 1528.7570571899414),"neck_1_joint": CGPoint(x: 562.3628479242325, y: 1372.0558547973633)]

    static let leaf = ["right_forearm_joint": CGPoint(x: 306.6883063316345, y: 1555.1069641113281),"right_shoulder_1_joint": CGPoint(x: 404.4702422618866, y: 1351.2240600585938),"left_shoulder_1_joint": CGPoint(x: 673.5779356956482, y: 1375.5497360229492),"right_upLeg_joint": CGPoint(x: 446.9652843475342, y: 872.2360610961914),"neck_1_joint": CGPoint(x: 539.0240889787674, y: 1363.3868980407715),"left_foot_joint": CGPoint(x: 733.7457203865051, y: 167.72586822509766),"left_ear_joint": CGPoint(x: 606.8452620506287, y: 1460.881576538086),"head_joint": CGPoint(x: 538.7545430660248, y: 1459.518928527832),"left_forearm_joint": CGPoint(x: 733.572428226471, y: 1589.9052429199219),"right_hand_joint": CGPoint(x: 400.5054438114166, y: 1781.8785095214844),"right_leg_joint": CGPoint(x: 348.0317151546478, y: 534.2239379882812),"right_ear_joint": CGPoint(x: 452.6137590408325, y: 1460.679817199707),"left_leg_joint": CGPoint(x: 718.8240551948547, y: 519.1028594970703),"root": CGPoint(x: 551.0871255397797, y: 875.1739311218262),"left_eye_joint": CGPoint(x: 565.7461166381836, y: 1485.5907440185547),"left_hand_joint": CGPoint(x: 603.02729845047, y: 1797.2638320922852),"right_foot_joint": CGPoint(x: 320.68750619888306, y: 252.1245574951172),"right_eye_joint": CGPoint(x: 501.6062915325165, y: 1484.5995712280273),"left_upLeg_joint": CGPoint(x: 655.2089667320251, y: 878.1118011474609)]

    static let topLeft = ["right_leg_joint": CGPoint(x: 294.546879529953, y: 537.4724578857422),"left_upLeg_joint": CGPoint(x: 565.3901982307434, y: 855.1902008056641),"right_ear_joint": CGPoint(x: 416.3528573513031, y: 1431.0778427124023),"left_hand_joint": CGPoint(x: 954.2224907875061, y: 1503.9250946044922),"right_hand_joint": CGPoint(x: 32.0565390586853, y: 1488.7007904052734),"left_leg_joint": CGPoint(x: 601.3174867630005, y: 532.3740005493164),"left_forearm_joint": CGPoint(x: 829.0365815162659, y: 1350.5766296386719),"left_foot_joint": CGPoint(x: 615.7637572288513, y: 255.44586181640625),"left_shoulder_1_joint": CGPoint(x: 627.3502564430237, y: 1288.9759826660156),"right_eye_joint": CGPoint(x: 463.5398232936859, y: 1456.0348892211914),"right_forearm_joint": CGPoint(x: 140.67472279071808, y: 1390.0182495117188),"root": CGPoint(x: 472.95817494392395, y: 861.6046142578125),"right_upLeg_joint": CGPoint(x: 380.5261516571045, y: 868.0190277099609),"left_ear_joint": CGPoint(x: 553.5956454277039, y: 1416.7298126220703),"head_joint": CGPoint(x: 495.255571603775, y: 1417.881088256836),"right_foot_joint": CGPoint(x: 231.94214165210724, y: 161.50245666503906),"right_shoulder_1_joint": CGPoint(x: 341.7700231075287, y: 1280.203514099121),"left_eye_joint": CGPoint(x: 522.446540594101, y: 1443.3592987060547),"neck_1_joint": CGPoint(x: 484.5601397752762, y: 1284.5897483825684)]

    static let builtInTracks: [Track] = [.init(fileName: "ymca", trackName: "YMCA", author: "Village People"), .init(fileName: "chacha", trackName: "Cha-cha Slide", author: "MC JIG")]
    
    static var addedTracks: [Track] = []
    
    static var allTracks: [Track] {
        return builtInTracks + addedTracks
    }
    static func findKeyPoints(in cachedObservations: [Pose], completion: @escaping ([Pose]) -> ()) {
        DispatchQueue(label: "com.alanyan.WWDC2021.find.key.points").async {
            let observations = cachedObservations.filter({$0.hasFullSkeleton})
            var keyPoses: [Pose] = []
            guard observations.count > 3 else { completion([]); return }
            
            var i = 0
            while i < observations.count - 1 {
                let observation = observations[i]
                for j in i+1..<observations.count {
                    if observation.absoluteDistance(to: observations[j]) > 4 || j == observations.count - 1 {
                        i = j
                        keyPoses.append(observations[i])
                        break
                    }
                }
            }
            
            var timeSpacedKeyPoses: [Pose] = []
            for keyPose in keyPoses {
                guard !timeSpacedKeyPoses.isEmpty else {
                    timeSpacedKeyPoses.append(keyPose)
                    continue
                }
                if keyPose.time - timeSpacedKeyPoses.last!.time < 0.4 {
                    continue
                }
                timeSpacedKeyPoses.append(keyPose)
            }
            
            completion(timeSpacedKeyPoses)
        }
    }
}
