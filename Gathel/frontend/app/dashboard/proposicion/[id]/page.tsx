"use client";

import { use, useEffect, useState } from "react";
import Link from "next/link";
import { Avatar, Chip, buttonVariants } from "@heroui/react";
import {
  ArrowLeft,
  Users,
  TrendingUp,
  TrendingDown,
  CheckCircle,
  Image as ImageIcon,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  getPredictionsByProposition,
  getPropositionById,
} from "@/lib/gathel-api";
import type {
  PredictionResponse,
  PropositionResponse,
} from "@/lib/gathel-api";

type Prediction = {
  personId: number | null;
  user: string;
  handle: string;
  vote: "si" | "no";
  amount: string;
  time: string;
  isCurrentUser?: boolean;
};

type PropositionDetail = {
  id: string;
  author: string;
  handle: string;
  subject: string;
  subjectHandle: string;
  text: string;
  status: "activa" | "cumplida" | "no cumplida";
  mode: "puntos" | "dinero" | "ambos";
  probability: number;
  pool: string;
  timeLeft: string;
  deadline: string;
  votes: number;
  createdAt: string;
  acceptedAt: string;
  evidence: string | null;
  predictions: Prediction[];
  creatorPersonId: number;
  targetPersonId: number;
};

function statusChip(status: PropositionDetail["status"]) {
  if (status === "cumplida") {
    return (
      <Chip color="success" variant="soft" size="sm">
        <Chip.Label>cumplida</Chip.Label>
      </Chip>
    );
  }

  if (status === "no cumplida") {
    return (
      <Chip color="danger" variant="soft" size="sm">
        <Chip.Label>no cumplida</Chip.Label>
      </Chip>
    );
  }

  return (
    <Chip color="accent" variant="soft" size="sm">
      <Chip.Label>activa</Chip.Label>
    </Chip>
  );
}

function modeChip(mode: PropositionDetail["mode"]) {
  const label =
    mode === "puntos"
      ? "solo puntos"
      : mode === "dinero"
      ? "dinero real"
      : "puntos y dinero";

  return (
    <Chip color="default" variant="soft" size="sm">
      <Chip.Label>{label}</Chip.Label>
    </Chip>
  );
}

function normalizeStatus(status: string | null | undefined): PropositionDetail["status"] {
  const value = (status ?? "").toLowerCase();

  if (value.includes("no")) return "no cumplida";
  if (value.includes("cumpl")) return "cumplida";

  return "activa";
}

