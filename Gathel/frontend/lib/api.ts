const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5145";

export async function apiGet<T>(path: string): Promise<T> {
  const url = `${API_URL}${path}`;

  const response = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!response.ok) {
    const rawText = await response.text();

    console.error("Error en apiGet:", {
      url,
      status: response.status,
      rawText,
    });

    throw new Error(rawText || `Error GET ${path}`);
  }

  return response.json();
}

export async function apiPost<T>(path: string, body: unknown): Promise<T> {
  const url = `${API_URL}${path}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const rawText = await response.text();

    console.error("Error en apiPost:", {
      url,
      status: response.status,
      rawText,
      requestBody: body,
    });

    let message = `Error POST ${path}`;

    try {
      const errorData = JSON.parse(rawText);
      message = errorData?.message || errorData?.title || message;
    } catch {
      if (rawText) {
        message = rawText;
      }
    }

    throw new Error(message);
  }

  if (response.status === 204) {
    return {} as T;
  }

  return response.json();
}