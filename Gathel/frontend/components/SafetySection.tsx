import { ShieldCheck, EyeOff, Bot, Coins } from "lucide-react";

const RULES = [
  {
    icon: ShieldCheck,
    title: "Control total sobre tu vida",
    body: "Puedes rechazar cualquier proposición sobre ti que consideres ofensiva, invasiva o inaceptable. Sin excepciones.",
  },
  {
    icon: EyeOff,
    title: "Votos siempre anónimos",
    body: "Ningún jugador puede ver cuántos votos tiene cada proposición. Solo la persona involucrada accede a esa información.",
  },
  {
    icon: Bot,
    title: "Filtro de IA antes de publicar",
    body: "Todo el contenido se analiza automáticamente para bloquear temas ilegales, violentos, sexuales, discriminatorios o fraudulentos.",
  },
  {
    icon: Coins,
    title: "Puntos y dinero, separados con claridad",
    body: "Cada predicción arriesga un máximo de 1 punto, o el monto en dinero real que tú decidas, siempre bajo las reglas del evento.",
  },
];

export default function SafetySection() {
  return (
    <section id="seguridad" className="border-b border-(--separator)">
      <div className="mx-auto max-w-6xl px-6 py-16 md:py-24">
        <div className="grid gap-12 md:grid-cols-[0.9fr_1.1fr] md:items-start">
          <div>
            <span className="text-xs uppercase tracking-widest text-(--muted)">
              Reglas y seguridad
            </span>
            <h2 className="mt-3 font-display text-3xl font-semibold tracking-tight text-(--foreground) sm:text-4xl">
              Es un juego sobre personas reales. Por eso las reglas son
              estrictas.
            </h2>
            <p className="mt-4 text-sm leading-relaxed text-(--muted)">
              Antes de aceptar cualquier proposición, validamos que se
              respete la integridad moral, física y de salud de la persona
              involucrada, según los términos y condiciones de la
              plataforma.
            </p>
          </div>

          <div className="grid gap-px overflow-hidden rounded-2xl border border-(--border) bg-(--border) sm:grid-cols-2">
            {RULES.map((rule) => {
              const Icon = rule.icon;
              return (
                <div key={rule.title} className="bg-(--surface) p-6">
                  <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-(--accent-soft) text-(--accent)">
                    <Icon size={18} aria-hidden="true" />
                  </div>
                  <h3 className="mt-4 text-sm font-medium text-(--foreground)">
                    {rule.title}
                  </h3>
                  <p className="mt-2 text-sm leading-relaxed text-(--muted)">
                    {rule.body}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
