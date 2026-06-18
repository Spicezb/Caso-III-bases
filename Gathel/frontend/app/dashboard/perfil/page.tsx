"use client";

import { useEffect, useState } from "react";
import { Avatar, Chip, Tabs, Button } from "@heroui/react";
import { TrendingUp, TrendingDown, Clock, Link2 } from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  getActivePropositions,
  getMe,
  getPredictionsByPerson,
  PersonResponse,
  PropositionResponse,
  MyPredictionResponse,
} from "@/lib/gathel-api";

type HistorialItem = {
  id: string;
  text: string;
  result: "ganaste" | "perdiste" | "pendiente";
  amount: string;
  date: string;
};

type ProfileData = {
  name: string;
  handle: string;
  avatarFallback: string;
  joinedAt: string;
  followers: number;
  following: number;
  pointsBalance: number;
  moneyBalance: number;
  activePropositions: number;
  connectedNetworks: ("instagram" | "tiktok")[];
};

function resultIcon(result: HistorialItem["result"]) {
  if (result === "ganaste") {
    return <TrendingUp size={16} className="text-(--success)" />;
  }

  if (result === "perdiste") {
    return <TrendingDown size={16} className="text-(--danger)" />;
  }

  return <Clock size={16} className="text-(--muted)" />;
}

function resultChip(result: HistorialItem["result"]) {
  if (result === "ganaste") {
    return (
      <Chip color="success" variant="soft" size="sm">
        <Chip.Label>ganaste</Chip.Label>
      </Chip>
    );
  }

  if (result === "perdiste") {
    return (
      <Chip color="danger" variant="soft" size="sm">
        <Chip.Label>perdiste</Chip.Label>
      </Chip>
    );
  }

  return (
    <Chip color="default" variant="soft" size="sm">
      <Chip.Label>pendiente</Chip.Label>
    </Chip>
  );
}

function getAvatarFallback(name: string, lastName: string) {
  const first = name?.[0] || "";
  const second = lastName?.[0] || "";

  return `${first}${second}`.toUpperCase() || "U";
}

function formatJoinedAt() {
  return "Junio 2026";
}

function formatDeadline(dateText: string) {
  const deadline = new Date(dateText);
  const now = new Date();

  if (Number.isNaN(deadline.getTime())) {
    return "Fecha no disponible";
  }

  const diffMs = deadline.getTime() - now.getTime();
  const diffHours = Math.ceil(diffMs / (1000 * 60 * 60));
  const diffDays = Math.ceil(diffHours / 24);

  if (diffMs <= 0) {
    return "Finalizó";
  }

  if (diffHours < 24) {
    return `Vence en ${diffHours} h`;
  }

  return `Vence en ${diffDays} días`;
}

function mapPersonToProfile(
  person: PersonResponse,
  activePropositionsCount: number,
  moneyBalance: number
): ProfileData {
  return {
    name: `${person.name} ${person.lastName}`.trim(),
    handle: `@${person.username}`,
    avatarFallback: getAvatarFallback(person.name, person.lastName),
    joinedAt: formatJoinedAt(),
    followers: 0,
    following: 0,
    pointsBalance: person.pointsBalance ?? 0,
    moneyBalance,
    activePropositions: activePropositionsCount,
    connectedNetworks: ["instagram"],
  };
}

function mapPropositionToHistory(p: PropositionResponse): HistorialItem {
  return {
    id: String(p.propositionId),
    text: p.title || p.description || "Proposición sin título",
    result: "pendiente",
    amount: `${p.minimumEntryPointsAmount ?? 0} pts en juego`,
    date: formatDeadline(p.endPredictionDateTime),
  };
}

function mapPredictionToHistory(p: MyPredictionResponse): HistorialItem {
  const amount =
    p.pointsAmount !== null && p.pointsAmount !== undefined
      ? `${p.pointsAmount} pts`
      : p.moneyAmount !== null && p.moneyAmount !== undefined
      ? `$${Number(p.moneyAmount).toFixed(2)}`
      : "0";

  return {
    id: String(p.predictionId),
    text:
      p.propositionTitle ||
      p.propositionDescription ||
      "Proposición sin título",
    result: "pendiente",
    amount: `${amount} · votaste ${p.predictionValue ? "sí" : "no"}`,
    date: formatDeadline(p.propositionEndDateTime),
  };
}

