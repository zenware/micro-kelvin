/// TODO: Possible Extensions
///
/// Scheduling
/// `task_queue` currently uses `VecDeque`/FIFO, this is often called "Round Robin"
/// scheduling. However it may not be the most efficient for all workloads. It might
/// make sense to prioritize latency-critical tasks or tasks which do a lot of I/O.
/// - OSTEP Scheduling: http://pages.cs.wisc.edu/~remzi/OSTEP/cpu-sched.pdf
/// - Wiki Scheduling: https://en.wikipedia.org/wiki/Scheduling_(computing)
/// 
/// Task Spawning
/// Our `Executor::spawn` method currently requires a &mut self reference and is thus
/// no longer available after invoking the `run` method. To fix this we could create
/// an additional `Spawner` type that shares some kind of queue with the executor and
/// allows task creation from within tasks themselves. The queue could be the
/// `task_queue` directly, or a separate queue that the executor checks in its run loop.
///
/// Utilizing Threads
/// We don't have support for threads yet, but we will add it in the next post. This
/// will make it possible to launch multiple instances of the executor in different
/// threads. The advantage of this approach is that the delay imposed by long-running
/// tasks can be reduced because other tasks can run concurrently. This approach also
/// allows it to utilize multiple CPI cores.
///
/// Load Balancing
/// When adding threading support, it becomes important to know how to distribute the
/// tasks between the executors to ensure that all CPU cores are utilized. A common
/// technique for this is [*work stealing*](https://en.wikipedia.org/wiki/Work_stealing)
/// consider also implementing *work sharing*.
/// Would also be cool to try and find a secret third method.
use alloc::boxed::Box;
use core::{
    future::Future,
    pin::Pin,
    sync::atomic::{AtomicU64, Ordering},
    task::{Context, Poll},
};

pub mod executor;
pub mod keyboard;
pub mod simple_executor;

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
struct TaskId(u64);

impl TaskId {
    fn new() -> Self {
        static NEXT_ID: AtomicU64 = AtomicU64::new(0);
        TaskId(NEXT_ID.fetch_add(1, Ordering::Relaxed))
    }
}

pub struct Task {
    id: TaskId,
    future: Pin<Box<dyn Future<Output = ()>>>,
}

impl Task {
    pub fn new(future: impl Future<Output = ()> + 'static) -> Task {
        Task {
            id: TaskId::new(),
            future: Box::pin(future),
        }
    }

    fn poll(&mut self, context: &mut Context) -> Poll<()> {
        self.future.as_mut().poll(context)
    }
}