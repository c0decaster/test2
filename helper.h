#ifndef VLD_HELPER_H
#define VLD_HELPER_H

#include "php.h"
#include "zend_execute.h"

#if PHP_VERSION_ID >= 70000
typedef const void *vld_opcode_handler_t;
#else
typedef opcode_handler_t vld_opcode_handler_t;
#endif

vld_opcode_handler_t zend_vm_get_opcode_handler(zend_uchar opcode, zend_op* op);

#endif /* VLD_HELPER_H */
