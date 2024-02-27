#![no_std] // don't link the Rust standard library
#![no_main] // disable all Rust-level entry points
#![feature(custom_test_frameworks)]
#![test_runner(micro_kelvin::test_runner)]
#![reexport_test_harness_main = "test_main"]

use core::panic::PanicInfo;
use micro_kelvin::println;

/*
There is no main function because main() is called by a runtime.
There is no runtime where we're going, but we suspect that _start() is called first.
*/
#[no_mangle] // don't mangle the name of this function
pub extern "C" fn _start() -> ! {
    // this function is the entry point, since the linker looks for a function
    // named `_start` by default
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