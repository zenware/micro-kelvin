use core::{pin::Pin, task::{Poll, Context}};

use conquer_once::spin::OnceCell;
use crossbeam_queue::ArrayQueue;
use futures_util::{stream::{Stream, StreamExt}, task::AtomicWaker};
use pc_keyboard::{layouts, DecodedKey, HandleControl, Keyboard, ScancodeSet1};

use crate::{print, println};

// make it possible to perform safe one-time initialization of static values.
// We cannot yet do heap allocations at compile time, so we need this indirect init.
// It's also possible to use lazy_static! for this, however, OnceCell has the
// added benefit of ensuring initialization doesn't happen in the interrupt handler.
// This prevents the interrupt handler from doing a heap allocation.
// Ideally we want the interrupt handler to just shunt data off to this queue and
// that's it.
static SCANCODE_QUEUE: OnceCell<ArrayQueue<u8>> = OnceCell::uninit();
// Atomic instructions enable something to be stored in static and modified concurrently.
// TODO: What all things can be safely stored in static?
static WAKER: AtomicWaker = AtomicWaker::new();

/// Called by the keyboard interrupt handler
///
/// Must not block or allocate.
pub(crate) fn add_scancode(scancode: u8) {
    // TODO: What in the world are the semantics of how this function is declared?
    if let Ok(queue) = SCANCODE_QUEUE.try_get() {
        if let Err(_) = queue.push(scancode) {
            println!("WARNING: scancode queue full; dropping keyboard input");
        } else {
            // Wake up when adding a new scancode
            // (when keyboard interrupt is triggered)
            WAKER.wake();
        }
    } else {
        println!("WARNING: scancode queue uninitialized");
    }
}

pub struct ScancodeStream {
    _private: (),
}

impl ScancodeStream {
    pub fn new() -> Self {
        SCANCODE_QUEUE.try_init_once(|| ArrayQueue::new(100))
            .expect("ScancodeStream::new should only be called once");
        ScancodeStream { _private: () }
    }
}

impl Stream for ScancodeStream {
    type Item = u8;

    fn poll_next(self: Pin<&mut Self>, cx: &mut Context) -> Poll<Option<Self::Item>> {
        let queue = SCANCODE_QUEUE.try_get().expect("not initialized");

        // fast path
        if let Ok(scancode) = queue.pop() {
            return Poll::Ready(Some(scancode));
        }

        WAKER.register(&cx.waker());
        match queue.pop() {
            Ok(scancode) => {
                WAKER.take();
                Poll::Ready(Some(scancode))
            },
            Err(crossbeam_queue::PopError) => Poll::Pending,
        }
    }
}

// IBM XT, IBM 3270 PC, and IBM AT were the scancode sets.
// PS/2 keyboards emulate IBM XT, so that's what we do here.
// https://wiki.osdev.org/Keyboard#Scan_Code_Set_1
pub async fn print_keypresses() {
    // Read Scancodes from a Queue instead of directly off an IO Port.
    // Because of that we no longer need the mutex on the keyboard?
    let mut scancodes = ScancodeStream::new();
    let mut keyboard = Keyboard::new(layouts::Us104Key, ScancodeSet1,
        HandleControl::Ignore);
    
    while let Some(scancode) = scancodes.next().await {
        if let Ok(Some(key_event)) = keyboard.add_byte(scancode) {
            if let Some(key) = keyboard.process_keyevent(key_event) {
                match key {
                    DecodedKey::Unicode(character) => print!("{}", character),
                    DecodedKey::RawKey(key) => print!("{:?}", key),
                }
            }
        }
    }
    // TODO: Consider Configuring the PS/2 Keyboard
    // https://wiki.osdev.org/PS/2_Keyboard#Commands
}