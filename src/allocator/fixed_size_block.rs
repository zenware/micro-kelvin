/// TODO Ideas for improvement:
///
/// Instead of only allocating blocks lazily using the fallback allocator, it
/// might be better to pre-fill the lists to improve the performance of initial
/// allocations.
///
/// To simplify the implementation, we only allowed block sizes that are powers
/// of 2 so that we could also use them as the block alignment. By storing (or
/// calculating) the alignment in a different way, we could also allow arbitrary
/// other block sizes. This way, we could add more block sizes, e.g., for common
/// allocation sizes, in order to minimize the wasted memory.
///
/// We currently only create new blocks, but never free them again. This results
/// in fragmentation and might eventually result in allocation failure for large
/// allocations. It might make sense to enforce a maximum list length for each
/// block size. When the maximum length is reached, subsequent deallocations are
/// freed using the fallback allocator instead of being added to the list.
///
/// Instead of falling back to a linked list allocator, we could have a special
/// allocator for allocations greater than 4 KiB. The idea is to utilize paging,
/// which operates on 4 KiB pages, to map a continuous block of virtual memory
/// to non-continuous physical frames. This way, fragmentation of unused memory
/// is no longer a problem for large allocations.
///
/// With such a page allocator, it might make sense to add block sizes up to 4 KiB
/// and drop the linked list allocator completely. The main advantages of this
/// would be reduced fragmentation and improved performance predictability,
/// i.e., better worst-case performance.


struct ListNode {
    next: Option<&'static mut ListNode>,
}

/// The block sizes to use.
///
/// The sizes must each be a power of 2 because they are also used as
/// the block alignment (alignments must always be powers of 2).
const BLOCK_SIZES: &[usize] = &[8, 16, 32, 64, 128, 256, 512, 1024, 2048];

pub struct FixedSizeBlockAllocator {
    list_heads: [Option<&'static mut ListNode>; BLOCK_SIZES.len()],
    // when we need to allocate larger than the largest block size
    // use the fallback allocator
    fallback_allocator: linked_list_allocator::Heap,
}

use alloc::alloc::Layout;
use core::{mem, ptr, ptr::NonNull};

impl FixedSizeBlockAllocator {
    /// Creates an empty FixedSizeBlockAllocator.
    pub const fn new() -> Self {
        const EMPTY: Option<&'static mut ListNode> = None;
        FixedSizeBlockAllocator {
            list_heads: [EMPTY; BLOCK_SIZES.len()],
            fallback_allocator: linked_list_allocator::Heap::empty(),
        }
    }

    /// Initialize the allocator with the given heap bounds.
    ///
    /// This function is unsafe because the caller must guarantee that the given
    /// heap bounds are valid and that the heap is unused. This method must be
    /// called only once.
    pub unsafe fn init(&mut self, heap_start: usize, heap_size: usize) {
        self.fallback_allocator.init(heap_start, heap_size);
    }

    /// Allocates using the fallback allocator.
    fn fallback_alloc(&mut self, layout: Layout) -> *mut u8 {
        match self.fallback_allocator.allocate_first_fit(layout) {
            Ok(ptr) => ptr.as_ptr(),
            Err(_) => ptr::null_mut(),
        }
    }
}

/// Choose an appropriate block size for the given layout.
///
/// Returns an index into the `BLOCK_SIZES` array.
fn list_index(layout: &Layout) -> Option<usize> {
    let required_block_size = layout.size().max(layout.align());
    BLOCK_SIZES.iter().position(|&s| s >= required_block_size)
}

use super::Locked;
use alloc::alloc::GlobalAlloc;

unsafe impl GlobalAlloc for Locked<FixedSizeBlockAllocator> {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let mut allocator = self.lock();
        match list_index(&layout) {
            Some(index) => {
                match allocator.list_heads[index].take() {
                    Some(node) => {
                        allocator.list_heads[index] = node.next.take();
                        node as *mut ListNode as *mut u8
                    }
                    None => {
                        // no block exists in list => allocate new block
                        let block_size = BLOCK_SIZES[index];
                        // only works if all block sizes are a power of 2
                        let block_align = block_size;
                        let layout = Layout::from_size_align(block_size, block_align)
                            .unwrap();
                        allocator.fallback_alloc(layout)
                    }
                }
            }
            None => allocator.fallback_alloc(layout),
        }
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        let mut allocator = self.lock();
        match list_index(&layout) {
            Some(index) => {
                let new_node = ListNode {
                    next: allocator.list_heads[index].take(),
                };
                // verify that block has size and alignment required for storing node
                assert!(mem::size_of::<ListNode>() <= BLOCK_SIZES[index]);
                assert!(mem::align_of::<ListNode>() <= BLOCK_SIZES[index]);
                let new_node_ptr = ptr as *mut ListNode;
                new_node_ptr.write(new_node);
                allocator.list_heads[index] = Some(&mut *new_node_ptr);
            }
            None => {
                let ptr = NonNull::new(ptr).unwrap();
                allocator.fallback_allocator.deallocate(ptr, layout);
            }
        }
    }
}
