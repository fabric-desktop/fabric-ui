{ stdenv

, meson
, ninja

, pkg-config
, vala

, glib
, gtk4
}:

stdenv.mkDerivation {
  pname = "fabric.ui";
  version = "0.1";

  src = ./.;

  buildInputs = [
    glib
    gtk4
  ];

  nativeBuildInputs = [
    meson
    ninja

    pkg-config
    vala
  ];
}
