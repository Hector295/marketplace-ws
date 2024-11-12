#!/bin/bash

# Set variables
REPO_NAME="marketplace-ws"
OUTPUT_DIR="helm-repo"
PAGES_BRANCH="gh-pages"

# Save current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Switch to gh-pages branch
git checkout $PAGES_BRANCH

# Ensure the output directory exists
mkdir -p $OUTPUT_DIR

# Clean existing packages but keep the directory
rm -f $OUTPUT_DIR/*.tgz

# Switch back to main branch to package charts
git checkout $CURRENT_BRANCH

# Find and package all charts
echo "Packaging Helm charts..."
find . -name Chart.yaml -exec dirname {} \; | while read chart_dir; do
    if [ -f "$chart_dir/Chart.yaml" ]; then
        echo "Packaging $chart_dir"
        helm package "$chart_dir" -d temp_packages
    fi
done

# Switch to gh-pages and update packages
git checkout $PAGES_BRANCH
mv temp_packages/*.tgz $OUTPUT_DIR/
rm -rf temp_packages

# Generate the Helm repository index
echo "Generating Helm repository index..."
helm repo index $OUTPUT_DIR --url https://hector295.github.io/$REPO_NAME/$OUTPUT_DIR

# Add and commit files
git add $OUTPUT_DIR
git commit -m "Update Helm repository"

# Push to gh-pages branch
git push origin $PAGES_BRANCH

# Return to original branch
git checkout $CURRENT_BRANCH