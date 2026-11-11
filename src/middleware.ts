// Protege todas las rutas excepto el login y los endpoints de Auth.js.
export { auth as middleware } from "@/auth";

export const config = {
  matcher: ["/((?!login|api/auth|_next/static|_next/image|favicon.ico).*)"],
};
