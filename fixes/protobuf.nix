{ stdenv, fetchFromGitHub, autoreconfHook, autoconf, automake, libtool, zlib, gmock }:

stdenv.mkDerivation rec {
  name = "protobuf-${version}";

  version = "3.0.0";
  # make sure you test also -A pythonPackages.protobuf
  src = fetchFromGitHub {
    owner = "google";
    repo = "protobuf";
    rev = "v${version}";
    sha256 = "05qkcl96lkdama848m7q3nzzzdckjc158iiyvgmln0zi232xx7g7";
  };

  postPatch = ''
    rm -rf gmock
    cp -r ${gmock.source} gmock
    chmod -R a+w gmock
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace src/google/protobuf/testing/googletest.cc \
      --replace 'tmpnam(b)' '"'$TMPDIR'/foo"'
  '';

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ zlib libtool.lib ];

  enableParallelBuilding = true;

  doCheck = false;

  meta = {
    description = "Google's data interchange format";
    longDescription =
      ''Protocol Buffers are a way of encoding structured data in an efficient
        yet extensible format. Google uses Protocol Buffers for almost all of
        its internal RPC protocols and file formats.
      '';
    license = stdenv.lib.licenses.bsd3;
    platforms = stdenv.lib.platforms.unix;
    homepage = https://developers.google.com/protocol-buffers/;
  };

  passthru.version = version;
}