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

export default function CrearProposicionPage() {
  const router = useRouter();
  const [target, setTarget] = useState<"otro" | "yo">("otro");
  const [mode, setMode] = useState<"puntos" | "dinero" | "ambos">("puntos");
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsSubmitting(true);

    // TODO: enviar al backend (REST API) -> POST /proposiciones
    // El backend ejecuta el filtro de IA antes de publicarla
    setTimeout(() => {
      setIsSubmitting(false);
      router.push("/dashboard");
    }, 800);
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
          {/* Sobre quién */}
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
                      Podrá aceptarla o rechazarla
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
                      Inicia activa de inmediato
                    </p>
                  </div>
                </Radio.Content>
              </Radio>
            </div>
          </RadioGroup>

          {/* Persona objetivo (solo si es "otro") */}
          {target === "otro" && (
            <TextField name="targetUser" type="text" isRequired>
              <Label>Usuario de la persona</Label>
              <Input placeholder="@eliruns" />
              <FieldError />
            </TextField>
          )}

          {/* Texto de la proposición */}
          <TextField name="propositionText" isRequired maxLength={240}>
            <Label>Proposición</Label>
            <TextArea
              rows={3}
              placeholder='Ej: "Elizabeth terminará la maratón dentro de los primeros 30 lugares."'
            />
            <FieldError />
          </TextField>

          {/* Modo de predicción */}
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

          {/* Fecha límite */}
          <TextField name="deadline" type="datetime-local" isRequired>
            <Label>Fecha y hora límite para predicciones</Label>
            <Input />
            <FieldError />
          </TextField>

          {/* Aviso de filtro de IA */}
          <div className="flex items-start gap-3 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
            <Bot size={18} className="mt-0.5 shrink-0 text-(--accent)" aria-hidden="true" />
            <p className="text-sm text-(--muted)">
              Antes de publicarse, esta proposición pasará por un filtro de
              IA que bloquea contenido ilegal, violento, sexual,
              discriminatorio o que viole las reglas de la plataforma.
            </p>
          </div>

          {target === "otro" && (
            <div className="flex items-start gap-3 rounded-xl border border-(--border) bg-(--surface-secondary) p-4">
              <Info size={18} className="mt-0.5 shrink-0 text-(--accent)" aria-hidden="true" />
              <p className="text-sm text-(--muted)">
                La persona involucrada podrá rechazar esta proposición si la
                considera ofensiva, invasiva o inaceptable. Si la acepta,
                definirá la fecha límite final y activará el concurso.
              </p>
            </div>
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