export default function PerfilPage() {
  const [editando, setEditando] = useState(false);
  const [profile, setProfile] = useState<ProfileData | null>(null);
  const [historialProposiciones, setHistorialProposiciones] = useState<
    HistorialItem[]
  >([]);
  const [historialPredicciones, setHistorialPredicciones] = useState<
  HistorialItem[]
  >([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadProfile() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");

        if (!storedPersonId) {
          setErrorMessage("No se encontró el usuario en sesión.");
          return;
        }

        const personId = Number(storedPersonId);

        const [person, propositions, predictions] = await Promise.all([
          getMe(personId),
          getActivePropositions(),
          getPredictionsByPerson(personId),
        ]);

        const myActivePropositions = propositions.filter(
          (p: PropositionResponse) => p.creatorPersonId === personId
        );

        const usedMoney = predictions.reduce(
          (total, prediction) => total + (prediction.moneyAmount ?? 0),
          0
        );

        const availableMoney = 100 - usedMoney;

        setProfile(
          mapPersonToProfile(person, myActivePropositions.length, availableMoney)
        );
        setHistorialProposiciones(
          myActivePropositions.map(mapPropositionToHistory)
        );
        setHistorialPredicciones(
          predictions.map(mapPredictionToHistory)
        );
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudo cargar el perfil."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadProfile();
  }, []);

  function logout() {
    localStorage.removeItem("personId");
    localStorage.removeItem("username");
    localStorage.removeItem("email");

    window.location.href = "/login";
  }

  if (isLoading) {
    return (
      <AppShell>
        <div className="mx-auto max-w-2xl">
          <div className="rounded-2xl border border-(--border) bg-(--surface) p-6 text-center">
            <p className="text-sm text-(--muted)">Cargando perfil...</p>
          </div>
        </div>
      </AppShell>
    );
  }

  if (!profile) {
    return (
      <AppShell>
        <div className="mx-auto max-w-2xl">
          <div className="rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage || "No se pudo cargar el perfil."}
          </div>

          <div className="mt-6 border-t border-(--separator) pt-6">
            <button
              type="button"
              className="text-sm text-(--danger) hover:underline"
              onClick={logout}
            >
              Volver a iniciar sesión
            </button>
          </div>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        {errorMessage && (
          <div className="mb-4 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage}
          </div>
        )}

        <div className="rounded-2xl border border-(--border) bg-(--surface) p-6">
          <div className="flex items-start justify-between gap-4">
            <div className="flex items-center gap-4">
              <Avatar size="lg">
                <Avatar.Fallback className="text-lg">
                  {profile.avatarFallback}
                </Avatar.Fallback>
              </Avatar>

              <div>
                <h1 className="font-display text-xl font-semibold text-(--foreground)">
                  {profile.name}
                </h1>

                <p className="text-sm text-(--muted)">{profile.handle}</p>

                <p className="mt-1 text-xs text-(--muted)">
                  En Gathel desde {profile.joinedAt}
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

          <div className="mt-6 grid grid-cols-4 gap-px overflow-hidden rounded-xl border border-(--border) bg-(--border)">
            {[
              { label: "Pts", value: profile.pointsBalance },
              { label: "Dinero", value: `$${profile.moneyBalance.toFixed(2)}` },
              { label: "Activas", value: profile.activePropositions },
              { label: "Predicciones", value: historialPredicciones.length },
            ].map((s) => (
              <div
                key={s.label}
                className="bg-(--surface-secondary) py-3 text-center"
              >
                <p className="font-display text-xl font-semibold text-(--foreground)">
                  {s.value}
                </p>
                <p className="text-xs text-(--muted)">{s.label}</p>
              </div>
            ))}
          </div>

          <div className="mt-4 flex items-center gap-3">
            <p className="text-xs text-(--muted)">Redes conectadas:</p>

            {profile.connectedNetworks.includes("instagram") ? (
              <Chip color="success" variant="soft" size="sm">
                <Chip.Label className="flex items-center gap-1">
                  <Link2 size={12} />
                  Instagram
                </Chip.Label>
              </Chip>
            ) : (
              <button
                type="button"
                className="text-xs text-(--accent) hover:underline"
              >
                + Conectar Instagram
              </button>
            )}

            {!profile.connectedNetworks.includes("tiktok") && (
              <button
                type="button"
                className="text-xs text-(--muted) hover:text-(--foreground)"
              >
                + Conectar TikTok
              </button>
            )}
          </div>
        </div>

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
                {historialProposiciones.length > 0 ? (
                  historialProposiciones.map((item) => (
                    <div
                      key={item.id}
                      className="flex items-center gap-3 rounded-xl border border-(--border) bg-(--surface) p-4"
                    >
                      <div className="shrink-0">{resultIcon(item.result)}</div>

                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm text-(--foreground)">
                          &quot;{item.text}&quot;
                        </p>

                        <p className="mt-0.5 text-xs text-(--muted)">
                          {item.date}
                        </p>
                      </div>

                      <div className="flex shrink-0 flex-col items-end gap-1">
                        {resultChip(item.result)}

                        <span className="text-xs text-(--muted)">
                          {item.amount}
                        </span>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="rounded-xl border border-(--border) bg-(--surface) p-6 text-center">
                    <p className="text-sm text-(--muted)">
                      Todavía no tenés proposiciones activas.
                    </p>
                  </div>
                )}
              </div>
            </Tabs.Panel>

            <Tabs.Panel id="predicciones">
              <div className="mt-4 flex flex-col gap-3">
                {historialPredicciones.length > 0 ? (
                  historialPredicciones.map((item) => (
                    <div
                      key={item.id}
                      className="flex items-center gap-3 rounded-xl border border-(--border) bg-(--surface) p-4"
                    >
                      <div className="shrink-0">{resultIcon(item.result)}</div>

                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm text-(--foreground)">
                          &quot;{item.text}&quot;
                        </p>

                        <p className="mt-0.5 text-xs text-(--muted)">
                          {item.date}
                        </p>
                      </div>

                      <div className="flex shrink-0 flex-col items-end gap-1">
                        {resultChip(item.result)}

                        <span className="text-xs text-(--muted)">
                          {item.amount}
                        </span>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="rounded-xl border border-(--border) bg-(--surface) p-6 text-center">
                    <p className="text-sm text-(--muted)">
                      Todavía no tenés predicciones registradas.
                    </p>
                  </div>
                )}
              </div>
            </Tabs.Panel>
          </Tabs>
        </div>

        <div className="mt-8 border-t border-(--separator) pt-6">
          <button
            type="button"
            className="text-sm text-(--danger) hover:underline"
            onClick={logout}
          >
            Cerrar sesión
          </button>
        </div>
      </div>
    </AppShell>
  );
}