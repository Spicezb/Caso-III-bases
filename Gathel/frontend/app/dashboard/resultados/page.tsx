"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Avatar, Chip } from "@heroui/react";
import {
  TrendingUp,
  TrendingDown,
  Clock,
  CheckCircle,
  XCircle,
  Minus,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  getPredictionsByPerson,
  MyPredictionResponse,
} from "@/lib/gathel-api";

type Resultado = {
  id: string;
  propositionId: number;
  proposicion: string;
  autor: string;
  handle: string;
  fechaCierre: string;
  estado: "pendiente" | "gané" | "perdí";
  miVoto: "si" | "no";
  apuestaPuntos: number;
  apuestaDinero: number;
  gananciaPuntos: number;
  gananciaDinero: number;
};

type Filtro = "todos" | "gané" | "perdí" | "pendiente";

function formatDeadline(dateText: string) {
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

function isPending(dateText: string) {
  const deadline = new Date(dateText);
  const now = new Date();

  if (Number.isNaN(deadline.getTime())) {
    return true;
  }

  return deadline.getTime() > now.getTime();
}

function getAmount(prediction: MyPredictionResponse) {
  const apuestaPuntos = prediction.pointsAmount ?? 0;
  const apuestaDinero = prediction.moneyAmount ?? 0;

  return {
    apuestaPuntos,
    apuestaDinero,
  };
}

function mapPredictionToResultado(
  prediction: MyPredictionResponse
): Resultado {
  const pending = isPending(prediction.propositionEndDateTime);
  const { apuestaPuntos, apuestaDinero } = getAmount(prediction);

  let estado: Resultado["estado"] = "pendiente";

  if (!pending) {
    estado = prediction.isWinner ? "gané" : "perdí";
  }

  const gananciaPuntos =
    estado === "pendiente"
      ? 0
      : estado === "gané"
      ? apuestaPuntos
      : -apuestaPuntos;

  const gananciaDinero =
    estado === "pendiente"
      ? 0
      : estado === "gané"
      ? apuestaDinero
      : -apuestaDinero;

  return {
    id: String(prediction.predictionId),
    propositionId: prediction.propositionId,
    proposicion:
      prediction.propositionTitle ||
      prediction.propositionDescription ||
      "Proposición sin título",
    autor: prediction.user || `Usuario ${prediction.personId}`,
    handle: prediction.handle || `@user${prediction.personId}`,
    fechaCierre: formatDeadline(prediction.propositionEndDateTime),
    estado,
    miVoto: prediction.predictionValue ? "si" : "no",
    apuestaPuntos,
    apuestaDinero,
    gananciaPuntos,
    gananciaDinero,
  };
}

function calcBalance(resultados: Resultado[]) {
  return resultados.reduce(
    (acc, r) => ({
      puntos: acc.puntos + r.gananciaPuntos,
      dinero: acc.dinero + r.gananciaDinero,
    }),
    { puntos: 0, dinero: 0 }
  );
}

function estadoChip(estado: Resultado["estado"]) {
  if (estado === "gané") {
    return (
      <Chip color="success" variant="soft" size="sm">
        <Chip.Label className="flex items-center gap-1">
          <CheckCircle size={11} />
          Ganaste
        </Chip.Label>
      </Chip>
    );
  }

  if (estado === "perdí") {
    return (
      <Chip color="danger" variant="soft" size="sm">
        <Chip.Label className="flex items-center gap-1">
          <XCircle size={11} />
          Perdiste
        </Chip.Label>
      </Chip>
    );
  }

  return (
    <Chip color="default" variant="soft" size="sm">
      <Chip.Label className="flex items-center gap-1">
        <Minus size={11} />
        Pendiente
      </Chip.Label>
    </Chip>
  );
}

function avatarFallback(name: string) {
  return (
    name
      .split(" ")
      .map((p) => p[0])
      .join("")
      .slice(0, 2)
      .toUpperCase() || "U"
  );
}

function getApuestaText(r: Resultado) {
  const parts: string[] = [];

  if (r.apuestaPuntos > 0) {
    parts.push(`${r.apuestaPuntos} pts`);
  }

  if (r.apuestaDinero > 0) {
    parts.push(`$${r.apuestaDinero.toFixed(2)}`);
  }

  return parts.length > 0 ? parts.join(" · ") : "Sin monto";
}

function getResultadoText(r: Resultado) {
  if (r.estado === "pendiente") {
    return "Pendiente";
  }

  const parts: string[] = [];

  if (r.gananciaPuntos !== 0) {
    parts.push(
      `${r.gananciaPuntos > 0 ? "+" : ""}${r.gananciaPuntos} pts`
    );
  }

  if (r.gananciaDinero !== 0) {
    parts.push(
      `${r.gananciaDinero > 0 ? "+" : ""}$${r.gananciaDinero.toFixed(2)}`
    );
  }

  return parts.length > 0 ? parts.join(" · ") : "Sin cambio";
}

export default function ResultadosPage() {
  const [resultados, setResultados] = useState<Resultado[]>([]);
  const [filtro, setFiltro] = useState<Filtro>("todos");
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadResultados() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const storedPersonId = localStorage.getItem("personId");

        if (!storedPersonId) {
          setErrorMessage("No se encontró el usuario en sesión.");
          return;
        }

        const personId = Number(storedPersonId);
        const predictions = await getPredictionsByPerson(personId);

        setResultados(predictions.map(mapPredictionToResultado));
      } catch (error) {
        setErrorMessage(
          error instanceof Error
            ? error.message
            : "No se pudieron cargar los resultados."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadResultados();
  }, []);

  const visible = resultados.filter((r) => {
    if (filtro === "gané") return r.estado === "gané";
    if (filtro === "perdí") return r.estado === "perdí";
    if (filtro === "pendiente") return r.estado === "pendiente";

    return true;
  });

  const balance = calcBalance(resultados);
  const ganadas = resultados.filter((r) => r.estado === "gané").length;
  const perdidas = resultados.filter((r) => r.estado === "perdí").length;
  const pendientes = resultados.filter((r) => r.estado === "pendiente").length;

  const totalResueltas = ganadas + perdidas;
  const porcentajeAcierto =
    totalResueltas > 0 ? Math.round((ganadas / totalResueltas) * 100) : 0;

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Historial
        </span>

        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          Resultados
        </h1>

        <p className="mt-2 text-sm text-(--muted)">
          Historial de tus pronósticos. El balance es estimado porque todavía no
          se guarda el pago real ni el multiplicador final en la base de datos.
        </p>

        {errorMessage && (
          <div className="mt-4 rounded-2xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {errorMessage}
          </div>
        )}

        {isLoading ? (
          <div className="mt-6 rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
            <p className="text-sm text-(--muted)">Cargando resultados...</p>
          </div>
        ) : (
          <>
            <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
              <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
                <p className="text-xs text-(--muted)">Total</p>
                <p className="mt-1 font-display text-xl font-semibold text-(--foreground)">
                  {resultados.length}
                </p>
                <p className="text-xs text-(--muted)">predicciones</p>
              </div>

              <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
                <p className="text-xs text-(--muted)">Ganadas</p>
                <p className="mt-1 font-display text-xl font-semibold text-(--success)">
                  {ganadas}
                </p>
                <p className="text-xs text-(--muted)">
                  {porcentajeAcierto}% de acierto
                </p>
              </div>

              <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
                <p className="text-xs text-(--muted)">Balance pts</p>
                <p
                  className={`mt-1 font-display text-xl font-semibold ${
                    balance.puntos >= 0
                      ? "text-(--success)"
                      : "text-(--danger)"
                  }`}
                >
                  {balance.puntos > 0 ? "+" : ""}
                  {balance.puntos} pts
                </p>
              </div>

              <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
                <p className="text-xs text-(--muted)">Balance dinero</p>
                <p
                  className={`mt-1 font-display text-xl font-semibold ${
                    balance.dinero >= 0
                      ? "text-(--success)"
                      : "text-(--danger)"
                  }`}
                >
                  {balance.dinero > 0 ? "+" : ""}$
                  {balance.dinero.toFixed(2)}
                </p>
              </div>
            </div>

            <div className="mt-6 flex flex-wrap gap-2">
              {(["todos", "gané", "perdí", "pendiente"] as Filtro[]).map(
                (f) => (
                  <button
                    key={f}
                    type="button"
                    onClick={() => setFiltro(f)}
                    className="focus:outline-none"
                  >
                    <Chip
                      color={filtro === f ? "accent" : "default"}
                      variant={filtro === f ? "primary" : "soft"}
                      size="sm"
                      className="cursor-pointer capitalize"
                    >
                      <Chip.Label>
                        {f === "todos"
                          ? "Todos"
                          : f === "gané"
                          ? "Gané"
                          : f === "perdí"
                          ? "Perdí"
                          : "Pendientes"}
                      </Chip.Label>
                    </Chip>
                  </button>
                )
              )}
            </div>

            {pendientes > 0 && (
              <p className="mt-3 text-xs text-(--muted)">
                Tenés {pendientes} pronóstico
                {pendientes === 1 ? "" : "s"} pendiente
                {pendientes === 1 ? "" : "s"} de cierre.
              </p>
            )}

            <div className="mt-4 flex flex-col gap-3">
              {visible.length === 0 ? (
                <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
                  <p className="text-sm text-(--muted)">
                    No hay resultados en esta categoría.
                  </p>
                </div>
              ) : (
                visible.map((r) => {
                  const acierto = r.estado === "gané";

                  return (
                    <Link
                      key={r.id}
                      href={`/dashboard/proposicion/${r.propositionId}`}
                      className="block rounded-2xl border border-(--border) bg-(--surface) p-5 transition-colors hover:border-(--accent)/40"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div className="flex items-center gap-2.5">
                          <Avatar size="sm">
                            <Avatar.Fallback>
                              {avatarFallback(r.autor)}
                            </Avatar.Fallback>
                          </Avatar>

                          <div className="leading-tight">
                            <p className="text-sm font-medium text-(--foreground)">
                              {r.autor}
                            </p>
                            <p className="text-xs text-(--muted)">
                              {r.handle} · {r.fechaCierre}
                            </p>
                          </div>
                        </div>

                        {estadoChip(r.estado)}
                      </div>

                      <p className="mt-3 text-sm leading-relaxed text-(--foreground)">
                        &quot;{r.proposicion}&quot;
                      </p>

                      <div className="mt-4 grid grid-cols-3 gap-2 rounded-xl bg-(--surface-secondary) p-3 text-xs">
                        <div>
                          <p className="text-(--muted)">Mi pronóstico</p>
                          <p
                            className={`mt-0.5 flex items-center gap-1 font-medium ${
                              r.miVoto === "si"
                                ? "text-(--success)"
                                : "text-(--danger)"
                            }`}
                          >
                            {r.miVoto === "si" ? (
                              <TrendingUp size={12} />
                            ) : (
                              <TrendingDown size={12} />
                            )}

                            {r.miVoto === "si" ? "Sí" : "No"}
                          </p>
                        </div>

                        <div>
                          <p className="text-(--muted)">Apuesta</p>
                          <p className="mt-0.5 font-medium text-(--foreground)">
                            {getApuestaText(r)}
                          </p>
                        </div>

                        <div>
                          <p className="text-(--muted)">Resultado</p>
                          <p
                            className={`mt-0.5 font-medium ${
                              r.estado === "pendiente"
                                ? "text-(--muted)"
                                : acierto
                                ? "text-(--success)"
                                : "text-(--danger)"
                            }`}
                          >
                            {getResultadoText(r)}
                          </p>
                        </div>
                      </div>

                      <div className="mt-3 flex items-center justify-between text-xs text-(--muted)">
                        <span>
                          Participaste como:{" "}
                          <span className="text-(--foreground)">
                            hiciste un pronóstico
                          </span>
                        </span>

                        {r.estado === "pendiente" ? (
                          <span className="flex items-center gap-1">
                            <Clock size={11} />
                            pendiente de cierre
                          </span>
                        ) : (
                          <span className="flex items-center gap-1 text-(--success)">
                            <CheckCircle size={11} />
                            resultado registrado
                          </span>
                        )}
                      </div>
                    </Link>
                  );
                })
              )}
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}