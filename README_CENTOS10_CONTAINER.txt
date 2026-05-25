VLD SourceGuardian fork - CentOS 10 / container notes
=====================================================

Purpose
-------
This archive was extended so the host server does not need PHP development
packages, gcc, make, or SourceGuardian installed directly. Build and runtime can
happen inside a CentOS Stream 10 oriented container.

What was added without deleting existing code
--------------------------------------------
- Containerfile.centos10
- scripts/build-image.sh
- scripts/build-extension.sh
- scripts/install-extension.sh
- scripts/run-vld-container.sh
- scripts/run-host-container.sh
- examples/vld-sourceguardian.ini
- fix_sg_stub.c for non-x86_64 builds

Code-level improvements
-----------------------
- config.m4 now explicitly builds all extension sources, including fix_sg.S.
- x86_64 uses the original SourceGuardian assembly fixups.
- non-x86_64 builds use a safe stub instead of failing at compile time.
- vld.sg_offset was added, default: 0x211010.
- vld.sg_require_loader was added, default: 0.
- SourceGuardian loader detection warnings were added.
- NULL op_array / empty opcode safety checks were added.

Build container image
---------------------
From the project root:

  scripts/build-image.sh

or manually:

  podman build -f Containerfile.centos10 -t vld-sourceguardian-centos10 .

Run against a protected PHP file
--------------------------------
Assume:
- protected file: ./protected.php
- SourceGuardian loader files: ./sourceguardian/

  scripts/run-host-container.sh ./protected.php ./sourceguardian

Manual podman example:

  podman run --rm \
    -v "$PWD:/work:Z" \
    -v "$PWD/sourceguardian:/opt/sourceguardian:Z,ro" \
    -e VLD_SG_OFFSET=0x211010 \
    vld-sourceguardian-centos10 \
    /work/protected.php

Manual docker example:

  docker run --rm \
    -v "$PWD:/work" \
    -v "$PWD/sourceguardian:/opt/sourceguardian:ro" \
    -e VLD_SG_OFFSET=0x211010 \
    vld-sourceguardian-centos10 \
    /work/protected.php

Important
---------
SourceGuardian decoding is very sensitive to:
- PHP version
- SourceGuardian loader version
- architecture
- Zend Engine ABI
- the internal SourceGuardian structure offset

If your loader uses another internal offset, override it:

  VLD_SG_OFFSET=0xYOUR_OFFSET scripts/run-host-container.sh ./protected.php ./sourceguardian

If you want the extension to skip fixups when the loader is not detected:

  VLD_SG_REQUIRE_LOADER=1 scripts/run-host-container.sh ./protected.php ./sourceguardian

Host requirements
-----------------
Only one of these is required on the server:
- podman
- docker

The host does not need:
- php-devel
- gcc
- make
- SourceGuardian installed globally
