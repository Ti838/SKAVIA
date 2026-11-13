'use client';

export class AdminApiError extends Error {
  public readonly status: number;
  public readonly code: string;
  public readonly correlationId?: string;

  constructor(status: number, code: string, message: string, correlationId?: string) {
    super(message);
    this.name = 'AdminApiError';
    this.status = status;
    this.code = code;
    this.correlationId = correlationId;
  }
}

type StepUpListener = () => void;
const stepUpListeners = new Set<StepUpListener>();

export function subscribeStepUpRequired(listener: StepUpListener): () => void {
  stepUpListeners.add(listener);
  return () => {
    stepUpListeners.delete(listener);
  };
}

export async function apiFetch<T>(
  url: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(url, {
    ...options,
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      ...(options?.headers ?? {}),
    },
  });

  if (!response.ok) {
    let code = `HTTP_${response.status}`;
    let message = `Request failed (${response.status})`;
    let correlationId = response.headers.get('X-Correlation-Id') || undefined;

    try {
      const payload = (await response.json()) as {
        error?: { code?: string; message?: string; correlationId?: string };
      };
      if (payload.error) {
        code = payload.error.code || code;
        message = payload.error.message || message;
        correlationId = payload.error.correlationId || correlationId;
      }
    } catch {
      // Non-JSON error response
    }

    if (response.status === 401 && code === 'STEP_UP_REQUIRED') {
      stepUpListeners.forEach((fn) => fn());
    }

    throw new AdminApiError(response.status, code, message, correlationId);
  }

  return (await response.json()) as T;
}

