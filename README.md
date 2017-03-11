# µK - Microkernel

Drivers, Protocols, Filesystems, Etc. Should run in userspace
Thus the kernel itself should only support IPC, Virtual Memory,
and process scheduling.

The Microkernel design is more easy for me to grok. so I'm going to
head down that path first.

----

Actually I want to pursue a an Exokernel design, so the supported
stuff would just be allocating resources to userspace processes...
And the userspace processes would then get to choose their own
abstractions instead of relying on the kernel's.

So I need to preset disk blocks, memory pages, and processor time.
Which is Bare Disk I/O, Bare Memory I/O, and probably Completely Fair Scheduling.

----

Hopefully I can figure out how to remove the object builder metadata.

---
## TODO
* Not Sure yet.
---

## Currently Implemented
* Create the Multiboot header with ASM
* Setup a stack to be used by C
* then call an external symbol "kernel_main" (written in C)
* Address the VGA Color Monitor Text Buffer
* Write some data to the buffer and scroll the screen
