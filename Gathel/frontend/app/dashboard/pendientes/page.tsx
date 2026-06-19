"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Avatar, Chip } from "@heroui/react";
import {
  AlertCircle,
  ArrowRight,
  CheckCircle,
  Clock,
  ShieldCheck,
  XCircle,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  acceptWinningProposition,
  getPendingApprovalPropositions,
  PropositionResponse,
  rejectWinningProposition,
} from "@/lib/gathel-api";

type DateForm = {
  startPredictionDateTime: string;
  endPredictionDateTime: string;
};

function getAvatarFallback(text: string) {
  return (
    text
      .split(" ")
      .map((part) => part[0])
      .join("")
      .slice(0, 2)
      .toUpperCase() || "U"
  );
}

function toDatetimeLocalValue(date: Date) {
  const offset = date.getTimezoneOffset();
  const localDate = new Date(date.getTime() - offset * 60 * 1000);

  return localDate.toISOString().slice(0, 16);
}

function getDefaultDateForm(): DateForm {
  const start = new Date();
  const end = new Date();

  start.setHours(start.getHours() - 1);
  end.setDate(end.getDate() + 1);

  return {
    startPredictionDateTime: toDatetimeLocalValue(start),
    endPredictionDateTime: toDatetimeLocalValue(end),
  };
}

function toIsoDateTime(localValue: string) {
  return new Date(localValue).toISOString();
}

