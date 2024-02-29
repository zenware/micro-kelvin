// https://google.github.io/comprehensive-rust/bare-metal/no_std.html
// no_std leaves us with
// core, alloc, and possibly a few parts of std?
#![no_std] // don't link the Rust standard library
#![no_main] // disable all Rust-level entry points
#![feature(custom_test_frameworks)]
#![test_runner(micro_kelvin::test_runner)]
#![reexport_test_harness_main = "test_main"]

extern crate alloc;
use alloc::{boxed::Box, vec, vec::Vec, rc::Rc};
use core::panic::PanicInfo;

use bootloader::{BootInfo, entry_point};
//use bootloader_api::{BootInfo, entry_point};
//use bootloader_api::config::{BootloaderConfig, Mapping};

use micro_kelvin::{memory::{translate_addr, BootInfoFrameAllocator}, println, task::keyboard};
use micro_kelvin::task::{Task, simple_executor::SimpleExecutor, executor::Executor};

//pub static BOOTLOADER_CONFIG: BootloaderConfig = {
//    let mut config = BootloaderConfig::new_default();
//    config.mappings.physical_memory = Some(Mapping::Dynamic);
//    config
//};

//entry_point!(kernel_main, config = &BOOTLOADER_CONFIG);
entry_point!(kernel_main);

async fn async_number() -> u32 {
    42
}

async fn example_task() {
    let number = async_number().await;
    println!("async number: {}", number);
}

//fn kernel_main(boot_info: &'static mut BootInfo) -> ! {
fn kernel_main(boot_info: &'static BootInfo) -> ! {
    use micro_kelvin::allocator;
    use micro_kelvin::memory::{self, BootInfoFrameAllocator};
    use x86_64::{VirtAddr, structures::paging::Page};
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
    let mut mapper = unsafe { memory::init(phys_mem_offset) };
    // let mut frame_allocator = memory::EmptyFrameAllocator;
    let mut frame_allocator = unsafe {
        BootInfoFrameAllocator::init(&boot_info.memory_map)
    };

    allocator::init_heap(&mut mapper, &mut frame_allocator)
        .expect("heap initialization failed");

    // write the string `New!` to the screen through the new mapping
    //let page_ptr: *mut u64 = page.start_address().as_mut_ptr();
    // TODO: Waht is this magic number...?
    //unsafe { page_ptr.offset(400).write_volatile(0x_f021_f077_f065_f04d)};

    // allocate a number on the heap
    let heap_value = Box::new(41);
    println!("heap_value at {:p}", heap_value);

    // create a dynamically sized vector
    let mut vec = Vec::new();
    for i in 0..500 {
        vec.push(i);
    }
    println!("vec at {:p}", vec.as_slice());

    // create a reference counted vector -> will be freed when count reaches 0
    let reference_counted = Rc::new(vec![1, 2, 3]);
    let cloned_reference = reference_counted.clone();
    println!("current reference count is {}", Rc::strong_count(&cloned_reference));
    core::mem::drop(reference_counted);
    println!("reference count is {} now", Rc::strong_count(&cloned_reference));

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

    // TODO: Nothing seems to be able to run after the executor kicks off...
    // Placing this near the bottom of the entrypoint for now.
    // Hopefully will figure that out soon.
    // Setup and run async/await functions.
    let mut executor = Executor::new();
    executor.spawn(Task::new(example_task()));
    executor.spawn(Task::new(keyboard::print_keypresses()));
    executor.run(); // Do we not make it past here any longer?
    
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