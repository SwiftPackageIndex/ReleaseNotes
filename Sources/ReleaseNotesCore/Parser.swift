import Parsing


enum Parser {

    static let dependencyCount = Int.parser()
        .skip(" dependency has changed:".orElse(" dependencies have changed:"))

}
