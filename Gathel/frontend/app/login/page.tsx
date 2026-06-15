"use client";

import Link from "next/link";
import { useState } from "react";
import {
  Button,
  Checkbox,
  FieldError,
  Input,
  Label,
  TextField,
  buttonVariants,
} from "@heroui/react";
import { Eye, EyeOff } from "lucide-react";
import AuthLayout from "@/components/AuthLayout";

export default function LoginPage() {
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsSubmitting(true);

    // TODO: conectar con el endpoint de login del backend (REST API)
    setTimeout(() => setIsSubmitting(false), 800);
  }

  return (
    <AuthLayout
      eyebrow="Iniciar sesión"
      title="Bienvenido de vuelta."
      subtitle="Entra para ver tus proposiciones activas, tu balance y lo que está pasando ahora."
    >
      <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
        <TextField name="email" type="email" isRequired>
          <Label>Correo o nombre de usuario</Label>
          <Input placeholder="tu@correo.com" />
          <FieldError />
        </TextField>

        <TextField name="password" type={showPassword ? "text" : "password"} isRequired>
          <Label>Contraseña</Label>
          <div className="relative">
            <Input placeholder="Tu contraseña" className="pr-10" />
            <button
              type="button"
              onClick={() => setShowPassword((v) => !v)}
              className="absolute inset-y-0 right-0 flex w-10 items-center justify-center text-(--muted) hover:text-(--foreground)"
              aria-label={
                showPassword ? "Ocultar contraseña" : "Mostrar contraseña"
              }
            >
              {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
            </button>
          </div>
          <FieldError />
        </TextField>

        <div className="flex items-center justify-between">
          <Checkbox name="remember">
            <Checkbox.Content>
              <Checkbox.Control>
                <Checkbox.Indicator />
              </Checkbox.Control>
              <Label className="text-sm text-(--muted)">Recordarme</Label>
            </Checkbox.Content>
          </Checkbox>

          <Link
            href="/recuperar"
            className="text-sm text-(--accent) hover:underline"
          >
            ¿Olvidaste tu contraseña?
          </Link>
        </div>

        <Button
          type="submit"
          variant="primary"
          size="lg"
          fullWidth
          isDisabled={isSubmitting}
        >
          {isSubmitting ? "Entrando…" : "Iniciar sesión"}
        </Button>
      </form>

      <div className="my-6 flex items-center gap-3">
        <span className="h-px flex-1 bg-(--separator)" />
        <span className="text-xs text-(--muted)">o</span>
        <span className="h-px flex-1 bg-(--separator)" />
      </div>

      <div className="flex flex-col gap-3">
        <button
          type="button"
          className={buttonVariants({ variant: "outline", size: "lg", fullWidth: true })}
        >
          Continuar con Instagram
        </button>
        <button
          type="button"
          className={buttonVariants({ variant: "outline", size: "lg", fullWidth: true })}
        >
          Continuar con TikTok
        </button>
      </div>

      <p className="mt-6 text-center text-sm text-(--muted)">
        ¿No tienes cuenta?{" "}
        <Link href="/registro" className="text-(--accent) hover:underline">
          Regístrate gratis
        </Link>
      </p>
    </AuthLayout>
  );
}
