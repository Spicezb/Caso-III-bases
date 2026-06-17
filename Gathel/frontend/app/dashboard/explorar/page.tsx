"use client";

import { useState } from "react";
import { Input, Chip, TextField, Label } from "@heroui/react";
import { Search } from "lucide-react";
import AppShell from "@/components/AppShell";
import PropositionCard, { Proposition } from "@/components/PropositionCard";

const ALL: Proposition[] = [
  {
    id: "e1",
    author: "Karina M.",
    handle: "@karina",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    probability: 64,
    pool: "812 pts",
    timeLeft: "quedan 6 h",
    votes: 304,
    status: "activa",
    mode: "puntos",
  },
  {
    id: "e2",
    author: "Diego F.",
    handle: "@diegof",
    text: "Subo el video del lanzamiento antes del viernes.",
    probability: 78,
    pool: "$64",
    timeLeft: "quedan 2 días",
    votes: 132,
    status: "activa",
    mode: "dinero",
  },
  {
    id: "e3",
    author: "Luis C.",
    handle: "@luisc",
    text: "Llego al gimnasio los 5 días de esta semana.",
    probability: 55,
    pool: "390 pts",
    timeLeft: "quedan 18 h",
    votes: 211,
    status: "activa",
    mode: "puntos",
  },
  {
    id: "e4",
    author: "Sofía A.",
    handle: "@sofia.a",
    text: "Termino de leer el libro antes de fin de mes.",
    probability: 91,
    pool: "$30",
    timeLeft: "finalizó",
    votes: 47,
    status: "cumplida",
    mode: "dinero",
  },
  {
    id: "e5",
    author: "Pablo N.",
    handle: "@pablon",
    text: "Mi equipo gana el partido del domingo por más de 2 goles.",
    probability: 18,
    pool: "150 pts",
    timeLeft: "quedan 3 días",
    votes: 162,
    status: "activa",
    mode: "puntos",
  },
  {
    id: "e6",
    author: "Marian Q.",
    handle: "@marianq",
    text: "No publico nada en redes este fin de semana.",
    probability: 23,
    pool: "205 pts",
    timeLeft: "finalizó",
    votes: 89,
    status: "no cumplida",
    mode: "puntos",
  },
  {
    id: "e7",
    author: "Tomás B.",
    handle: "@tomasb",
    text: "Lanzo mi tienda online antes del 30 de junio.",
    probability: 67,
    pool: "$200",
    timeLeft: "quedan 5 días",
    votes: 388,
    status: "activa",
    mode: "ambos",
  },
  {
    id: "e8",
    author: "Camila R.",
    handle: "@camilar",
    text: "Consigo 1000 seguidores nuevos en TikTok este mes.",
    probability: 45,
    pool: "560 pts",
    timeLeft: "quedan 12 días",
    votes: 241,
    status: "activa",
    mode: "puntos",
  },
];

const FILTERS = ["Todas", "Activas", "Cumplidas", "No cumplidas"] as const;
type Filter = (typeof FILTERS)[number];

export default function ExplorarPage() {
  const [query, setQuery]   = useState("");
  const [filter, setFilter] = useState<Filter>("Todas");

  const visible = ALL.filter((p) => {
    const matchesText =
      query.trim() === "" ||
      p.text.toLowerCase().includes(query.toLowerCase()) ||
      p.handle.toLowerCase().includes(query.toLowerCase()) ||
      p.author.toLowerCase().includes(query.toLowerCase());

    const matchesFilter =
      filter === "Todas" ||
      (filter === "Activas"      && p.status === "activa")      ||
      (filter === "Cumplidas"    && p.status === "cumplida")    ||
      (filter === "No cumplidas" && p.status === "no cumplida");

    return matchesText && matchesFilter;
  });

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">
        <span className="text-xs uppercase tracking-widest text-(--muted)">
          Explorar
        </span>
        <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight text-(--foreground) sm:text-3xl">
          Todas las proposiciones
        </h1>

        {/* Buscador */}
        <div className="mt-6">
          <TextField
            value={query}
            onChange={setQuery}
            aria-label="Buscar proposiciones"
          >
            <Label className="sr-only">Buscar proposiciones</Label>
            <div className="relative">
              <Search
                size={16}
                className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-(--muted)"
                aria-hidden="true"
              />
              <Input
                placeholder="Buscar por texto, usuario o handle…"
                className="pl-9"
              />
            </div>
          </TextField>
        </div>

        {/* Filtros */}
        <div className="mt-4 flex flex-wrap gap-2">
          {FILTERS.map((f) => (
            <button
              key={f}
              type="button"
              onClick={() => setFilter(f)}
              className="focus:outline-none"
            >
              <Chip
                color={filter === f ? "accent" : "default"}
                variant={filter === f ? "primary" : "soft"}
                size="sm"
                className="cursor-pointer"
              >
                <Chip.Label>{f}</Chip.Label>
              </Chip>
            </button>
          ))}
        </div>

        {/* Resultados */}
        <div className="mt-6 flex flex-col gap-4">
          {visible.length > 0 ? (
            visible.map((item) => (
              <PropositionCard key={item.id} item={item} />
            ))
          ) : (
            <div className="rounded-2xl border border-(--border) bg-(--surface) py-12 text-center">
              <p className="text-sm text-(--muted)">
                No hay proposiciones que coincidan con tu búsqueda.
              </p>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}
