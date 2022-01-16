import ArgumentParser


@main
struct App {
    static func main() async {
        await ReleaseNotes.main()
    }
}
