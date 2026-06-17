"use client";

import { useState } from "react";
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
  type: NotifType;
  title: string;
  body: string;
  time: string;
  read: boolean;
};

const MOCK_NOTIFS: Notif[] = [
  {
    id: "n1",
    type: "proposicion_aceptada",
    title: "Elizabeth aceptó tu proposición",
    body: '"Elizabeth terminará la maratón dentro de los primeros 30 lugares." — ya está activa para pronósticos.',
    time: "Hace 10 min",
    read: false,
  },
  {
    id: "n2",
    type: "nuevo_pronostico",
    title: "48 nuevos pronósticos",
    body: 'Tu proposición "Voy a lograr al menos el décimo lugar" acumuló 48 pronósticos nuevos hoy.',
    time: "Hace 1 h",
    read: false,
  },
  {
    id: "n3",
    type: "resultado_validado_ganaste",
    title: "¡Ganaste 12 pts!",
    body: '"Sofía termina el libro antes de fin de mes" se cumplió. Tu pronóstico fue correcto.',
    time: "Hace 3 h",
    read: false,
  },
  {
    id: "n4",
    type: "proposicion_rechazada",
    title: "Diego rechazó una proposición",
    body: '"Diego no publicará nada este mes." fue rechazada. Perdiste 1 pt de tu balance.',
    time: "Ayer, 9:14 p.m.",
    read: true,
  },
  {
    id: "n5",
    type: "resultado_validado_perdiste",
    title: "Perdiste este pronóstico",
    body: '"Pablo no llegó a los 5 días de gym" — no se cumplió. Perdiste el punto apostado.',
    time: "Ayer, 6:00 p.m.",
    read: true,
  },
  {
    id: "n6",
    type: "nuevo_seguidor",
    title: "Karina M. ahora te sigue",
    body: "Karina está siguiendo tu actividad en Gathel.",
    time: "Hace 2 días",
    read: true,
  },
  {
    id: "n7",
    type: "penalizacion",
    title: "Penalización aplicada",
    body: "No fue posible validar el resultado de una proposición. Se descontó el 15% de tus puntos (−19 pts).",
    time: "Hace 3 días",
    read: true,
  },
];

const ICON_MAP: Record<NotifType, React.ReactNode> = {
  proposicion_aceptada:       <CheckCircle   size={18} className="text-(--success)" />,
  proposicion_rechazada:      <XCircle       size={18} className="text-(--danger)"  />,
  nuevo_pronostico:           <TrendingUp    size={18} className="text-(--accent)"  />,
  resultado_validado_ganaste: <Coins         size={18} className="text-(--success)" />,
  resultado_validado_perdiste:<XCircle       size={18} className="text-(--danger)"  />,
  nuevo_seguidor:             <UserPlus      size={18} className="text-(--accent)"  />,
  penalizacion:               <AlertCircle   size={18} className="text-(--warning)" />,
};

export default function NotificacionesPage() {
  const [notifs, setNotifs] = useState<Notif[]>(MOCK_NOTIFS);

  const unread = notifs.filter((n) => !n.read).length;

  function markAllRead() {
    setNotifs((prev) => prev.map((n) => ({ ...n, read: true })));
  }

  function markRead(id: string) {
    setNotifs((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
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

        <div className="mt-6 flex flex-col gap-2">
          {notifs.map((n) => (
            <button
              key={n.id}
              type="button"
              onClick={() => markRead(n.id)}
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
                    <p
                      className={`text-sm font-medium ${
                        n.read ? "text-(--foreground)" : "text-(--foreground)"
                      }`}
                    >
                      {n.title}
                    </p>
                    {!n.read && (
                      <span className="h-2 w-2 shrink-0 rounded-full bg-(--accent)" />
                    )}
                  </div>
                  <p className="mt-0.5 text-sm leading-relaxed text-(--muted)">
                    {n.body}
                  </p>
                  <p className="mt-1.5 text-xs text-(--muted)">{n.time}</p>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
