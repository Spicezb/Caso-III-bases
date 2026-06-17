"use client";

import { use } from "react";
import Link from "next/link";
import { Avatar, Chip, Button, buttonVariants } from "@heroui/react";
import {
  ArrowLeft,
  Users,
  Clock,
  TrendingUp,
  TrendingDown,
  CheckCircle,
  Image as ImageIcon,
} from "lucide-react";
import AppShell from "@/components/AppShell";
import { useUser } from "@/lib/user-context";

// ---------------------------------------------------------------------------
// Datos mock — reemplazar con fetch al endpoint GET /proposiciones/:id
// ---------------------------------------------------------------------------
const MOCK_DETAIL: Record<string, PropositionDetail> = {
  "1": {
    id: "1",
    author: "Karina M.",
    handle: "@karina",
    subject: "Elizabeth V.",
    subjectHandle: "@eliruns",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    status: "activa",
    mode: "puntos",
    probability: 64,
    pool: "812 pts",
    timeLeft: "quedan 6 h",
    deadline: "15 jun 2025, 10:00 p.m.",
    votes: 304,
    createdAt: "13 jun 2025",
    acceptedAt: "13 jun 2025",
    evidence: null,
    predictions: [
      { user: "Tomás B.",  handle: "@tomasb",  vote: "si",  amount: "1 pt",  time: "Hace 2 h" },
      { user: "Sofía A.",  handle: "@sofia.a", vote: "no",  amount: "1 pt",  time: "Hace 3 h" },
      { user: "Pablo N.",  handle: "@pablon",  vote: "si",  amount: "1 pt",  time: "Hace 5 h" },
      { user: "Camila R.", handle: "@camilar", vote: "si",  amount: "1 pt",  time: "Hace 6 h" },
      { user: "Diego F.",  handle: "@diegof",  vote: "no",  amount: "1 pt",  time: "Hace 8 h" },
    ],
  },
  "2": {
    id: "2",
    author: "Diego F.",
    handle: "@diegof",
    subject: "Diego F.",
    subjectHandle: "@diegof",
    text: "Subo el video del lanzamiento del producto antes del viernes a medianoche.",
    status: "activa",
    mode: "dinero",
    probability: 78,
    pool: "$64",
    timeLeft: "quedan 2 días",
    deadline: "17 jun 2025, 11:59 p.m.",
    votes: 132,
    createdAt: "12 jun 2025",
    acceptedAt: "12 jun 2025",
    evidence: null,
    predictions: [
      { user: "Karina M.", handle: "@karina",  vote: "si", amount: "$5",  time: "Hace 1 h" },
      { user: "Luis C.",   handle: "@luisc",   vote: "si", amount: "$10", time: "Hace 4 h" },
      { user: "Marian Q.", handle: "@marianq", vote: "no", amount: "$3",  time: "Hace 6 h" },
    ],
  },
  default: {
    id: "?",
    author: "Usuario",
    handle: "@usuario",
    subject: "Alguien",
    subjectHandle: "@alguien",
    text: "Esta proposición no existe o fue eliminada.",
    status: "activa",
    mode: "puntos",
    probability: 50,
    pool: "0 pts",
    timeLeft: "—",
    deadline: "—",
    votes: 0,
    createdAt: "—",
    acceptedAt: "—",
    evidence: null,
    predictions: [],
  },
};

type Prediction = {
  user: string;
  handle: string;
  vote: "si" | "no";
  amount: string;
  time: string;
};

type PropositionDetail = {
  id: string;
  author: string;
  handle: string;
  subject: string;
  subjectHandle: string;
  text: string;
  status: "activa" | "cumplida" | "no cumplida";
  mode: "puntos" | "dinero" | "ambos";
  probability: number;
  pool: string;
  timeLeft: string;
  deadline: string;
  votes: number;
  createdAt: string;
  acceptedAt: string;
  evidence: string | null;
  predictions: Prediction[];
};

function statusChip(status: PropositionDetail["status"]) {
  if (status === "cumplida")
    return <Chip color="success" variant="soft" size="sm"><Chip.Label>cumplida</Chip.Label></Chip>;
  if (status === "no cumplida")
    return <Chip color="danger" variant="soft" size="sm"><Chip.Label>no cumplida</Chip.Label></Chip>;
  return <Chip color="accent" variant="soft" size="sm"><Chip.Label>activa</Chip.Label></Chip>;
}

