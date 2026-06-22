# Peso-Tracker

Tracker personal de peso y abdomen, mobile-first, con análisis de tendencias, patrones horarios y eventos contextuales. Datos sincronizados en Supabase y accesibles desde cualquier dispositivo con un link privado.

- **App:** una sola página, `index.html` (sin build, sin dependencias locales).
- **Backend:** Supabase (Postgres + REST), proyecto `Peso-Tracker`.
- **Hosting:** GitHub Pages.

---

## Cómo funciona la seguridad (léelo)

No hay pantalla de login. El acceso se controla con una **clave de espacio** (capability key): un token aleatorio que vive en el `#hash` de tu URL y en el `localStorage` de tu navegador, **nunca en este repositorio**.

- La Row Level Security (RLS) de Supabase exige ese token vía el header `x-space-key`. Sin él, ninguna fila es legible ni editable.
- El `publishable key` de Supabase que aparece en `index.html` es **público por diseño**; no da acceso a los datos por sí solo.
- **Tu link privado** (el que tiene `#k=...`) es tu credencial. Trátalo como una contraseña: quien lo tenga, ve y edita tus datos. No lo subas a ningún lado público.

La primera vez que abres la app, se genera tu token automáticamente. Para usar el mismo dato en el celular: abre Ajustes ⚙︎ → **Copiar link** → ábrelo en el teléfono.

---

## Desplegar en GitHub Pages

```bash
# 1) En la carpeta del proyecto (donde está index.html)
git init
git add index.html README.md schema.sql .gitignore
git commit -m "Peso-Tracker: app + esquema"

# 2) Crea un repo PÚBLICO vacío en github.com (sin README) y conéctalo
git branch -M main
git remote add origin https://github.com/<TU_USUARIO>/peso-tracker.git
git push -u origin main
```

Luego en GitHub: **Settings → Pages → Source: `main` / root → Save**.
En ~1 minuto tendrás tu URL:

```
https://<TU_USUARIO>.github.io/peso-tracker/
```

Ábrela en la Mac (genera tu token), entra a Ajustes ⚙︎, copia el link con `#k=` y úsalo en el celular.

---

## Estructura

| Archivo        | Qué es |
|----------------|--------|
| `index.html`   | La app completa (UI + lógica + cliente Supabase). |
| `schema.sql`   | Backup del esquema y políticas RLS (ya aplicado en Supabase). |
| `.gitignore`   | Evita subir backups `.json` exportados desde la app. |

## Datos

- **Offline-first:** la app funciona sin señal (guarda en el dispositivo) y sincroniza al volver la conexión. El punto de color junto a ⚙︎ indica el estado (verde = sincronizado, ámbar = sin conexión).
- **Backup manual:** Ajustes ⚙︎ → Exportar JSON.

## Tablas (Supabase)

- `weight_entries` — cada medición (`entry_date`, `entry_time`, `weight`, `waist`, `note`).
- `weight_events` — eventos por día o rango (`category`, `start_date`, `end_date`, `note`).
- `weight_settings` — objetivos (`start_weight`, `target_weight`, `height_cm`, `alert_weight`).

Todas con columna `space_key` y RLS por capability key.
