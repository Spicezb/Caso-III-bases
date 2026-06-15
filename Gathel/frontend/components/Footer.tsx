import Link from "next/link";

export default function Footer() {
  return (
    <footer className="px-6 py-10">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 text-sm text-(--muted) sm:flex-row">
        <div className="flex items-center gap-2">
          <span className="font-display font-semibold text-(--foreground)">
            gathel
          </span>
          <span>© {new Date().getFullYear()}</span>
        </div>
        <nav className="flex flex-wrap items-center justify-center gap-6">
          <Link href="/terminos" className="hover:text-(--foreground)">
            Términos y condiciones
          </Link>
          <Link href="/privacidad" className="hover:text-(--foreground)">
            Privacidad
          </Link>
          <a href="#seguridad" className="hover:text-(--foreground)">
            Reglas de la plataforma
          </a>
        </nav>
      </div>
    </footer>
  );
}
