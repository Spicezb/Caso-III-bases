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
import {
  Bot,
  CalendarClock,
  FileText,
  Info,
  Link as LinkIcon,
  Lightbulb,
  Target,
  Trophy,
  Users,
  Wallet,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import { createProposition } from "@/lib/gathel-api";

type TargetMode = "otro" | "yo";
type PredictionMode = "puntos" | "dinero" | "ambos";

function getNowIso() {
  return new Date().toISOString();
}

function getVotingDeadlineIso() {
  const now = new Date();
  const deadline = new Date(now.getTime() + 24 * 60 * 60 * 1000);

  return deadline.toISOString();
}

function buildTitle(text: string, maxLength = 90) {
  const cleanText = text.trim();

  if (cleanText.length <= maxLength) {
    return cleanText;
  }

  return `${cleanText.slice(0, maxLength)}...`;
}

export default function CrearProposicionPage() {
  const router = useRouter();

  const [target, setTarget] = useState<TargetMode>("otro");
  const [mode, setMode] = useState<PredictionMode>("puntos");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    setIsSubmitting(true);
    setErrorMessage("");

    const formData = new FormData(e.currentTarget);

    const storedPersonId = localStorage.getItem("personId");

    if (!storedPersonId) {
      setErrorMessage(
        "No se encontró el usuario en sesión. Iniciá sesión otra vez."
      );
      setIsSubmitting(false);
      return;
    }

    const personId = Number(storedPersonId);

    const targetPersonIdText = String(
      formData.get("targetPersonId") || ""
    ).trim();

    const publicationTitle = String(
      formData.get("publicationTitle") || ""
    ).trim();

    const publicationDescription = String(
      formData.get("publicationDescription") || ""
    ).trim();

    const sourceUrl = String(formData.get("sourceUrl") || "").trim();

    const initialCandidateText = String(
      formData.get("initialCandidateText") || ""
    ).trim();

    const initialCandidateDescription = String(
      formData.get("initialCandidateDescription") || ""
    ).trim();

    if (!publicationTitle) {
      setErrorMessage("Debe escribir el evento o publicación base del Gathel.");
      setIsSubmitting(false);
      return;
    }

    if (!publicationDescription) {
      setErrorMessage(
        "Debe describir un poco la publicación o el contexto del Gathel."
      );
      setIsSubmitting(false);
      return;
    }

    let finalTargetPersonId = personId;

    if (target === "otro") {
      if (!targetPersonIdText) {
        setErrorMessage("Debe indicar el ID de la persona objetivo.");
        setIsSubmitting(false);
        return;
      }

      finalTargetPersonId = Number(targetPersonIdText);

      if (
        Number.isNaN(finalTargetPersonId) ||
        finalTargetPersonId <= 0 ||
        !Number.isInteger(finalTargetPersonId)
      ) {
        setErrorMessage("El ID de la persona objetivo debe ser válido.");
        setIsSubmitting(false);
        return;
      }
    }

    const startPredictionDateTime = getNowIso();
    const endPredictionDateTime = getVotingDeadlineIso();

    const parentTitle = buildTitle(publicationTitle);

    const parentDescriptionParts = [
      "Tipo: Gathel padre",
      "",
      "Publicación o evento base:",
      publicationDescription,
      "",
      target === "otro"
        ? `Persona objetivo ID: ${finalTargetPersonId}`
        : "Persona objetivo: el creador",
      `Modo de predicción permitido: ${mode}`,
      "Etapa inicial: votación de proposiciones candidatas por 24 horas.",
      sourceUrl ? `Fuente o enlace: ${sourceUrl}` : null,
    ].filter(Boolean);

    try {
      const parentResponse = await createProposition({
        creatorPersonId: personId,
        targetPersonId: finalTargetPersonId,
        targetSocialAccountId: null,
        title: parentTitle,
        description: parentDescriptionParts.join("\n"),
        startPredictionDateTime,
        endPredictionDateTime,
        minimumEntryPointsAmount: mode === "dinero" ? null : 1,
        winningProfitPercentage: 10,
        parentProposition: null,
        parentPropositionId: null,
      });
      const parentId =
        parentResponse.propositionId ??
        parentResponse.proposition?.propositionId;

      if (!parentId) {
        router.push("/dashboard/explorar");
        return;
      }

      if (initialCandidateText) {
        const childTitle = buildTitle(initialCandidateText);

        const childDescriptionParts = [
          initialCandidateDescription || "Proposición candidata inicial.",
          "",
          `Proposición hija del Gathel ID: ${parentId}`,
          `Creada inicialmente por usuario ID: ${personId}`,
          `Modo heredado del Gathel: ${mode}`,
        ];

        await createProposition({
          creatorPersonId: personId,
          targetPersonId: finalTargetPersonId,
          targetSocialAccountId: null,
          title: childTitle,
          description: childDescriptionParts.join("\n"),
          startPredictionDateTime,
          endPredictionDateTime,
          minimumEntryPointsAmount: mode === "dinero" ? null : 1,
          winningProfitPercentage: 10,
          parentProposition: parentId,
          parentPropositionId: parentId,
        });
      }

      router.push(`/dashboard/proposicion/${parentId}`);
    } catch (error) {
      setErrorMessage(
        error instanceof Error ? error.message : "No se pudo crear el Gathel."
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Nuevo Gathel
        </span>

        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          Crear Gathel desde una publicación
        </h1>

        <p className="mt-2 text-sm leading-relaxed text-(--muted)">
          Primero creás el Gathel padre a partir de una publicación o evento
          real. Podés agregar una primera proposición candidata, y luego otros
          usuarios también podrán añadir sus propias propuestas.
        </p>

        <div className="mt-5 rounded-2xl border border-(--border) bg-(--surface) p-4">
          <div className="flex items-start gap-3">
            <div className="rounded-xl bg-(--accent-soft) p-2 text-(--accent)">
              <Trophy size={18} />
            </div>

            <div>
              <p className="text-sm font-medium text-(--foreground)">
                Este formulario crea el Gathel padre
              </p>

              <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                Todavía no se crean apuestas. Primero se abre la etapa para que
                la gente proponga opciones candidatas y vote cuál quiere que
                avance.
              </p>
            </div>
          </div>
        </div>

        <form className="mt-6 flex flex-col gap-6" onSubmit={handleSubmit}>
          <div className="rounded-2xl border border-(--border) bg-(--surface) p-5">
            <div className="flex items-start gap-3">
              <div className="rounded-xl bg-(--surface-secondary) p-2 text-(--accent)">
                <FileText size={18} />
              </div>

              <div>
                <p className="text-sm font-medium text-(--foreground)">
                  Publicación o evento base
                </p>

                <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                  Escribí lo que viste: una publicación, reto, anuncio, historia
                  o evento real que puede generar propuestas candidatas.
                </p>
              </div>
            </div>

            <div className="mt-5 flex flex-col gap-4">
              <TextField name="publicationTitle" isRequired maxLength={140}>
                <Label>Título del Gathel</Label>
                <Input placeholder='Ej: "María está entrenando para una maratón"' />
                <FieldError />
              </TextField>

              <TextField
                name="publicationDescription"
                isRequired
                maxLength={500}
              >
                <Label>Descripción de la publicación o contexto</Label>
                <TextArea
                  rows={4}
                  placeholder="Ej: María subió una publicación diciendo que está entrenando para correr una maratón el próximo mes. La comunidad podrá proponer qué creen que pasará."
                />
                <FieldError />
              </TextField>

              <TextField name="sourceUrl" type="url">
                <Label>Enlace de la publicación, opcional</Label>

                <div className="relative">
                  <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-(--muted)">
                    <LinkIcon size={15} />
                  </span>

                  <Input placeholder="https://..." className="pl-9" />
                </div>

                <FieldError />
              </TextField>
            </div>
          </div>

          <div className="rounded-2xl border border-(--border) bg-(--surface) p-5">
            <div className="flex items-start gap-3">
              <div className="rounded-xl bg-(--surface-secondary) p-2 text-(--accent)">
                <Target size={18} />
              </div>

              <div>
                <p className="text-sm font-medium text-(--foreground)">
                  Persona objetivo
                </p>

                <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                  Es la persona sobre la que trata el Gathel. Esa persona tendrá
                  que aceptar o rechazar la opción ganadora más adelante.
                </p>
              </div>
            </div>

            <RadioGroup
              value={target}
              onChange={(value) => setTarget(value as TargetMode)}
            >
              <div className="mt-4 grid grid-cols-2 gap-2">
                <Radio value="otro">
                  <Radio.Content
                    className={`flex items-center gap-3 rounded-xl border p-4 transition-colors ${
                      target === "otro"
                        ? "border-(--accent) bg-(--accent-soft)"
                        : "border-(--border) bg-(--surface-secondary)"
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
                        Usando el ID de persona
                      </p>
                    </div>
                  </Radio.Content>
                </Radio>

                <Radio value="yo">
                  <Radio.Content
                    className={`flex items-center gap-3 rounded-xl border p-4 transition-colors ${
                      target === "yo"
                        ? "border-(--accent) bg-(--accent-soft)"
                        : "border-(--border) bg-(--surface-secondary)"
                    }`}
                  >
                    <Radio.Control>
                      <Radio.Indicator />
                    </Radio.Control>

                    <div className="leading-tight">
                      <Label className="text-sm font-medium text-(--foreground)">
                        Sobre mí
                      </Label>

                      <p className="text-xs text-(--muted)">
                        Usa tu propio usuario
                      </p>
                    </div>
                  </Radio.Content>
                </Radio>
              </div>
            </RadioGroup>

            {target === "otro" && (
              <div className="mt-4">
                <TextField name="targetPersonId" type="number" isRequired>
                  <Label>ID de la persona objetivo</Label>
                  <Input placeholder="Ej: 130" />
                  <FieldError />
                </TextField>
              </div>
            )}
          </div>

          <div className="rounded-2xl border border-(--border) bg-(--surface) p-5">
            <div className="flex items-start gap-3">
              <div className="rounded-xl bg-(--surface-secondary) p-2 text-(--accent)">
                <Wallet size={18} />
              </div>

              <div>
                <p className="text-sm font-medium text-(--foreground)">
                  Modo de predicción
                </p>

                <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                  Esto define qué tipo de pronósticos se permitirán si la opción
                  ganadora es aceptada por la persona objetivo.
                </p>
              </div>
            </div>

            <RadioGroup
              value={mode}
              onChange={(value) => setMode(value as PredictionMode)}
            >
              <div className="mt-4 grid grid-cols-3 gap-2">
                {[
                  {
                    value: "puntos",
                    label: "Puntos",
                    description: "Máximo 1 punto",
                  },
                  {
                    value: "dinero",
                    label: "Dinero",
                    description: "Bolsa real",
                  },
                  {
                    value: "ambos",
                    label: "Ambos",
                    description: "Puntos o dinero",
                  },
                ].map((option) => (
                  <Radio key={option.value} value={option.value}>
                    <Radio.Content
                      className={`flex h-full flex-col items-center gap-2 rounded-xl border p-3 text-center transition-colors ${
                        mode === option.value
                          ? "border-(--accent) bg-(--accent-soft)"
                          : "border-(--border) bg-(--surface-secondary)"
                      }`}
                    >
                      <Radio.Control>
                        <Radio.Indicator />
                      </Radio.Control>

                      <div>
                        <Label className="text-sm font-medium text-(--foreground)">
                          {option.label}
                        </Label>

                        <p className="mt-0.5 text-xs text-(--muted)">
                          {option.description}
                        </p>
                      </div>
                    </Radio.Content>
                  </Radio>
                ))}
              </div>
            </RadioGroup>
          </div>

          <div className="rounded-2xl border border-(--border) bg-(--surface) p-5">
            <div className="flex items-start gap-3">
              <div className="rounded-xl bg-(--surface-secondary) p-2 text-(--accent)">
                <Lightbulb size={18} />
              </div>

              <div>
                <p className="text-sm font-medium text-(--foreground)">
                  Proposición candidata inicial
                </p>

                <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                  Opcional. Podés dejar una primera opción para que la comunidad
                  vote. Otros usuarios también podrán añadir más propuestas
                  después.
                </p>
              </div>
            </div>

            <div className="mt-5 flex flex-col gap-4">
              <TextField name="initialCandidateText" maxLength={240}>
                <Label>Primera propuesta candidata, opcional</Label>
                <TextArea
                  rows={3}
                  placeholder='Ej: "María termina la maratón en menos de 5 horas."'
                />
                <FieldError />
              </TextField>

              <TextField name="initialCandidateDescription" maxLength={300}>
                <Label>Descripción de la propuesta inicial, opcional</Label>
                <TextArea
                  rows={2}
                  placeholder="Ej: Se puede verificar con el resultado oficial de la maratón o una publicación posterior."
                />
                <FieldError />
              </TextField>
            </div>
          </div>

          <div className="rounded-2xl border border-(--border) bg-(--surface) p-5">
            <div className="flex items-start gap-3">
              <div className="rounded-xl bg-(--surface-secondary) p-2 text-(--accent)">
                <CalendarClock size={18} />
              </div>

              <div>
                <p className="text-sm font-medium text-(--foreground)">
                  Etapa de votación
                </p>

                <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                  Al crear el Gathel, se abre una etapa de 24 horas para que la
                  comunidad añada y vote opciones candidatas. Luego se escoge la
                  opción más votada.
                </p>
              </div>
            </div>

            <div className="mt-4 rounded-xl border border-(--accent)/30 bg-(--accent-soft) p-4">
              <p className="text-sm font-medium text-(--foreground)">
                Duración: 24 horas
              </p>

              <p className="mt-1 text-xs leading-relaxed text-(--muted)">
                La fecha de cierre de votación se calcula automáticamente desde
                el momento de creación.
              </p>
            </div>
          </div>

          <div className="flex items-start gap-3 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
            <Bot
              size={18}
              className="mt-0.5 shrink-0 text-(--accent)"
              aria-hidden="true"
            />

            <p className="text-sm text-(--muted)">
              Antes de publicarse, este Gathel debería pasar por un filtro de IA
              que bloquee contenido ilegal, violento, sexual, discriminatorio o
              que viole las reglas de la plataforma.
            </p>
          </div>

          <div className="flex items-start gap-3 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
            <Users
              size={18}
              className="mt-0.5 shrink-0 text-(--accent)"
              aria-hidden="true"
            />

            <p className="text-sm text-(--muted)">
              Después de crear el Gathel, otras personas podrán añadir
              proposiciones candidatas. Por ejemplo: “María no asiste”, “María
              queda top 10” o “María termina en menos de 5 horas”.
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
                Por ahora, para el MVP, se usa el ID de la persona objetivo. Más
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
                Confirmo que este Gathel se basa en una publicación o evento
                real y verificable.
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
              {isSubmitting ? "Creando Gathel…" : "Crear Gathel"}
            </Button>
          </div>
        </form>
      </div>
    </AppShell>
  );
}