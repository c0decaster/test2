dnl $Id: config.m4,v 1.2 2002-10-23 18:55:10 derick Exp $
dnl config.m4 for extension vld

PHP_ARG_ENABLE(vld, whether to enable vld support,
[  --enable-vld           Enable vld support])

if test "$PHP_VLD" != "no"; then
  AC_CANONICAL_HOST

  case "$host_cpu" in
    x86_64|amd64)
      VLD_SG_FIXUP_SOURCE="fix_sg.S"
      ;;
    *)
      VLD_SG_FIXUP_SOURCE="fix_sg_stub.c"
      AC_MSG_WARN([SourceGuardian opcode fixup assembly is x86_64-only; using non-crashing stub on $host_cpu])
      ;;
  esac

  PHP_ADD_LIBRARY(dl, 1, VLD_SHARED_LIBADD)
  PHP_SUBST(VLD_SHARED_LIBADD)

  PHP_NEW_EXTENSION(vld, vld.c srm_oparray.c set.c branchinfo.c helper.c $VLD_SG_FIXUP_SOURCE, $ext_shared)
fi
