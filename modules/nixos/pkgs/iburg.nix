{
  perSystem =
    { pkgs, ... }:
    with pkgs;
    {
      packages.iburg = stdenv.mkDerivation {
        pname = "iburg";
        version = "0.9";

        src = fetchurl {
          url = "https://www.complang.tuwien.ac.at/ublu/tools/iburg09.tar.gz";
          hash = "sha256-8iCGGF39QOfugfXyqxcpHctrhIACNXxe6kj7wppld1U=";
        };

        nativeBuildInputs = [ bison ];

        env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";

        installPhase = ''
          mkdir -p $out/bin $out/share/man/man1
          cp iburg $out/bin/
          cp iburg.1 $out/share/man/man1/
        '';

        meta = with lib; {
          description = "A Tree Parser Generator (code generator generator)";
          homepage = "https://www.complang.tuwien.ac.at/ublu/tools/";
          # Should be licenses.unfreeRedistributable , right?
          license = licenses.mit;
          maintainers = [ ];
          platforms = platforms.unix;
        };
      };
    };
}
