import Foundation
import ReleaseNotesCore


let group = DispatchGroup()
group.enter()
Task {
    defer { group.leave() }
    await App.main()
}

group.wait()
