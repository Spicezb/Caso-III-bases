"use client";

import { useEffect, useMemo, useState } from "react";
import { Button, Chip, Input, Label, TextField } from "@heroui/react";
import { Search } from "lucide-react";
import AppShell from "@/components/AppShell";
import PropositionCard from "@/components/PropositionCard";
import type { Proposition } from "@/components/PropositionCard";
import {
  getActivePropositions,
  getPredictionsByProposition,
} from "@/lib/gathel-api";
import type {
  PredictionResponse,
  PropositionResponse,
} from "@/lib/gathel-api";

const FILTERS = ["Todas", "Activas", "Cumplidas", "No cumplidas"] as const;
type Filter = (typeof FILTERS)[number];

const PAGE_SIZE = 25;

function normalizeStatus(status: string): Proposition["status"] {
  const value = status.toLowerCase();

  if (value.includes("no")) return "no cumplida";
  if (value.includes("cumpl")) return "cumplida";

  return "activa";
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

function calculateProbability(predictions: PredictionResponse[]) {
  if (predictions.length === 0) {
    return 50;
  }

  const yesVotes = predictions.filter((p) => p.predictionValue).length;

  return Math.round((yesVotes / predictions.length) * 100);
}

function calculatePool(
  predictions: PredictionResponse[],
  fallbackPoints: number | null
) {
  if (predictions.length === 0) {
    return `${fallbackPoints ?? 0} pts`;
  }

  const totalPoints = predictions.reduce(
    (total, p) => total + (p.pointsAmount ?? 0),
    0
  );

  const totalMoney = predictions.reduce(
    (total, p) => total + (p.moneyAmount ?? 0),
    0
  );

  if (totalPoints > 0 && totalMoney > 0) {
    return `${totalPoints} pts · $${totalMoney.toFixed(2)}`;
  }

  if (totalMoney > 0) {
    return `$${totalMoney.toFixed(2)}`;
  }

  return `${totalPoints} pts`;
}

function detectMode(predictions: PredictionResponse[]): Proposition["mode"] {
  const hasPoints = predictions.some(
    (p) => p.pointsAmount !== null && p.pointsAmount !== undefined
  );

  const hasMoney = predictions.some(
    (p) => p.moneyAmount !== null && p.moneyAmount !== undefined
  );

  if (hasPoints && hasMoney) return "ambos";
  if (hasMoney) return "dinero";

  return "puntos";
}

function mapPropositionToCard(
  p: PropositionResponse,
  predictions: PredictionResponse[],
  currentPersonId: number | null
): Proposition {
  const isMine =
    currentPersonId !== null &&
    (p.creatorPersonId === currentPersonId ||
      p.targetPersonId === currentPersonId);

  const alreadyVoted =
    currentPersonId !== null &&
    predictions.some((prediction) => prediction.personId === currentPersonId);

  return {
    id: String(p.propositionId),
    author: `Usuario ${p.creatorPersonId}`,
    handle: `@user${p.creatorPersonId}`,
    text: p.title || p.description || "Proposición sin título",
    probability: calculateProbability(predictions),
    pool: calculatePool(predictions, p.minimumEntryPointsAmount),
    timeLeft: getTimeLeft(p.endPredictionDateTime),
    votes: predictions.length,
    status: normalizeStatus(p.status),
    mode: detectMode(predictions),
    alreadyVoted,
    isMine,
  };
}

function matchesSearchAndFilter(
  p: PropositionResponse,
  query: string,
  filter: Filter
) {
  const normalizedQuery = query.trim().toLowerCase();

  const status = normalizeStatus(p.status);

  const matchesText =
    normalizedQuery === "" ||
    String(p.propositionId).includes(normalizedQuery) ||
    p.title?.toLowerCase().includes(normalizedQuery) ||
    p.description?.toLowerCase().includes(normalizedQuery) ||
    `usuario ${p.creatorPersonId}`.includes(normalizedQuery) ||
    `@user${p.creatorPersonId}`.includes(normalizedQuery) ||
    `usuario ${p.targetPersonId}`.includes(normalizedQuery) ||
    `@user${p.targetPersonId}`.includes(normalizedQuery);

  const matchesFilter =
    filter === "Todas" ||
    (filter === "Activas" && status === "activa") ||
    (filter === "Cumplidas" && status === "cumplida") ||
    (filter === "No cumplidas" && status === "no cumplida");

  return matchesText && matchesFilter;
}

async function buildCards(
  propositions: PropositionResponse[],
  currentPersonId: number | null
) {
  const cards = await Promise.all(
    propositions.map(async (proposition) => {
      try {
        const predictions = await getPredictionsByProposition(
          proposition.propositionId
        );

        return mapPropositionToCard(
          proposition,
          predictions,
          currentPersonId
        );
      } catch {
        return mapPropositionToCard(proposition, [], currentPersonId);
      }
    })
  );

  return cards;
}

export default function ExplorarPage() {
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState<Filter>("Todas");

  const [allPropositions, setAllPropositions] = useState<PropositionResponse[]>(
    []
  );

  const [items, setItems] = useState<Proposition[]>([]);
  const [visibleCount, setVisibleCount] = useState(PAGE_SIZE);
  const [currentPersonId, setCurrentPersonId] = useState<number | null>(null);

  const [isLoading, setIsLoading] = useState(true);
  const [isMapping, setIsMapping] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  const filteredRawPropositions = useMemo(() => {
    return allPropositions.filter((p) =>
      matchesSearchAndFilter(p, query, filter)
    );
  }, [allPropositions, query, filter]);

  const hasMore = visibleCount < filteredRawPropositions.length;

  useEffect(() => {
    async function loadPropositions() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");
        const personId = storedPersonId ? Number(storedPersonId) : null;

        setCurrentPersonId(personId);

        const response = await getActivePropositions();
        setAllPropositions(response);
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudieron cargar las proposiciones."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadPropositions();
  }, []);

  useEffect(() => {
    // Avoid synchronous setState inside effect to prevent cascading renders.
    const t = setTimeout(() => setVisibleCount(PAGE_SIZE), 0);

    return () => clearTimeout(t);
  }, [query, filter]);

  useEffect(() => {
    async function loadVisibleCards() {
      if (isLoading) {
        return;
      }

      try {
        setIsMapping(true);

        const visibleRaw = filteredRawPropositions.slice(0, visibleCount);
        const cards = await buildCards(visibleRaw, currentPersonId);

        setItems(cards);
      } finally {
        setIsMapping(false);
      }
    }

    loadVisibleCards();
  }, [filteredRawPropositions, visibleCount, currentPersonId, isLoading]);

  function handleShowMore() {
    setVisibleCount((prev) => prev + PAGE_SIZE);
  }

  return (
    <AppShell active="/dashboard/explorar">
      <div className="mx-auto max-w-2xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Explorar
        </span>

        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          Todas las proposiciones
        </h1>

        <p className="mt-2 text-sm text-(--muted)">
          Mostrando {items.length} de {filteredRawPropositions.length} resultados.
        </p>

        <div className="mt-6">
          <TextField
            value={query}
            onChange={setQuery}
            aria-label="Buscar proposiciones"
          >
            <Label className="sr-only">Buscar proposiciones</Label>

            <div className="relative">
              <Search
                size={16}
                className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-(--muted)"
                aria-hidden="true"
              />

              <Input
                placeholder="Buscar por texto, usuario, handle o ID…"
                className="pl-9"
              />
            </div>
          </TextField>
        </div>

        <div className="mt-4 flex flex-wrap gap-2">
          {FILTERS.map((f) => (
            <button
              key={f}
              type="button"
              onClick={() => setFilter(f)}
              className="focus:outline-none"
            >
              <Chip
                color={filter === f ? "accent" : "default"}
                variant={filter === f ? "primary" : "soft"}
                size="sm"
                className="cursor-pointer"
              >
                <Chip.Label>{f}</Chip.Label>
              </Chip>
            </button>
          ))}
        </div>

        {errorMessage && (
          <div className="mt-4 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage}
          </div>
        )}

        <div className="mt-6 flex flex-col gap-4">
          {isLoading ? (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                Cargando proposiciones...
              </p>
            </div>
          ) : isMapping ? (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                Buscando y calculando porcentajes...
              </p>
            </div>
          ) : items.length > 0 ? (
            <>
              {items.map((item) => (
                <PropositionCard key={item.id} item={item} />
              ))}

              {hasMore && (
                <Button
                  type="button"
                  variant="outline"
                  size="md"
                  fullWidth
                  isDisabled={isMapping}
                  onClick={handleShowMore}
                >
                  Mostrar más
                </Button>
              )}
            </>
          ) : (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                No hay proposiciones que coincidan con tu búsqueda.
              </p>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}