#!/bin/bash

# Mendapatkan absolute path dari direktori tempat script ini berada
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fungsi untuk melakukan git pull pada repositori
pull_repo() {
    local repo_path="$1"
    local repo_name="$2"

    echo ""
    echo "Pulling ${repo_name}..."
    
    # Checkout main first, then pull from origin main
    if git -C "${repo_path}" checkout main && git -C "${repo_path}" pull origin main; then
        return 0
    else
        echo "Failed to pull ${repo_name}."
        return 1
    fi
}

# 1. Pull root repository utama (orkestrator)
pull_repo "${ROOT_DIR}" "root repository"

# 2. Pull repositori spesifik yang sudah didefinisikan jika foldernya ada
for repo in api-gateway frontend shared-lib; do
    if [ -d "${ROOT_DIR}/${repo}" ]; then
        pull_repo "${ROOT_DIR}/${repo}" "${repo}"
    else
        echo ""
        echo "Skipping ${repo}: folder not found."
    fi
done

# 3. Pull otomatis semua folder yang diawali dengan nama 'service-*'
for repo_dir in "${ROOT_DIR}"/service-*; do
    # Memastikan hasil globbing wildcard benar-benar berupa direktori asli
    if [ -d "${repo_dir}" ]; then
        repo_name=$(basename "${repo_dir}")
        pull_repo "${repo_dir}" "${repo_name}"
    fi
done

echo ""
echo "Done."