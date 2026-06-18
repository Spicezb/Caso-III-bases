"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import {
  Button,
  Checkbox,
  FieldError,
  Input,
  Label,
  Radio,
  RadioGroup,
  TextArea,
  TextField,
} from "@heroui/react";
import { Info, Bot } from "lucide-react";
import AppShell from "@/components/AppShell";
import { createProposition } from "@/lib/gathel-api";

export default function CrearProposicionPage() {
  const router = useRouter();

  const [target, setTarget] = useState<"otro" | "yo">("otro");
  const [mode, setMode] = useState<"puntos" | "dinero" | "ambos">("puntos");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsSubmitting(true);
    setErrorMessage("");

    const formData = new FormData(e.currentTarget);

    const storedPersonId = localStorage.getItem("personId");

    if (!storedPersonId) {
      setErrorMessage("No se encontró el usuario en sesión. Iniciá sesión otra vez.");
      setIsSubmitting(false);
      return;
    }

    const personId = Number(storedPersonId);

    const targetPersonIdText = String(formData.get("targetPersonId") || "").trim();
    const propositionText = String(formData.get("propositionText") || "").trim();
    const deadline = String(formData.get("deadline") || "");

    if (!propositionText) {
      setErrorMessage("Debe escribir una proposición.");
      setIsSubmitting(false);
      return;
    }

    if (!deadline) {
      setErrorMessage("Debe seleccionar una fecha límite.");
      setIsSubmitting(false);
      return;
    }

    let finalTargetPersonId = personId;

    if (target === "otro") {
      if (!targetPersonIdText) {
        setErrorMessage("Debe indicar el ID del jugador objetivo.");
        setIsSubmitting(false);
        return;
      }

      finalTargetPersonId = Number(targetPersonIdText);

      if (
        Number.isNaN(finalTargetPersonId) ||
        finalTargetPersonId <= 0 ||
        !Number.isInteger(finalTargetPersonId)
      ) {
        setErrorMessage("El ID del jugador objetivo debe ser un número válido.");
        setIsSubmitting(false);
        return;
      }
    }

    const startPredictionDateTime = new Date().toISOString();
    const endPredictionDateTime = new Date(deadline).toISOString();

    if (new Date(endPredictionDateTime) <= new Date(startPredictionDateTime)) {
      setErrorMessage("La fecha límite debe ser posterior al momento actual.");
      setIsSubmitting(false);
      return;
    }

    const title =
      propositionText.length > 80
        ? `${propositionText.slice(0, 80)}...`
        : propositionText;

    const descriptionParts = [
      propositionText,
      target === "otro"
        ? `Persona objetivo ID: ${finalTargetPersonId}`
        : "Persona objetivo: el creador",
      `Modo de predicción: ${mode}`,
    ];

    try {
      const response = await createProposition({
        creatorPersonId: personId,
        targetPersonId: finalTargetPersonId,
        targetSocialAccountId: null,
        title,
        description: descriptionParts.join("\n"),
        startPredictionDateTime,
        endPredictionDateTime,
        minimumEntryPointsAmount: mode === "dinero" ? null : 1,
        winningProfitPercentage: 10,
      });

      const createdId =
        response.propositionId ?? response.proposition?.propositionId;

      if (createdId) {
        router.push(`/dashboard/proposicion/${createdId}`);
      } else {
        router.push("/dashboard");
      }
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "No se pudo crear la proposición."
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Nueva proposición
        </span>

        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          ¿Qué crees que va a pasar?
        </h1>

        <p className="mt-1 text-sm text-(--muted)">
          Describe un evento real y verificable. La comunidad podrá
          pronosticar si va a cumplirse o no.
        </p>

        <form className="mt-6 flex flex-col gap-6" onSubmit={handleSubmit}>
          <RadioGroup
            value={target}
            onChange={(v) => setTarget(v as "otro" | "yo")}
          >
            <Label>¿Sobre quién es esta proposición?</Label>

            <div className="mt-2 grid grid-cols-2 gap-2">
              <Radio value="otro">
                <Radio.Content
                  className={`flex items-center gap-3 rounded-xl border p-4 transition-colors ${
                    target === "otro"
                      ? "border-(--accent) bg-(--accent-soft)"
                      : "border-(--border) bg-(--surface)"
                  }`}
                >
                  <Radio.Control>
                    <Radio.Indicator />
                  </Radio.Control>

                  <div className="leading-tight">
                    <Label className="text-sm font-medium text-(--foreground)">
                      Sobre otra persona
                    </Label>
                    <p className="text-xs text-(--muted)">
                      Usando el ID del jugador objetivo
                    </p>
                  </div>
                </Radio.Content>
              </Radio>

              <Radio value="yo">
                <Radio.Content
                  className={`flex items-center gap-3 rounded-xl border p-4 transition-colors ${
                    target === "yo"
                      ? "border-(--accent) bg-(--accent-soft)"
                      : "border-(--border) bg-(--surface)"
                  }`}
                >
                  <Radio.Control>
                    <Radio.Indicator />
                  </Radio.Control>

                  <div className="leading-tight">
                    <Label className="text-sm font-medium text-(--foreground)">
                      Sobre mí mismo/a
                    </Label>
                    <p className="text-xs text-(--muted)">
                      Se crea usando tu propio usuario
                    </p>
                  </div>
                </Radio.Content>
              </Radio>
            </div>
          </RadioGroup>

          {target === "otro" && (
            <TextField name="targetPersonId" type="number" isRequired>
              <Label>ID del jugador objetivo</Label>
              <Input placeholder="Ej: 1022" />
              <FieldError />
            </TextField>
          )}

          <TextField name="propositionText" isRequired maxLength={240}>
            <Label>Proposición</Label>
            <TextArea
              rows={3}
              placeholder='Ej: "Elizabeth terminará la maratón dentro de los primeros 30 lugares."'
            />
            <FieldError />
          </TextField>

          <RadioGroup
            value={mode}
            onChange={(v) => setMode(v as "puntos" | "dinero" | "ambos")}
          >
            <Label>¿Con qué se puede pronosticar?</Label>

            <div className="mt-2 grid grid-cols-3 gap-2">
              {[
                { value: "puntos", label: "Puntos" },
                { value: "dinero", label: "Dinero real" },
                { value: "ambos", label: "Ambos" },
              ].map((opt) => (
                <Radio key={opt.value} value={opt.value}>
                  <Radio.Content
                    className={`flex flex-col items-center gap-2 rounded-xl border p-3 text-center transition-colors ${
                      mode === opt.value
                        ? "border-(--accent) bg-(--accent-soft)"
                        : "border-(--border) bg-(--surface)"
                    }`}
                  >
                    <Radio.Control>
                      <Radio.Indicator />
                    </Radio.Control>

                    <Label className="text-sm text-(--foreground)">
                      {opt.label}
                    </Label>
                  </Radio.Content>
                </Radio>
              ))}
            </div>
          </RadioGroup>

          <TextField name="deadline" type="datetime-local" isRequired>
            <Label>Fecha y hora límite para predicciones</Label>
            <Input />
            <FieldError />
          </TextField>

          <div className="flex items-start gap-3 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
            <Bot
              size={18}
              className="mt-0.5 shrink-0 text-(--accent)"
              aria-hidden="true"
            />

            <p className="text-sm text-(--muted)">
              Antes de publicarse, esta proposición pasará por un filtro de IA
              que bloquea contenido ilegal, violento, sexual, discriminatorio o
              que viole las reglas de la plataforma.
            </p>
          </div>

          {target === "otro" && (
            <div className="flex items-start gap-3 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
              <Info
                size={18}
                className="mt-0.5 shrink-0 text-(--accent)"
                aria-hidden="true"
              />

              <p className="text-sm text-(--muted)">
                Por ahora, para el MVP, se usa el ID del jugador objetivo. Más
                adelante se puede cambiar por búsqueda usando @username.
              </p>
            </div>
          )}

          {errorMessage && (
            <p className="rounded-xl border border-red-500/40 bg-red-500/10 px-3 py-2 text-sm text-red-300">
              {errorMessage}
            </p>
          )}

          <Checkbox name="confirm" isRequired>
            <Checkbox.Content>
              <Checkbox.Control>
                <Checkbox.Indicator />
              </Checkbox.Control>

              <Label className="text-sm text-(--muted)">
                Confirmo que esta proposición describe un evento real y
                verificable.
              </Label>
            </Checkbox.Content>

            <FieldError />
          </Checkbox>

          <div className="flex gap-3">
            <Button
              type="button"
              variant="ghost"
              size="lg"
              onClick={() => router.back()}
            >
              Cancelar
            </Button>

            <Button
              type="submit"
              variant="primary"
              size="lg"
              fullWidth
              isDisabled={isSubmitting}
            >
              {isSubmitting ? "Publicando…" : "Publicar proposición"}
            </Button>
          </div>
        </form>
      </div>
    </AppShell>
  );
}