function modeChip(mode: PropositionDetail["mode"]) {
  const label = mode === "puntos" ? "solo puntos" : mode === "dinero" ? "dinero real" : "puntos y dinero";
  return <Chip color="default" variant="soft" size="sm"><Chip.Label>{label}</Chip.Label></Chip>;
}

// ---------------------------------------------------------------------------

export default function ProposicionDetallePage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { user } = useUser();
  const item = MOCK_DETAIL[id] ?? MOCK_DETAIL["default"];

  const siCount  = item.predictions.filter((p) => p.vote === "si").length;
  const noCount  = item.predictions.filter((p) => p.vote === "no").length;
  const isActive = item.status === "activa";
  const isMine   = item.subjectHandle === user.handle;

  return (
    <AppShell>
      <div className="mx-auto max-w-2xl">

        {/* Volver */}
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-1.5 text-sm text-(--muted) hover:text-(--foreground) transition-colors"
        >
          <ArrowLeft size={15} aria-hidden="true" />
          Volver al feed
        </Link>

        {/* Cabecera */}
        <div className="mt-5 rounded-2xl border border-(--border) bg-(--surface) p-5">
          <div className="flex flex-wrap items-center gap-2">
            {statusChip(item.status)}
            {modeChip(item.mode)}
          </div>

          <p className="mt-4 font-display text-xl font-semibold leading-snug text-(--foreground) sm:text-2xl">
            "{item.text}"
          </p>

          <div className="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-4 text-sm">
            <div>
              <p className="text-xs text-(--muted)">Propuesta por</p>
              <p className="mt-0.5 font-medium text-(--foreground)">{item.author}</p>
              <p className="text-xs text-(--muted)">{item.handle}</p>
            </div>
            <div>
              <p className="text-xs text-(--muted)">Sobre</p>
              <p className="mt-0.5 font-medium text-(--foreground)">{item.subject}</p>
              <p className="text-xs text-(--muted)">{item.subjectHandle}</p>
            </div>
            <div>
              <p className="text-xs text-(--muted)">Creada</p>
              <p className="mt-0.5 font-medium text-(--foreground)">{item.createdAt}</p>
            </div>
            <div>
              <p className="text-xs text-(--muted)">Cierra</p>
              <p className="mt-0.5 font-medium text-(--foreground)">{item.deadline}</p>
              <p className="text-xs text-(--accent)">{item.timeLeft}</p>
            </div>
          </div>
        </div>

        {/* Probabilidad */}
        <div className="mt-4 rounded-2xl border border-(--border) bg-(--surface) p-5">
          <div className="flex items-center justify-between text-sm">
            <span className="text-(--muted)">Probabilidad de la comunidad</span>
            <span className="font-display text-lg font-semibold text-(--accent)">
              {item.probability}%
            </span>
          </div>
          <div className="mt-3 h-2 w-full overflow-hidden rounded-full bg-(--default)">
            <div
              className="h-full rounded-full bg-(--accent) transition-all"
              style={{ width: `${item.probability}%` }}
            />
          </div>
          <div className="mt-3 flex items-center justify-between text-xs text-(--muted)">
            <span className="flex items-center gap-1">
              <TrendingUp size={13} className="text-(--success)" />
              {siCount} dicen que sí
            </span>
            <span className="flex items-center gap-1">
              <TrendingDown size={13} className="text-(--danger)" />
              {noCount} dicen que no
            </span>
            <span className="flex items-center gap-1">
              <Users size={13} />
              {item.votes} en total · {item.pool}
            </span>
          </div>
        </div>

        {/* Evidencia (si ya terminó) */}
        {item.status !== "activa" && (
          <div className="mt-4 rounded-2xl border border-(--border) bg-(--surface) p-5">
            <p className="text-xs uppercase tracking-widest text-(--muted)">Evidencia publicada</p>
            {item.evidence ? (
              <p className="mt-2 text-sm text-(--foreground)">{item.evidence}</p>
            ) : (
              <div className="mt-3 flex flex-col items-center justify-center gap-2 rounded-xl border border-dashed border-(--border) py-8 text-center">
                <ImageIcon size={24} className="text-(--muted)" aria-hidden="true" />
                <p className="text-sm text-(--muted)">
                  La evidencia fue analizada por IA a partir de publicaciones
                  en redes sociales con el hashtag #gathel.
                </p>
              </div>
            )}
          </div>
        )}

        {/* Acciones — solo si es activa y es sobre el usuario actual */}
        {isActive && isMine && (
          <div className="mt-4 rounded-2xl border border-(--accent)/30 bg-(--accent-soft) p-5">
            <p className="text-sm font-medium text-(--foreground)">
              Esta proposición es sobre ti.
            </p>
            <p className="mt-1 text-sm text-(--muted)">
              Cuando llegue el momento, sube evidencia del resultado con el
              hashtag <span className="text-(--accent)">#gathel</span> en
              Instagram o TikTok. La IA lo validará automáticamente.
            </p>
            <div className="mt-4 flex items-center gap-2">
              <Link
                href="/dashboard"
                className={buttonVariants({ variant: "secondary", size: "sm" })}
              >
                Ver mis proposiciones
              </Link>
            </div>
          </div>
        )}

        {/* Pronosticar — solo si es activa y NO es sobre ti */}
        {isActive && !isMine && (
          <div className="mt-4 rounded-2xl border border-(--border) bg-(--surface) p-5">
            <p className="text-sm font-medium text-(--foreground)">
              ¿Qué crees que va a pasar?
            </p>
            <p className="mt-1 text-sm text-(--muted)">
              Modo:{" "}
              <span className="text-(--foreground)">
                {item.mode === "puntos"
                  ? "apuesta hasta 1 punto"
                  : item.mode === "dinero"
                  ? "elige el monto en dinero real"
                  : "puntos o dinero real"}
              </span>
            </p>
            <div className="mt-4 grid grid-cols-2 gap-3">
              <Link
                href={`/dashboard/proposicion/${item.id}/pronosticar?voto=si`}
                className={buttonVariants({ variant: "secondary", size: "lg", fullWidth: true })}
              >
                <TrendingUp size={16} className="mr-1" />
                Sí va a pasar
              </Link>
              <Link
                href={`/dashboard/proposicion/${item.id}/pronosticar?voto=no`}
                className={buttonVariants({ variant: "outline", size: "lg", fullWidth: true })}
              >
                <TrendingDown size={16} className="mr-1" />
                No va a pasar
              </Link>
            </div>
          </div>
        )}

        {/* Lista de predicciones */}
        <div className="mt-6">
          <p className="text-xs uppercase tracking-widest text-(--muted)">
            Últimos pronósticos
          </p>
          <div className="mt-3 flex flex-col gap-2">
            {item.predictions.length === 0 ? (
              <div className="rounded-xl border border-(--border) bg-(--surface) py-8 text-center">
                <p className="text-sm text-(--muted)">Todavía no hay pronósticos.</p>
              </div>
            ) : (
              item.predictions.map((p, i) => (
                <div
                  key={i}
                  className="flex items-center justify-between rounded-xl border border-(--border) bg-(--surface) px-4 py-3"
                >
                  <div className="flex items-center gap-2.5">
                    <Avatar size="sm">
                      <Avatar.Fallback>
                        {p.user.split(" ").map((x) => x[0]).join("")}
                      </Avatar.Fallback>
                    </Avatar>
                    <div className="leading-tight">
                      <p className="text-sm font-medium text-(--foreground)">{p.user}</p>
                      <p className="text-xs text-(--muted)">{p.handle} · {p.time}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-(--muted)">{p.amount}</span>
                    {p.vote === "si" ? (
                      <Chip color="success" variant="soft" size="sm">
                        <Chip.Label className="flex items-center gap-1">
                          <CheckCircle size={11} />
                          sí
                        </Chip.Label>
                      </Chip>
                    ) : (
                      <Chip color="danger" variant="soft" size="sm">
                        <Chip.Label>no</Chip.Label>
                      </Chip>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

      </div>
    </AppShell>
  );
}
