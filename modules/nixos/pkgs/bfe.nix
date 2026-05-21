{
  perSystem =
    { pkgs, ... }:
    with pkgs;
    {
      packages.bfe = stdenv.mkDerivation {
        pname = "bfe";
        version = "1999-04-23";

        src = fetchurl {
          url = "https://www.complang.tuwien.ac.at/ublu/tools/bfe.tar.gz";
          hash = "sha256-oxsn08AkO5pDtE7dcjIYQr8r6uloZ7h0JvWbVxfOrSM=";
        };

        installPhase = ''
          mkdir -p $out/bin $out/lib
          cp local/bin/bfe $out/bin/
          cp local/lib/bfe.awk $out/lib/
          substituteInPlace $out/bin/bfe \
            --replace /usr/local/lib/bfe.awk $out/lib/bfe.awk
        '';

        meta = with lib; {
          description = "Preprocessor for iburg (Burg Fast Extractor)";
          homepage = "https://www.complang.tuwien.ac.at/ublu/tools/";
          # Should be licenses.unfree , right?
          license = licenses.mit;
          maintainers = [ ];
          platforms = platforms.unix;
        };
      };
    };
}
