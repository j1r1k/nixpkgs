{stdenv, fetchFromGitHub, which}:
let
  baseName="firejail";
  version="0.9.38.4";
  name="${baseName}-${version}";
in
stdenv.mkDerivation {
  inherit name version;
  src = fetchFromGitHub {
    owner = "netblue30";
    repo = "firejail";
    rev = version;
    sha256 = "1ksngr03pdh3ljn6x4x5ps37whijp85nnjg8fqb9qdj9ik3jyfan";
  };

  buildInputs = [
    which
  ];

  preConfigure = ''
    sed -e 's@/bin/bash@${stdenv.shell}@g' -i $( grep -lr /bin/bash .)
    sed -e "s@/bin/cp@$(which cp)@g" -i $( grep -lr /bin/cp .)
    sed -e '/void fs_var_run(/achar *vrcs = get_link("/var/run/current-system")\;' -i ./src/firejail/fs_var.c
    sed -e '/ \/run/iif(vrcs!=NULL){symlink(vrcs, "/var/run/current-system")\;free(vrcs)\;}' -i ./src/firejail/fs_var.c
  '';

  preBuild = ''
    sed -e "s@/etc/@$out/etc/@g" -i Makefile
  '';

  meta = {
    inherit version;
    inherit name;
    description = ''Namespace-based sandboxing tool for Linux'';
    license = stdenv.lib.licenses.gpl2Plus ;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
    homepage = "http://l3net.wordpress.com/projects/firejail/";
    downloadPage = "http://sourceforge.net/projects/firejail/files/firejail/";
  };
}
