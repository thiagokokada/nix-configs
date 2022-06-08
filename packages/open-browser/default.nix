{ python3
, makeDesktopItem
}:

python3.pkgs.buildPythonApplication rec {
  pname = "open-browser";
  version = "0.1";

  src = ./.;

  desktopItem = makeDesktopItem {
    categories = [
      "Application"
      "Network"
      "WebBrowser"
    ];
    comment = "Open browser according to user preference";
    desktopName = "open-browser";
    exec = "open-browser %u";
    mimeTypes = [
      "x-scheme-handler/unknown"
      "x-scheme-handler/about"
      "x-scheme-handler/https"
      "x-scheme-handler/http"
      "text/xml"
      "application/xhtml+xml"
    ];
    name = "open-browser";
    startupNotify = true;
    terminal = false;
    type = "Application";
  };

  postInstall = ''
    install -Dm644 ${desktopItem}/share/applications/*.desktop -t $out/share/applications
  '';
}
