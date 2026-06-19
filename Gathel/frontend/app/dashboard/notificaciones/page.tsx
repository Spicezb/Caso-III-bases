"use client";

import { useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";
import { Chip, Tabs } from "@heroui/react";
import {
  CheckCircle,
  XCircle,
  TrendingUp,
  UserPlus,
  AlertCircle,
  Coins,
  RefreshCw,
  Bell,
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
  proposicion_rechazada: <XCircle size={18} className="text-(--danger)" />,
  nuevo_pronostico: <TrendingUp size={18} className="text-(--accent)" />,
  resultado_validado_ganaste: (
    <Coins size={18} className="text-(--success)" />
  ),
  resultado_validado_perdiste: (
    <XCircle size={18} className="text-(--danger)" />
  ),
  nuevo_seguidor: <UserPlus size={18} className="text-(--accent)" />,
  penalizacion: <AlertCircle size={18} className="text-(--warning)" />,
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
    title: n.title || "Notificación",
    body: n.body || "Tenés una nueva actualización en Gathel.",
    time: formatTime(n.createdAt),
    read: n.isRead,
  };
}

function EmptyState({ message }: { message: string }) {
  return (
    <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
      <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-(--surface-secondary) text-(--muted)">
        <Bell size={22} />
      </div>

      <p className="mt-3 text-sm text-(--muted)">{message}</p>
    </div>
  );
}

function NotificationCard({
  notification,
  onRead,
}: {
  notification: Notif;
  onRead: (notificationId: number) => void;
}) {
  return (
    <button
      type="button"
      onClick={() => onRead(notification.notificationId)}
      className={`w-full rounded-2xl border p-4 text-left transition-colors ${
        notification.read
          ? "border-(--border) bg-(--surface) hover:bg-(--surface-secondary)"
          : "border-(--accent)/30 bg-(--accent-soft) hover:border-(--accent)"
      }`}
    >
      <div className="flex items-start gap-3">
        <div className="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-(--surface)">
          {ICON_MAP[notification.type]}
        </div>

        <div className="min-w-0 flex-1">
          <div className="flex items-center justify-between gap-2">
            <p className="text-sm font-semibold text-(--foreground)">
              {notification.title}
            </p>

            {!notification.read && (
              <span className="h-2 w-2 shrink-0 rounded-full bg-(--accent)" />
            )}
          </div>

          <p className="mt-1 text-sm leading-relaxed text-(--muted)">
            {notification.body}
          </p>

          <div className="mt-2 flex items-center gap-2">
            <p className="text-xs text-(--muted)">{notification.time}</p>

            {!notification.read && (
              <Chip color="accent" variant="soft" size="sm">
                <Chip.Label>sin leer</Chip.Label>
              </Chip>
            )}
          </div>
        </div>
      </div>
    </button>
  );
}

function NotificationList({
  items,
  emptyMessage,
  onRead,
}: {
  items: Notif[];
  emptyMessage: string;
  onRead: (notificationId: number) => void;
}) {
  if (items.length === 0) {
    return <EmptyState message={emptyMessage} />;
  }

  return (
    <div className="flex flex-col gap-2">
      {items.map((notification) => (
        <NotificationCard
          key={notification.id}
          notification={notification}
          onRead={onRead}
        />
      ))}
    </div>
  );
}

