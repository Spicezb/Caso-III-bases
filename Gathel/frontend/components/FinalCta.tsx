import Link from "next/link";
import { buttonVariants } from "@heroui/react";

export default function FinalCta() {
  return (
    <section className="border-b border-(--separator)">
      <div className="mx-auto max-w-6xl px-6 py-16 text-center md:py-24">
        <h2 className="font-display text-3xl font-semibold tracking-tight text-(--foreground) sm:text-4xl md:text-5xl">
          Tu próxima publicación podría valer puntos.
        </h2>
        <p className="mx-auto mt-4 max-w-xl text-sm text-(--muted) sm:text-base">
          Regístrate, conecta tu Instagram o TikTok y recibe 100 puntos para
          empezar a crear y pronosticar proposiciones hoy mismo.
        </p>
        <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
          <Link
            href="/registro"
            className={buttonVariants({ variant: "primary", size: "lg" })}
          >
            Crear cuenta gratis
          </Link>
          <Link
            href="/login"
            className={buttonVariants({ variant: "ghost", size: "lg" })}
          >
            Iniciar sesión
          </Link>
        </div>
      </div>
    </section>
  );
}
