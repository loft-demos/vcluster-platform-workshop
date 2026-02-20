#!/usr/bin/env bash
set -euo pipefail

# Assumes this script lives in ./labs and is run from ./labs
LABS_ROOT="${LABS_ROOT:-.}"
PUBLIC_DIR="${PUBLIC_DIR:-${LABS_ROOT}/public}"

# Exclude non-lab directories (add more as needed)
EXCLUDED_DIRS="${EXCLUDED_DIRS:-base workshop-setup public .git .github node_modules}"

# Base URL handling:
# 1) Prefer HUGO_BASEURL from actions/configure-pages output (recommended)
# 2) Fall back to GitHub Pages project path derived from repo name
# 3) Fall back to "/" for local use
if [[ -n "${HUGO_BASEURL:-}" ]]; then
  BASE_URL="${HUGO_BASEURL%/}/"
elif [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
  REPO_NAME="${GITHUB_REPOSITORY#*/}"
  BASE_URL="/${REPO_NAME}/"
else
  BASE_URL="/"
fi

echo "Using BASE_URL=${BASE_URL}"

# Update submodules if present
if [[ -f "${LABS_ROOT}/.gitmodules" ]]; then
  git submodule update --init --recursive
fi

# Clean + recreate public dir
rm -rf "${PUBLIC_DIR}"
mkdir -p "${PUBLIC_DIR}"

# Shared Hugo base lives at ./base (same structure as your original script)
BASE_DIR="${LABS_ROOT}/base"
if [[ ! -d "${BASE_DIR}" ]]; then
  echo "ERROR: Expected '${BASE_DIR}' directory to exist (shared Hugo base)."
  exit 1
fi

cd "${BASE_DIR}"

# Find lab directories (siblings of ./base): ../<lab>/
mapfile -t LAB_DIRS < <(
  find .. -mindepth 1 -maxdepth 1 -type d -print \
    | sed 's#^\.\./##' \
    | awk 'NF' \
    | while read -r d; do
        skip=0
        for ex in ${EXCLUDED_DIRS}; do
          [[ "${d}" == "${ex}" ]] && skip=1
        done
        [[ $skip -eq 0 ]] && echo "${d}"
      done \
    | sort
)

# Create landing page
INDEX_HTML="${PUBLIC_DIR}/index.html"
{
  echo "<!doctype html>"
  echo "<html><head><meta charset=\"utf-8\"/>"
  echo "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"/>"
  echo "<title>vCluster Platform Workshop</title></head><body>"
  echo "<h1>vCluster Platform Workshop</h1>"
  echo "<p>Select a lab module below:</p>"
  echo "<ul>"
} > "${INDEX_HTML}"

for lab in "${LAB_DIRS[@]}"; do
  LAB_PATH="../${lab}"

  # Support config.toml OR config.yaml/yml
  CONFIG=""
  for f in "${LAB_PATH}/config.toml" "${LAB_PATH}/config.yaml" "${LAB_PATH}/config.yml"; do
    [[ -f "${f}" ]] && CONFIG="${f}"
  done

  if [[ -z "${CONFIG}" ]]; then
    echo "Skipping '${lab}' (no config.toml/config.yaml/config.yml found)"
    continue
  fi

  CONTENT_DIR="${LAB_PATH}/content"
  if [[ ! -d "${CONTENT_DIR}" ]]; then
    echo "Skipping '${lab}' (no content/ directory found)"
    continue
  fi

  DEST_DIR="${PUBLIC_DIR}/${lab}"
  LAB_BASEURL="${BASE_URL}${lab}/"

  echo "Building lab '${lab}' → ${DEST_DIR} (baseURL=${LAB_BASEURL})"

  hugo \
    --minify \
    --config "${CONFIG}" \
    --contentDir "${CONTENT_DIR}/" \
    --destination "${DEST_DIR}" \
    --baseURL "${LAB_BASEURL}"

  echo "<li><a href=\"${LAB_BASEURL}\">${lab}</a></li>" >> "${INDEX_HTML}"
done

echo "</ul></body></html>" >> "${INDEX_HTML}"
echo "Done. Output in ${PUBLIC_DIR}"