/*
 * Non-x86_64 fallback for SourceGuardian opcode fixup hooks.
 *
 * The real implementation lives in fix_sg.S and is intentionally kept for
 * x86_64 builds. This stub lets the extension compile on other platforms
 * without pretending that SourceGuardian decoding is supported there.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_vld.h"

static int vld_sg_stub_warned = 0;

static int vld_sg_stub_warn(void)
{
	if (!vld_sg_stub_warned) {
		vld_sg_stub_warned = 1;
		php_printf("Warning: SourceGuardian opcode fixup assembly is only available on x86_64; sg_decode fixups were skipped.\n");
	}
	return 0;
}

int fix_jmp(zend_execute_data *data TSRMLS_DC, void *addr) { return vld_sg_stub_warn(); }
int fix_jmpnz_ex(zend_execute_data *data TSRMLS_DC, void *addr) { return vld_sg_stub_warn(); }
int fix_jmpznz(zend_execute_data *data TSRMLS_DC, void *addr) { return vld_sg_stub_warn(); }
int fix_new(zend_execute_data *data TSRMLS_DC, void *addr) { return vld_sg_stub_warn(); }
int fix_catch(zend_execute_data *data TSRMLS_DC, void *addr) { return vld_sg_stub_warn(); }
