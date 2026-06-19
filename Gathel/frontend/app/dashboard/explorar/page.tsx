"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { Avatar, Chip } from "@heroui/react";
import {
  AlertCircle,
  ArrowRight,
  CheckCircle,
  Clock,
  DollarSign,
  Lightbulb,
  Plus,
  Search,
  SlidersHorizontal,
  Target,
  Trophy,
  Users,
  Vote,
  X,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  createProposition,
  getActivePropositions,
  getMyVotingVotes,
  getVotingPropositions,
  PropositionResponse,
  voteForCandidateProposition,
  VotingPropositionGroupResponse,
} from "@/lib/gathel-api";

type ExploreTab = "voting" | "active";

type ExploreFilter =
  | "todos"
  | "ya-vote"
  | "no-vote"
  | "sobre-mi"
  | "creados-por-mi";

type ExploreSort = "recientes" | "cierran-pronto" | "mas-opciones";

const FILTERS: { id: ExploreFilter; label: string }[] = [
  { id: "todos", label: "Todos" },
  { id: "ya-vote", label: "Ya voté" },
  { id: "no-vote", label: "No he votado" },
  { id: "sobre-mi", label: "Sobre mí" },
  { id: "creados-por-mi", label: "Creados por mí" },
];

const SORTS: { id: ExploreSort; label: string }[] = [
  { id: "recientes", label: "Más recientes" },
  { id: "cierran-pronto", label: "Cierran pronto" },
  { id: "mas-opciones", label: "Más opciones" },
];

function getAvatarFallback(name: string) {
  return (
    name
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2)
      .toUpperCase() || "U"
  );
}

function getTimeLeft(dateText: string) {
  const deadline = new Date(dateText);
  const now = new Date();

  if (Number.isNaN(deadline.getTime())) {
    return "tiempo no disponible";
  }

  const diffMs = deadline.getTime() - now.getTime();
  const diffHours = Math.ceil(diffMs / (1000 * 60 * 60));

  if (diffMs <= 0) {
    return "cerrada";
  }

  if (diffHours < 24) {
    return `quedan ${diffHours} h`;
  }

  const diffDays = Math.ceil(diffHours / 24);

  return `quedan ${diffDays} días`;
}

