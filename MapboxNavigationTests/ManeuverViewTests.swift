import XCTest
import FBSnapshotTestCase
import MapboxDirections
@testable import MapboxNavigation
@testable import MapboxCoreNavigation


class ManeuverViewTests: FBSnapshotTestCase {
    
    let maneuverView = ManeuverView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
    
    override func setUp() {
        super.setUp()
        maneuverView.backgroundColor = .white
        recordMode = false
        isDeviceAgnostic = true
        
        let window = UIWindow(frame: maneuverView.bounds)
        window.addSubview(maneuverView)
    }
    
    func maneuverInstruction(_ maneuverType: ManeuverType, _ maneuverDirection: ManeuverDirection, _ degrees: CLLocationDegrees = 180) -> VisualInstruction {
        let component = VisualInstructionComponent(type: .delimiter, text: "", imageURL: nil, abbreviation: nil, abbreviationPriority: 0)
        return VisualInstruction(text: "", maneuverType: maneuverType, maneuverDirection: maneuverDirection, components: [component], degrees: degrees)
    }
    
    func testStraightRoundabout() {
        maneuverView.visualInstruction = maneuverInstruction(.takeRoundabout, .straightAhead)
        FBSnapshotVerifyLayer(maneuverView.layer)
    }
    
    func testTurnRight() {
        maneuverView.visualInstruction = maneuverInstruction(.turn, .right)
        FBSnapshotVerifyLayer(maneuverView.layer)
    }
    
    func testTurnSlightRight() {
        maneuverView.visualInstruction = maneuverInstruction(.turn, .slightRight)
        FBSnapshotVerifyLayer(maneuverView.layer)
    }
    
    func testMergeRight() {
        maneuverView.visualInstruction = maneuverInstruction(.merge, .right)
        FBSnapshotVerifyLayer(maneuverView.layer)
    }
    
    func testRoundaboutTurnLeft() {
        maneuverView.visualInstruction = maneuverInstruction(.takeRoundabout, .right, CLLocationDegrees(270))
        FBSnapshotVerifyLayer(maneuverView.layer)
    }
    
    func testLeftUTurn() {
        maneuverView.drivingSide = .right
        maneuverView.visualInstruction = maneuverInstruction(.turn, .uTurn)
        // Layer transformations are not rendered when snapshotting so we
        // manually flip the U-turn for right-hand rule of the road in this test.
        let image = maneuverView.asImage()
        let flipped = UIImage(cgImage: image.cgImage!, scale: UIScreen.main.scale, orientation: .upMirrored)
        let imageView = UIImageView(image: flipped)
        FBSnapshotVerifyView(imageView)
    }
    
    func testRightUTurn() {
        maneuverView.drivingSide = .left
        maneuverView.visualInstruction = maneuverInstruction(.turn, .uTurn)
        FBSnapshotVerifyLayer(maneuverView.layer)
        let image = maneuverView.asImage()
        let imageView = UIImageView(image: image)
        FBSnapshotVerifyView(imageView)
    }
    
    func testRoundabout() {
        let incrementer: CGFloat = 45
        let size = CGSize(width: maneuverView.bounds.width * (360 / incrementer), height: maneuverView.bounds.height)
        let views = UIView(frame: CGRect(origin: .zero, size: size))
        
        for bearing in stride(from: CGFloat(0), to: CGFloat(360), by: incrementer) {
            let position = CGPoint(x: maneuverView.bounds.width * (bearing / incrementer), y: 0)
            let view = ManeuverView(frame: CGRect(origin: position, size: maneuverView.bounds.size))
            view.backgroundColor = .white
            view.visualInstruction = maneuverInstruction(.takeRoundabout, .right, CLLocationDegrees(bearing))
            views.addSubview(view)
        }
        
        FBSnapshotVerifyLayer(views.layer)
    }
    
    // TODO: Figure out why the flip transformation do not render in a snapshot so we can test left turns and left side rule of the road.
}

extension UIView {
    
    func asImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
