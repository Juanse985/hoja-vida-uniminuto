// Autenticación con Microsoft 365 (Outlook institucional) — Auth.js v5
// Regla 1 de CLAUDE.md: solo cuentas @uniminuto.edu.co del tenant de UNIMINUTO.

import NextAuth from "next-auth";
import MicrosoftEntraID from "next-auth/providers/microsoft-entra-id";
import { prisma } from "@/lib/prisma";

const DOMINIO = process.env.ALLOWED_EMAIL_DOMAIN ?? "uniminuto.edu.co";
const TENANT = process.env.AZURE_AD_TENANT_ID;

export function esCorreoInstitucional(correo: string | null | undefined): boolean {
  return !!correo && correo.toLowerCase().endsWith(`@${DOMINIO}`);
}

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    MicrosoftEntraID({
      clientId: process.env.AZURE_AD_CLIENT_ID,
      clientSecret: process.env.AZURE_AD_CLIENT_SECRET,
      // single-tenant si TI registra la app en su tenant; si no, "common" + filtro de dominio
      issuer: TENANT
        ? `https://login.microsoftonline.com/${TENANT}/v2.0`
        : "https://login.microsoftonline.com/common/v2.0",
    }),
  ],
  session: { strategy: "jwt", maxAge: 8 * 60 * 60 }, // 8 horas
  pages: { signIn: "/login", error: "/login" },
  callbacks: {
    async signIn({ profile }) {
      const correo = (profile?.email ?? profile?.preferred_username) as string | undefined;
      if (!esCorreoInstitucional(correo)) return "/login?error=dominio";
      if (TENANT && profile?.tid !== TENANT) return "/login?error=tenant";

      const usuario = await prisma.usuario.upsert({
        where: { correo: correo!.toLowerCase() },
        update: { ultimoIngreso: new Date(), nombre: profile?.name ?? "" },
        create: {
          correo: correo!.toLowerCase(),
          nombre: profile?.name ?? "",
          tenantId: String(profile?.tid ?? ""),
          hojaVida: { create: {} }, // borrador vacío en el primer ingreso
        },
      });
      await prisma.auditoria.create({ data: { usuarioId: usuario.id, accion: "LOGIN" } });
      return true;
    },
    async jwt({ token, profile }) {
      if (profile) {
        const correo = String(profile.email ?? profile.preferred_username).toLowerCase();
        const usuario = await prisma.usuario.findUnique({ where: { correo } });
        token.usuarioId = usuario?.id;
      }
      return token;
    },
    async session({ session, token }) {
      // Regla 2: el usuario_id SOLO viaja aquí, desde el servidor.
      session.user.id = token.usuarioId as string;
      return session;
    },
  },
});
