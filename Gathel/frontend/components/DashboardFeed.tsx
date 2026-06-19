"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { Button, Tabs } from "@heroui/react";
import {
  AlertCircle,
  CheckCircle,
  Clock,
  Compass,
  ClipboardCheck,
  Plus,
  Trophy,
  Users,
  Vote,
} from "lucide-react";
import PropositionCard from "@/components/PropositionCard";
import type { Proposition } from "@/components/PropositionCard";
import {
  getActivePropositions,
  getPredictionsByProposition,
  getVotingPropositions,
  getMyVotingVotes,
  voteForCandidateProposition,
} from "@/lib/gathel-api";
import type {
  PredictionResponse,
  PropositionResponse,
  VotingPropositionGroupResponse,
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
    return <EmptyState message="No hay proposiciones activas para apostar." />;
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
              Proposiciones activas para pronosticar
            </p>
          )}

          <PropositionList items={batch.items} />
        </section>
      ))}
    </>
  );
}

type DashboardSummaryProps = {
  activeCount: number;
  votingCount: number;
  myVoteCount: number;
  myItemsCount: number;
};

function DashboardSummary({
  activeCount,
  votingCount,
  myVoteCount,
  myItemsCount,
}: DashboardSummaryProps) {
  return (
    <div className="mb-5 rounded-2xl border border-(--border) bg-(--surface) p-5">
      <p className="text-xs uppercase tracking-widest text-(--muted)">Inicio</p>

      <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground)">
        Resumen de Gathel
      </h1>

      <p className="mt-1 text-sm leading-relaxed text-(--muted)">
        Revisá los Gathel en votación, las proposiciones activas para
        pronosticar y tus movimientos dentro de la plataforma.
      </p>

      <div className="mt-4 grid grid-cols-2 gap-3 sm:grid-cols-4">
        <div className="rounded-xl border border-(--border) bg-(--surface-secondary) p-3">
          <p className="text-xs text-(--muted)">En votación</p>
          <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
            {votingCount}
          </p>
        </div>

        <div className="rounded-xl border border-(--border) bg-(--surface-secondary) p-3">
          <p className="text-xs text-(--muted)">Activas</p>
          <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
            {activeCount}
          </p>
        </div>

        <div className="rounded-xl border border-(--border) bg-(--surface-secondary) p-3">
          <p className="text-xs text-(--muted)">Tus votos</p>
          <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
            {myVoteCount}
          </p>
        </div>

        <div className="rounded-xl border border-(--border) bg-(--surface-secondary) p-3">
          <p className="text-xs text-(--muted)">Relacionados a vos</p>
          <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
            {myItemsCount}
          </p>
        </div>
      </div>

      <div className="mt-4 grid grid-cols-1 gap-2 sm:grid-cols-3">
        <Link
          href="/dashboard/crear"
          className="inline-flex items-center justify-center gap-2 rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
        >
          <Plus size={15} />
          Crear Gathel
        </Link>

        <Link
          href="/dashboard/explorar"
          className="inline-flex items-center justify-center gap-2 rounded-(--field-radius) border border-(--border) bg-(--surface-secondary) px-4 py-2 text-sm font-medium text-(--foreground) transition-colors hover:bg-(--surface)"
        >
          <Compass size={15} />
          Explorar
        </Link>

        <Link
          href="/dashboard/pendientes"
          className="inline-flex items-center justify-center gap-2 rounded-(--field-radius) border border-(--border) bg-(--surface-secondary) px-4 py-2 text-sm font-medium text-(--foreground) transition-colors hover:bg-(--surface)"
        >
          <ClipboardCheck size={15} />
          Pendientes
        </Link>
      </div>
    </div>
  );
}

type VotingGroupsListProps = {
  groups: VotingPropositionGroupResponse[];
  votedCandidateIds: number[];
  votedParentIds: number[];
  isVotingId: number | null;
  onVote: (candidatePropositionId: number, parentPropositionId: number) => void;
};

