import time
from collections import deque


class SlidingWindowLimiter:
    """Allow at most `limit` calls per `window` seconds."""

    def __init__(self, limit: int, window: float):
        self.limit = limit
        self.window = window
        self.calls: deque[float] = deque()

    def allow(self) -> bool:
        now = time.monotonic()
        while self.calls and now - self.calls[0] >= self.window:
            self.calls.popleft()
        if len(self.calls) < self.limit:
            self.calls.append(now)
            return True
        return False
