import Link from "next/link";
import { Avatar, Chip } from "@heroui/react";

const SIDE_PROPOSITIONS = [
  {
    author: "Karina M.",
    handle: "@karina",
    text: "Elizabeth terminará la maratón dentro de los primeros 30 lugares.",
    probability: 64,
  },
  {
    author: "Diego F.",
    handle: "@diegof",
    text: "Subo el video del lanzamiento antes del viernes.",
    probability: 78,
  },
  {
    author: "Luis C.",
    handle: "@luisc",
    text: "Llego al gym los 5 días de esta semana.",
    probability: 55,
  },
];

export default function AuthLayout({
  children,
  eyebrow,
  title,
  subtitle,
}: {
  children: React.ReactNode;
  eyebrow: string;
  title: string;
  subtitle: string;
}) {
  return (
    <div className="grid min-h-screen lg:grid-cols-2">
      {/* Panel del formulario */}
      <div className="flex flex-col justify-between px-6 py-8 sm:px-12 lg:px-16">
        <Link href="/" className="flex items-center gap-2">
          <span className="font-display text-xl font-semibold tracking-tight text-(--foreground)">
            gathel
          </span>
          <span className="h-1.5 w-1.5 rounded-full bg-(--success)" />
        </Link>

        <div className="mx-auto w-full max-w-sm py-12">
          <span className="text-xs uppercase tracking-widest text-(--muted)">
            {eyebrow}
          </span>
          <h1 className="mt-3 font-display text-3xl font-semibold tracking-tight text-(--foreground) sm:text-4xl">
            {title}
          </h1>
          <p className="mt-2 text-sm text-(--muted)">{subtitle}</p>

          <div className="mt-8">{children}</div>
        </div>

        <p className="text-center text-xs text-(--muted) lg:text-left">
          Al continuar aceptas los{" "}
          <Link href="/terminos" className="text-(--accent) hover:underline">
            términos y condiciones
          </Link>{" "}
          y las reglas de la plataforma.
        </p>
      </div>

      {/* Panel visual: feed en vivo */}
      <div className="bg-noise hidden border-l border-(--separator) bg-(--surface-secondary) p-10 lg:flex lg:flex-col lg:justify-center">
        <div className="mx-auto w-full max-w-md">
          <Chip color="accent" variant="soft" size="sm">
            <Chip.Label>en vivo ahora</Chip.Label>
          </Chip>

          <h2 className="mt-4 font-display text-2xl font-semibold leading-tight tracking-tight text-(--foreground)">
            Tu feed ya está pasando algo.
          </h2>
          <p className="mt-2 text-sm text-(--muted)">
            Esto es lo que la comunidad está pronosticando ahora mismo.
          </p>

          <div className="mt-6 flex flex-col gap-3">
            {SIDE_PROPOSITIONS.map((item) => (
              <article
                key={item.handle}
                className="rounded-lg border border-(--border) bg-(--surface) p-4"
              >
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
                <p className="mt-3 text-sm leading-snug text-(--foreground)">
                  “{item.text}”
                </p>
                <div className="mt-3">
                  <div className="flex items-center justify-between text-xs text-(--muted)">
                    <span>Probabilidad</span>
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
                </div>
              </article>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
