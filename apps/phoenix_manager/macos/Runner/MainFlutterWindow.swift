import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Abrir em ecrã inteiro (sair: Esc ou Controlo+Cmd+F).
    collectionBehavior.insert(.fullScreenPrimary)
    DispatchQueue.main.async { [weak self] in
      guard let self, !self.styleMask.contains(.fullScreen) else { return }
      self.toggleFullScreen(nil)
    }
  }
}
