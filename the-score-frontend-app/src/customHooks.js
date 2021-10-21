import { useEffect, useCallback, useRef } from "react";

export function useDebounce(f, delayMs) {
  const timeout = useRef();

  return function debounced(...args) {
    clearTimeout(timeout.current);
    timeout.current = setTimeout(() => f(...args), delayMs);
  };
}

export function useIsMounted() {
  const isMounted = useRef();

  useEffect(() => {
    isMounted.current = true;
    return () => {
      isMounted.current = false;
    };
  }, []);

  return useCallback(() => isMounted.current, []);
}
