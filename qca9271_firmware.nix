{ stdenv, fetchurl}:

stdenv.mkDerivation rec {
  version = "1.4.0";
  name = "qca9271-${version}";
  src = fetchurl {
    url = "https://github.com/olerem/ath9k-htc-firmware-blob/raw/master/htc_9271.fw";
    sha256 = "88895d5190d6a558937c4e1797bdb12b44f543204e8572097cfe955e4fe8fd23";
  };
  dontBuild = true;
  unpackPhase = ''
    cp "$src" .
  '';

  installPhase = ''
    mkdir -p "$out/lib/firmware"
    cp "$src" "$out/lib/firmware/htc_9271.fw"
  '';

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  meta = with stdenv.lib; {
    description = "Binary firmware for QCA9271 chipset";
    homepage = https://github.com/olerem/ath9k-htc-firmware-blob;
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };

  passthru = { inherit version; };
}
