#![no_std] // don't link the Rust standard library
#![no_main] // disable all Rust-level entry points
#![feature(custom_test_frameworks)]
#![test_runner(micro_kelvin::test_runner)]
#![reexport_test_harness_main = "test_main"]

use core::panic::PanicInfo;
use bootloader::{BootInfo, entry_point};
use micro_kelvin::{memory::translate_addr, println};

// There is no main function because main() is called by a runtime.
entry_point!(kernel_main);

fn kernel_main(boot_info: &'static BootInfo) -> ! {
    use micro_kelvin::memory;
    use x86_64::{VirtAddr, structures::paging::Translate};
    println!("Hello from a macro!");
    println!("The numbers are {} and {}", 42, 1.0/3.0);

    micro_kelvin::init();

    // Invoke breakpoint exception
    // x86_64::instructions::interrupts::int3();

    //fn stack_overflow() {
    //    stack_overflow();
    //}
    //stack_overflow(); // trigger stack overflow 

    // trigger a page fault
    // since we don't have a handler for this, it creates a double fault
    //unsafe {
    //    *(0xdeadbeef as *mut u8) = 42;
    //};
    // TODO: Do these two mean the same thing since they both cause a page fault?
    //let ptr = 0xdeadbeef as *mut u8;
    //unsafe { *ptr = 42; }

    // TODO: What is 'control register' Cr3?
    let phys_mem_offset = VirtAddr::new(boot_info.physical_memory_offset);
    let mapper = unsafe { memory::init(phys_mem_offset) };
    let mut frame_allocator = memory::EmptyFrameAllocator;

    // map an unused page
    //let page = Page::containing_address(VirtAddr::new(0));
    //memory::create_example_mapping(page, &mut mapper, &mut frame_allocator);

    let addresses = [
        // the identity-mapped vga buffer page
        0xb8000,
        // some code page
        0x201008,
        // some stack page
        0x0100_0020_1a10,
        // virtual address space mapped to physical address 0
        boot_info.physical_memory_offset,
    ];

    for &address in &addresses {
        let virt = VirtAddr::new(address);
        let phys = mapper.translate_addr(virt);
        println!("{:?} -> {:?}", virt, phys);
    }

    // somewhat entertaining to print the pages
    /*
    let l4_table = unsafe { active_level_4_table(phys_mem_offset) };

    for (i, entry) in l4_table.iter().enumerate() {
        use x86_64::structures::paging::PageTable;

        if !entry.is_unused() {
            println!("L4 Entry {}: {:?}", i, entry);

            // get physical address from entry and convert it
            let phys = entry.frame().unwrap().start_address();
            let virt = phys.as_u64() + boot_info.physical_memory_offset;
            let ptr = VirtAddr::new(virt).as_mut_ptr();
            let l3_table: &PageTable = unsafe { &*ptr };

            // print non-empty entries of the level 3 table
            for (i, entry) in l3_table.iter().enumerate() {
                if !entry.is_unused() {
                    println!("  L3 Entry {}: {:?}", i, entry);
                }
            }
        }
    }
    */

    //let ptr = 0x2071dc as *mut u8;
    //unsafe { let x = *ptr; }
    //println!("read worked");
    //unsafe { *ptr = 42; }
    //println!("write worked");

    #[cfg(test)]
    test_main();

    println!("It did not crash!");
    micro_kelvin::hlt_loop();
}

/// This function is called on panic.
#[cfg(not(test))] // don't run for testing mode
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    println!("{}", info);
    micro_kelvin::hlt_loop();
}


#[cfg(test)]
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    micro_kelvin::test_panic_handler(info)
}

/// Validate that the test_runner is working
#[test_case]
fn trivial_assertion() {
    assert_eq!(1, 1);
}