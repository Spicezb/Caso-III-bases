"use client";

import { useEffect, useState } from "react";
import type { ReactNode } from "react";
import { Chip } from "@heroui/react";
import {
  CheckCircle,
  XCircle,
  TrendingUp,
  UserPlus,
  AlertCircle,
  Coins,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  getMyNotifications,
  markAllNotificationsRead,
  markNotificationRead,
} from "@/lib/gathel-api";
import type { NotificationResponse } from "@/lib/gathel-api";

type NotifType =
  | "proposicion_aceptada"
  | "proposicion_rechazada"
  | "nuevo_pronostico"
  | "resultado_validado_ganaste"
  | "resultado_validado_perdiste"
  | "nuevo_seguidor"
  | "penalizacion";

type Notif = {
  id: string;
  notificationId: number;
  type: NotifType;
  title: string;
  body: string;
  time: string;
  read: boolean;
};

const ICON_MAP: Record<NotifType, ReactNode> = {
  proposicion_aceptada: (
    <CheckCircle size={18} className="text-(--success)" />
  ),
  proposicion_rechazada: (
    <XCircle size={18} className="text-(--danger)" />
  ),
  nuevo_pronostico: (
    <TrendingUp size={18} className="text-(--accent)" />
  ),
  resultado_validado_ganaste: (
    <Coins size={18} className="text-(--success)" />
  ),
  resultado_validado_perdiste: (
    <XCircle size={18} className="text-(--danger)" />
  ),
  nuevo_seguidor: (
    <UserPlus size={18} className="text-(--accent)" />
  ),
  penalizacion: (
    <AlertCircle size={18} className="text-(--warning)" />
  ),
};

function normalizeType(type: string): NotifType {
  const normalized = type.toLowerCase();

  if (normalized.includes("acept")) return "proposicion_aceptada";
  if (normalized.includes("rechaz")) return "proposicion_rechazada";
  if (normalized.includes("pronost")) return "nuevo_pronostico";
  if (normalized.includes("gan")) return "resultado_validado_ganaste";
  if (normalized.includes("perd")) return "resultado_validado_perdiste";
  if (normalized.includes("seguidor")) return "nuevo_seguidor";
  if (normalized.includes("penal")) return "penalizacion";

  return "nuevo_pronostico";
}

function formatTime(dateText: string) {
  const date = new Date(dateText);
  const now = new Date();

  if (Number.isNaN(date.getTime())) {
    return "Fecha no disponible";
  }

  const diffMs = now.getTime() - date.getTime();
  const diffMinutes = Math.floor(diffMs / (1000 * 60));
  const diffHours = Math.floor(diffMinutes / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffMinutes < 1) return "Hace un momento";
  if (diffMinutes < 60) return `Hace ${diffMinutes} min`;
  if (diffHours < 24) return `Hace ${diffHours} h`;
  if (diffDays === 1) return "Ayer";

  return `Hace ${diffDays} días`;
}

function mapNotification(n: NotificationResponse): Notif {
  return {
    id: String(n.notificationId),
    notificationId: n.notificationId,
    type: normalizeType(n.notificationType),
    title: n.title,
    body: n.body,
    time: formatTime(n.createdAt),
    read: n.isRead,
  };
}

export default function NotificacionesPage() {
  const [notifs, setNotifs] = useState<Notif[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  const unread = notifs.filter((n) => !n.read).length;

  useEffect(() => {
    async function loadNotifications() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");

        if (!storedPersonId) {
          setErrorMessage("No se encontró el usuario en sesión.");
          return;
        }

        const personId = Number(storedPersonId);
        const response = await getMyNotifications(personId);

        setNotifs(response.map(mapNotification));
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudieron cargar las notificaciones."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadNotifications();
  }, []);

  async function markAllRead() {
    const storedPersonId = localStorage.getItem("personId");

    if (!storedPersonId) {
      setErrorMessage("No se encontró el usuario en sesión.");
      return;
    }

    const personId = Number(storedPersonId);

    setNotifs((prev) => prev.map((n) => ({ ...n, read: true })));

    try {
      await markAllNotificationsRead(personId);
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudieron marcar como leídas."
      );
    }
  }

  async function markRead(notificationId: number) {
    setNotifs((prev) =>
      prev.map((n) =>
        n.notificationId === notificationId ? { ...n, read: true } : n
      )
    );

    try {
      await markNotificationRead(notificationId);
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudo marcar la notificación como leída."
      );
    }
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <div className="flex items-center justify-between">
          <div>
            <span className="text-xs uppercase tracking-widest text-(--muted)">
              Centro de actividad
            </span>

            <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
              Notificaciones
            </h1>
          </div>

          {unread > 0 && (
            <button
              type="button"
              onClick={markAllRead}
              className="text-sm text-(--accent) hover:underline"
            >
              Marcar todas como leídas
            </button>
          )}
        </div>

        {unread > 0 && (
          <div className="mt-3">
            <Chip color="accent" variant="soft" size="sm">
              <Chip.Label>{unread} sin leer</Chip.Label>
            </Chip>
          </div>
        )}

        {errorMessage && (
          <div className="mt-4 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage}
          </div>
        )}

        <div className="mt-6 flex flex-col gap-2">
          {isLoading ? (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                Cargando notificaciones...
              </p>
            </div>
          ) : notifs.length > 0 ? (
            notifs.map((n) => (
              <button
                key={n.id}
                type="button"
                onClick={() => markRead(n.notificationId)}
                className={`w-full rounded-2xl border p-4 text-left transition-colors ${
                  n.read
                    ? "border-(--border) bg-(--surface)"
                    : "border-(--accent)/30 bg-(--accent-soft)"
                }`}
              >
                <div className="flex items-start gap-3">
                  <div className="mt-0.5 shrink-0">
                    {ICON_MAP[n.type]}
                  </div>

                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between gap-2">
                      <p className="text-sm font-medium text-(--foreground)">
                        {n.title}
                      </p>

                      {!n.read && (
                        <span className="h-2 w-2 shrink-0 rounded-full bg-(--accent)" />
                      )}
                    </div>

                    <p className="mt-0.5 text-sm leading-relaxed text-(--muted)">
                      {n.body}
                    </p>

                    <p className="mt-1.5 text-xs text-(--muted)">
                      {n.time}
                    </p>
                  </div>
                </div>
              </button>
            ))
          ) : (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                No tenés notificaciones por ahora.
              </p>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}