import { Avatar, Chip } from "@heroui/react";

const STEPS = [
  {
    label: "01",
    title: "Conecta tus redes",
    body: "Autoriza a Gathel a leer tus publicaciones, historias y reels desde Instagram o TikTok. Esa actividad es la materia prima del juego.",
  },
  {
    label: "02",
    title: "Alguien propone, tú decides",
    body: "Cualquier seguidor puede crear una proposición sobre un evento real. La persona involucrada puede aceptarla o rechazarla antes de que arranque.",
  },
  {
    label: "03",
    title: "La comunidad pronostica",
    body: "Mientras la proposición está activa, los demás jugadores arriesgan puntos o dinero a que sí o que no va a pasar.",
  },
  {
    label: "04",
    title: "La IA valida el resultado",
    body: "El día del evento, la evidencia publicada con el hashtag de Gathel se analiza automáticamente para determinar quién ganó.",
  },
];

export default function HowItWorks() {
  return (
    <section id="como-funciona" className="border-b border-(--separator)">
      <div className="mx-auto max-w-6xl px-6 py-16 md:py-24">
        <div className="max-w-xl">
          <span className="text-xs uppercase tracking-widest text-(--muted)">
            Cómo funciona
          </span>
          <h2 className="mt-3 font-display text-3xl font-semibold tracking-tight text-(--foreground) sm:text-4xl">
            Un juego de predicciones que corre solo, con tu vida real como
            tablero.
          </h2>
        </div>

        <div className="mt-12 grid gap-px overflow-hidden rounded-2xl border border-(--border) bg-(--border) sm:grid-cols-2 lg:grid-cols-4">
          {STEPS.map((step) => (
            <div key={step.label} className="bg-(--surface) p-6">
              <span className="font-display text-sm text-(--accent)">
                {step.label}
              </span>
              <h3 className="mt-3 text-base font-medium text-(--foreground)">
                {step.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-(--muted)">
                {step.body}
              </p>
            </div>
          ))}
        </div>

        {/* Ejemplo narrado, basado en el caso de Elizabeth */}
        <div className="mt-12 rounded-2xl border border-(--border) bg-(--surface-secondary) p-6 md:p-8">
          <div className="flex flex-wrap items-center gap-3">
            <Avatar size="md">
              <Avatar.Fallback>EV</Avatar.Fallback>
            </Avatar>
            <div className="leading-tight">
              <p className="text-sm font-medium text-(--foreground)">
                Elizabeth publica que está entrenando para una maratón
              </p>
              <p className="text-xs text-(--muted)">
                Hace 2 h · vía Instagram
              </p>
            </div>
            <Chip color="success" variant="soft" size="sm" className="ml-auto">
              <Chip.Label>evento detectado</Chip.Label>
            </Chip>
          </div>

          <div className="mt-5 grid gap-3 sm:grid-cols-3">
            <div className="rounded-lg border border-(--border) bg-(--surface) p-4">
              <p className="text-sm text-(--foreground)">
                “Elizabeth no asistirá a la maratón.”
              </p>
              <p className="mt-2 text-xs text-(--muted)">propuesta por @johnrr</p>
            </div>
            <div className="rounded-lg border border-(--border) bg-(--surface) p-4">
              <p className="text-sm text-(--foreground)">
                “Terminará dentro de los primeros 30 lugares.”
              </p>
              <p className="mt-2 text-xs text-(--muted)">propuesta por @karina</p>
            </div>
            <div className="rounded-lg border border-(--accent) bg-(--surface) p-4">
              <p className="text-sm text-(--foreground)">
                “Voy a lograr al menos el décimo lugar.”
              </p>
              <p className="mt-2 text-xs text-(--accent)">
                propuesta por la propia Elizabeth
              </p>
            </div>
          </div>

          <p className="mt-5 text-sm text-(--muted)">
            Después de 24 horas, Gathel muestra la proposición ganadora y
            Elizabeth decide si la acepta. Si la acepta, define la fecha
            límite y el concurso queda activo para que la comunidad
            pronostique.
          </p>
        </div>
      </div>
    </section>
  );
}
