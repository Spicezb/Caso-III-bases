"use client";

import Link from "next/link";
import { Avatar, Chip, buttonVariants } from "@heroui/react";
import {
  Users,
  Clock,
  ArrowRight,
  CheckCircle,
  TrendingUp,
  TrendingDown,
} from "lucide-react";

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
  alreadyVoted?: boolean;
  isMine?: boolean;
};

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

function avatarFallback(author: string) {
  return (
    author
      .split(" ")
      .map((p) => p[0])
      .join("")
      .slice(0, 2)
      .toUpperCase() || "U"
  );
}

function calculateMultiplier(probability: number) {
  const safeProbability = Math.max(probability, 5);

  return Number((100 / safeProbability).toFixed(2));
}

export default function PropositionCard({ item }: { item: Proposition }) {
  const isActive = item.status === "activa";

  const yesMultiplier = calculateMultiplier(item.probability);
  const noMultiplier = calculateMultiplier(100 - item.probability);

  return (
    <article className="rounded-2xl border border-(--border) bg-(--surface) p-5">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <Avatar size="sm">
            <Avatar.Fallback>{avatarFallback(item.author)}</Avatar.Fallback>
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

      <Link
        href={`/dashboard/proposicion/${item.id}`}
        className="group mt-3 flex items-start justify-between gap-2"
      >
        <p className="text-sm leading-relaxed text-(--foreground) transition-colors group-hover:text-(--accent)">
          &quot;{item.text}&quot;
        </p>

        <ArrowRight
          size={14}
          className="mt-0.5 shrink-0 text-(--muted) transition-colors group-hover:text-(--accent)"
          aria-hidden="true"
        />
      </Link>

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

        <div className="mt-3 grid grid-cols-2 gap-2 text-xs">
          <div className="rounded-lg border border-(--border) bg-(--surface-secondary) px-3 py-2">
            <div className="flex items-center gap-1.5 text-(--muted)">
              <TrendingUp size={13} className="text-(--success)" />
              <span>Sí</span>
            </div>

            <p className="mt-0.5 font-display text-base font-semibold text-(--success)">
              x{yesMultiplier.toFixed(2)}
            </p>
          </div>

          <div className="rounded-lg border border-(--border) bg-(--surface-secondary) px-3 py-2">
            <div className="flex items-center gap-1.5 text-(--muted)">
              <TrendingDown size={13} className="text-(--danger)" />
              <span>No</span>
            </div>

            <p className="mt-0.5 font-display text-base font-semibold text-(--danger)">
              x{noMultiplier.toFixed(2)}
            </p>
          </div>
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

      {isActive && !item.alreadyVoted && !item.isMine && (
        <div className="mt-4 grid grid-cols-2 gap-2">
          <Link
            href={`/dashboard/proposicion/${item.id}/pronosticar?voto=si`}
            className={buttonVariants({
              variant: "secondary",
              size: "md",
              fullWidth: true,
            })}
          >
            Sí va a pasar
          </Link>

          <Link
            href={`/dashboard/proposicion/${item.id}/pronosticar?voto=no`}
            className={buttonVariants({
              variant: "outline",
              size: "md",
              fullWidth: true,
            })}
          >
            No va a pasar
          </Link>
        </div>
      )}

      {isActive && item.alreadyVoted && (
        <div className="mt-4 rounded-xl border border-(--success)/30 bg-(--success-soft) px-4 py-3">
          <div className="flex items-start gap-2">
            <CheckCircle
              size={16}
              className="mt-0.5 shrink-0 text-(--success)"
              aria-hidden="true"
            />

            <div>
              <p className="text-sm font-medium text-(--foreground)">
                Ya hiciste un pronóstico.
              </p>
              <p className="mt-0.5 text-xs text-(--muted)">
                Solo se permite un voto por proposición.
              </p>
            </div>
          </div>
        </div>
      )}

      {isActive && item.isMine && (
        <div className="mt-4 rounded-xl border border-(--accent)/30 bg-(--accent-soft) px-4 py-3">
          <p className="text-sm font-medium text-(--foreground)">
            Esta proposición es tuya.
          </p>
          <p className="mt-0.5 text-xs text-(--muted)">
            No podés hacer pronósticos en una proposición que creaste o que es
            sobre vos.
          </p>
        </div>
      )}
    </article>
  );
}