function formatDate(dateText: string) {
  const date = new Date(dateText);

  if (Number.isNaN(date.getTime())) {
    return "Fecha no disponible";
  }

  return date.toLocaleDateString("es-CR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function formatDeadline(dateText: string) {
  const date = new Date(dateText);

  if (Number.isNaN(date.getTime())) {
    return "Fecha no disponible";
  }

  return date.toLocaleString("es-CR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function getTimeLeft(dateText: string) {
  const deadline = new Date(dateText);
  const now = new Date();

  if (Number.isNaN(deadline.getTime())) {
    return "—";
  }

  const diffMs = deadline.getTime() - now.getTime();
  const diffHours = Math.ceil(diffMs / (1000 * 60 * 60));
  const diffDays = Math.ceil(diffHours / 24);

  if (diffMs <= 0) return "finalizó";
  if (diffHours < 24) return `quedan ${diffHours} h`;

  return `quedan ${diffDays} días`;
}

function formatPredictionTime(dateText: string) {
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

function calculateProbability(predictions: Prediction[]) {
  if (predictions.length === 0) {
    return 50;
  }

  const yesVotes = predictions.filter((p) => p.vote === "si").length;

  return Math.round((yesVotes / predictions.length) * 100);
}

function calculatePool(
  predictions: Prediction[],
  fallbackPoints: number | null,
  mode: PropositionDetail["mode"]
) {
  if (predictions.length === 0) {
    if (mode === "dinero") {
      return "$0.00";
    }

    if (mode === "ambos") {
      return `${fallbackPoints ?? 1} pts · $0.00`;
    }

    return `${fallbackPoints ?? 1} pts`;
  }

  let totalPoints = 0;
  let totalMoney = 0;

  predictions.forEach((p) => {
    if (p.amount.includes("pt")) {
      const value = Number.parseFloat(p.amount);
      totalPoints += Number.isNaN(value) ? 0 : value;
    }

    if (p.amount.includes("$")) {
      const value = Number.parseFloat(p.amount.replace("$", ""));
      totalMoney += Number.isNaN(value) ? 0 : value;
    }
  });

  if (mode === "dinero") {
    return `$${totalMoney.toFixed(2)}`;
  }

  if (mode === "ambos") {
    return `${totalPoints} pts · $${totalMoney.toFixed(2)}`;
  }

  return `${totalPoints} pts`;
}


function detectMode(predictions: Prediction[]): PropositionDetail["mode"] {
  const hasPoints = predictions.some((p) => p.amount.includes("pt"));
  const hasMoney = predictions.some((p) => p.amount.includes("$"));

  if (hasPoints && hasMoney) return "ambos";
  if (hasMoney) return "dinero";

  return "puntos";
}

function mapPrediction(
  p: PredictionResponse,
  currentPersonId: number | null
): Prediction {
  const hasPoints = p.pointsAmount !== null && p.pointsAmount !== undefined;
  const hasMoney = p.moneyAmount !== null && p.moneyAmount !== undefined;

  return {
    personId: p.personId,
    user: p.user?.trim() || `Usuario ${p.personId}`,
    handle: p.handle || `@user${p.personId}`,
    vote: p.predictionValue ? "si" : "no",
    amount: hasPoints
      ? `${p.pointsAmount} pt`
      : hasMoney
      ? `$${Number(p.moneyAmount).toFixed(2)}`
      : "0",
    time: formatPredictionTime(p.predictionDateTime),
    isCurrentUser: currentPersonId !== null && p.personId === currentPersonId,
  };
}

function detectPropositionMode(
  p: PropositionResponse,
  predictions: Prediction[]
): PropositionDetail["mode"] {
  const text = `${p.title ?? ""} ${p.description ?? ""}`.toLowerCase();

  if (text.includes("modo de predicción: dinero")) {
    return "dinero";
  }

  if (text.includes("modo de predicción: ambos")) {
    return "ambos";
  }

  if (text.includes("modo de predicción: puntos")) {
    return "puntos";
  }

  return detectMode(predictions);
}

function mapPropositionToDetail(
  p: PropositionResponse,
  predictions: Prediction[]
): PropositionDetail {
  const mode = detectPropositionMode(p, predictions);

  return {
    id: String(p.propositionId),
    author: `Usuario ${p.creatorPersonId}`,
    handle: `@user${p.creatorPersonId}`,
    subject: `Usuario ${p.targetPersonId}`,
    subjectHandle: `@user${p.targetPersonId}`,
    text: p.title || p.description || "Proposición sin título",
    status: normalizeStatus(p.status),
    mode,
    probability: calculateProbability(predictions),
    pool: calculatePool(predictions, p.minimumEntryPointsAmount, mode),
    timeLeft: getTimeLeft(p.endPredictionDateTime),
    deadline: formatDeadline(p.endPredictionDateTime),
    votes: predictions.length,
    createdAt: formatDate(p.startPredictionDateTime),
    acceptedAt: formatDate(p.startPredictionDateTime),
    evidence: null,
    predictions,
    creatorPersonId: p.creatorPersonId,
    targetPersonId: p.targetPersonId,
  };
}

export default function ProposicionDetallePage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);

  const [item, setItem] = useState<PropositionDetail | null>(null);
  const [currentPersonId, setCurrentPersonId] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadProposition() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");
        const personId = storedPersonId ? Number(storedPersonId) : null;

        setCurrentPersonId(personId);

        const propositionId = Number(id);

        const [propositionResponse, predictionsResponse] = await Promise.all([
          getPropositionById(propositionId),
          getPredictionsByProposition(propositionId),
        ]);

        const mappedPredictions = predictionsResponse
          .map((prediction) => mapPrediction(prediction, personId))
          .sort((a, b) => {
            if (a.isCurrentUser && !b.isCurrentUser) return -1;
            if (!a.isCurrentUser && b.isCurrentUser) return 1;
            return 0;
        });

        setItem(
          mapPropositionToDetail(propositionResponse, mappedPredictions)
        );
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudo cargar la proposición."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadProposition();
  }, [id]);

  if (isLoading) {
    return (
      <AppShell>
        <div className="mx-auto max-w-2xl">
          <p className="text-sm text-(--muted)">Cargando proposición...</p>
        </div>
      </AppShell>
    );
  }

  if (!item) {
    return (
      <AppShell>
        <div className="mx-auto max-w-2xl">
          <Link
            href="/dashboard"
            className="inline-flex items-center gap-1.5 text-sm text-(--muted) hover:text-(--foreground) transition-colors"
          >
            <ArrowLeft size={15} aria-hidden="true" />
            Volver al feed
          </Link>

          <div className="mt-5 rounded-2xl border border-red-500/40 bg-red-500/10 p-5 text-sm text-red-300">
            {errorMessage || "No se encontró la proposición."}
          </div>
        </div>
      </AppShell>
    );
  }

  const siCount = item.predictions.filter((p) => p.vote === "si").length;
  const noCount = item.predictions.filter((p) => p.vote === "no").length;
  const isActive = item.status === "activa";
  const isMine =
    currentPersonId !== null &&
    (currentPersonId === item.creatorPersonId ||
      currentPersonId === item.targetPersonId);

  const alreadyVoted =
    currentPersonId !== null &&
    item.predictions.some((p) => p.personId === currentPersonId);

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-1.5 text-sm text-(--muted) hover:text-(--foreground) transition-colors"
        >
          <ArrowLeft size={15} aria-hidden="true" />
          Volver al feed
        </Link>

        <div className="mt-5 rounded-2xl border border-(--border) bg-(--surface) p-5">
          <div className="flex flex-wrap items-center gap-2">
            {statusChip(item.status)}
            {modeChip(item.mode)}
          </div>

          <p className="mt-4 font-display text-xl font-semibold leading-snug text-(--foreground) sm:text-2xl">
            &quot;{item.text}&quot;
          </p>

          <div className="mt-5 grid grid-cols-2 gap-3 text-sm sm:grid-cols-4">
            <div>
              <p className="text-xs text-(--muted)">Propuesta por</p>
              <p className="mt-0.5 font-medium text-(--foreground)">
                {item.author}
              </p>
              <p className="text-xs text-(--muted)">{item.handle}</p>
            </div>

            <div>
              <p className="text-xs text-(--muted)">Sobre</p>
              <p className="mt-0.5 font-medium text-(--foreground)">
                {item.subject}
              </p>
              <p className="text-xs text-(--muted)">{item.subjectHandle}</p>
            </div>

            <div>
              <p className="text-xs text-(--muted)">Creada</p>
              <p className="mt-0.5 font-medium text-(--foreground)">
                {item.createdAt}
              </p>
            </div>

            <div>
              <p className="text-xs text-(--muted)">Cierra</p>
              <p className="mt-0.5 font-medium text-(--foreground)">
                {item.deadline}
              </p>
              <p className="text-xs text-(--accent)">{item.timeLeft}</p>
            </div>
          </div>
        </div>

        <div className="mt-4 rounded-2xl border border-(--border) bg-(--surface) p-5">
          <div className="flex items-center justify-between text-sm">
            <span className="text-(--muted)">Probabilidad de la comunidad</span>
            <span className="font-display text-lg font-semibold text-(--accent)">
              {item.probability}%
            </span>
          </div>

          <div className="mt-3 h-2 w-full overflow-hidden rounded-full bg-(--default)">
            <div
              className="h-full rounded-full bg-(--accent) transition-all"
              style={{ width: `${item.probability}%` }}
            />
          </div>

          <div className="mt-3 flex items-center justify-between text-xs text-(--muted)">
            <span className="flex items-center gap-1">
              <TrendingUp size={13} className="text-(--success)" />
              {siCount} dicen que sí
            </span>

            <span className="flex items-center gap-1">
              <TrendingDown size={13} className="text-(--danger)" />
              {noCount} dicen que no
            </span>

            <span className="flex items-center gap-1">
              <Users size={13} />
              {item.votes} en total · {item.pool}
            </span>
          </div>
        </div>

        {item.status !== "activa" && (
          <div className="mt-4 rounded-2xl border border-(--border) bg-(--surface) p-5">
            <p className="text-xs uppercase tracking-widest text-(--muted)">
              Evidencia publicada
            </p>

            {item.evidence ? (
              <p className="mt-2 text-sm text-(--foreground)">
                {item.evidence}
              </p>
            ) : (
              <div className="mt-3 flex flex-col items-center justify-center gap-2 rounded-xl border border-dashed border-(--border) py-8 text-center">
                <ImageIcon
                  size={24}
                  className="text-(--muted)"
                  aria-hidden="true"
                />
                <p className="text-sm text-(--muted)">
                  La evidencia fue analizada por IA a partir de publicaciones
                  en redes sociales con el hashtag #gathel.
                </p>
              </div>
            )}
          </div>
        )}

        {isActive && isMine && (
          <div className="mt-4 rounded-2xl border border-(--accent)/30 bg-(--accent-soft) p-5">
            <p className="text-sm font-medium text-(--foreground)">
              No podés pronosticar en esta proposición.
            </p>

            <p className="mt-1 text-sm text-(--muted)">
              No se permite pronosticar en proposiciones que creaste o que son sobre vos,
              para evitar conflictos de interés.
            </p>

            <div className="mt-4 flex items-center gap-2">
              <Link
                href="/dashboard"
                className={buttonVariants({
                  variant: "secondary",
                  size: "sm",
                })}
              >
                Volver al feed
              </Link>
            </div>
          </div>
        )}

        {isActive && !isMine && !alreadyVoted && (
          <div className="mt-4 rounded-2xl border border-(--border) bg-(--surface) p-5">
            <p className="text-sm font-medium text-(--foreground)">
              ¿Qué crees que va a pasar?
            </p>

            <p className="mt-1 text-sm text-(--muted)">
              Modo:{" "}
              <span className="text-(--foreground)">
                {item.mode === "puntos"
                  ? "apuesta hasta 1 punto"
                  : item.mode === "dinero"
                  ? "elige el monto en dinero real"
                  : "puntos o dinero real"}
              </span>
            </p>

            <div className="mt-4 grid grid-cols-2 gap-3">
              <Link
                href={`/dashboard/proposicion/${item.id}/pronosticar?voto=si`}
                className={buttonVariants({
                  variant: "secondary",
                  size: "lg",
                  fullWidth: true,
                })}
              >
                <TrendingUp size={16} className="mr-1" />
                Sí va a pasar
              </Link>

              <Link
                href={`/dashboard/proposicion/${item.id}/pronosticar?voto=no`}
                className={buttonVariants({
                  variant: "outline",
                  size: "lg",
                  fullWidth: true,
                })}
              >
                <TrendingDown size={16} className="mr-1" />
                No va a pasar
              </Link>
            </div>
          </div>
        )}

        {isActive && !isMine && alreadyVoted && (
          <div className="mt-4 rounded-2xl border border-(--success)/30 bg-(--success-soft) p-5">
            <p className="text-sm font-medium text-(--foreground)">
              Ya hiciste un pronóstico en esta proposición.
            </p>

            <p className="mt-1 text-sm text-(--muted)">
              Solo se permite un pronóstico por usuario en cada proposición.
            </p>
          </div>
        )}

        <div className="mt-6">
          <p className="text-xs uppercase tracking-widest text-(--muted)">
            Últimos pronósticos
          </p>

          <div className="mt-3 flex flex-col gap-2">
            {item.predictions.length === 0 ? (
              <div className="rounded-xl border border-(--border) bg-(--surface) py-8 text-center">
                <p className="text-sm text-(--muted)">
                  Todavía no hay pronósticos.
                </p>
              </div>
            ) : (
              item.predictions.map((p, i) => (
                <div
                  key={`${p.personId}-${i}`}
                  className="flex items-center justify-between rounded-xl border border-(--border) bg-(--surface) px-4 py-3"
                >
                  <div className="flex items-center gap-2.5">
                    <Avatar size="sm">
                      <Avatar.Fallback>
                        {p.user
                          .split(" ")
                          .map((x) => x[0])
                          .join("")
                          .toUpperCase()}
                      </Avatar.Fallback>
                    </Avatar>

                    <div className="leading-tight">
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-(--foreground)">
                          {p.isCurrentUser ? "Tu pronóstico" : p.user}
                        </p>

                        {p.isCurrentUser && (
                          <Chip color="success" variant="soft" size="sm">
                            <Chip.Label>tuyo</Chip.Label>
                          </Chip>
                        )}
                      </div>

                      <p className="text-xs text-(--muted)">
                        {p.handle} · {p.time}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <span className="text-xs text-(--muted)">
                      {p.amount}
                    </span>

                    {p.vote === "si" ? (
                      <Chip color="success" variant="soft" size="sm">
                        <Chip.Label className="flex items-center gap-1">
                          <CheckCircle size={11} />
                          sí
                        </Chip.Label>
                      </Chip>
                    ) : (
                      <Chip color="danger" variant="soft" size="sm">
                        <Chip.Label>no</Chip.Label>
                      </Chip>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </AppShell>
  );
}