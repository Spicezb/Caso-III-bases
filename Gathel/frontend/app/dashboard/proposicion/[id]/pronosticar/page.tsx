"use client";

import { use, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import {
  Button,
  Chip,
  Label,
  Radio,
  RadioGroup,
  TextField,
  Input,
  FieldError,
} from "@heroui/react";
import { ArrowLeft, TrendingUp, TrendingDown, AlertCircle, CheckCircle } from "lucide-react";
import AppShell from "@/components/AppShell";
import { useUser } from "@/lib/user-context";

// ---------------------------------------------------------------------------
// Datos mock — reemplazar con fetch GET /proposiciones/:id
// ---------------------------------------------------------------------------
const MOCK: Record<string, { text: string; pool: string; timeLeft: string; mode: "puntos" | "dinero" | "ambos" }> = {
  "1": { text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.", pool: "812 pts", timeLeft: "quedan 6 h", mode: "puntos" },
  "2": { text: "Subo el video del lanzamiento del producto antes del viernes a medianoche.", pool: "$64", timeLeft: "quedan 2 días", mode: "dinero" },
  "3": { text: "Llego al gimnasio los 5 días de esta semana.", pool: "390 pts", timeLeft: "quedan 18 h", mode: "puntos" },
  "7": { text: "Lanzo mi tienda online antes del 30 de junio.", pool: "$200", timeLeft: "quedan 5 días", mode: "ambos" },
};

const MAX_POINTS = 1; // el caso dice máximo 1 punto por predicción

export default function PronosticarPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id }      = use(params);
  const router      = useRouter();
  const searchParams = useSearchParams();
  const { user, setUser } = useUser();

  const votoInicial = searchParams.get("voto") === "no" ? "no" : "si";
  const prop        = MOCK[id] ?? MOCK["1"];

  // Estado del formulario
  const [voto,       setVoto]       = useState<"si" | "no">(votoInicial as "si" | "no");
  const [metodo,     setMetodo]     = useState<"puntos" | "dinero">(
    prop.mode === "dinero" ? "dinero" : "puntos"
  );
  const [monto,      setMonto]      = useState("");
  const [submitted,  setSubmitted]  = useState(false);
  const [isLoading,  setIsLoading]  = useState(false);
  const [error,      setError]      = useState("");

  const usarPuntos = metodo === "puntos";
  const montoNum   = parseFloat(monto) || 0;

  function validate() {
    if (usarPuntos) return null;
    if (!monto || montoNum <= 0) return "Ingresá un monto mayor a 0.";
    if (montoNum > user.moneyBalance) return `Tu balance es $${user.moneyBalance.toFixed(2)}.`;
    return null;
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const err = validate();
    if (err) { setError(err); return; }
    setError("");
    setIsLoading(true);

    // TODO: POST /predicciones { proposicionId: id, voto, metodo, monto }
    setTimeout(() => {
      // Actualizar balance mock
      if (usarPuntos) {
        setUser({ ...user, pointsBalance: user.pointsBalance - MAX_POINTS });
      } else {
        setUser({ ...user, moneyBalance: user.moneyBalance - montoNum });
      }
      setIsLoading(false);
      setSubmitted(true);
    }, 700);
  }

  // ---------------------------------------------------------------------------
  // Pantalla de confirmación
  // ---------------------------------------------------------------------------
  if (submitted) {
    const newLocal = <p className="mt-1 text-sm text-foreground">&quot;{prop.text}&quot;</p>;
    return (
      <AppShell>
        <div className="mx-auto flex max-w-sm flex-col items-center py-16 text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-(--success-soft)">
            <CheckCircle size={32} className="text-(--success)" aria-hidden="true" />
          </div>
          <h1 className="mt-6 font-display text-2xl font-semibold text-(--foreground)">
            ¡Pronóstico registrado!
          </h1>
          <p className="mt-2 text-sm text-(--muted)">
            Apostaste a que{" "}
            <span className="font-medium text-(--foreground)">
              {voto === "si" ? "sí va a pasar" : "no va a pasar"}
            </span>{" "}
            usando{" "}
            {usarPuntos
              ? `${MAX_POINTS} punto`
              : `$${montoNum.toFixed(2)}`}
            .
          </p>

          <div className="mt-4 w-full rounded-xl border border-(--border) bg-(--surface) p-4 text-left">
            <p className="text-xs text-(--muted)">Proposición</p>
            {newLocal}
            <div className="mt-3 flex items-center justify-between text-xs text-(--muted)">
              <span>Bolsa acumulada</span>
              <span className="text-(--foreground)">{prop.pool}</span>
            </div>
            <div className="flex items-center justify-between text-xs text-(--muted)">
              <span>Cierra</span>
              <span className="text-(--accent)">{prop.timeLeft}</span>
            </div>
          </div>

          <p className="mt-4 text-xs text-(--muted)">
            Nuevo balance:{" "}
            {usarPuntos
              ? <><span className="text-(--foreground)">{user.pointsBalance} pts</span></>
              : <><span className="text-(--foreground)">${user.moneyBalance.toFixed(2)}</span></>
            }
          </p>

          <div className="mt-8 flex w-full flex-col gap-3">
            <Link
              href={`/dashboard/proposicion/${id}`}
              className="rounded-lg bg-(--accent) px-4 py-2.5 text-center text-sm font-medium text-(--accent-foreground) hover:opacity-90 transition-opacity"
            >
              Ver la proposición
            </Link>
            <Link
              href="/dashboard"
              className="rounded-lg border border-(--border) px-4 py-2.5 text-center text-sm text-(--muted) hover:text-(--foreground) transition-colors"
            >
              Volver al feed
            </Link>
          </div>
        </div>
      </AppShell>
    );
  }

  // ---------------------------------------------------------------------------
  // Formulario
  // ---------------------------------------------------------------------------
  return (
    <AppShell>
      <div className="mx-auto max-w-sm">
        <Link
          href={`/dashboard/proposicion/${id}`}
          className="inline-flex items-center gap-1.5 text-sm text-muted hover:text-foreground transition-colors"
        >
          <ArrowLeft size={15} aria-hidden="true" />
          Volver al detalle
        </Link>

        <h1 className="mt-5 font-display text-2xl font-semibold tracking-tight text-foreground">
          Hacer un pronóstico
        </h1>

        {/* Resumen de la proposición */}
        <div className="mt-4 rounded-xl border border-border bg-surface p-4">
          <p className="text-sm leading-relaxed text-foreground">&quot;{prop.text}&quot;</p>
          <div className="mt-2 flex items-center gap-2 text-xs text-muted">
            <span>{prop.pool} en la bolsa</span>
            <span>·</span>
            <span className="text-accent">{prop.timeLeft}</span>
          </div>
        </div>

        <form className="mt-6 flex flex-col gap-5" onSubmit={handleSubmit}>

          {/* Voto */}
          <RadioGroup
            value={voto}
            onChange={(v) => setVoto(v as "si" | "no")}
          >
            <Label>Tu pronóstico</Label>
            <div className="mt-2 grid grid-cols-2 gap-2">
              {(["si", "no"] as const).map((v) => (
                <Radio key={v} value={v}>
                  <Radio.Content
                    className={`flex items-center gap-2 rounded-xl border p-3 transition-colors cursor-pointer ${
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
                      {v === "si"
                        ? <TrendingUp size={15} className="text-(--success)" />
                        : <TrendingDown size={15} className="text-(--danger)" />
                      }
                      <Label className="text-sm font-medium text-(--foreground) cursor-pointer">
                        {v === "si" ? "Sí va a pasar" : "No va a pasar"}
                      </Label>
                    </div>
                  </Radio.Content>
                </Radio>
              ))}
            </div>
          </RadioGroup>

          {/* Método (solo si la proposición lo permite) */}
          {prop.mode === "ambos" && (
            <RadioGroup
              value={metodo}
              onChange={(v) => { setMetodo(v as "puntos" | "dinero"); setMonto(""); setError(""); }}
            >
              <Label>¿Con qué apostás?</Label>
              <div className="mt-2 grid grid-cols-2 gap-2">
                {(["puntos", "dinero"] as const).map((m) => (
                  <Radio key={m} value={m}>
                    <Radio.Content
                      className={`flex items-center gap-2 rounded-xl border p-3 transition-colors cursor-pointer ${
                        metodo === m
                          ? "border-(--accent) bg-(--accent-soft)"
                          : "border-(--border) bg-(--surface)"
                      }`}
                    >
                      <Radio.Control>
                        <Radio.Indicator />
                      </Radio.Control>
                      <Label className="text-sm text-(--foreground) cursor-pointer">
                        {m === "puntos" ? "Puntos" : "Dinero real"}
                      </Label>
                    </Radio.Content>
                  </Radio>
                ))}
              </div>
            </RadioGroup>
          )}

          {/* Monto */}
          {usarPuntos ? (
            <div className="rounded-xl border border-(--border) bg-(--surface) p-4">
              <p className="text-sm text-(--muted)">Monto a apostar</p>
              <p className="mt-1 font-display text-3xl font-semibold text-(--foreground)">
                1 punto
              </p>
              <p className="mt-1 text-xs text-(--muted)">
                Máximo permitido por predicción · Tu balance: {user.pointsBalance} pts
              </p>
              {user.pointsBalance < 1 && (
                <div className="mt-3 flex items-start gap-2 rounded-lg bg-(--danger-soft) p-3 text-xs text-(--danger)">
                  <AlertCircle size={14} className="mt-0.5 shrink-0" />
                  No tenés puntos suficientes. Podés comprar más en tu perfil.
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
              <Label>Monto a apostar (USD)</Label>
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
                Balance disponible:{" "}
                <span className="text-(--foreground)">${user.moneyBalance.toFixed(2)}</span>
              </p>
            </TextField>
          )}

          {/* Error de validación */}
          {error && (
            <div className="flex items-start gap-2 rounded-lg border border-(--danger)/30 bg-(--danger-soft) p-3 text-sm text-(--danger)">
              <AlertCircle size={15} className="mt-0.5 shrink-0" />
              {error}
            </div>
          )}

          {/* Resumen antes de confirmar */}
          {(usarPuntos || montoNum > 0) && !error && (
            <div className="rounded-xl border border-(--border) bg-(--surface-secondary) p-4 text-sm">
              <p className="text-xs uppercase tracking-widest text-(--muted)">Resumen</p>
              <div className="mt-2 flex flex-col gap-1.5">
                <div className="flex justify-between">
                  <span className="text-(--muted)">Pronóstico</span>
                  <span className="font-medium text-(--foreground)">
                    {voto === "si" ? "Sí va a pasar" : "No va a pasar"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-(--muted)">Apuesta</span>
                  <span className="font-medium text-(--foreground)">
                    {usarPuntos ? "1 pt" : `$${montoNum.toFixed(2)}`}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-(--muted)">Balance tras apostar</span>
                  <span className="font-medium text-(--foreground)">
                    {usarPuntos
                      ? `${user.pointsBalance - MAX_POINTS} pts`
                      : `$${(user.moneyBalance - montoNum).toFixed(2)}`
                    }
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
            isDisabled={isLoading || (usarPuntos && user.pointsBalance < 1)}
          >
            {isLoading ? "Registrando…" : "Confirmar pronóstico"}
          </Button>
        </form>
      </div>
    </AppShell>
  );
}