function VotingGroupsList({
  groups,
  votedCandidateIds,
  votedParentIds,
  isVotingId,
  onVote,
}: VotingGroupsListProps) {
  if (groups.length === 0) {
    return <EmptyState message="No hay Gathel en votación por ahora." />;
  }

  return (
    <section className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <div className="h-px flex-1 bg-(--border)" />
        <p className="text-xs uppercase tracking-widest text-(--muted)">
          Gathel en votación
        </p>
        <div className="h-px flex-1 bg-(--border)" />
      </div>

      {groups.map((group) => {
        const groupAlreadyVoted = votedParentIds.includes(group.propositionId);

        return (
          <article
            key={group.propositionId}
            className="rounded-2xl border border-(--border) bg-(--surface) p-5"
          >
            <div className="flex items-start justify-between gap-3">
              <div>
                <div className="flex items-center gap-2 text-xs text-(--muted)">
                  <Trophy size={14} />
                  <span>Gathel sobre usuario {group.targetPersonId}</span>
                </div>

                <Link
                  href={`/dashboard/proposicion/${group.propositionId}`}
                  className="mt-2 block text-base font-semibold leading-relaxed text-(--foreground) transition-colors hover:text-(--accent)"
                >
                  {group.title}
                </Link>

                {group.description && (
                  <p className="mt-1 text-sm leading-relaxed text-(--muted)">
                    {group.description}
                  </p>
                )}
              </div>

              <div className="shrink-0 rounded-full border border-(--border) px-3 py-1 text-xs text-(--muted)">
                En votación
              </div>
            </div>

            <div className="mt-4 flex items-center justify-between border-t border-(--separator) pt-3 text-xs text-(--muted)">
              <span className="flex items-center gap-1">
                <Users size={14} />
                {group.candidates.length} opciones
              </span>

              <span className="flex items-center gap-1">
                <Clock size={14} />
                {getTimeLeft(group.endPredictionDateTime)}
              </span>
            </div>

            {groupAlreadyVoted && (
              <div className="mt-4 rounded-xl border border-(--success)/30 bg-(--success-soft) p-3">
                <p className="text-xs font-medium text-(--success)">
                  Ya votaste en este Gathel. Solo se permite un voto por Gathel.
                </p>
              </div>
            )}

            <div className="mt-4 rounded-xl bg-(--surface-secondary) p-4">
              <p className="text-xs font-medium uppercase tracking-widest text-(--muted)">
                Opciones candidatas
              </p>

              {group.candidates.length === 0 ? (
                <p className="mt-3 text-sm text-(--muted)">
                  Este Gathel todavía no tiene opciones para votar.
                </p>
              ) : (
                <div className="mt-3 flex flex-col gap-3">
                  {group.candidates.map((candidate) => {
                    const voted = votedCandidateIds.includes(
                      candidate.propositionId
                    );

                    return (
                      <div
                        key={candidate.propositionId}
                        className="rounded-xl border border-(--border) bg-(--surface) p-4"
                      >
                        <div className="flex items-start justify-between gap-3">
                          <div>
                            <p className="text-sm font-medium leading-relaxed text-(--foreground)">
                              {candidate.title}
                            </p>

                            {candidate.description && (
                              <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                                {candidate.description}
                              </p>
                            )}

                            <p className="mt-2 text-xs text-(--muted)">
                              Propuesta por usuario {candidate.creatorPersonId}
                            </p>
                          </div>

                          {voted ? (
                            <div className="inline-flex shrink-0 items-center gap-1 rounded-full border border-(--success)/30 bg-(--success-soft) px-3 py-1 text-xs font-medium text-(--success)">
                              <CheckCircle size={13} />
                              Votada
                            </div>
                          ) : groupAlreadyVoted ? (
                            <div className="inline-flex shrink-0 items-center gap-1 rounded-full border border-(--border) bg-(--surface-secondary) px-3 py-1 text-xs font-medium text-(--muted)">
                              Bloqueada
                            </div>
                          ) : (
                            <button
                              type="button"
                              disabled={isVotingId === candidate.propositionId}
                              onClick={() =>
                                onVote(
                                  candidate.propositionId,
                                  group.propositionId
                                )
                              }
                              className="inline-flex shrink-0 items-center justify-center gap-2 rounded-(--field-radius) bg-(--accent) px-3 py-2 text-xs font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover) disabled:cursor-not-allowed disabled:opacity-60"
                            >
                              <Vote size={14} />
                              {isVotingId === candidate.propositionId
                                ? "Votando..."
                                : "Votar"}
                            </button>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            <div className="mt-4">
              <Link
                href={`/dashboard/proposicion/${group.propositionId}`}
                className="inline-flex items-center justify-center rounded-(--field-radius) border border-(--border) bg-(--surface-secondary) px-4 py-2 text-sm font-medium text-(--foreground) transition-colors hover:bg-(--surface)"
              >
                Ver detalle y añadir propuestas
              </Link>
            </div>
          </article>
        );
      })}
    </section>
  );
}

type MyVotingGroupsListProps = {
  groups: VotingPropositionGroupResponse[];
};

function MyVotingGroupsList({ groups }: MyVotingGroupsListProps) {
  if (groups.length === 0) {
    return null;
  }

  return (
    <section className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <div className="h-px flex-1 bg-(--border)" />
        <p className="text-xs uppercase tracking-widest text-(--muted)">
          Gathel relacionados conmigo
        </p>
        <div className="h-px flex-1 bg-(--border)" />
      </div>

      {groups.map((group) => (
        <article
          key={group.propositionId}
          className="rounded-2xl border border-(--border) bg-(--surface) p-5"
        >
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="text-xs text-(--muted)">
                Creado por usuario {group.creatorPersonId} · Sobre usuario{" "}
                {group.targetPersonId}
              </p>

              <Link
                href={`/dashboard/proposicion/${group.propositionId}`}
                className="mt-2 block text-base font-semibold text-(--foreground) transition-colors hover:text-(--accent)"
              >
                {group.title}
              </Link>

              {group.description && (
                <p className="mt-1 text-sm text-(--muted)">
                  {group.description}
                </p>
              )}
            </div>

            <div className="shrink-0 rounded-full border border-(--border) px-3 py-1 text-xs text-(--muted)">
              En votación
            </div>
          </div>

          <div className="mt-4 flex items-center justify-between border-t border-(--separator) pt-3 text-xs text-(--muted)">
            <span className="flex items-center gap-1">
              <Users size={14} />
              {group.candidates.length} opciones
            </span>

            <span className="flex items-center gap-1">
              <Clock size={14} />
              {getTimeLeft(group.endPredictionDateTime)}
            </span>
          </div>
        </article>
      ))}
    </section>
  );
}

export default function DashboardFeed() {
  const [allPropositions, setAllPropositions] = useState<PropositionResponse[]>(
    []
  );

  const [votingGroups, setVotingGroups] = useState<
    VotingPropositionGroupResponse[]
  >([]);

  const [paraTiBatches, setParaTiBatches] = useState<PropositionBatch[]>([]);
  const [mias, setMias] = useState<Proposition[]>([]);
  const [siguiendo] = useState<Proposition[]>([]);

  const [currentPersonId, setCurrentPersonId] = useState<number | null>(null);
  const [loadedCount, setLoadedCount] = useState(0);

  const [votedCandidateIds, setVotedCandidateIds] = useState<number[]>([]);
  const [votedParentIds, setVotedParentIds] = useState<number[]>([]);
  const [isVotingId, setIsVotingId] = useState<number | null>(null);

  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const hasMore = loadedCount < allPropositions.length;

  const myVotingGroups = useMemo(() => {
    if (currentPersonId === null) {
      return [];
    }

    return votingGroups.filter(
      (group) =>
        group.creatorPersonId === currentPersonId ||
        group.targetPersonId === currentPersonId ||
        group.candidates.some(
          (candidate) => candidate.creatorPersonId === currentPersonId
        )
    );
  }, [currentPersonId, votingGroups]);

  useEffect(() => {
    async function loadFeed() {
      try {
        setIsLoading(true);
        setErrorMessage("");
        setSuccessMessage("");

        const storedPersonId = localStorage.getItem("personId");
        const personId = storedPersonId ? Number(storedPersonId) : null;

        setCurrentPersonId(personId);

        const [activePropositions, votingGroupsResponse, myVotingVotes] =
          await Promise.all([
            getActivePropositions(),
            getVotingPropositions(),
            personId ? getMyVotingVotes(personId) : Promise.resolve([]),
          ]);

        setAllPropositions(activePropositions);
        setVotingGroups(votingGroupsResponse);

        setVotedCandidateIds(
          myVotingVotes.map((vote) => vote.candidatePropositionId)
        );

        setVotedParentIds(
          myVotingVotes.map((vote) => vote.parentPropositionId)
        );

        const firstBatchRaw = activePropositions.slice(0, PAGE_SIZE);
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

  async function handleVote(
    candidatePropositionId: number,
    parentPropositionId: number
  ) {
    try {
      setErrorMessage("");
      setSuccessMessage("");
      setIsVotingId(candidatePropositionId);

      const storedPersonId = localStorage.getItem("personId");

      if (!storedPersonId) {
        setErrorMessage("No se encontró el usuario en sesión.");
        return;
      }

      const personId = Number(storedPersonId);

      await voteForCandidateProposition({
        propositionId: candidatePropositionId,
        personId,
        voteValue: true,
      });

      setVotedCandidateIds((current) =>
        current.includes(candidatePropositionId)
          ? current
          : [...current, candidatePropositionId]
      );

      setVotedParentIds((current) =>
        current.includes(parentPropositionId)
          ? current
          : [...current, parentPropositionId]
      );

      setSuccessMessage("Voto registrado correctamente.");
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudo registrar el voto."
      );
    } finally {
      setIsVotingId(null);
    }
  }

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
        <p className="text-sm text-(--muted)">Cargando inicio...</p>
      </div>
    );
  }

  if (errorMessage) {
    return (
      <div className="flex gap-2 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
        <AlertCircle size={16} className="mt-0.5 shrink-0" />
        <p>{errorMessage}</p>
      </div>
    );
  }

  return (
    <>
      <DashboardSummary
        activeCount={allPropositions.length}
        votingCount={votingGroups.length}
        myVoteCount={votedParentIds.length}
        myItemsCount={mias.length + myVotingGroups.length}
      />

      {successMessage && (
        <div className="mb-4 flex gap-2 rounded-2xl border border-(--success)/30 bg-(--success-soft) p-4 text-sm text-(--success)">
          <CheckCircle size={16} className="mt-0.5 shrink-0" />
          <p>{successMessage}</p>
        </div>
      )}

      <Tabs defaultSelectedKey="para-ti">
        <Tabs.ListContainer>
          <Tabs.List>
            <Tabs.Tab id="para-ti">Para ti</Tabs.Tab>
            <Tabs.Tab id="votar">Votar</Tabs.Tab>
            <Tabs.Tab id="siguiendo">Siguiendo</Tabs.Tab>
            <Tabs.Tab id="mias">Mías</Tabs.Tab>
          </Tabs.List>
        </Tabs.ListContainer>

        <Tabs.Panel id="para-ti">
          <div className="mt-4 flex flex-col gap-6">
            <VotingGroupsList
              groups={votingGroups.slice(0, 5)}
              votedCandidateIds={votedCandidateIds}
              votedParentIds={votedParentIds}
              isVotingId={isVotingId}
              onVote={handleVote}
            />

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
                {isLoadingMore ? "Cargando..." : "Mostrar más apuestas"}
              </Button>
            )}
          </div>
        </Tabs.Panel>

        <Tabs.Panel id="votar">
          <div className="mt-4 flex flex-col gap-4">
            <VotingGroupsList
              groups={votingGroups}
              votedCandidateIds={votedCandidateIds}
              votedParentIds={votedParentIds}
              isVotingId={isVotingId}
              onVote={handleVote}
            />
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
          <div className="mt-4 flex flex-col gap-6">
            <MyVotingGroupsList groups={myVotingGroups} />

            {mias.length > 0 ? (
              <section className="flex flex-col gap-4">
                <div className="flex items-center gap-3">
                  <div className="h-px flex-1 bg-(--border)" />
                  <p className="text-xs uppercase tracking-widest text-(--muted)">
                    Proposiciones activas relacionadas conmigo
                  </p>
                  <div className="h-px flex-1 bg-(--border)" />
                </div>

                <PropositionList items={mias} />
              </section>
            ) : myVotingGroups.length === 0 ? (
              <EmptyState message="Todavía no tenés Gathel o proposiciones activas visibles." />
            ) : null}

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
    </>
  );
}