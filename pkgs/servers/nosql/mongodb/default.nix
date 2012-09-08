{ stdenv, fetchurl, scons, which, v8, useV8 ? false}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "mongodb-2.2.0";

  src = fetchurl {
    url = http://downloads.mongodb.org/src/mongodb-src-r2.2.0.tar.gz;
    sha256 = "12v0cpq9j2gmagr9pbw08karqwqgl4j9r223w7x7sx5cfvj2cih8";
  };

  buildNativeInputs = [ scons which ];

  enableParallelBuilding = true;

  patchPhase = ''
    substituteInPlace SConstruct --replace "Environment( BUILD_DIR" "Environment( ENV = os.environ, BUILD_DIR"
  '' + optionalString useV8 ''
    substituteInPlace SConstruct --replace "#/../v8" "${v8}" \
                                 --replace "[\"${v8}/\"]" "[\"${v8}/lib\"]"
  '';

  buildPhase = ''
    echo $PATH
    scons all --cc=`which gcc` --cxx=`which g++` ${optionalString useV8 "--usev8"}
  '';

  installPhase = ''
    scons install --cc=`which gcc` --cxx=`which g++` ${optionalString useV8 "--usev8"} --full --prefix=$out
    rm -rf $out/lib64 # exact same files as installed in $out/lib
  '';

  meta = {
    description = "a scalable, high-performance, open source NoSQL database";
    homepage = http://www.mongodb.org;
    license = "AGPLv3";

    maintainers = [ stdenv.lib.maintainers.bluescreen303 ];
    platforms = stdenv.lib.platforms.all;
  };
}
