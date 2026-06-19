"use client";

import { use, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import {
  Button,
  Label,
  Radio,
  RadioGroup,
  TextField,
  Input,
  FieldError,
} from "@heroui/react";
import {
  ArrowLeft,
  TrendingUp,
  TrendingDown,
  AlertCircle,
  CheckCircle,
  Wallet,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import {
  createMoneyPrediction,
  createPointPrediction,
  getMe,
  getPropositionById,
  getPredictionsByProposition,
  PersonResponse,
  PropositionResponse,
  PredictionResponse,
} from "@/lib/gathel-api";

const MAX_POINTS = 1;

type PredictionMode = "puntos" | "dinero" | "ambos";

type PropositionForPrediction = {
  id: string;
  text: string;
  status: string;
  pool: string;
  timeLeft: string;
  mode: PredictionMode;
  creatorPersonId: number;
  targetPersonId: number;
};

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

function normalizeStatus(status: string | null | undefined) {
  return (status ?? "").toLowerCase();
}

function detectPredictionMode(
  p: PropositionResponse,
  predictions: PredictionResponse[]
): PredictionMode {
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

  const hasPoints = predictions.some(
    (prediction) =>
      prediction.pointsAmount !== null &&
      prediction.pointsAmount !== undefined &&
      prediction.pointsAmount > 0
  );

  const hasMoney = predictions.some(
    (prediction) =>
      prediction.moneyAmount !== null &&
      prediction.moneyAmount !== undefined &&
      prediction.moneyAmount > 0
  );

  if (hasPoints && hasMoney) return "ambos";
  if (hasMoney) return "dinero";

  return "puntos";
}

function calculatePool(
  predictions: PredictionResponse[],
  fallbackPoints: number | null,
  mode: PredictionMode
) {
  const totalPoints = predictions.reduce(
    (total, prediction) => total + (prediction.pointsAmount ?? 0),
    0
  );

  const totalMoney = predictions.reduce(
    (total, prediction) => total + (prediction.moneyAmount ?? 0),
    0
  );

  if (mode === "dinero") {
    return `$${totalMoney.toFixed(2)}`;
  }

  if (mode === "ambos") {
    return `${totalPoints || fallbackPoints || 1} pts · $${totalMoney.toFixed(
      2
    )}`;
  }

  return `${totalPoints || fallbackPoints || 1} pts`;
}

function mapProposition(
  p: PropositionResponse,
  predictions: PredictionResponse[]
): PropositionForPrediction {
  const mode = detectPredictionMode(p, predictions);

  return {
    id: String(p.propositionId),
    text: p.title || p.description || "Proposición sin título",
    status: p.status,
    pool: calculatePool(predictions, p.minimumEntryPointsAmount ?? null, mode),
    timeLeft: getTimeLeft(p.endPredictionDateTime),
    mode,
    creatorPersonId: p.creatorPersonId,
    targetPersonId: p.targetPersonId,
  };
}

export default function PronosticarPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const searchParams = useSearchParams();

  const votoInicial = searchParams.get("voto") === "no" ? "no" : "si";

  const [prop, setProp] = useState<PropositionForPrediction | null>(null);
  const [person, setPerson] = useState<PersonResponse | null>(null);

  const [voto, setVoto] = useState<"si" | "no">(votoInicial);
  const [metodo, setMetodo] = useState<"puntos" | "dinero">("puntos");
  const [monto, setMonto] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");

  const usarPuntos = metodo === "puntos";
  const montoNum = parseFloat(monto) || 0;

  useEffect(() => {
    async function loadData() {
      try {
        setIsLoading(true);
        setError("");

        const storedPersonId = localStorage.getItem("personId");

        if (!storedPersonId) {
          setError("No se encontró el usuario en sesión.");
          return;
        }

        const personId = Number(storedPersonId);

        const [propositionResponse, predictionsResponse, personResponse] =
          await Promise.all([
            getPropositionById(Number(id)),
            getPredictionsByProposition(Number(id)),
            getMe(personId),
          ]);

        const mapped = mapProposition(propositionResponse, predictionsResponse);

        if (normalizeStatus(mapped.status) !== "active") {
          setError(
            "Esta proposición todavía no está activa para recibir pronósticos."
          );
          return;
        }

        if (
          mapped.creatorPersonId === personId ||
          mapped.targetPersonId === personId
        ) {
          setError(
            "No podés pronosticar en una proposición que creaste o que es sobre vos."
          );
          return;
        }

        setProp(mapped);
        setPerson(personResponse);

        if (mapped.mode === "dinero") {
          setMetodo("dinero");
        } else {
          setMetodo("puntos");
        }
      } catch (error) {
        setError(
          error instanceof Error
            ? error.message
            : "No se pudo cargar la información."
        );
      } finally {
        setIsLoading(false);
      }
    }

    loadData();
  }, [id]);

  function validate() {
    if (!person) return "No se encontró el usuario en sesión.";
    if (!prop) return "No se encontró la proposición.";

    if (normalizeStatus(prop.status) !== "active") {
      return "Esta proposición no está activa para pronosticar.";
    }

    if (person.personId === prop.creatorPersonId) {
      return "No podés pronosticar en una proposición que creaste.";
    }

    if (person.personId === prop.targetPersonId) {
      return "No podés pronosticar en una proposición que es sobre vos.";
    }

    if (usarPuntos) {
      if (person.pointsBalance < MAX_POINTS) {
        return "No tenés puntos suficientes.";
      }

      return null;
    }

    if (!monto || montoNum <= 0) {
      return "Ingresá un monto mayor a 0.";
    }

    return null;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    const err = validate();

    if (err) {
      setError(err);
      return;
    }

    if (!person || !prop) {
      setError("No se pudo registrar el pronóstico.");
      return;
    }

    setError("");
    setIsSubmitting(true);

    try {
      if (usarPuntos) {
        await createPointPrediction({
          propositionId: Number(prop.id),
          personId: person.personId,
          predictionValue: voto === "si",
        });
      } else {
        await createMoneyPrediction({
          propositionId: Number(prop.id),
          personId: person.personId,
          predictionValue: voto === "si",
          moneyAmount: montoNum,
        });
      }

      const updatedPerson = await getMe(person.personId);
      setPerson(updatedPerson);
      setSubmitted(true);
    } catch (error) {
      setError(
        error instanceof Error
          ? error.message
          : "No se pudo registrar el pronóstico."
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  if (isLoading) {
    return (
      <AppShell>
        <div className="mx-auto max-w-sm">
          <p className="text-sm text-(--muted)">Cargando pronóstico...</p>
        </div>
      </AppShell>
    );
  }

  if (!prop || !person) {
    return (
      <AppShell>
        <div className="mx-auto max-w-sm">
          <Link
            href={`/dashboard/proposicion/${id}`}
            className="inline-flex items-center gap-1.5 text-sm text-(--muted) transition-colors hover:text-(--foreground)"
          >
            <ArrowLeft size={15} aria-hidden="true" />
            Volver al detalle
          </Link>

          <div className="mt-5 rounded-xl border border-red-500/40 bg-red-500/10 p-4 text-sm text-red-300">
            {error || "No se pudo cargar la información."}
          </div>
        </div>
      </AppShell>
    );
  }

  if (submitted) {
    return (
      <AppShell>
        <div className="mx-auto flex max-w-sm flex-col items-center py-16 text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-(--success-soft)">
            <CheckCircle
              size={32}
              className="text-(--success)"
              aria-hidden="true"
            />
          </div>

          <h1 className="mt-6 font-display text-2xl font-semibold text-(--foreground)">
            ¡Pronóstico registrado!
          </h1>

          <p className="mt-2 text-sm text-(--muted)">
            Pronosticaste que{" "}
            <span className="font-medium text-(--foreground)">
              {voto === "si" ? "sí va a pasar" : "no va a pasar"}
            </span>{" "}
            usando{" "}
            {usarPuntos ? `${MAX_POINTS} punto` : `$${montoNum.toFixed(2)}`}.
          </p>

          <div className="mt-4 w-full rounded-xl border border-(--border) bg-(--surface) p-4 text-left">
            <p className="text-xs text-(--muted)">Proposición</p>

            <p className="mt-1 text-sm text-(--foreground)">
              &quot;{prop.text}&quot;
            </p>

            <div className="mt-3 flex items-center justify-between text-xs text-(--muted)">
              <span>Bolsa acumulada</span>
              <span className="text-(--foreground)">{prop.pool}</span>
            </div>

            <div className="flex items-center justify-between text-xs text-(--muted)">
              <span>Cierra</span>
              <span className="text-(--accent)">{prop.timeLeft}</span>
            </div>

            <div className="flex items-center justify-between text-xs text-(--muted)">
              <span>Tu pronóstico</span>
              <span className="text-(--foreground)">
                {voto === "si" ? "Sí va a pasar" : "No va a pasar"}
              </span>
            </div>

            <div className="flex items-center justify-between text-xs text-(--muted)">
              <span>Monto usado</span>
              <span className="text-(--foreground)">
                {usarPuntos ? "1 pt" : `$${montoNum.toFixed(2)}`}
              </span>
            </div>
          </div>

          <p className="mt-4 text-xs text-(--muted)">
            Nuevo balance:{" "}
            <span className="text-(--foreground)">
              {person.pointsBalance} pts
            </span>
          </p>

          <div className="mt-8 flex w-full flex-col gap-3">
            <Link
              href={`/dashboard/proposicion/${id}`}
              className="rounded-lg bg-(--accent) px-4 py-2.5 text-center text-sm font-medium text-(--accent-foreground) transition-opacity hover:opacity-90"
            >
              Ver la proposición
            </Link>

            <Link
              href="/dashboard"
              className="rounded-lg border border-(--border) px-4 py-2.5 text-center text-sm text-(--muted) transition-colors hover:text-(--foreground)"
            >
              Volver al feed
            </Link>
          </div>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-sm">
        <Link
          href={`/dashboard/proposicion/${id}`}
          className="inline-flex items-center gap-1.5 text-sm text-(--muted) transition-colors hover:text-(--foreground)"
        >
          <ArrowLeft size={15} aria-hidden="true" />
          Volver al detalle
        </Link>

        <h1 className="mt-5 font-display text-2xl font-semibold tracking-tight text-(--foreground)">
          Hacer un pronóstico
        </h1>

        <div className="mt-4 rounded-xl border border-(--border) bg-(--surface) p-4">
          <p className="text-sm leading-relaxed text-(--foreground)">
            &quot;{prop.text}&quot;
          </p>

          <div className="mt-2 flex items-center gap-2 text-xs text-(--muted)">
            <span>{prop.pool} en la bolsa</span>
            <span>·</span>
            <span className="text-(--accent)">{prop.timeLeft}</span>
          </div>

          <div className="mt-4 flex items-start gap-2 rounded-lg border border-(--accent)/30 bg-(--accent-soft) p-3">
            <Wallet size={16} className="mt-0.5 shrink-0 text-(--accent)" />

            <p className="text-xs leading-relaxed text-(--muted)">
              La recompensa se calcula con la bolsa acumulada y la distribución
              final de ganadores. No se usa multiplicador fijo en esta pantalla.
            </p>
          </div>
        </div>

        <form className="mt-6 flex flex-col gap-5" onSubmit={handleSubmit}>
          <RadioGroup value={voto} onChange={(v) => setVoto(v as "si" | "no")}>
            <Label>Tu pronóstico</Label>

            <div className="mt-2 grid grid-cols-2 gap-2">
              {(["si", "no"] as const).map((v) => (
                <Radio key={v} value={v}>
                  <Radio.Content
                    className={`flex cursor-pointer items-center gap-2 rounded-xl border p-3 transition-colors ${
                      voto === v
                        ? v === "si"
                          ? "border-(--success) bg-(--success-soft)"
                          : "border-(--danger) bg-(--danger-soft)"
                        : "border-(--border) bg-(--surface)"
                    }`}
                  >
                    <Radio.Control>
                      <Radio.Indicator />
                    </Radio.Control>

                    <div className="flex items-center gap-1.5">
                      {v === "si" ? (
                        <TrendingUp size={15} className="text-(--success)" />
                      ) : (
                        <TrendingDown size={15} className="text-(--danger)" />
                      )}

                      <Label className="cursor-pointer text-sm font-medium text-(--foreground)">
                        {v === "si" ? "Sí va a pasar" : "No va a pasar"}
                      </Label>
                    </div>
                  </Radio.Content>
                </Radio>
              ))}
            </div>
          </RadioGroup>

          {prop.mode === "ambos" && (
            <RadioGroup
              value={metodo}
              onChange={(v) => {
                setMetodo(v as "puntos" | "dinero");
                setMonto("");
                setError("");
              }}
            >
              <Label>¿Con qué pronosticás?</Label>

              <div className="mt-2 grid grid-cols-2 gap-2">
                {(["puntos", "dinero"] as const).map((m) => (
                  <Radio key={m} value={m}>
                    <Radio.Content
                      className={`flex cursor-pointer items-center gap-2 rounded-xl border p-3 transition-colors ${
                        metodo === m
                          ? "border-(--accent) bg-(--accent-soft)"
                          : "border-(--border) bg-(--surface)"
                      }`}
                    >
                      <Radio.Control>
                        <Radio.Indicator />
                      </Radio.Control>

                      <Label className="cursor-pointer text-sm text-(--foreground)">
                        {m === "puntos" ? "Puntos" : "Dinero real"}
                      </Label>
                    </Radio.Content>
                  </Radio>
                ))}
              </div>
            </RadioGroup>
          )}

          {usarPuntos ? (
            <div className="rounded-xl border border-(--border) bg-(--surface) p-4">
              <p className="text-sm text-(--muted)">Monto a usar</p>

              <p className="mt-1 font-display text-3xl font-semibold text-(--foreground)">
                1 punto
              </p>

              <p className="mt-1 text-xs text-(--muted)">
                Máximo permitido por predicción · Tu balance:{" "}
                {person.pointsBalance} pts
              </p>

              {person.pointsBalance < 1 && (
                <div className="mt-3 flex items-start gap-2 rounded-lg bg-(--danger-soft) p-3 text-xs text-(--danger)">
                  <AlertCircle size={14} className="mt-0.5 shrink-0" />
                  No tenés puntos suficientes.
                </div>
              )}
            </div>
          ) : (
            <TextField
              name="monto"
              type="number"
              value={monto}
              onChange={setMonto}
              isRequired
            >
              <Label>Monto a usar (USD)</Label>

              <div className="relative">
                <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-sm text-(--muted)">
                  $
                </span>

                <Input
                  placeholder="0.00"
                  className="pl-7"
                  step="0.01"
                  min="0.01"
                />
              </div>

              <FieldError />

              <p className="mt-1 text-xs text-(--muted)">
                Podés aumentar el monto hasta que cierre la proposición.
              </p>
            </TextField>
          )}

          {error && (
            <div className="flex items-start gap-2 rounded-lg border border-(--danger)/30 bg-(--danger-soft) p-3 text-sm text-(--danger)">
              <AlertCircle size={15} className="mt-0.5 shrink-0" />
              {error}
            </div>
          )}

          {(usarPuntos || montoNum > 0) && !error && (
            <div className="rounded-xl border border-(--border) bg-(--surface-secondary) p-4 text-sm">
              <p className="text-xs uppercase tracking-widest text-(--muted)">
                Resumen
              </p>

              <div className="mt-2 flex flex-col gap-1.5">
                <div className="flex justify-between">
                  <span className="text-(--muted)">Pronóstico</span>
                  <span className="font-medium text-(--foreground)">
                    {voto === "si" ? "Sí va a pasar" : "No va a pasar"}
                  </span>
                </div>

                <div className="flex justify-between">
                  <span className="text-(--muted)">Monto</span>
                  <span className="font-medium text-(--foreground)">
                    {usarPuntos ? "1 pt" : `$${montoNum.toFixed(2)}`}
                  </span>
                </div>

                <div className="flex justify-between">
                  <span className="text-(--muted)">Bolsa actual</span>
                  <span className="font-medium text-(--foreground)">
                    {prop.pool}
                  </span>
                </div>

                <div className="flex justify-between">
                  <span className="text-(--muted)">Balance tras usar puntos</span>
                  <span className="font-medium text-(--foreground)">
                    {usarPuntos
                      ? `${person.pointsBalance - MAX_POINTS} pts`
                      : "No aplica"}
                  </span>
                </div>
              </div>
            </div>
          )}

          <Button
            type="submit"
            variant="primary"
            size="lg"
            fullWidth
            isDisabled={isSubmitting || (usarPuntos && person.pointsBalance < 1)}
          >
            {isSubmitting ? "Registrando…" : "Confirmar pronóstico"}
          </Button>
        </form>
      </div>
    </AppShell>
  );
}