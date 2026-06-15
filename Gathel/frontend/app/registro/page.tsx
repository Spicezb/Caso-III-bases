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

export default function RegistroPage() {
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsSubmitting(true);

    // TODO: conectar con el endpoint de registro del backend (REST API)
    // const formData = new FormData(e.currentTarget);
    setTimeout(() => setIsSubmitting(false), 800);
  }

  return (
    <AuthLayout
      eyebrow="Crear cuenta"
      title="Empieza a jugar con tu vida real."
      subtitle="Te damos 100 puntos al registrarte. Podrás conectar tus redes sociales después."
    >
      <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
        <TextField name="name" type="text" isRequired>
          <Label>Nombre completo</Label>
          <Input placeholder="Elizabeth Vargas" />
          <FieldError />
        </TextField>

        <TextField name="username" type="text" isRequired>
          <Label>Nombre de usuario</Label>
          <Input placeholder="eliruns" />
          <FieldError />
        </TextField>

        <TextField name="email" type="email" isRequired>
          <Label>Correo electrónico</Label>
          <Input placeholder="tu@correo.com" />
          <FieldError />
        </TextField>

        <TextField name="password" type={showPassword ? "text" : "password"} isRequired minLength={8}>
          <Label>Contraseña</Label>
          <div className="relative">
            <Input placeholder="Mínimo 8 caracteres" className="pr-10" />
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

        <Checkbox name="acceptTerms" isRequired>
          <Checkbox.Content>
            <Checkbox.Control>
              <Checkbox.Indicator />
            </Checkbox.Control>
            <Label className="text-sm text-(--muted)">
              He leído y acepto los{" "}
              <Link href="/terminos" className="text-(--accent) hover:underline">
                términos y condiciones
              </Link>{" "}
              y las reglas de la plataforma.
            </Label>
          </Checkbox.Content>
          <FieldError />
        </Checkbox>

        <Button
          type="submit"
          variant="primary"
          size="lg"
          fullWidth
          isDisabled={isSubmitting}
        >
          {isSubmitting ? "Creando cuenta…" : "Crear cuenta"}
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
        ¿Ya tienes cuenta?{" "}
        <Link href="/login" className="text-(--accent) hover:underline">
          Inicia sesión
        </Link>
      </p>
    </AuthLayout>
  );
}