export default function NotificacionesPage() {
  const [notifs, setNotifs] = useState<Notif[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [isMarkingAll, setIsMarkingAll] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const unread = notifs.filter((n) => !n.read).length;
  const read = notifs.filter((n) => n.read).length;

  const unreadNotifications = useMemo(
    () => notifs.filter((n) => !n.read),
    [notifs]
  );

  const readNotifications = useMemo(
    () => notifs.filter((n) => n.read),
    [notifs]
  );

  async function loadNotifications(showRefreshing = false) {
    try {
      if (showRefreshing) {
        setIsRefreshing(true);
      } else {
        setIsLoading(true);
      }

      setErrorMessage("");
      setSuccessMessage("");

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
      setIsRefreshing(false);
    }
  }

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    loadNotifications();
  }, []);

  async function markAllRead() {
    const storedPersonId = localStorage.getItem("personId");

    if (!storedPersonId) {
      setErrorMessage("No se encontró el usuario en sesión.");
      return;
    }

    const personId = Number(storedPersonId);
    const previous = notifs;

    setErrorMessage("");
    setSuccessMessage("");
    setIsMarkingAll(true);

    setNotifs((prev) => prev.map((n) => ({ ...n, read: true })));

    try {
      await markAllNotificationsRead(personId);
      setSuccessMessage("Todas las notificaciones fueron marcadas como leídas.");
    } catch (error) {
      setNotifs(previous);
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudieron marcar como leídas."
      );
    } finally {
      setIsMarkingAll(false);
    }
  }

  async function markRead(notificationId: number) {
    const selected = notifs.find((n) => n.notificationId === notificationId);

    if (!selected || selected.read) {
      return;
    }

    const previous = notifs;

    setErrorMessage("");
    setSuccessMessage("");

    setNotifs((prev) =>
      prev.map((n) =>
        n.notificationId === notificationId ? { ...n, read: true } : n
      )
    );

    try {
      await markNotificationRead(notificationId);
    } catch (error) {
      setNotifs(previous);
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
        <div className="flex items-start justify-between gap-4">
          <div>
            <span className="text-xs uppercase tracking-widest text-(--muted)">
              Centro de actividad
            </span>

            <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
              Notificaciones
            </h1>

            <p className="mt-2 text-sm leading-relaxed text-(--muted)">
              Revisá cambios importantes: proposiciones aceptadas, rechazos,
              pronósticos, resultados y penalizaciones.
            </p>
          </div>

          <button
            type="button"
            onClick={() => loadNotifications(true)}
            disabled={isRefreshing}
            className="inline-flex shrink-0 items-center gap-2 rounded-(--field-radius) border border-(--border) bg-(--surface) px-3 py-2 text-sm font-medium text-(--foreground) transition-colors hover:bg-(--surface-secondary) disabled:cursor-not-allowed disabled:opacity-60"
          >
            <RefreshCw size={15} className={isRefreshing ? "animate-spin" : ""} />
            Refrescar
          </button>
        </div>

        <div className="mt-5 grid grid-cols-3 gap-3">
          <div className="rounded-xl border border-(--border) bg-(--surface) p-3">
            <p className="text-xs text-(--muted)">Todas</p>
            <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
              {notifs.length}
            </p>
          </div>

          <div className="rounded-xl border border-(--border) bg-(--surface) p-3">
            <p className="text-xs text-(--muted)">Sin leer</p>
            <p className="mt-1 font-display text-xl font-semibold text-(--accent)">
              {unread}
            </p>
          </div>

          <div className="rounded-xl border border-(--border) bg-(--surface) p-3">
            <p className="text-xs text-(--muted)">Leídas</p>
            <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
              {read}
            </p>
          </div>
        </div>

        <div className="mt-4 flex items-center justify-between gap-3">
          {unread > 0 ? (
            <Chip color="accent" variant="soft" size="sm">
              <Chip.Label>{unread} sin leer</Chip.Label>
            </Chip>
          ) : (
            <Chip color="success" variant="soft" size="sm">
              <Chip.Label>todo al día</Chip.Label>
            </Chip>
          )}

          {unread > 0 && (
            <button
              type="button"
              onClick={markAllRead}
              disabled={isMarkingAll}
              className="text-sm text-(--accent) hover:underline disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isMarkingAll ? "Marcando..." : "Marcar todas como leídas"}
            </button>
          )}
        </div>

        {errorMessage && (
          <div className="mt-4 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage}
          </div>
        )}

        {successMessage && (
          <div className="mt-4 rounded-2xl border border-(--success)/40 bg-(--success-soft) p-4 text-sm text-(--success)">
            {successMessage}
          </div>
        )}

        <div className="mt-6">
          {isLoading ? (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                Cargando notificaciones...
              </p>
            </div>
          ) : (
            <Tabs defaultSelectedKey="todas">
              <Tabs.ListContainer>
                <Tabs.List>
                  <Tabs.Tab id="todas">Todas</Tabs.Tab>
                  <Tabs.Tab id="sin-leer">Sin leer</Tabs.Tab>
                  <Tabs.Tab id="leidas">Leídas</Tabs.Tab>
                </Tabs.List>
              </Tabs.ListContainer>

              <Tabs.Panel id="todas">
                <div className="mt-4">
                  <NotificationList
                    items={notifs}
                    emptyMessage="No tenés notificaciones por ahora."
                    onRead={markRead}
                  />
                </div>
              </Tabs.Panel>

              <Tabs.Panel id="sin-leer">
                <div className="mt-4">
                  <NotificationList
                    items={unreadNotifications}
                    emptyMessage="No tenés notificaciones sin leer."
                    onRead={markRead}
                  />
                </div>
              </Tabs.Panel>

              <Tabs.Panel id="leidas">
                <div className="mt-4">
                  <NotificationList
                    items={readNotifications}
                    emptyMessage="Todavía no tenés notificaciones leídas."
                    onRead={markRead}
                  />
                </div>
              </Tabs.Panel>
            </Tabs>
          )}
        </div>
      </div>
    </AppShell>
  );
}