package Variant


import logger "core:log"
import os     "core:os"
import time   "core:time"

// open :: proc(path: string, mode: int = O_RDONLY, perm: int = 0) -> (Handle, Error) {

	// 

log_proc :: #type proc(level: logger.Level, fmt_str: string, args: ..any )


log      :: proc(level: logger.Level, fmt_str: string, args: ..any )
{
	ctx       := get_context()
	allocator := ctx.get_runtime_allocator()

	t         := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	b, _  := builder_make_none(allocator)
	dir,_ := get_working_directory(allocator)
	tbuf  := make([]u8,time.MIN_HMS_LEN,allocator)

	builder_write_string(&b,dir)
	builder_write_string(&b,"\\")
	builder_write_string(&b,"nuo_log")
	builder_write_string(&b,".log")

	h, _          := os.open(to_string(b), os.O_WRONLY | os.O_APPEND | os.O_CREATE )

	clogger       := context.logger
	n_logger      := logger.create_file_logger(h,allocator = allocator) 
	context.logger = n_logger

	logger.logf(level, fmt_str, ..args)
	logger.destroy_file_logger(n_logger,allocator)

    context.logger = clogger
}