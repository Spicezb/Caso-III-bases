import { Avatar, Chip } from "@heroui/react";

type Proposition = {
  id: string;
  author: string;
  handle: string;
  text: string;
  probability: number; // 0-100, probabilidad de "sí" según la comunidad
  pool: string;
  status: "activa" | "cumplida" | "no cumplida";
};

const PROPOSITIONS: Proposition[] = [
  {
    id: "1",
    author: "Karina M.",
    handle: "@karina",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    probability: 64,
    pool: "812 pts",
    status: "activa",
  },
  {
    id: "2",
    author: "John R.",
    handle: "@johnrr",
    text: "Elizabeth no asistirá a la maratón.",
    probability: 12,
    pool: "340 pts",
    status: "activa",
  },
  {
    id: "3",
    author: "Elizabeth V.",
    handle: "@eliruns",
    text: "Voy a lograr al menos el décimo lugar en la maratón.",
    probability: 41,
    pool: "$128",
    status: "activa",
  },
  {
    id: "4",
    author: "Diego F.",
    handle: "@diegof",
    text: "Subo el video del lanzamiento antes del viernes.",
    probability: 78,
    pool: "$64",
    status: "cumplida",
  },
  {
    id: "5",
    author: "Marian Q.",
    handle: "@marianq",
    text: "No publico nada en redes este fin de semana.",
    probability: 23,
    pool: "205 pts",
    status: "no cumplida",
  },
  {
    id: "6",
    author: "Luis C.",
    handle: "@luisc",
    text: "Llego al gym los 5 días de esta semana.",
    probability: 55,
    pool: "390 pts",
    status: "activa",
  },
];

function statusChip(status: Proposition["status"]) {
  if (status === "cumplida") {
    return (
      <Chip color="success" variant="soft" size="sm">
        <Chip.Label>cumplida</Chip.Label>
      </Chip>
    );
  }
  if (status === "no cumplida") {
    return (
      <Chip color="danger" variant="soft" size="sm">
        <Chip.Label>no cumplida</Chip.Label>
      </Chip>
    );
  }
  return (
    <Chip color="accent" variant="soft" size="sm">
      <Chip.Label>activa</Chip.Label>
    </Chip>
  );
}

function PropositionCard({ item }: { item: Proposition }) {
  return (
    <article className="rounded-lg border border-(--border) bg-(--surface) p-4">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <Avatar size="sm">
            <Avatar.Fallback>
              {item.author
                .split(" ")
                .map((p) => p[0])
                .join("")}
            </Avatar.Fallback>
          </Avatar>
          <div className="leading-tight">
            <p className="text-sm font-medium text-(--foreground)">
              {item.author}
            </p>
            <p className="text-xs text-(--muted)">{item.handle}</p>
          </div>
        </div>
        {statusChip(item.status)}
      </div>

      <p className="mt-3 text-sm leading-snug text-(--foreground)">
        “{item.text}”
      </p>

      <div className="mt-4">
        <div className="flex items-center justify-between text-xs text-(--muted)">
          <span>Probabilidad de la comunidad</span>
          <span className="font-display font-semibold text-(--accent)">
            {item.probability}%
          </span>
        </div>
        <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-(--default)">
          <div
            className="h-full rounded-full bg-(--accent)"
            style={{ width: `${item.probability}%` }}
          />
        </div>
        <div className="mt-2 text-xs text-(--muted)">
          Bolsa acumulada: <span className="text-(--foreground)">{item.pool}</span>
        </div>
      </div>
    </article>
  );
}

export default function LiveTicker() {
  // Duplicamos la lista para crear el efecto de scroll infinito
  const items = [...PROPOSITIONS, ...PROPOSITIONS];

  return (
    <div className="relative h-[560px] overflow-hidden rounded-2xl border border-(--border) bg-(--surface-secondary) p-3">
      <div className="pointer-events-none absolute inset-x-0 top-0 z-10 h-16 bg-gradient-to-b from-(--surface-secondary) to-transparent" />
      <div className="pointer-events-none absolute inset-x-0 bottom-0 z-10 h-16 bg-gradient-to-t from-(--surface-secondary) to-transparent" />

      <div className="ticker-track flex flex-col gap-3">
        {items.map((item, i) => (
          <PropositionCard key={`${item.id}-${i}`} item={item} />
        ))}
      </div>
    </div>
  );
}
