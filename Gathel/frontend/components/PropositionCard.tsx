"use client";

import { useState } from "react";
import Link from "next/link";
import { Avatar, Chip, buttonVariants } from "@heroui/react";
import { Users, Clock, ArrowRight } from "lucide-react";

export type Proposition = {
  id: string;
  author: string;
  handle: string;
  text: string;
  probability: number;
  pool: string;
  timeLeft: string;
  votes: number;
  status: "activa" | "cumplida" | "no cumplida";
  mode: "puntos" | "dinero" | "ambos";
};

function statusChip(status: Proposition["status"]) {
  if (status === "cumplida")
    return <Chip color="success" variant="soft" size="sm"><Chip.Label>cumplida</Chip.Label></Chip>;
  if (status === "no cumplida")
    return <Chip color="danger" variant="soft" size="sm"><Chip.Label>no cumplida</Chip.Label></Chip>;
  return <Chip color="accent" variant="soft" size="sm"><Chip.Label>activa</Chip.Label></Chip>;
}

export default function PropositionCard({ item }: { item: Proposition }) {
  const [vote, setVote] = useState<"si" | "no" | null>(null);
  const isActive = item.status === "activa";

  return (
    <article className="rounded-2xl border border-(--border) bg-(--surface) p-5">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <Avatar size="sm">
            <Avatar.Fallback>
              {item.author.split(" ").map((p) => p[0]).join("")}
            </Avatar.Fallback>
          </Avatar>
          <div className="leading-tight">
            <p className="text-sm font-medium text-(--foreground)">{item.author}</p>
            <p className="text-xs text-(--muted)">{item.handle}</p>
          </div>
        </div>
        {statusChip(item.status)}
      </div>

      {/* Título navegable */}
      <Link
        href={`/dashboard/proposicion/${item.id}`}
        className="group mt-3 flex items-start justify-between gap-2"
      >
        <p className="text-sm leading-relaxed text-(--foreground) group-hover:text-(--accent) transition-colors">
          "{item.text}"
        </p>
        <ArrowRight
          size={14}
          className="mt-0.5 shrink-0 text-(--muted) group-hover:text-(--accent) transition-colors"
          aria-hidden="true"
        />
      </Link>

      <div className="mt-4">
        <div className="flex items-center justify-between text-xs text-(--muted)">
          <span>Probabilidad de la comunidad</span>
          <span className="font-display font-semibold text-(--accent)">{item.probability}%</span>
        </div>
        <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-(--default)">
          <div
            className="h-full rounded-full bg-(--accent)"
            style={{ width: `${item.probability}%` }}
          />
        </div>
      </div>

      <div className="feed-divider mt-4 flex items-center justify-between pt-3 text-xs text-(--muted)">
        <span className="flex items-center gap-1">
          <Users size={14} aria-hidden="true" />
          {item.votes} pronósticos · {item.pool}
        </span>
        <span className="flex items-center gap-1">
          <Clock size={14} aria-hidden="true" />
          {item.timeLeft}
        </span>
      </div>

      {isActive && (
        <div className="mt-4">
          {vote === null ? (
            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => setVote("si")}
                className={buttonVariants({ variant: "secondary", size: "md", fullWidth: true })}
              >
                Sí va a pasar
              </button>
              <button
                type="button"
                onClick={() => setVote("no")}
                className={buttonVariants({ variant: "outline", size: "md", fullWidth: true })}
              >
                No va a pasar
              </button>
            </div>
          ) : (
            <div className="flex items-center justify-between rounded-lg border border-(--border) bg-(--surface-secondary) px-4 py-2.5 text-sm">
              <span className="text-(--foreground)">
                Pronosticaste:{" "}
                <span className="font-medium">
                  {vote === "si" ? "sí va a pasar" : "no va a pasar"}
                </span>
              </span>
              <button
                type="button"
                onClick={() => setVote(null)}
                className="text-xs text-(--accent) hover:underline"
              >
                cambiar
              </button>
            </div>
          )}
        </div>
      )}
    </article>
  );
}
