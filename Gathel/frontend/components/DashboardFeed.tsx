"use client";

import { useEffect, useState } from "react";
import { Button, Tabs } from "@heroui/react";
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

const PAGE_SIZE = 25;

type PropositionBatch = {
  title: string;
  items: Proposition[];
};

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

function mapProposition(
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

        return mapProposition(proposition, predictions, currentPersonId);
      } catch {
        return mapProposition(proposition, [], currentPersonId);
      }
    })
  );

  return cards;
}

function EmptyState({ message }: { message: string }) {
  return (
    <div className="rounded-2xl border border-(--border) bg-(--surface) py-10 text-center">
      <p className="text-sm text-(--muted)">{message}</p>
    </div>
  );
}

function PropositionList({ items }: { items: Proposition[] }) {
  if (items.length === 0) {
    return <EmptyState message="No hay proposiciones para mostrar." />;
  }

  return (
    <>
      {items.map((item) => (
        <PropositionCard key={item.id} item={item} />
      ))}
    </>
  );
}

function PropositionBatchList({ batches }: { batches: PropositionBatch[] }) {
  if (batches.length === 0) {
    return <EmptyState message="No hay proposiciones para mostrar." />;
  }

  return (
    <>
      {batches.map((batch, index) => (
        <section key={`${batch.title}-${index}`} className="flex flex-col gap-4">
          {index > 0 && (
            <div className="mt-2 flex items-center gap-3">
              <div className="h-px flex-1 bg-(--border)" />
              <p className="text-xs uppercase tracking-widest text-(--muted)">
                {batch.title}
              </p>
              <div className="h-px flex-1 bg-(--border)" />
            </div>
          )}

          {index === 0 && (
            <p className="text-xs uppercase tracking-widest text-(--muted)">
              Más recientes
            </p>
          )}

          <PropositionList items={batch.items} />
        </section>
      ))}
    </>
  );
}

export default function DashboardFeed() {
  const [allPropositions, setAllPropositions] = useState<PropositionResponse[]>(
    []
  );

  const [paraTiBatches, setParaTiBatches] = useState<PropositionBatch[]>([]);
  const [mias, setMias] = useState<Proposition[]>([]);
  const [siguiendo] = useState<Proposition[]>([]);

  const [currentPersonId, setCurrentPersonId] = useState<number | null>(null);
  const [loadedCount, setLoadedCount] = useState(0);

  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  const hasMore = loadedCount < allPropositions.length;

  useEffect(() => {
    async function loadFeed() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");
        const personId = storedPersonId ? Number(storedPersonId) : null;

        setCurrentPersonId(personId);

        const propositions = await getActivePropositions();
        setAllPropositions(propositions);

        const firstBatchRaw = propositions.slice(0, PAGE_SIZE);
        const firstCards = await buildCards(firstBatchRaw, personId);

        setParaTiBatches([
          {
            title: "Más recientes",
            items: firstCards,
          },
        ]);

        setMias(firstCards.filter((item) => item.isMine));
        setLoadedCount(firstBatchRaw.length);
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

    loadFeed();
  }, []);

  async function handleShowMore() {
    if (isLoadingMore || !hasMore) {
      return;
    }

    try {
      setIsLoadingMore(true);

      const start = loadedCount;
      const end = loadedCount + PAGE_SIZE;

      const nextBatchRaw = allPropositions.slice(start, end);
      const nextCards = await buildCards(nextBatchRaw, currentPersonId);

      setParaTiBatches((prev) => [
        ...prev,
        {
          title: `Cargadas después ${start + 1}-${start + nextCards.length}`,
          items: nextCards,
        },
      ]);

      setMias((prev) => [
        ...prev,
        ...nextCards.filter((item) => item.isMine),
      ]);

      setLoadedCount((prev) => prev + nextBatchRaw.length);
    } finally {
      setIsLoadingMore(false);
    }
  }

  if (isLoading) {
    return (
      <div className="rounded-2xl border border-(--border) bg-(--surface) py-10 text-center">
        <p className="text-sm text-(--muted)">Cargando proposiciones...</p>
      </div>
    );
  }

  if (errorMessage) {
    return (
      <div className="rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
        {errorMessage}
      </div>
    );
  }

  return (
    <Tabs defaultSelectedKey="para-ti">
      <Tabs.ListContainer>
        <Tabs.List>
          <Tabs.Tab id="para-ti">Para ti</Tabs.Tab>
          <Tabs.Tab id="siguiendo">Siguiendo</Tabs.Tab>
          <Tabs.Tab id="mias">Mías</Tabs.Tab>
        </Tabs.List>
      </Tabs.ListContainer>

      <Tabs.Panel id="para-ti">
        <div className="mt-4 flex flex-col gap-4">
          <PropositionBatchList batches={paraTiBatches} />

          {hasMore && (
            <Button
              type="button"
              variant="outline"
              size="md"
              fullWidth
              isDisabled={isLoadingMore}
              onClick={handleShowMore}
            >
              {isLoadingMore ? "Cargando..." : "Mostrar más"}
            </Button>
          )}
        </div>
      </Tabs.Panel>

      <Tabs.Panel id="siguiendo">
        <div className="mt-4 flex flex-col gap-4">
          {siguiendo.length > 0 ? (
            <PropositionList items={siguiendo} />
          ) : (
            <EmptyState message="Todavía no estamos cargando proposiciones de usuarios seguidos." />
          )}
        </div>
      </Tabs.Panel>

      <Tabs.Panel id="mias">
        <div className="mt-4 flex flex-col gap-4">
          {mias.length > 0 ? (
            <PropositionList items={mias} />
          ) : (
            <EmptyState message="Todavía no tenés proposiciones activas visibles." />
          )}

          {hasMore && (
            <Button
              type="button"
              variant="outline"
              size="md"
              fullWidth
              isDisabled={isLoadingMore}
              onClick={handleShowMore}
            >
              {isLoadingMore ? "Cargando..." : "Mostrar más"}
            </Button>
          )}
        </div>
      </Tabs.Panel>
    </Tabs>
  );
}