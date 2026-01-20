#!/bin/bash

set -euo pipefail

: "${HYTALE_ASSETS_PATH:?Environment variable HYTALE_ASSETS_PATH is required}"
: "${HYTALE_JAR_PATH:?Environment variable HYTALE_JAR_PATH is required}"

IMAGE_TAG="${HYTALE_IMAGE_TAG:-hytale-server:1.0}"
DOCKERFILE_DIR="Dockerfiles/hytale"
PLATFORMS="${HYTALE_PLATFORMS:-}"
PUSH_IMAGE="${HYTALE_PUSH:-}"

if [[ ! -f "${HYTALE_ASSETS_PATH}" ]]; then
  echo "Assets file not found: ${HYTALE_ASSETS_PATH}" >&2
  exit 1
fi

if [[ ! -f "${HYTALE_JAR_PATH}" ]]; then
  echo "Jar file not found: ${HYTALE_JAR_PATH}" >&2
  exit 1
fi

mkdir -p "${DOCKERFILE_DIR}"

cleanup() {
  rm -f "${DOCKERFILE_DIR}/Assets.zip" "${DOCKERFILE_DIR}/HytaleServer.jar"
}

trap cleanup EXIT

cp -f "${HYTALE_ASSETS_PATH}" "${DOCKERFILE_DIR}/Assets.zip"
cp -f "${HYTALE_JAR_PATH}" "${DOCKERFILE_DIR}/HytaleServer.jar"

if [[ -n "${PLATFORMS}" ]]; then
  if [[ -n "${PUSH_IMAGE}" ]]; then
    docker buildx build --platform "${PLATFORMS}" -t "${IMAGE_TAG}" --push "${DOCKERFILE_DIR}"
  else
    docker buildx build --platform "${PLATFORMS}" -t "${IMAGE_TAG}" "${DOCKERFILE_DIR}"
  fi
else
  docker build -t "${IMAGE_TAG}" "${DOCKERFILE_DIR}"
fi
