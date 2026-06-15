import Link from "next/link";
import { buttonVariants } from "@heroui/react";

export default function Navbar() {
  return (
    <header className="sticky top-0 z-50 border-b border-(--separator) bg-(--background)/85 backdrop-blur-md">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <Link href="/" className="flex items-center gap-2">
          <span className="font-display text-xl font-semibold tracking-tight text-(--foreground)">
            gathel
          </span>
          <span className="hidden h-1.5 w-1.5 rounded-full bg-(--success) sm:inline" />
          <span className="hidden text-xs text-(--muted) sm:inline">
            en vivo
          </span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          <a
            href="#como-funciona"
            className="text-sm text-(--muted) transition-colors hover:text-(--foreground)"
          >
            Cómo funciona
          </a>
          <a
            href="#proposiciones"
            className="text-sm text-(--muted) transition-colors hover:text-(--foreground)"
          >
            Proposiciones
          </a>
          <a
            href="#seguridad"
            className="text-sm text-(--muted) transition-colors hover:text-(--foreground)"
          >
            Reglas y seguridad
          </a>
        </nav>

        <div className="flex items-center gap-2">
          <Link href="/login" className={buttonVariants({ variant: "ghost", size: "sm" })}>
            Iniciar sesión
          </Link>
          <Link href="/registro" className={buttonVariants({ variant: "primary", size: "sm" })}>
            Crear cuenta
          </Link>
        </div>
      </div>
    </header>
  );
}
