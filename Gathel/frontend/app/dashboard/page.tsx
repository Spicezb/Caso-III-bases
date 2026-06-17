import AppShell from "@/components/AppShell";
import DashboardFeed from "@/components/DashboardFeed";

export default function DashboardPage() {
  return (
    <AppShell active="/dashboard">
      <div className="mx-auto max-w-2xl">
        {/* Resumen de balance */}
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
            <p className="text-xs text-(--muted)">Puntos</p>
            <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
              128
            </p>
          </div>
          <div className="rounded-2xl border border-(--border) bg-(--surface) p-4">
            <p className="text-xs text-(--muted)">Dinero real</p>
            <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
              $42.50
            </p>
          </div>
          <div className="col-span-2 rounded-2xl border border-(--border) bg-(--surface) p-4 sm:col-span-1">
            <p className="text-xs text-(--muted)">Proposiciones activas</p>
            <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
              5
            </p>
          </div>
        </div>

        {/* Feed con tabs */}
        <div className="mt-8">
          <DashboardFeed />
        </div>
      </div>
    </AppShell>
  );
}