function detectMode(item: PropositionResponse) {
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

function getParentInfo(item: PropositionResponse) {
  const parentId =
    item.parentProposition ??
    item.parentPropositionId ??
    null;

  if (!parentId) {
    return null;
  }

  return `Gathel padre ID: ${parentId}`;
}

function getTargetLabel(item: PropositionResponse, currentPersonId: number | null) {
  if (currentPersonId !== null && item.targetPersonId === currentPersonId) {
    return "sobre vos";
  }

  return `sobre usuario ${item.targetPersonId}`;
}

export default function PendientesPage() {
  const [propositions, setPropositions] = useState<PropositionResponse[]>([]);
  const [dateForms, setDateForms] = useState<Record<number, DateForm>>({});
  const [currentPersonId, setCurrentPersonId] = useState<number | null>(null);

  const [isLoading, setIsLoading] = useState(true);
  const [actionLoadingId, setActionLoadingId] = useState<number | null>(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  async function loadPendingPropositions() {
    try {
      setIsLoading(true);
      setErrorMessage("");
      setSuccessMessage("");

      const storedPersonId = localStorage.getItem("personId");

      if (!storedPersonId) {
        setErrorMessage("No se encontró el usuario en sesión.");
        return;
      }

      const targetPersonId = Number(storedPersonId);

      setCurrentPersonId(targetPersonId);

      const response = await getPendingApprovalPropositions(targetPersonId);

      setPropositions(response);

      const defaultForms: Record<number, DateForm> = {};

      response.forEach((proposition) => {
        defaultForms[proposition.propositionId] = getDefaultDateForm();
      });

      setDateForms(defaultForms);
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudieron cargar las proposiciones pendientes."
      );
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    loadPendingPropositions();
  }, []);

  function updateDateForm(
    propositionId: number,
    field: keyof DateForm,
    value: string
  ) {
    setDateForms((current) => ({
      ...current,
      [propositionId]: {
        ...current[propositionId],
        [field]: value,
      },
    }));
  }

  async function handleAccept(propositionId: number) {
    try {
      setErrorMessage("");
      setSuccessMessage("");
      setActionLoadingId(propositionId);

      const storedPersonId = localStorage.getItem("personId");

      if (!storedPersonId) {
        setErrorMessage("No se encontró el usuario en sesión.");
        return;
      }

      const targetPersonId = Number(storedPersonId);
      const form = dateForms[propositionId];

      if (!form) {
        setErrorMessage("No se encontraron las fechas de predicción.");
        return;
      }

      if (!form.startPredictionDateTime || !form.endPredictionDateTime) {
        setErrorMessage("Debés definir fecha de inicio y fecha de cierre.");
        return;
      }

      const startDate = new Date(form.startPredictionDateTime);
      const endDate = new Date(form.endPredictionDateTime);
      const now = new Date();

      if (Number.isNaN(startDate.getTime()) || Number.isNaN(endDate.getTime())) {
        setErrorMessage("Las fechas ingresadas no son válidas.");
        return;
      }

      if (startDate < now) {
        setErrorMessage("La fecha de inicio debe ser posterior al momento actual.");
        return;
      }

      if (endDate <= startDate) {
        setErrorMessage("La fecha de cierre debe ser posterior a la de inicio.");
        return;
      }

      await acceptWinningProposition({
        propositionId,
        targetPersonId,
        startPredictionDateTime: toIsoDateTime(form.startPredictionDateTime),
        endPredictionDateTime: toIsoDateTime(form.endPredictionDateTime),
      });

      setPropositions((current) =>
        current.filter((item) => item.propositionId !== propositionId)
      );

      setSuccessMessage(
        "Proposición aceptada. Ahora está activa para recibir predicciones."
      );
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudo aceptar la proposición."
      );
    } finally {
      setActionLoadingId(null);
    }
  }

  async function handleReject(propositionId: number) {
    try {
      setErrorMessage("");
      setSuccessMessage("");
      setActionLoadingId(propositionId);

      const storedPersonId = localStorage.getItem("personId");

      if (!storedPersonId) {
        setErrorMessage("No se encontró el usuario en sesión.");
        return;
      }

      const targetPersonId = Number(storedPersonId);

      await rejectWinningProposition({
        propositionId,
        targetPersonId,
      });

      setPropositions((current) =>
        current.filter((item) => item.propositionId !== propositionId)
      );

      setSuccessMessage(
        "Proposición rechazada. Se aplicó la penalización correspondiente."
      );
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudo rechazar la proposición."
      );
    } finally {
      setActionLoadingId(null);
    }
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Pendientes
        </span>

        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          Proposiciones por aceptar
        </h1>

        <p className="mt-2 text-sm leading-relaxed text-(--muted)">
          Estas son las opciones ganadoras de un Gathel. Como sos la persona
          objetivo, podés aceptarlas para abrir predicciones o rechazarlas si no
          estás de acuerdo.
        </p>

        <div className="mt-5 rounded-2xl border border-(--border) bg-(--surface) p-4">
          <div className="flex items-start gap-3">
            <div className="rounded-xl bg-(--accent-soft) p-2 text-(--accent)">
              <ShieldCheck size={18} />
            </div>

            <div>
              <p className="text-sm font-medium text-(--foreground)">
                Regla importante
              </p>

              <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                Si aceptás, definís la ventana para que otros jugadores hagan
                predicciones. Si rechazás, la proposición no se activa y se
                aplica la penalización definida por las reglas.
              </p>
            </div>
          </div>
        </div>

        {errorMessage && (
          <div className="mt-4 flex gap-2 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            <AlertCircle size={16} className="mt-0.5 shrink-0" />
            <p>{errorMessage}</p>
          </div>
        )}

        {successMessage && (
          <div className="mt-4 flex gap-2 rounded-2xl border border-(--success)/40 bg-(--success-soft) p-4 text-sm text-(--success)">
            <CheckCircle size={16} className="mt-0.5 shrink-0" />
            <p>{successMessage}</p>
          </div>
        )}

        {isLoading ? (
          <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
            <p className="text-sm text-(--muted)">
              Cargando proposiciones pendientes...
            </p>
          </div>
        ) : propositions.length === 0 ? (
          <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
            <p className="text-sm text-(--muted)">
              No tenés proposiciones pendientes de aceptación.
            </p>

            <Link
              href="/dashboard/explorar"
              className="mt-4 inline-flex rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
            >
              Ver Gathel en votación
            </Link>
          </div>
        ) : (
          <div className="mt-6 flex flex-col gap-4">
            {propositions.map((item) => {
              const form = dateForms[item.propositionId] ?? getDefaultDateForm();
              const isWorking = actionLoadingId === item.propositionId;
              const parentInfo = getParentInfo(item);
              const mode = detectMode(item);
              const targetLabel = getTargetLabel(item, currentPersonId);

              return (
                <article
                  key={item.propositionId}
                  className="rounded-2xl border border-(--border) bg-(--surface) p-5"
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex items-center gap-2.5">
                      <Avatar size="sm">
                        <Avatar.Fallback>
                          {getAvatarFallback(`Usuario ${item.creatorPersonId}`)}
                        </Avatar.Fallback>
                      </Avatar>

                      <div className="leading-tight">
                        <p className="text-sm font-medium text-(--foreground)">
                          Usuario {item.creatorPersonId}
                        </p>

                        <p className="text-xs text-(--muted)">
                          propuso esta opción ganadora {targetLabel}
                        </p>
                      </div>
                    </div>

                    <Chip color="warning" variant="soft" size="sm">
                      <Chip.Label>Pendiente</Chip.Label>
                    </Chip>
                  </div>

                  <div className="mt-4 flex flex-wrap gap-2">
                    <Chip color="default" variant="soft" size="sm">
                      <Chip.Label>{mode}</Chip.Label>
                    </Chip>

                    {parentInfo && (
                      <Chip color="default" variant="soft" size="sm">
                        <Chip.Label>{parentInfo}</Chip.Label>
                      </Chip>
                    )}
                  </div>

                  <Link
                    href={`/dashboard/proposicion/${item.propositionId}`}
                    className="group mt-3 flex items-start justify-between gap-2"
                  >
                    <p className="text-base font-semibold leading-relaxed text-(--foreground) transition-colors group-hover:text-(--accent)">
                      {item.title}
                    </p>

                    <ArrowRight
                      size={16}
                      className="mt-1 shrink-0 text-(--muted) transition-colors group-hover:text-(--accent)"
                      aria-hidden="true"
                    />
                  </Link>

                  {item.description && (
                    <p className="mt-2 text-xs leading-relaxed text-(--muted)">
                      {item.description}
                    </p>
                  )}

                  <div className="mt-4 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
                    <div className="flex items-center gap-2 text-xs text-(--muted)">
                      <Clock size={14} />
                      <span>Definí la ventana para recibir predicciones</span>
                    </div>

                    <div className="mt-3 grid gap-3 sm:grid-cols-2">
                      <label className="text-xs text-(--muted)">
                        Inicio de predicciones
                        <input
                          type="datetime-local"
                          value={form.startPredictionDateTime}
                          onChange={(event) =>
                            updateDateForm(
                              item.propositionId,
                              "startPredictionDateTime",
                              event.target.value
                            )
                          }
                          className="mt-1 w-full rounded-(--field-radius) border border-(--border) bg-(--background) px-3 py-2 text-sm text-(--foreground) outline-none transition-colors focus:border-(--accent)"
                        />
                      </label>

                      <label className="text-xs text-(--muted)">
                        Cierre de predicciones
                        <input
                          type="datetime-local"
                          value={form.endPredictionDateTime}
                          onChange={(event) =>
                            updateDateForm(
                              item.propositionId,
                              "endPredictionDateTime",
                              event.target.value
                            )
                          }
                          className="mt-1 w-full rounded-(--field-radius) border border-(--border) bg-(--background) px-3 py-2 text-sm text-(--foreground) outline-none transition-colors focus:border-(--accent)"
                        />
                      </label>
                    </div>
                  </div>

                  <div className="mt-4 grid grid-cols-2 gap-2">
                    <button
                      type="button"
                      disabled={isWorking}
                      onClick={() => handleReject(item.propositionId)}
                      className="inline-flex items-center justify-center gap-2 rounded-(--field-radius) border border-(--danger)/40 px-4 py-2 text-sm font-medium text-(--danger) transition-colors hover:bg-(--danger)/10 disabled:cursor-not-allowed disabled:opacity-60"
                    >
                      <XCircle size={16} />
                      {isWorking ? "Procesando..." : "Rechazar"}
                    </button>

                    <button
                      type="button"
                      disabled={isWorking}
                      onClick={() => handleAccept(item.propositionId)}
                      className="inline-flex items-center justify-center gap-2 rounded-(--field-radius) bg-(--accent) px-4 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover) disabled:cursor-not-allowed disabled:opacity-60"
                    >
                      <CheckCircle size={16} />
                      {isWorking ? "Procesando..." : "Aceptar y activar"}
                    </button>
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