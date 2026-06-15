import Link from "next/link";
import { Avatar, Chip, buttonVariants } from "@heroui/react";
import { TrendingUp, MessageCircle, Users } from "lucide-react";

const FEED = [
  {
    author: "Diego F.",
    handle: "@diegof",
    avatar: "DF",
    text: "Subo el video del lanzamiento del producto antes del viernes a medianoche.",
    probability: 78,
    pool: "$64",
    votes: 132,
    status: "activa" as const,
  },
  {
    author: "Marian Q.",
    handle: "@marianq",
    avatar: "MQ",
    text: "No publico nada en redes sociales este fin de semana.",
    probability: 23,
    pool: "205 pts",
    votes: 89,
    status: "no cumplida" as const,
  },
  {
    author: "Luis C.",
    handle: "@luisc",
    avatar: "LC",
    text: "Llego al gimnasio los 5 días de esta semana.",
    probability: 55,
    pool: "390 pts",
    votes: 211,
    status: "activa" as const,
  },
  {
    author: "Karina M.",
    handle: "@karina",
    avatar: "KM",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    probability: 64,
    pool: "812 pts",
    votes: 304,
    status: "activa" as const,
  },
  {
    author: "Sofía A.",
    handle: "@sofia.a",
    avatar: "SA",
    text: "Termino de leer el libro antes de fin de mes.",
    probability: 91,
    pool: "$30",
    votes: 47,
    status: "cumplida" as const,
  },
  {
    author: "Pablo N.",
    handle: "@pablon",
    avatar: "PN",
    text: "Mi equipo gana el partido del domingo por más de 2 goles.",
    probability: 18,
    pool: "150 pts",
    votes: 162,
    status: "activa" as const,
  },
];

function statusChip(status: "activa" | "cumplida" | "no cumplida") {
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

export default function FeedPreview() {
  return (
    <section id="proposiciones" className="border-b border-(--separator)">
      <div className="mx-auto max-w-6xl px-6 py-16 md:py-24">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div className="max-w-xl">
            <span className="text-xs uppercase tracking-widest text-(--muted)">
              El feed
            </span>
            <h2 className="mt-3 font-display text-3xl font-semibold tracking-tight text-(--foreground) sm:text-4xl">
              Esto es lo que está pasando ahora en Gathel.
            </h2>
          </div>
          <Link
            href="/registro"
            className={buttonVariants({ variant: "secondary", size: "md" })}
          >
            Únete y empieza a pronosticar
          </Link>
        </div>

        <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {FEED.map((post) => (
            <article
              key={post.handle + post.text.slice(0, 8)}
              className="flex flex-col rounded-2xl border border-(--border) bg-(--surface) p-5"
            >
              <div className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-2.5">
                  <Avatar size="sm">
                    <Avatar.Fallback>{post.avatar}</Avatar.Fallback>
                  </Avatar>
                  <div className="leading-tight">
                    <p className="text-sm font-medium text-(--foreground)">
                      {post.author}
                    </p>
                    <p className="text-xs text-(--muted)">{post.handle}</p>
                  </div>
                </div>
                {statusChip(post.status)}
              </div>

              <p className="mt-3 flex-1 text-sm leading-relaxed text-(--foreground)">
                “{post.text}”
              </p>

              <div className="mt-4">
                <div className="flex items-center justify-between text-xs text-(--muted)">
                  <span className="flex items-center gap-1">
                    <TrendingUp size={14} aria-hidden="true" />
                    Probabilidad
                  </span>
                  <span className="font-display font-semibold text-(--accent)">
                    {post.probability}%
                  </span>
                </div>
                <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-(--default)">
                  <div
                    className="h-full rounded-full bg-(--accent)"
                    style={{ width: `${post.probability}%` }}
                  />
                </div>
              </div>

              <div className="feed-divider mt-4 flex items-center justify-between pt-3 text-xs text-(--muted)">
                <span className="flex items-center gap-1">
                  <Users size={14} aria-hidden="true" />
                  {post.votes} pronósticos
                </span>
                <span className="flex items-center gap-1">
                  <MessageCircle size={14} aria-hidden="true" />
                  Bolsa: {post.pool}
                </span>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
