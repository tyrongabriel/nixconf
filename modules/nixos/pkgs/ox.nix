{
  perSystem =
    { pkgs, ... }:
    {
      packages.ox = pkgs.stdenv.mkDerivation rec {
        pname = "ox-attribute-grammar-compiler";
        version = "1.12.3";

        src = pkgs.fetchurl {
          url = "https://downloads.sourceforge.net/project/ox-attribute-grammar-compiler/ox-${version}/ox-${version}.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fox-attribute-grammar-compiler%2Ffiles%2Fox-${version}%2Fox-${version}.tar.gz%2Fdownload&use_mirror=netcologne";
          hash = "sha256:0sr4b06r7plvp4nifhh7xk8c8s0aiqflcwqw9m5fxdjv0pqwiv08";
        };

        nativeBuildInputs = with pkgs; [
          bison
          flex
        ];

        meta = with pkgs.lib; {
          description = "Attribute Grammar Compiler (OX)";
          homepage = "https://sourceforge.net/projects/ox-attribute-grammar-compiler/";
          license = pkgs.lib.licenses.gpl2;
          maintainers = [ ];
          platforms = pkgs.lib.platforms.unix;
        };
      };
    };

}
