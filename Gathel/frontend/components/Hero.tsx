import Link from "next/link";
import { buttonVariants, Chip } from "@heroui/react";
import LiveTicker from "./LiveTicker";

export default function Hero() {
  return (
    <section className="bg-noise relative overflow-hidden border-b border-(--separator)">
      <div className="mx-auto grid max-w-6xl gap-12 px-6 py-16 md:grid-cols-2 md:items-center md:py-24">
        <div>
          <Chip color="accent" variant="soft" size="sm">
            <Chip.Label>nuevo · social prediction game</Chip.Label>
          </Chip>

          <h1 className="mt-6 font-display text-4xl font-semibold leading-[1.1] tracking-tight text-(--foreground) sm:text-5xl md:text-6xl">
            La vida de tu gente,{" "}
            <span className="text-(--accent)">convertida en pronóstico</span>.
          </h1>

          <p className="mt-6 max-w-md text-base leading-relaxed text-(--muted)">
            Conecta tus redes sociales, crea proposiciones sobre lo que va a
            pasar (o no) con tus amigos y creadores favoritos, y arriesga
            puntos o dinero real. Gathel valida los resultados con IA a
            partir de lo que la gente publica.
          </p>

          <div className="mt-8 flex flex-col gap-3 sm:flex-row">
            <Link
              href="/registro"
              className={buttonVariants({ variant: "primary", size: "lg" })}
            >
              Crear cuenta gratis
            </Link>
            <Link
              href="/login"
              className={buttonVariants({ variant: "outline", size: "lg" })}
            >
              Ya tengo cuenta
            </Link>
          </div>

          <div className="mt-10 grid grid-cols-3 gap-6 border-t border-(--separator) pt-6">
            <div>
              <p className="font-display text-2xl font-semibold text-(--foreground)">
                100 pts
              </p>
              <p className="text-xs text-(--muted)">
                balance inicial al registrarte
              </p>
            </div>
            <div>
              <p className="font-display text-2xl font-semibold text-(--foreground)">
                24 h
              </p>
              <p className="text-xs text-(--muted)">
                para votar cada proposición
              </p>
            </div>
            <div>
              <p className="font-display text-2xl font-semibold text-(--foreground)">
                IA
              </p>
              <p className="text-xs text-(--muted)">valida cada resultado</p>
            </div>
          </div>
        </div>

        <LiveTicker />
      </div>
    </section>
  );
}
