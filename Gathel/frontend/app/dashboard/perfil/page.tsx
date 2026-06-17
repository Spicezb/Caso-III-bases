"use client";

import { useState } from "react";
import { Avatar, Chip, Tabs, Button } from "@heroui/react";
import { TrendingUp, TrendingDown, Clock, Link2 } from "lucide-react";
import AppShell from "@/components/AppShell";
import { useUser } from "@/lib/mock-user";

type HistorialItem = {
  id: string;
  text: string;
  result: "ganaste" | "perdiste" | "pendiente";
  amount: string;
  date: string;
};

const HISTORIAL_PROPOSICIONES: HistorialItem[] = [
  {
    id: "h1",
    text: "Voy a lograr al menos el décimo lugar en la maratón.",
    result: "pendiente",
    amount: "$128 en juego",
    date: "Vence hoy",
  },
  {
    id: "h2",
    text: "Termino de leer el libro antes de fin de mes.",
    result: "ganaste",
    amount: "+$30",
    date: "12 jun 2025",
  },
  {
    id: "h3",
    text: "No publico nada en redes este fin de semana.",
    result: "perdiste",
    amount: "−15 pts",
    date: "8 jun 2025",
  },
];

const HISTORIAL_PREDICCIONES: HistorialItem[] = [
  {
    id: "p1",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    result: "pendiente",
    amount: "1 pt en juego",
    date: "Vence hoy",
  },
  {
    id: "p2",
    text: "Sofía termina el libro antes de fin de mes.",
    result: "ganaste",
    amount: "+12 pts",
    date: "12 jun 2025",
  },
  {
    id: "p3",
    text: "Pablo llega al gym 5 días.",
    result: "perdiste",
    amount: "−1 pt",
    date: "9 jun 2025",
  },
  {
    id: "p4",
    text: "Diego sube el video antes del viernes.",
    result: "pendiente",
    amount: "$5 en juego",
    date: "Vence en 2 días",
  },
];

function resultIcon(result: HistorialItem["result"]) {
  if (result === "ganaste") return <TrendingUp size={16} className="text-(--success)" />;
  if (result === "perdiste") return <TrendingDown size={16} className="text-(--danger)" />;
  return <Clock size={16} className="text-(--muted)" />;
}

function resultChip(result: HistorialItem["result"]) {
  if (result === "ganaste")
    return <Chip color="success" variant="soft" size="sm"><Chip.Label>ganaste</Chip.Label></Chip>;
  if (result === "perdiste")
    return <Chip color="danger" variant="soft" size="sm"><Chip.Label>perdiste</Chip.Label></Chip>;
  return <Chip color="default" variant="soft" size="sm"><Chip.Label>pendiente</Chip.Label></Chip>;
}

export default function PerfilPage() {
  const { user } = useUser();
  const [editando, setEditando] = useState(false);

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">

        {/* Cabecera del perfil */}
        <div className="rounded-2xl border border-(--border) bg-(--surface) p-6">
          <div className="flex items-start justify-between gap-4">
            <div className="flex items-center gap-4">
              <Avatar size="lg">
                <Avatar.Fallback className="text-lg">
                  {user.avatarFallback}
                </Avatar.Fallback>
              </Avatar>
              <div>
                <h1 className="font-display text-xl font-semibold text-(--foreground)">
                  {user.name}
                </h1>
                <p className="text-sm text-(--muted)">{user.handle}</p>
                <p className="mt-1 text-xs text-(--muted)">
                  En Gathel desde {user.joinedAt}
                </p>
              </div>
            </div>

            <Button
              variant="outline"
              size="sm"
              onClick={() => setEditando((v) => !v)}
            >
              {editando ? "Guardar" : "Editar perfil"}
            </Button>
          </div>

          {/* Stats */}
          <div className="mt-6 grid grid-cols-4 gap-px overflow-hidden rounded-xl border border-(--border) bg-(--border)">
            {[
              { label: "Seguidores",  value: user.followers },
              { label: "Siguiendo",   value: user.following },
              { label: "Pts",         value: user.pointsBalance },
              { label: "Activas",     value: user.activePropositions },
            ].map((s) => (
              <div key={s.label} className="bg-(--surface-secondary) py-3 text-center">
                <p className="font-display text-xl font-semibold text-(--foreground)">
                  {s.value}
                </p>
                <p className="text-xs text-(--muted)">{s.label}</p>
              </div>
            ))}
          </div>

          {/* Redes conectadas */}
          <div className="mt-4 flex items-center gap-3">
            <p className="text-xs text-(--muted)">Redes conectadas:</p>
            {user.connectedNetworks.includes("instagram") ? (
              <Chip color="success" variant="soft" size="sm">
                <Chip.Label className="flex items-center gap-1">
                  <Link2 size={12} />
                  Instagram
                </Chip.Label>
              </Chip>
            ) : (
              <button type="button" className="text-xs text-(--accent) hover:underline">
                + Conectar Instagram
              </button>
            )}
            {!user.connectedNetworks.includes("tiktok") && (
              <button type="button" className="text-xs text-(--muted) hover:text-(--foreground)">
                + Conectar TikTok
              </button>
            )}
          </div>
        </div>

        {/* Historial con Tabs */}
        <div className="mt-6">
          <Tabs defaultSelectedKey="proposiciones">
            <Tabs.ListContainer>
              <Tabs.List>
                <Tabs.Tab id="proposiciones">Mis proposiciones</Tabs.Tab>
                <Tabs.Tab id="predicciones">Mis predicciones</Tabs.Tab>
              </Tabs.List>
            </Tabs.ListContainer>

            <Tabs.Panel id="proposiciones">
              <div className="mt-4 flex flex-col gap-3">
                {HISTORIAL_PROPOSICIONES.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center gap-3 rounded-xl border border-(--border) bg-(--surface) p-4"
                  >
                    <div className="shrink-0">{resultIcon(item.result)}</div>
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm text-(--foreground)">
                        "{item.text}"
                      </p>
                      <p className="mt-0.5 text-xs text-(--muted)">{item.date}</p>
                    </div>
                    <div className="flex flex-col items-end gap-1 shrink-0">
                      {resultChip(item.result)}
                      <span className="text-xs text-(--muted)">{item.amount}</span>
                    </div>
                  </div>
                ))}
              </div>
            </Tabs.Panel>

            <Tabs.Panel id="predicciones">
              <div className="mt-4 flex flex-col gap-3">
                {HISTORIAL_PREDICCIONES.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center gap-3 rounded-xl border border-(--border) bg-(--surface) p-4"
                  >
                    <div className="shrink-0">{resultIcon(item.result)}</div>
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm text-(--foreground)">
                        "{item.text}"
                      </p>
                      <p className="mt-0.5 text-xs text-(--muted)">{item.date}</p>
                    </div>
                    <div className="flex flex-col items-end gap-1 shrink-0">
                      {resultChip(item.result)}
                      <span className="text-xs text-(--muted)">{item.amount}</span>
                    </div>
                  </div>
                ))}
              </div>
            </Tabs.Panel>
          </Tabs>
        </div>

        {/* Cerrar sesión */}
        <div className="mt-8 border-t border-(--separator) pt-6">
          <button
            type="button"
            className="text-sm text-(--danger) hover:underline"
            onClick={() => {
              // TODO: limpiar sesión y redirigir a /login
              window.location.href = "/login";
            }}
          >
            Cerrar sesión
          </button>
        </div>
      </div>
    </AppShell>
  );
}
