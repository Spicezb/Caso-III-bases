"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Avatar, Chip } from "@heroui/react";
import {
  Home,
  Compass,
  Bell,
  User,
  Wallet,
  Plus,
} from "lucide-react";
import { getMe, PersonResponse, getPredictionsByPerson } from "@/lib/gathel-api";

const INITIAL_MONEY_BALANCE = 100;

const NAV_ITEMS = [
  { href: "/dashboard", label: "Inicio", icon: Home },
  { href: "/dashboard/explorar", label: "Explorar", icon: Compass },
  { href: "/dashboard/notificaciones", label: "Notificaciones", icon: Bell },
  { href: "/dashboard/perfil", label: "Perfil", icon: User },
];

function getAvatarFallback(name?: string, lastName?: string) {
  const first = name?.[0] || "";
  const second = lastName?.[0] || "";

  return `${first}${second}`.toUpperCase() || "U";
}

export default function AppShell({
  children,
  active = "/dashboard",
}: {
  children: React.ReactNode;
  active?: string;
}) {
  const [user, setUser] = useState<PersonResponse | null>(null);
  const [moneyBalance, setMoneyBalance] = useState(INITIAL_MONEY_BALANCE);

  useEffect(() => {
    async function loadUser() {
      const storedPersonId = localStorage.getItem("personId");

      if (!storedPersonId) {
        return;
      }

      try {
        const personId = Number(storedPersonId);

        const [person, predictions] = await Promise.all([
          getMe(personId),
          getPredictionsByPerson(personId),
        ]);

        const usedMoney = predictions.reduce(
          (total, prediction) => total + (prediction.moneyAmount ?? 0),
          0
        );

        const availableMoney = INITIAL_MONEY_BALANCE - usedMoney;

        setUser(person);
        setMoneyBalance(availableMoney);
      } catch (error) {
        console.error("No se pudo cargar el usuario en AppShell:", error);
      }
    }

    loadUser();
  }, []);

  const displayName = user
    ? `${user.name} ${user.lastName}`.trim()
    : "Usuario";

  const handle = user?.username ? `@${user.username}` : "@usuario";
  const pointsBalance = user?.pointsBalance ?? 0;
  const avatarFallback = getAvatarFallback(user?.name, user?.lastName);

  return (
    <div className="min-h-screen lg:grid lg:grid-cols-[260px_1fr]">
      <aside className="hidden border-r border-(--separator) bg-(--surface-secondary) px-4 py-6 lg:flex lg:flex-col">
        <Link href="/" className="flex items-center gap-2 px-2">
          <span className="font-display text-xl font-semibold tracking-tight text-(--foreground)">
            gathel
          </span>
          <span className="h-1.5 w-1.5 rounded-full bg-(--success)" />
        </Link>

        <nav className="mt-8 flex flex-col gap-1">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = item.href === active;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors ${
                  isActive
                    ? "bg-(--accent-soft) text-(--accent-soft-foreground)"
                    : "text-(--muted) hover:bg-(--surface) hover:text-(--foreground)"
                }`}
              >
                <Icon size={18} aria-hidden="true" />
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="mt-8 rounded-xl border border-(--border) bg-(--surface) p-4">
          <p className="text-xs text-(--muted)">Tu balance</p>

          <p className="mt-1 font-display text-2xl font-semibold text-(--foreground)">
            {pointsBalance} pts
          </p>

          <div className="mt-1 flex items-center gap-1.5 text-xs text-(--muted)">
            <Wallet size={14} aria-hidden="true" />
            <span>${moneyBalance.toFixed(2)} disponibles</span>
          </div>
        </div>

        <div className="mt-auto flex items-center gap-2.5 rounded-lg px-2 py-2">
          <Avatar size="sm">
            <Avatar.Fallback>{avatarFallback}</Avatar.Fallback>
          </Avatar>

          <div className="leading-tight">
            <p className="text-sm font-medium text-(--foreground)">
              {displayName}
            </p>
            <p className="text-xs text-(--muted)">{handle}</p>
          </div>
        </div>
      </aside>

      <div className="flex flex-col">
        <header className="sticky top-0 z-40 flex items-center justify-between border-b border-(--separator) bg-(--background)/85 px-4 py-3 backdrop-blur-md sm:px-6">
          <Link href="/" className="flex items-center gap-2 lg:hidden">
            <span className="font-display text-lg font-semibold tracking-tight text-(--foreground)">
              gathel
            </span>
          </Link>

          <div className="hidden items-center gap-2 sm:flex">
            <Chip color="success" variant="soft" size="sm">
              <Chip.Label>{pointsBalance} pts</Chip.Label>
            </Chip>

            <Chip color="accent" variant="soft" size="sm">
              <Chip.Label>${moneyBalance.toFixed(2)}</Chip.Label>
            </Chip>
          </div>

          <div className="flex items-center gap-2">
            <Link
              href="/dashboard/crear"
              className="flex items-center gap-1.5 rounded-(--field-radius) bg-(--accent) px-3 py-2 text-sm font-medium text-(--accent-foreground) transition-colors hover:bg-(--accent-hover)"
            >
              <Plus size={16} aria-hidden="true" />
              <span className="hidden sm:inline">Nueva proposición</span>
            </Link>

            <Avatar size="sm" className="lg:hidden">
              <Avatar.Fallback>{avatarFallback}</Avatar.Fallback>
            </Avatar>
          </div>
        </header>

        <main className="flex-1 px-4 py-6 sm:px-6">{children}</main>

        <nav className="sticky bottom-0 z-40 flex items-center justify-around border-t border-(--separator) bg-(--background)/95 py-2 backdrop-blur-md lg:hidden">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = item.href === active;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex flex-col items-center gap-0.5 px-3 py-1 text-xs ${
                  isActive ? "text-(--accent)" : "text-(--muted)"
                }`}
              >
                <Icon size={20} aria-hidden="true" />
                {item.label}
              </Link>
            );
          })}
        </nav>
      </div>
    </div>
  );
}