function formatDate(dateText: string) {
  const date = new Date(dateText);

  if (Number.isNaN(date.getTime())) {
    return "Fecha no disponible";
  }

  return date.toLocaleString("es-CR", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function getSearchableVotingText(group: VotingPropositionGroupResponse) {
  return `
    ${group.title}
    ${group.description ?? ""}
    ${group.creatorPersonId}
    ${group.targetPersonId}
    usuario ${group.creatorPersonId}
    usuario ${group.targetPersonId}
    ${group.candidates.map((candidate) => candidate.title).join(" ")}
    ${group.candidates
      .map((candidate) => candidate.description ?? "")
      .join(" ")}
    ${group.candidates
      .map((candidate) => candidate.creatorPersonId)
      .join(" ")}
  `.toLowerCase();
}

function getSearchableActiveText(item: PropositionResponse) {
  return `
    ${item.title}
    ${item.description ?? ""}
    ${item.creatorPersonId}
    ${item.targetPersonId}
    usuario ${item.creatorPersonId}
    usuario ${item.targetPersonId}
    ${item.status}
  `.toLowerCase();
}

function buildTitle(text: string, maxLength = 90) {
  const cleanText = text.trim();

  if (cleanText.length <= maxLength) {
    return cleanText;
  }

  return `${cleanText.slice(0, maxLength)}...`;
}

function getPredictionMode(item: PropositionResponse) {
  const text = `${item.title ?? ""} ${item.description ?? ""}`.toLowerCase();

  if (text.includes("modo de predicción: dinero")) {
    return "Dinero real";
  }

  if (text.includes("modo de predicción: ambos")) {
    return "Puntos y dinero";
  }

  if (text.includes("modo de predicción: puntos")) {
    return "Puntos";
  }

  if (item.minimumEntryPointsAmount === null) {
    return "Dinero real";
  }

  return "Puntos";
}

export default function ExplorarPage() {
  const [tab, setTab] = useState<ExploreTab>("voting");

  const [groups, setGroups] = useState<VotingPropositionGroupResponse[]>([]);
  const [activePropositions, setActivePropositions] = useState<
    PropositionResponse[]
  >([]);

  const [votedCandidateIds, setVotedCandidateIds] = useState<number[]>([]);
  const [votedParentIds, setVotedParentIds] = useState<number[]>([]);
  const [currentPersonId, setCurrentPersonId] = useState<number | null>(null);

  const [searchText, setSearchText] = useState("");
  const [filter, setFilter] = useState<ExploreFilter>("todos");
  const [sort, setSort] = useState<ExploreSort>("recientes");

  const [candidateTexts, setCandidateTexts] = useState<Record<number, string>>(
    {}
  );

  const [candidateDescriptions, setCandidateDescriptions] = useState<
    Record<number, string>
  >({});

  const [isLoading, setIsLoading] = useState(true);
  const [isVotingId, setIsVotingId] = useState<number | null>(null);
  const [isAddingCandidateId, setIsAddingCandidateId] = useState<number | null>(
    null
  );

  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
    async function loadExploreData() {
      try {
        setIsLoading(true);
        setErrorMessage("");
        setSuccessMessage("");

        const storedPersonId = localStorage.getItem("personId");
        const personId = storedPersonId ? Number(storedPersonId) : null;

        setCurrentPersonId(personId);

        const [votingResponse, activeResponse, myVotingVotes] =
          await Promise.all([
            getVotingPropositions(),
            getActivePropositions(),
            personId ? getMyVotingVotes(personId) : Promise.resolve([]),
          ]);

        setGroups(votingResponse);
        setActivePropositions(activeResponse);

        setVotedCandidateIds(
          myVotingVotes.map((vote) => vote.candidatePropositionId)
        );

        setVotedParentIds(
          myVotingVotes.map((vote) => vote.parentPropositionId)
        );
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudieron cargar los Gathel."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadExploreData();
  }, []);

  const filteredGroups = useMemo(() => {
    const normalizedSearch = searchText.trim().toLowerCase();

    return groups
      .filter((group) => {
        if (!normalizedSearch) {
          return true;
        }

        return getSearchableVotingText(group).includes(normalizedSearch);
      })
      .filter((group) => {
        if (filter === "todos") {
          return true;
        }

        if (filter === "ya-vote") {
          return votedParentIds.includes(group.propositionId);
        }

        if (filter === "no-vote") {
          return !votedParentIds.includes(group.propositionId);
        }

        if (!currentPersonId) {
          return false;
        }

        if (filter === "sobre-mi") {
          return group.targetPersonId === currentPersonId;
        }

        if (filter === "creados-por-mi") {
          return group.creatorPersonId === currentPersonId;
        }

        return true;
      })
      .sort((a, b) => {
        if (sort === "cierran-pronto") {
          return (
            new Date(a.endPredictionDateTime).getTime() -
            new Date(b.endPredictionDateTime).getTime()
          );
        }

        if (sort === "mas-opciones") {
          return b.candidates.length - a.candidates.length;
        }

        return b.propositionId - a.propositionId;
      });
  }, [groups, searchText, filter, sort, votedParentIds, currentPersonId]);

  const filteredActivePropositions = useMemo(() => {
    const normalizedSearch = searchText.trim().toLowerCase();

    return activePropositions
      .filter((item) => {
        if (!normalizedSearch) {
          return true;
        }

        return getSearchableActiveText(item).includes(normalizedSearch);
      })
      .filter((item) => {
        if (filter === "todos") {
          return true;
        }

        if (!currentPersonId) {
          return false;
        }

        if (filter === "sobre-mi") {
          return item.targetPersonId === currentPersonId;
        }

        if (filter === "creados-por-mi") {
          return item.creatorPersonId === currentPersonId;
        }

        return true;
      })
      .sort((a, b) => {
        if (sort === "cierran-pronto") {
          return (
            new Date(a.endPredictionDateTime).getTime() -
            new Date(b.endPredictionDateTime).getTime()
          );
        }

        return b.propositionId - a.propositionId;
      });
  }, [activePropositions, searchText, filter, sort, currentPersonId]);

  const hasActiveSearchOrFilter =
    searchText.trim().length > 0 || filter !== "todos" || sort !== "recientes";

  const totalVisible =
    tab === "voting" ? filteredGroups.length : filteredActivePropositions.length;

  const totalAvailable =
    tab === "voting" ? groups.length : activePropositions.length;

  async function refreshVotingGroups() {
    const updatedGroups = await getVotingPropositions();
    setGroups(updatedGroups);
  }

  async function refreshActivePropositions() {
    const updatedActive = await getActivePropositions();
    setActivePropositions(updatedActive);
  }

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

  async function handleAddCandidate(group: VotingPropositionGroupResponse) {
    try {
      setErrorMessage("");
      setSuccessMessage("");
      setIsAddingCandidateId(group.propositionId);

      const storedPersonId = localStorage.getItem("personId");

      if (!storedPersonId) {
        setErrorMessage("No se encontró el usuario en sesión.");
        return;
      }

      const personId = Number(storedPersonId);

      const candidateText = (candidateTexts[group.propositionId] ?? "").trim();

      const candidateDescription = (
        candidateDescriptions[group.propositionId] ?? ""
      ).trim();

      if (!candidateText) {
        setErrorMessage("Debe escribir una propuesta candidata.");
        return;
      }

      const title = buildTitle(candidateText);

      const descriptionParts = [
        candidateDescription || "Proposición candidata añadida por la comunidad.",
        "",
        `Proposición hija del Gathel ID: ${group.propositionId}`,
        `Creada por usuario ID: ${personId}`,
      ];

      await createProposition({
        creatorPersonId: personId,
        targetPersonId: group.targetPersonId,
        targetSocialAccountId: group.targetSocialAccountId ?? null,
        title,
        description: descriptionParts.join("\n"),
        startPredictionDateTime: group.startPredictionDateTime,
        endPredictionDateTime: group.endPredictionDateTime,
        minimumEntryPointsAmount: 1,
        winningProfitPercentage: 10,
        parentProposition: group.propositionId,
        parentPropositionId: group.propositionId,
      });

      setCandidateTexts((current) => ({
        ...current,
        [group.propositionId]: "",
      }));

      setCandidateDescriptions((current) => ({
        ...current,
        [group.propositionId]: "",
      }));

      await refreshVotingGroups();

      setSuccessMessage("Propuesta candidata añadida correctamente.");
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudo añadir la propuesta candidata."
      );
    } finally {
      setIsAddingCandidateId(null);
    }
  }

  function clearFilters() {
    setSearchText("");
    setFilter("todos");
    setSort("recientes");
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-3xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Explorar
        </span>

        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          Explorar Gathel
        </h1>

        <p className="mt-2 text-sm leading-relaxed text-(--muted)">
          Buscá Gathel en votación para elegir candidatas o encontrá
          proposiciones activas donde ya podés pronosticar con puntos o dinero.
        </p>

        <div className="mt-5 grid gap-3 sm:grid-cols-2">
          <button
            type="button"
            onClick={() => {
              setTab("voting");
              setFilter("todos");
            }}
            className={`rounded-2xl border p-4 text-left transition-colors ${
              tab === "voting"
                ? "border-(--accent) bg-(--accent-soft)"
                : "border-(--border) bg-(--surface) hover:bg-(--surface-secondary)"
            }`}
          >
            <div className="flex items-center gap-3">
              <div className="rounded-xl bg-(--surface) p-2 text-(--accent)">
                <Trophy size={18} />
              </div>

              <div>
                <p className="text-sm font-semibold text-(--foreground)">
                  En votación
                </p>

                <p className="text-xs text-(--muted)">
                  {groups.length} Gathel para votar candidatas
                </p>
              </div>
            </div>
          </button>

          <button
            type="button"
            onClick={() => {
              setTab("active");
              setFilter("todos");
              refreshActivePropositions();
            }}
            className={`rounded-2xl border p-4 text-left transition-colors ${
              tab === "active"
                ? "border-(--accent) bg-(--accent-soft)"
                : "border-(--border) bg-(--surface) hover:bg-(--surface-secondary)"
            }`}
          >
            <div className="flex items-center gap-3">
              <div className="rounded-xl bg-(--surface) p-2 text-(--accent)">
                <DollarSign size={18} />
              </div>

              <div>
                <p className="text-sm font-semibold text-(--foreground)">
                  Activas para pronosticar
                </p>

                <p className="text-xs text-(--muted)">
                  {activePropositions.length} disponibles para apostar
                </p>
              </div>
            </div>
          </button>
        </div>

        <div className="mt-5 rounded-2xl border border-(--border) bg-(--surface) p-4">
          <div className="flex items-start gap-3">
            <div className="rounded-xl bg-(--accent-soft) p-2 text-(--accent)">
              {tab === "voting" ? <Trophy size={18} /> : <Target size={18} />}
            </div>

            <div>
              <p className="text-sm font-medium text-(--foreground)">
                {tab === "voting"
                  ? "No estás apostando todavía"
                  : "Estas sí permiten pronosticar"}
              </p>

              <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                {tab === "voting"
                  ? "En esta sección solo se proponen y votan opciones candidatas. Solo podés votar por una opción dentro de cada Gathel."
                  : "En esta sección aparecen proposiciones aceptadas y activas. Desde el detalle podés realizar pronósticos usando puntos o dinero real."}
              </p>
            </div>
          </div>
        </div>

        <div className="mt-5 rounded-2xl border border-(--border) bg-(--surface) p-4">
          <div className="flex items-center gap-2">
            <Search size={17} className="text-(--muted)" />

            <input
              value={searchText}
              onChange={(event) => setSearchText(event.target.value)}
              placeholder={
                tab === "voting"
                  ? "Buscar por título, descripción, usuario o candidata..."
                  : "Buscar activas por título, descripción o usuario..."
              }
              className="min-w-0 flex-1 bg-transparent text-sm text-(--foreground) outline-none placeholder:text-(--muted)"
            />

            {searchText && (
              <button
                type="button"
                onClick={() => setSearchText("")}
                className="rounded-full p-1 text-(--muted) transition-colors hover:bg-(--surface-secondary) hover:text-(--foreground)"
                aria-label="Limpiar búsqueda"
              >
                <X size={15} />
              </button>
            )}
          </div>

          <div className="mt-4 flex items-center gap-2 text-xs text-(--muted)">
            <SlidersHorizontal size={14} />
            <span>Filtros</span>
          </div>

          <div className="mt-3 flex flex-wrap gap-2">
            {FILTERS.map((item) => {
              const active = filter === item.id;
              const disabled =
                tab === "active" &&
                (item.id === "ya-vote" || item.id === "no-vote");

              return (
                <button
                  key={item.id}
                  type="button"
                  disabled={disabled}
                  onClick={() => setFilter(item.id)}
                  className={`rounded-full border px-3 py-1.5 text-xs font-medium transition-colors disabled:cursor-not-allowed disabled:opacity-40 ${
                    active
                      ? "border-(--accent) bg-(--accent-soft) text-(--accent)"
                      : "border-(--border) bg-(--surface-secondary) text-(--muted) hover:text-(--foreground)"
                  }`}
                >
                  {item.label}
                </button>
              );
            })}
          </div>

          <div className="mt-4 flex items-center gap-2 text-xs text-(--muted)">
            <Clock size={14} />
            <span>Orden</span>
          </div>

          <div className="mt-3 flex flex-wrap gap-2">
            {SORTS.map((item) => {
              const active = sort === item.id;
              const disabled = tab === "active" && item.id === "mas-opciones";

              return (
                <button
                  key={item.id}
                  type="button"
                  disabled={disabled}
                  onClick={() => setSort(item.id)}
                  className={`rounded-full border px-3 py-1.5 text-xs font-medium transition-colors disabled:cursor-not-allowed disabled:opacity-40 ${
                    active
                      ? "border-(--accent) bg-(--accent-soft) text-(--accent)"
                      : "border-(--border) bg-(--surface-secondary) text-(--muted) hover:text-(--foreground)"
                  }`}
                >
                  {item.label}
                </button>
              );
            })}
          </div>

          <div className="mt-4 flex items-center justify-between border-t border-(--separator) pt-3">
            <p className="text-xs text-(--muted)">
              Mostrando{" "}
              <span className="font-medium text-(--foreground)">
                {totalVisible}
              </span>{" "}
              de{" "}
              <span className="font-medium text-(--foreground)">
                {totalAvailable}
              </span>{" "}
              {tab === "voting" ? "Gathel" : "proposiciones activas"}
            </p>

            {hasActiveSearchOrFilter && (
              <button
                type="button"
                onClick={clearFilters}
                className="text-xs font-medium text-(--accent) transition-colors hover:text-(--accent-hover)"
              >
                Limpiar filtros
              </button>
            )}
          </div>
        </div>

        {errorMessage && (
          <div className="mt-4 flex gap-2 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            <AlertCircle size={16} className="mt-0.5 shrink-0" />
            <p>{errorMessage}</p>
          </div>
        )}

        {successMessage && (
          <div className="mt-4 flex gap-2 rounded-2xl border border-(--success)/30 bg-(--success-soft) p-4 text-sm text-(--success)">
            <CheckCircle size={16} className="mt-0.5 shrink-0" />
            <p>{successMessage}</p>
          </div>
        )}

        {isLoading ? (
          <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
            <p className="text-sm text-(--muted)">Cargando Gathel...</p>
          </div>
        ) : tab === "active" ? (
          activePropositions.length === 0 ? (
            <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                No hay proposiciones activas para pronosticar por ahora.
              </p>

              <button
                type="button"
                onClick={() => setTab("voting")}
                className="mt-4 inline-flex rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
              >
                Ver Gathel en votación
              </button>
            </div>
          ) : filteredActivePropositions.length === 0 ? (
            <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm font-medium text-(--foreground)">
                No se encontraron proposiciones activas con esos filtros.
              </p>

              <p className="mt-1 text-sm text-(--muted)">
                Probá buscar otra palabra o limpiar los filtros.
              </p>

              <button
                type="button"
                onClick={clearFilters}
                className="mt-4 inline-flex rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
              >
                Limpiar filtros
              </button>
            </div>
          ) : (
            <div className="mt-6 flex flex-col gap-5">
              {filteredActivePropositions.map((item) => {
                const mode = getPredictionMode(item);

                return (
                  <article
                    key={item.propositionId}
                    className="rounded-2xl border border-(--border) bg-(--surface) p-5"
                  >
                    <div className="flex items-center justify-between gap-3">
                      <div className="flex items-center gap-2.5">
                        <Avatar size="sm">
                          <Avatar.Fallback>
                            {getAvatarFallback(`Usuario ${item.targetPersonId}`)}
                          </Avatar.Fallback>
                        </Avatar>

                        <div className="leading-tight">
                          <p className="text-sm font-medium text-(--foreground)">
                            Proposición sobre usuario {item.targetPersonId}
                          </p>

                          <p className="text-xs text-(--muted)">
                            creada por usuario {item.creatorPersonId}
                          </p>
                        </div>
                      </div>

                      <div className="flex flex-wrap justify-end gap-2">
                        <Chip color="success" variant="soft" size="sm">
                          <Chip.Label>Activa</Chip.Label>
                        </Chip>

                        <Chip color="accent" variant="soft" size="sm">
                          <Chip.Label>{mode}</Chip.Label>
                        </Chip>
                      </div>
                    </div>

                    <Link
                      href={`/dashboard/proposicion/${item.propositionId}`}
                      className="group mt-4 flex items-start justify-between gap-2"
                    >
                      <div>
                        <p className="text-base font-semibold leading-relaxed text-(--foreground) transition-colors group-hover:text-(--accent)">
                          {item.title}
                        </p>

                        {item.description && (
                          <p className="mt-1 text-sm leading-relaxed text-(--muted)">
                            {item.description}
                          </p>
                        )}
                      </div>

                      <ArrowRight
                        size={16}
                        className="mt-1 shrink-0 text-(--muted) transition-colors group-hover:text-(--accent)"
                        aria-hidden="true"
                      />
                    </Link>

                    <div className="mt-4 grid gap-2 rounded-xl bg-(--surface-secondary) p-3 text-xs sm:grid-cols-3">
                      <div>
                        <p className="text-(--muted)">Inicio</p>
                        <p className="mt-0.5 font-medium text-(--foreground)">
                          {formatDate(item.startPredictionDateTime)}
                        </p>
                      </div>

                      <div>
                        <p className="text-(--muted)">Cierre</p>
                        <p className="mt-0.5 font-medium text-(--foreground)">
                          {formatDate(item.endPredictionDateTime)}
                        </p>
                      </div>

                      <div>
                        <p className="text-(--muted)">Tiempo restante</p>
                        <p className="mt-0.5 font-medium text-(--accent)">
                          {getTimeLeft(item.endPredictionDateTime)}
                        </p>
                      </div>
                    </div>

                    <Link
                      href={`/dashboard/proposicion/${item.propositionId}`}
                      className="mt-4 inline-flex w-full items-center justify-center gap-2 rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
                    >
                      Pronosticar
                      <ArrowRight size={15} />
                    </Link>
                  </article>
                );
              })}
            </div>
          )
        ) : groups.length === 0 ? (
          <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
            <p className="text-sm text-(--muted)">
              No hay Gathel en votación por ahora.
            </p>

            <Link
              href="/dashboard/crear"
              className="mt-4 inline-flex rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
            >
              Crear Gathel
            </Link>
          </div>
        ) : filteredGroups.length === 0 ? (
          <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
            <p className="text-sm font-medium text-(--foreground)">
              No se encontraron Gathel con esos filtros.
            </p>

            <p className="mt-1 text-sm text-(--muted)">
              Probá buscar otra palabra o limpiar los filtros.
            </p>

            <button
              type="button"
              onClick={clearFilters}
              className="mt-4 inline-flex rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
            >
              Limpiar filtros
            </button>
          </div>
        ) : (
          <div className="mt-6 flex flex-col gap-5">
            {filteredGroups.map((group) => {
              const groupAlreadyVoted = votedParentIds.includes(
                group.propositionId
              );

              return (
                <article
                  key={group.propositionId}
                  className="rounded-2xl border border-(--border) bg-(--surface) p-5"
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex items-center gap-2.5">
                      <Avatar size="sm">
                        <Avatar.Fallback>
                          {getAvatarFallback(`Usuario ${group.targetPersonId}`)}
                        </Avatar.Fallback>
                      </Avatar>

                      <div className="leading-tight">
                        <p className="text-sm font-medium text-(--foreground)">
                          Gathel sobre usuario {group.targetPersonId}
                        </p>

                        <p className="text-xs text-(--muted)">
                          creado por usuario {group.creatorPersonId}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      {groupAlreadyVoted && (
                        <Chip color="success" variant="soft" size="sm">
                          <Chip.Label>Ya votaste</Chip.Label>
                        </Chip>
                      )}

                      <Chip color="accent" variant="soft" size="sm">
                        <Chip.Label>En votación</Chip.Label>
                      </Chip>
                    </div>
                  </div>

                  <Link
                    href={`/dashboard/proposicion/${group.propositionId}`}
                    className="group mt-4 flex items-start justify-between gap-2"
                  >
                    <div>
                      <p className="text-base font-semibold leading-relaxed text-(--foreground) transition-colors group-hover:text-(--accent)">
                        {group.title}
                      </p>

                      {group.description && (
                        <p className="mt-1 text-sm leading-relaxed text-(--muted)">
                          {group.description}
                        </p>
                      )}
                    </div>

                    <ArrowRight
                      size={16}
                      className="mt-1 shrink-0 text-(--muted) transition-colors group-hover:text-(--accent)"
                      aria-hidden="true"
                    />
                  </Link>

                  <div className="mt-4 flex items-center justify-between border-t border-(--separator) pt-3 text-xs text-(--muted)">
                    <span className="flex items-center gap-1">
                      <Users size={14} aria-hidden="true" />
                      {group.candidates.length} opciones candidatas
                    </span>

                    <span className="flex items-center gap-1">
                      <Clock size={14} aria-hidden="true" />
                      {getTimeLeft(group.endPredictionDateTime)}
                    </span>
                  </div>

                  {groupAlreadyVoted && (
                    <div className="mt-4 rounded-xl border border-(--success)/30 bg-(--success-soft) p-3">
                      <p className="text-xs font-medium text-(--success)">
                        Ya votaste en este Gathel. Las demás opciones quedaron
                        bloqueadas.
                      </p>
                    </div>
                  )}

                  <div className="mt-4 rounded-xl bg-(--surface-secondary) p-4">
                    <p className="text-xs font-medium uppercase tracking-widest text-(--muted)">
                      Opciones para votar
                    </p>

                    {group.candidates.length === 0 ? (
                      <p className="mt-3 text-sm text-(--muted)">
                        Este Gathel todavía no tiene opciones candidatas.
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
                                    Propuesta por usuario{" "}
                                    {candidate.creatorPersonId}
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
                                    disabled={
                                      isVotingId === candidate.propositionId
                                    }
                                    onClick={() =>
                                      handleVote(
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

                  <div className="mt-4 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
                    <div className="flex items-start gap-3">
                      <div className="rounded-lg bg-(--accent-soft) p-2 text-(--accent)">
                        <Lightbulb size={16} />
                      </div>

                      <div>
                        <p className="text-xs font-medium uppercase tracking-widest text-(--muted)">
                          Añadir propuesta candidata
                        </p>

                        <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                          Agregá otra opción posible para que la comunidad pueda
                          votarla dentro de este Gathel.
                        </p>
                      </div>
                    </div>

                    <div className="mt-3 flex flex-col gap-3">
                      <textarea
                        value={candidateTexts[group.propositionId] ?? ""}
                        onChange={(event) =>
                          setCandidateTexts((current) => ({
                            ...current,
                            [group.propositionId]: event.target.value,
                          }))
                        }
                        rows={3}
                        maxLength={240}
                        placeholder='Ej: "María termina la maratón en menos de 5 horas."'
                        className="w-full resize-none rounded-xl border border-(--border) bg-(--surface) px-3 py-2 text-sm text-(--foreground) outline-none placeholder:text-(--muted) focus:border-(--accent)"
                      />

                      <textarea
                        value={
                          candidateDescriptions[group.propositionId] ?? ""
                        }
                        onChange={(event) =>
                          setCandidateDescriptions((current) => ({
                            ...current,
                            [group.propositionId]: event.target.value,
                          }))
                        }
                        rows={2}
                        maxLength={300}
                        placeholder="Descripción o forma de verificarla, opcional."
                        className="w-full resize-none rounded-xl border border-(--border) bg-(--surface) px-3 py-2 text-sm text-(--foreground) outline-none placeholder:text-(--muted) focus:border-(--accent)"
                      />

                      <button
                        type="button"
                        disabled={isAddingCandidateId === group.propositionId}
                        onClick={() => handleAddCandidate(group)}
                        className="inline-flex items-center justify-center gap-2 rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover) disabled:cursor-not-allowed disabled:opacity-60"
                      >
                        <Plus size={15} />

                        {isAddingCandidateId === group.propositionId
                          ? "Añadiendo..."
                          : "Añadir propuesta"}
                      </button>
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </div>
    </AppShell>
  );
}